dofile( "$SURVIVAL_DATA/Scripts/game/managers/BeaconManager.lua" )

dofile( "$SURVIVAL_DATA/Scripts/game/managers/ElevatorManager.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/managers/EffectManager.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/managers/RespawnManager.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/managers/UnitManager.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/survival_constants.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/survival_harvestable.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/survival_shapes.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/survival_units.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/survival_projectiles.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/survival_meleeattacks.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/util/recipes.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/util/Timer.lua" )
dofile( "$GAME_DATA/Scripts/game/managers/EventManager.lua" )

-- CONTENT
dofile( "$CONTENT_DATA/Scripts/game/managers/TaskManager.lua" )
dofile( "$CONTENT_DATA/Scripts/game/managers/ImpostorManager.lua" )
dofile( "$CONTENT_DATA/Scripts/game/managers/MettingManager.lua" )
dofile( "$CONTENT_DATA/Scripts/util/Language.lua" )
dofile( "$CONTENT_DATA/Scripts/util/BetterTimer.lua" )




---@class SurvivalGame : GameClass
---@field sv table
---@field cl table
---@field warehouses table
SurvivalGame = class( nil )
SurvivalGame.defaultInventorySize = 40
SurvivalGame.enableLimitedInventory = false -- !!!!! FALSE ONLY FOR DEV !!!!! -- (default to true)
SurvivalGame.enableRestrictions = true -- set true to have good game
SurvivalGame.enableFuelConsumption = true
SurvivalGame.enableAmmoConsumption = true
SurvivalGame.enableUpgrade = false

local SyncInterval = 400 -- 400 ticks | 10 seconds
local IntroFadeDuration = 1.1
local IntroEndFadeDuration = 1.1
local IntroFadeTimeout = 5.0

function SurvivalGame.server_onCreate( self )
	print( "[AMONG SCRAP] Game.server_onCreate" )
	self.sv = {}
	self.sv.saved = self.storage:load()
	if self.sv.saved == nil then
		self.sv.saved = {}
		self.sv.saved.data = self.data
		self.sv.saved.overworld = sm.world.createWorld( "$CONTENT_DATA/Scripts/terrain/SpawnWorld.lua", "Overworld", { dev = self.sv.saved.data.dev }, self.sv.saved.data.seed )
		self.storage:save( self.sv.saved )
	end
	self.data = nil

	print( self.sv.saved.data )
	if self.sv.saved.data and self.sv.saved.data.dev then
		g_godMode = false
		g_survivalDev = true
		sm.log.info( "[AMONG SCRAP] Starting AmongScrap in DEV mode" )
	end

	self:loadCraftingRecipes()
	g_enableCollisionTumble = true

	g_eventManager = EventManager()
	g_eventManager:sv_onCreate()

	g_elevatorManager = ElevatorManager()
	g_elevatorManager:sv_onCreate()

	--g_effectManager = EffectManager()
	--g_effectManager:sv_onCreate()

	g_respawnManager = RespawnManager()
	g_respawnManager:sv_onCreate( self.sv.saved.overworld )

	g_unitManager = UnitManager()
	g_unitManager:sv_onCreate( self.sv.saved.overworld )

	self.sv.time = sm.storage.load( STORAGE_CHANNEL_TIME )
	if self.sv.time then
		print( "[AMONG SCRAP] Loaded timeData:" )
		print( self.sv.time )
	else
		self.sv.time = {}
		self.sv.time.timeOfDay = 6 / 24 -- 06:00
		self.sv.time.timeProgress = false
		sm.storage.save( STORAGE_CHANNEL_TIME, self.sv.time )
	end
	self.network:setClientData( { dev = g_survivalDev }, 1 )
	self:sv_updateClientData()

	self.sv.syncTimer = Timer()
	self.sv.syncTimer:start( 0 )


	-- content -- 
	g_taskManager = TaskManager()
	g_taskManager:sv_onCreate()

	g_impostorManager = ImpostorManager()
	g_impostorManager:sv_onCreate()

	g_mettingManager = MettingManager()
	g_mettingManager:sv_onCreate()

	self.sv.deadUnits = {}

	self.sv.betterTimer = BetterTimer()
	self.sv.betterTimer:onCreate()

	self.sv.isRoundStarted = false
	self.sv.isWonkShipWorldExist = false
	self.sv.isWonkShipDeadWorldExist = false
	self.sv.witchWorldPlayersAre = "Overworld"
end

function SurvivalGame.server_onRefresh( self )
	print("[AMONG SCRAP] Game.server_onRefresh")
	--g_craftingRecipes = nil
	--g_refineryRecipes = nil
	--g_taskManager:sv_onRefresh()
	--self:loadCraftingRecipes()
end

function SurvivalGame.client_onCreate( self )

	self.cl = {}
	self.cl.time = {}
	self.cl.time.timeOfDay = 0.7
	self.cl.time.timeProgress = true

	self.cl.isImpostor = false

	
	self.cl.betterTimer = BetterTimer()
	self.cl.betterTimer:onCreate()

	if not sm.isHost then
		self:loadCraftingRecipes()
		g_enableCollisionTumble = true
	end

	if g_respawnManager == nil then
		--assert( not sm.isHost )
		g_respawnManager = RespawnManager()
	end
	g_respawnManager:cl_onCreate()

	if g_unitManager == nil then
		assert( not sm.isHost )
		g_unitManager = UnitManager()

	end
	g_unitManager:cl_onCreate()

	g_effectManager = EffectManager()
	g_effectManager:cl_onCreate()

	if g_taskManager == nil then
		assert( not sm.isHost )
		g_taskManager = TaskManager()
	end
	g_taskManager:cl_onCreate()

	if g_impostorManager == nil then
		assert( not sm.isHost )
		g_impostorManager = ImpostorManager()
	end
	g_impostorManager:cl_onCreate()

	if g_mettingManager == nil then
		assert( not sm.isHost )
		g_mettingManager = MettingManager()
	end
	g_mettingManager:cl_onCreate()

	-- Music effect
	g_survivalMusic = sm.effect.createEffect("ElevatorWall")
	assert(g_survivalMusic)

	-- content --
	g_Language = Language()
	g_Language:cl_loadLanguage()

	-- Survival HUD
	--g_survivalHud = sm.gui.createSurvivalHudGui()
	--assert(g_survivalHud)
	-- Task bar
	g_survivalHudTaskBar = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Hud/Hud_TaskBar.layout",false, {isHud = true, isInteractive = false, needsCursor = false})
	g_survivalHudTaskBar:setVisible("TaskGreen1", false)
	g_survivalHudTaskBar:setVisible("TaskGreen2", false)
	g_survivalHudTaskBar:setVisible("TaskGreen3", false)
	g_survivalHudTaskBar:setVisible("TaskGreen4", false)
	g_survivalHudTaskBar:setVisible("TaskGreen5", false)
	g_survivalHudTaskBar:setVisible("TaskGreen6", false)
	g_survivalHudTaskBar:setVisible("TaskGreen7", false)
	g_survivalHudTaskBar:setVisible("TaskGreen8", false)
	g_survivalHudTaskBar:setVisible("TaskGreen9", false)
	g_survivalHudTaskBar:setVisible("TaskGreen10", false)

	g_survivalHudTaskBar:setText("TotalTaskCompleteText", g_Language:cl_getTraduction("HUD_BAR_TOTAL_TASK_COMPLETED"))
	
	assert(g_survivalHudTaskBar)

	-- Task list
	g_survivalHudTaskList = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Hud/Hud_TaskList.layout",false, {isHud = true, isInteractive = false, needsCursor = false})
	g_survivalHudTaskList:setVisible("TaskList",false)
	g_survivalHudTaskList:setVisible("TaskListVerticalBar",true)
	g_survivalHudTaskList:setVisible("TaskListBarNotification", false)

	g_survivalHudTaskList:setText("TaskText", g_Language:cl_getTraduction("HUD_BAR_TASK"))

	assert(g_survivalHudTaskList)

	-- Impostor
	g_survivalHudImpostor = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Hud/Hud_Impostor.layout",false, {isHud = true, isInteractive = false, needsCursor = false})
	g_survivalHudImpostor:setVisible("CrewmateText",true)
	g_survivalHudImpostor:setVisible("ImpostorText",false)
	g_survivalHudImpostor:setVisible("NotText",false)

	g_survivalHudImpostor:setText("CrewmateText", g_Language:cl_getTraduction("HUD_ROLE_CREWMATE"))
	g_survivalHudImpostor:setText("ImpostorText", g_Language:cl_getTraduction("HUD_ROLE_IMPOSTOR"))
	g_survivalHudImpostor:setText("NotText", g_Language:cl_getTraduction("HUD_ROLE_NO_ROLE"))
	
	assert(g_survivalHudImpostor)
end

function SurvivalGame.bindChatCommands( self )

	local addCheats = true

	if addCheats then
		sm.game.bindChatCommand( "/god", {}, "cl_onChatCommand", "Mechanic characters will take no damage" )
		sm.game.bindChatCommand( "/respawn", {}, "cl_onChatCommand", "Respawn at last bed (or at the crash site)" )
		sm.game.bindChatCommand( "/limited", {}, "cl_onChatCommand", "Use the limited inventory" )
		sm.game.bindChatCommand( "/unlimited", {}, "cl_onChatCommand", "Use the unlimited inventory" )
		sm.game.bindChatCommand( "/spawn", { { "string", "unitName", true }, { "int", "amount", true } }, "cl_onChatCommand", "Spawn a unit: 'woc', 'tapebot', 'totebot', 'haybot'" )
		sm.game.bindChatCommand( "/cleardebug", {}, "cl_onChatCommand", "Clear debug draw objects" )

		--CONTENT
		sm.game.bindChatCommand( "/task", {}, "cl_onChatCommand", "Init the task system for one round" )
		sm.game.bindChatCommand( "/impostor", {}, "cl_onChatCommand", "Create the impostor status" )
		sm.game.bindChatCommand( "/metting", {}, "cl_onChatCommand", "Init the metting system for one round" )
		sm.game.bindChatCommand( "/vote", {}, "cl_onChatCommand", "Open the voting gui" )

		sm.game.bindChatCommand( "/start", {}, "cl_onChatCommand", "Start a round of Among Scrap" )
		sm.game.bindChatCommand( "/reset", {}, "cl_onChatCommand", "Reset all the system for another round" )

		sm.game.bindChatCommand( "/impostornum", {{"int", "number", true}}, "cl_onChatCommand", "Change the number of impostor for the next game" )

		sm.game.bindChatCommand( "/spawnship", {}, "cl_onChatCommand", "Go to spawn" )
		sm.game.bindChatCommand( "/wonkship", {}, "cl_onChatCommand", "Go to Wonk ship" )
	end
end

function SurvivalGame.client_onClientDataUpdate( self, clientData, channel )
	if channel == 2 then
		self.cl.time = clientData.time
	elseif channel == 1 then
		g_survivalDev = clientData.dev
		self:bindChatCommands()
	end
end


function SurvivalGame.loadCraftingRecipes( self )
	LoadCraftingRecipes({
		workbench = "$SURVIVAL_DATA/CraftingRecipes/workbench.json",
		dispenser = "$SURVIVAL_DATA/CraftingRecipes/dispenser.json",
		cookbot = "$SURVIVAL_DATA/CraftingRecipes/cookbot.json",
		craftbot = "$SURVIVAL_DATA/CraftingRecipes/craftbot.json",
		dressbot = "$SURVIVAL_DATA/CraftingRecipes/dressbot.json"
	})
end

function SurvivalGame.server_onFixedUpdate( self, timeStep )
	-- Update time

	local prevTime = self.sv.time.timeOfDay
	if self.sv.time.timeProgress then
		self.sv.time.timeOfDay = self.sv.time.timeOfDay + timeStep / DAYCYCLE_TIME
	end
	local newDay = self.sv.time.timeOfDay >= 1.0
	if newDay then
		self.sv.time.timeOfDay = math.fmod( self.sv.time.timeOfDay, 1 )
	end

	if self.sv.time.timeOfDay >= DAYCYCLE_DAWN and prevTime < DAYCYCLE_DAWN then
		g_unitManager:sv_initNewDay()
	end

	-- Ambush
	--if not g_survivalDev then
	--	for _,ambush in ipairs( AMBUSHES ) do
	--		if self.sv.time.timeOfDay >= ambush.time and ( prevTime < ambush.time or newDay ) then
	--			self:sv_ambush( { magnitude = ambush.magnitude, wave = ambush.wave } )
	--		end
	--	end
	--end

	-- Client and save sync
	self.sv.syncTimer:tick()
	if self.sv.syncTimer:done() then
		self.sv.syncTimer:start( SyncInterval )
		sm.storage.save( STORAGE_CHANNEL_TIME, self.sv.time )
		self:sv_updateClientData()
	end

	g_unitManager:sv_onFixedUpdate()
	if g_eventManager then
		g_eventManager:sv_onFixedUpdate()
	end

	--- CONTENT ---
	self.sv.betterTimer:onFixedUpdate()
	--g_mettingManager.sv.betterTimer:onFixedUpdate()
end

function SurvivalGame.sv_updateClientData( self )
	self.network:setClientData( { time = self.sv.time }, 2 )
end

function SurvivalGame.client_onFixedUpdate( self )
	-- content -- 
	self.cl.betterTimer:onFixedUpdate()
	g_mettingManager.cl.betterTimer:onFixedUpdate()
end

function SurvivalGame.client_onUpdate( self, dt )
	-- Update time
	if self.cl.time.timeProgress then
		self.cl.time.timeOfDay = math.fmod( self.cl.time.timeOfDay + dt / DAYCYCLE_TIME, 1.0 )
	end
	sm.game.setTimeOfDay( self.cl.time.timeOfDay )

	-- Update lighting values
	local index = 1
	while index < #DAYCYCLE_LIGHTING_TIMES and self.cl.time.timeOfDay >= DAYCYCLE_LIGHTING_TIMES[index + 1] do
		index = index + 1
	end
	assert( index <= #DAYCYCLE_LIGHTING_TIMES )

	local light = 0.0
	if index < #DAYCYCLE_LIGHTING_TIMES then
		local p = ( self.cl.time.timeOfDay - DAYCYCLE_LIGHTING_TIMES[index] ) / ( DAYCYCLE_LIGHTING_TIMES[index + 1] - DAYCYCLE_LIGHTING_TIMES[index] )
		light = sm.util.lerp( DAYCYCLE_LIGHTING_VALUES[index], DAYCYCLE_LIGHTING_VALUES[index + 1], p )
	else
		light = DAYCYCLE_LIGHTING_VALUES[index]
	end
	sm.render.setOutdoorLighting( light )
end

function SurvivalGame.client_showMessage( self, msg )
	sm.gui.chatMessage( msg )
end

function SurvivalGame.cl_onChatCommand( self, params )

	local unitSpawnNames =
	{
		woc = unit_woc,
		tapebot = unit_tapebot,
		tb = unit_tapebot,
		redtapebot = unit_tapebot_red,
		rtb = unit_tapebot_red,
		totebot = unit_totebot_green,
		green = unit_totebot_green,
		t = unit_totebot_green,
		totered = unit_totebot_red,
		red = unit_totebot_red,
		tr = unit_totebot_red,
		haybot = unit_haybot,
		h = unit_haybot,
		worm = unit_worm,
		farmbot = unit_farmbot,
		f = unit_farmbot,
	}

	if params[1] == "/god" then
		self.network:sendToServer( "sv_switchGodMode" )
	elseif params[1] == "/unlimited" then
		self.network:sendToServer( "sv_setLimitedInventory", false )
	elseif params[1] == "/limited" then
		self.network:sendToServer( "sv_setLimitedInventory", true )
	elseif params[1] == "/ambush" then
		self.network:sendToServer( "sv_ambush", { magnitude = params[2] or 1, wave = params[3] } )
	elseif params[1] == "/recreate" then
		self.network:sendToServer( "sv_recreateWorld", sm.localPlayer.getPlayer() )
	elseif params[1] == "/timeofday" then
		self.network:sendToServer( "sv_setTimeOfDay", params[2] )
	elseif params[1] == "/timeprogress" then
		self.network:sendToServer( "sv_setTimeProgress", params[2] )
	elseif params[1] == "/day" then
		self.network:sendToServer( "sv_setTimeOfDay", 0.5 )
		self.network:sendToServer( "sv_setTimeProgress", false )
	elseif params[1] == "/die" then
		self.network:sendToServer( "sv_killPlayer", { player = sm.localPlayer.getPlayer() })

	elseif params[1] == "/spawn" then
		local rayCastValid, rayCastResult = sm.localPlayer.getRaycast( 100 )
		if rayCastValid then
			local spawnParams = {
				uuid = sm.uuid.getNil(),
				world = sm.localPlayer.getPlayer().character:getWorld(),
				position = rayCastResult.pointWorld,
				yaw = 0.0,
				amount = 1
			}
			if unitSpawnNames[params[2]] then
				spawnParams.uuid = unitSpawnNames[params[2]]
			else
				spawnParams.uuid = sm.uuid.new( params[2] )
			end
			if params[3] then
				spawnParams.amount = params[3]
			end
			self.network:sendToServer( "sv_spawnUnit", spawnParams )
		end
	elseif params[1] == "/cleardebug" then
		sm.debugDraw.clear()
	elseif params[1] == "/export" then
		local rayCastValid, rayCastResult = sm.localPlayer.getRaycast( 100 )
		if rayCastValid and rayCastResult.type == "body" then
			local importParams = {
				name = params[2],
				body = rayCastResult:getBody()
			}
			self.network:sendToServer( "sv_exportCreation", importParams )
		end
	elseif params[1] == "/reloadcell" then
		local world = sm.localPlayer.getPlayer():getCharacter():getWorld()
		local player = sm.localPlayer.getPlayer()
		local pos = player.character:getWorldPosition();
		local x = params[2] or math.floor( pos.x / 64 )
		local y = params[3] or math.floor( pos.y / 64 )
		self.network:sendToServer( "sv_reloadCell", { x = x, y = y, world = world, player = player } )


	--- CONTENT ---
	elseif params[1] == "/vote" then
		self.network:sendToServer("sv_e_onEmergencyMetting", {player = sm.localPlayer.getPlayer()} )

	else
		self.network:sendToServer( "sv_onChatCommand", params )
	end
end

function SurvivalGame.sv_reloadCell( self, params, player )
	print( "[AMONG SCRAP] sv_reloadCell Reloading cell at {" .. params.x .. " : " .. params.y .. "}" )

	self.sv.saved.overworld:loadCell( params.x, params.y, player )
end

function SurvivalGame.sv_giveItem( self, params )
	sm.container.beginTransaction()
	sm.container.collect( params.player:getInventory(), params.item, params.quantity, false )
	sm.container.endTransaction()
end

function SurvivalGame.cl_n_onJoined( self, params )
	--self.cl.playIntroCinematic = params.newPlayer
end

function SurvivalGame.client_onLoadingScreenLifted( self )
	self.network:sendToServer( "sv_n_loadingScreenLifted" )
	--if self.cl.playIntroCinematic then
		--local callbacks = {}
		--callbacks[#callbacks + 1] = { fn = "cl_onCinematicEvent", params = { cinematicName = "cinematic.survivalstart01" }, ref = self }
		--g_effectManager:cl_playNamedCinematic( "cinematic.survivalstart01", callbacks )
	--end
end

function SurvivalGame.sv_n_loadingScreenLifted( self, _, player )
	if not g_survivalDev then
		--QuestManager.Sv_TryActivateQuest( "quest_tutorial" )
	end
end

function SurvivalGame.cl_onCinematicEvent( self, eventName, params )
--[[
	local myPlayer = sm.localPlayer.getPlayer()
	local myCharacter = myPlayer and myPlayer.character or nil
	if eventName == "survivalstart01.dramatics_standup" then
		if sm.exists( myCharacter ) then
			sm.event.sendToCharacter( myCharacter, "cl_e_onEvent", "dramatics_standup" )
		end
	elseif eventName == "survivalstart01.fadeout" then
		sm.event.sendToPlayer( myPlayer, "cl_e_startFadeToBlack", { duration = IntroFadeDuration, timeout = IntroFadeTimeout } )
	elseif eventName == "survivalstart01.fadein" then
		sm.event.sendToPlayer( myPlayer, "cl_n_endFadeToBlack", { duration = IntroEndFadeDuration } )
	end
]]
end

function SurvivalGame.sv_switchGodMode( self )
	g_godMode = not g_godMode
	self.network:sendToClients( "client_showMessage", "GODMODE: " .. ( g_godMode and "On" or "Off" ) )
end

function SurvivalGame.sv_n_switchAggroMode( self, params )
	sm.game.setEnableAggro(params.aggroMode )
	self.network:sendToClients( "client_showMessage", "AGGRO: " .. ( params.aggroMode and "On" or "Off" ) )
end

function SurvivalGame.sv_enableRestrictions( self, state )
	sm.game.setEnableRestrictions( state )
	self.network:sendToClients( "client_showMessage", ( state and "Restricted" or "Unrestricted"  ) )
end

function SurvivalGame.sv_setLimitedInventory( self, state )
	sm.game.setLimitedInventory( state )
	self.network:sendToClients( "client_showMessage", ( state and "Limited inventory" or "Unlimited inventory"  ) )
end

function SurvivalGame.sv_ambush( self, params )
	if sm.exists( self.sv.saved.overworld ) then
		sm.event.sendToWorld( self.sv.saved.overworld, "sv_ambush", params )
	end
end

function SurvivalGame.sv_recreateWorld( self, player )
	local character = player:getCharacter()
	if character:getWorld() == self.sv.saved.overworld then
		self.sv.saved.overworld:destroy()
		self.sv.saved.overworld = sm.world.createWorld( "$CONTENT_DATA/Scripts/terrain/World.lua", "Overworld", { dev = g_survivalDev }, self.sv.saved.data.seed )
		self.storage:save( self.sv.saved )

		local params = { pos = character:getWorldPosition(), dir = character:getDirection() }
		self.sv.saved.overworld:loadCell( math.floor( params.pos.x/64 ), math.floor( params.pos.y/64 ), player, "sv_recreatePlayerCharacter", params )

		self.network:sendToClients( "client_showMessage", "Recreating world" )
	else
		self.network:sendToClients( "client_showMessage", "Recreate world only allowed for overworld" )
	end
end

function SurvivalGame.sv_setTimeOfDay( self, timeOfDay )
	if timeOfDay then
		self.sv.time.timeOfDay = timeOfDay
		self.sv.syncTimer.count = self.sv.syncTimer.ticks -- Force sync
	end
	self.network:sendToClients( "client_showMessage", ( "Time of day set to "..self.sv.time.timeOfDay ) )
end

function SurvivalGame.sv_setTimeProgress( self, timeProgress )
	if timeProgress ~= nil then
		self.sv.time.timeProgress = timeProgress
		self.sv.syncTimer.count = self.sv.syncTimer.ticks -- Force sync
	end
	self.network:sendToClients( "client_showMessage", ( "Time scale set to "..( self.sv.time.timeProgress and "on" or "off ") ) )
end

function SurvivalGame.sv_killPlayer( self, params )
	params.damage = 9999
	sm.event.sendToPlayer( params.player, "sv_e_receiveDamage", params )
end

function SurvivalGame.sv_onChatCommand( self, params, player )
	if params[1] == "/tumble" then
		if params[2] ~= nil then
			player.character:setTumbling( params[2] )
		else
			player.character:setTumbling( not player.character:isTumbling() )
		end
		if player.character:isTumbling() then
			self.network:sendToClients( "client_showMessage", "Player is tumbling" )
		else
			self.network:sendToClients( "client_showMessage", "Player is not tumbling" )
		end

	elseif params[1] == "/sethp" then
		sm.event.sendToPlayer( player, "sv_e_debug", { hp = params[2] } )

	elseif params[1] == "/setwater" then
		sm.event.sendToPlayer( player, "sv_e_debug", { water = params[2] } )

	elseif params[1] == "/setfood" then
		sm.event.sendToPlayer( player, "sv_e_debug", { food = params[2] } )

	elseif params[1] == "/goto" then
		local pos
		if params[2] == "here" then
			pos = player.character:getWorldPosition()
		elseif params[2] == "start" then
			pos = START_AREA_SPAWN_POINT
		else
			self.network:sendToClient( player, "client_showMessage", "Unknown place" )
		end
		if pos then
			local cellX, cellY = math.floor( pos.x/64 ), math.floor( pos.y/64 )
			if not sm.exists( self.sv.saved.overworld ) then
				sm.world.loadWorld( self.sv.saved.overworld )
			end
			self.sv.saved.overworld:loadCell( cellX, cellY, player, "sv_recreatePlayerCharacter", { pos = pos, dir = player.character:getDirection() } )
		end

	elseif params[1] == "/respawn" then
		sm.event.sendToPlayer( player, "sv_e_respawn" )

	elseif params[1] == "/printglobals" then
		print( "[AMONG SCRAP] Globals:" )
		for k,_ in pairs(_G) do
			print( k )
		end



-- content command --
	elseif params[1] == "/task" then
		self:sv_e_onInitTask()


	elseif params[1] == "/impostor" then
		self:sv_e_onInitImpostor()

	elseif params[1] == "/metting" then
		self:sv_e_onInitMetting()

	--elseif params[1] == "/vote" then
		--g_mettingManager:cl_openMettingGui()

	elseif params[1] == "/start" then
		self:sv_onInitRound()


	elseif params[1] == "/reset" then
		self:sv_onResetRound()

	elseif params[1] == "/impostornum" then
		print(params[2])
		g_impostorManager:sv_changeImpostorNumber(params[2])

	elseif params[1] == "/spawnship" then
		self:sv_onGoToOverworld()

	elseif params[1] == "/wonkship" then
		self:sv_onGoToWonkShip()

--[[
	elseif params[1] == "/activatequest" then
		local questName = params[2]
		if questName then
			QuestManager.Sv_ActivateQuest( questName )
		end
	elseif params[1] == "/completequest" then
		local questName = params[2]
		if questName then
			QuestManager.Sv_CompleteQuest( questName )
		end
]]--
	else
		params.player = player
		if sm.exists( player.character ) then
			sm.event.sendToWorld( player.character:getWorld(), "sv_e_onChatCommand", params )
		end
	end
end

function SurvivalGame.server_onPlayerJoined( self, player, newPlayer )
	print( player.name, "joined the game [AMONG SCRAP]" )

	if true then --Player is first time joiners
		local inventory = player:getInventory()

		sm.container.beginTransaction()

		if g_survivalDev then
			--Hotbar
			sm.container.setItem( inventory, 0,obj_consumable_longsandwich, 1 )

			--sm.container.setItem( inventory, 1, obj_interactive_task_interface_id_1, 1 )
			sm.container.setItem( inventory, 7, obj_plantables_potato, 50 )
			sm.container.setItem( inventory, 8, tool_lift, 1 )
			sm.container.setItem( inventory, 9, tool_connect, 1 )

			--Actual inventory
			sm.container.setItem( inventory, 10, tool_paint, 1 )
			sm.container.setItem( inventory, 11, tool_weld, 1 )
		else
			sm.container.setItem( inventory, 0,obj_consumable_longsandwich, 1 )

			sm.container.setItem( inventory, 1, tool_spudgun, 1 )
			sm.container.setItem( inventory, 7, obj_plantables_potato, 50 )
			sm.container.setItem( inventory, 8, tool_lift, 1 )
			sm.container.setItem( inventory, 9, tool_connect, 1 )

			--Actual inventory
			sm.container.setItem( inventory, 10, tool_paint, 1 )
			sm.container.setItem( inventory, 11, tool_weld, 1 )
		end

		sm.container.endTransaction()

		local spawnPoint = sm.vec3.new( 0.0, 0.0, 100.0 )

		if not sm.exists( self.sv.saved.overworld ) then
			sm.world.loadWorld( self.sv.saved.overworld )
		end

		if self.sv.witchWorldPlayersAre == "Overworld" then  -- content   -- should be temp
			self.sv.saved.overworld:loadCell( math.floor( spawnPoint.x/64 ), math.floor( spawnPoint.y/64 ), player, "sv_createNewPlayer" )

		elseif self.sv.witchWorldPlayersAre == "Wonkship" then
			self.sv.wonkShipWorld:loadCell( math.floor( spawnPoint.x/64 ), math.floor( spawnPoint.y/64 ), player, "sv_createNewPlayer" ) 
		
		else
			self.sv.saved.overworld:loadCell( math.floor( spawnPoint.x/64 ), math.floor( spawnPoint.y/64 ), player, "sv_createNewPlayer" ) -- should be temp
		end
		self.network:sendToClient( player, "cl_n_onJoined", { newPlayer = newPlayer } )
	
	else
		local inventory = player:getInventory()

		local sledgehammerCount = sm.container.totalQuantity( inventory, tool_sledgehammer )
		if sledgehammerCount == 0 then
			sm.container.beginTransaction()
			sm.container.collect( inventory, tool_sledgehammer, 1 )
			sm.container.endTransaction()
		elseif sledgehammerCount > 1 then
			sm.container.beginTransaction()
			sm.container.spend( inventory, tool_sledgehammer, sledgehammerCount - 1 )
			sm.container.endTransaction()
		end

		local tool_lift_creative = sm.uuid.new( "5cc12f03-275e-4c8e-b013-79fc0f913e1b" )
		local creativeLiftCount = sm.container.totalQuantity( inventory, tool_lift_creative )
		if creativeLiftCount > 0 then
			sm.container.beginTransaction()
			sm.container.spend( inventory, tool_lift_creative, creativeLiftCount )
			sm.container.endTransaction()
		end

		local liftCount = sm.container.totalQuantity( inventory, tool_lift )
		if liftCount == 0 then
			sm.container.beginTransaction()
			sm.container.collect( inventory, tool_lift, 1 )
			sm.container.endTransaction()
		elseif liftCount > 1 then
			sm.container.beginTransaction()
			sm.container.spend( inventory, tool_lift, liftCount - 1 )
			sm.container.endTransaction()
		end
	end
	--if player.id > 1 then --Too early for self. Questmanager is not created yet...
		--QuestManager.Sv_OnEvent( QuestEvent.PlayerJoined, { player = player } )
	--end
	g_unitManager:sv_onPlayerJoined( player )

	-- CONTENT --

end

function SurvivalGame.server_onPlayerLeft( self, player )
	print( player.name, "left the game [AMONG SCRAP] " )
	if player.id > 1 then
		--QuestManager.Sv_OnEvent( QuestEvent.PlayerLeft, { player = player } )
	end
end

function SurvivalGame.sv_e_requestWarehouseRestrictions( self, params )
	-- Send the warehouse restrictions to the world that asked
	print("SurvivalGame.sv_e_requestWarehouseRestrictions")

	-- Warehouse get
	local warehouse = nil
	if params.warehouseIndex then
		warehouse = self.sv.warehouses[params.warehouseIndex]
	end
	if warehouse then
		sm.event.sendToWorld( params.world, "server_updateRestrictions", warehouse.restrictions )
	end
end

function SurvivalGame.sv_e_setWarehouseRestrictions( self, params )
	-- Set the restrictions for this warehouse and propagate the restrictions to all floors

	-- Warehouse get
	local warehouse = nil
	if params.warehouseIndex then
		warehouse = self.sv.warehouses[params.warehouseIndex]
	end

	if warehouse then
		for _, newRestrictionSetting in pairs( params.restrictions ) do
			if warehouse.restrictions[newRestrictionSetting.name] then
				warehouse.restrictions[newRestrictionSetting.name].state = newRestrictionSetting.state
			else
				warehouse.restrictions[newRestrictionSetting.name] = newRestrictionSetting
			end
		end
		self.sv.warehouses[params.warehouseIndex] = warehouse
		sm.storage.save( STORAGE_CHANNEL_WAREHOUSES, self.sv.warehouses )

		for i, world in ipairs( warehouse.worlds ) do
			if sm.exists( world ) then
				sm.event.sendToWorld( world, "server_updateRestrictions", warehouse.restrictions )
			end
		end
	end
end

function SurvivalGame.sv_createNewPlayer( self, world, x, y, player )
	local params = { player = player, x = x, y = y }
	sm.event.sendToWorld( self.sv.saved.overworld, "sv_spawnNewCharacter", params )
end

function SurvivalGame.sv_recreatePlayerCharacter( self, world, x, y, player, params )
	local yaw = math.atan2( params.dir.y, params.dir.x ) - math.pi/2
	local pitch = math.asin( params.dir.z )
	local newCharacter = sm.character.createCharacter( player, self.sv.saved.overworld, params.pos, yaw, pitch )
	player:setCharacter( newCharacter )
	print( "[AMONG SCRAP] Recreate character in new world" )
	print( params )
end

function SurvivalGame.sv_e_respawn( self, params )
	if params.player.character and sm.exists( params.player.character ) then
		g_respawnManager:sv_requestRespawnCharacter( params.player )
	else
		local spawnPoint = g_survivalDev and SURVIVAL_DEV_SPAWN_POINT or START_AREA_SPAWN_POINT
		if not sm.exists( self.sv.saved.overworld ) then
			sm.world.loadWorld( self.sv.saved.overworld )
		end
		self.sv.saved.overworld:loadCell( math.floor( spawnPoint.x/64 ), math.floor( spawnPoint.y/64 ), params.player, "sv_createNewPlayer" )
	end
end

function SurvivalGame.sv_e_onSpawnPlayerCharacter( self, player )
	if player.character and sm.exists( player.character ) then
		g_respawnManager:sv_onSpawnCharacter( player )
		--local char = player:getCharacter()
		--char:setMovementSpeedFraction(200000)
	else
		sm.log.warning("SurvivalGame.sv_e_onSpawnPlayerCharacter for a character that doesn't exist")

	end
end

function SurvivalGame.sv_loadedRespawnCell( self, world, x, y, player )
	g_respawnManager:sv_respawnCharacter( player, world )
end


function SurvivalGame.sv_e_markBag( self, params )
	if sm.exists( params.world ) then
		sm.event.sendToWorld( params.world, "sv_e_markBag", params )
	else
		sm.log.warning("SurvivalGame.sv_e_markBag in a world that doesn't exist")
	end
end

function SurvivalGame.sv_e_unmarkBag( self, params )
	if sm.exists( params.world ) then
		sm.event.sendToWorld( params.world, "sv_e_unmarkBag", params )
	else
		sm.log.warning("SurvivalGame.sv_e_unmarkBag in a world that doesn't exist")
	end
end

-- Beacons
function SurvivalGame.sv_e_createBeacon( self, params )
	if sm.exists( params.beacon.world ) then
		sm.event.sendToWorld( params.beacon.world, "sv_e_createBeacon", params )
	else
		sm.log.warning( "SurvivalGame.sv_e_createBeacon in a world that doesn't exist" )
	end
end

function SurvivalGame.sv_e_destroyBeacon( self, params )
	if sm.exists( params.beacon.world ) then
		sm.event.sendToWorld( params.beacon.world, "sv_e_destroyBeacon", params )
	else
		sm.log.warning( "SurvivalGame.sv_e_destroyBeacon in a world that doesn't exist" )
	end
end

function SurvivalGame.sv_e_unloadBeacon( self, params )
	if sm.exists( params.beacon.world ) then
		sm.event.sendToWorld( params.beacon.world, "sv_e_unloadBeacon", params )
	else
		sm.log.warning( "SurvivalGame.sv_e_unloadBeacon in a world that doesn't exist" )
	end
end

--function SurvivalGame.sv_n_fireMsg( self ) end



----------------------------------------------------------------------
------------------------------ CONTENT -------------------------------
----------------------------------------------------------------------


--- GENERAL ---

-------
function SurvivalGame.sv_e_onPlayerKilled( self , data )
	self:sv_onGoToWonkShipDead(data) -- should be uncomment
	--sm.event.sendToWorld(self.sv.wonkShipWorld, "sv_onPlayerKilled", data.player) -- only if im alone :=(

	g_mettingManager:sv_onPlayerKilled(data)
	self.network:sendToClients("cl_e_onPlayerKilled", data)
end

function SurvivalGame.cl_e_onPlayerKilled( self , data )
	g_mettingManager:cl_onPlayerKilled(data)
end
------

------
function SurvivalGame.sv_onGameOver( self , data )
	data.overworld = self.sv.saved.overworld
	if data.gameOverReason == "allTaskFinished" then
		sm.log.info("[AMONG SCRAP] -- GAME OVER -- All tasks are finish.")
		self.network:sendToClients("cl_onGameOver", data)
		self:sv_onResetRound()

	elseif data.gameOverReason == "impostorKillAll" then
		sm.log.info("[AMONG SCRAP] -- GAME OVER -- Impostors kill all crewmates.")
		self.network:sendToClients("cl_onGameOver", data)
		self:sv_onResetRound()

	elseif data.gameOverReason == "crewmateEjectAll" then
		sm.log.info("[AMONG SCRAP] -- GAME OVER -- Crewmates eject all impostors.")
		self.network:sendToClients("cl_onGameOver", data)
		self:sv_onResetRound()
	end
end

function SurvivalGame.cl_onGameOver( self )
	sm.gui.startFadeToBlack( 4, 2 )
	sm.gui.displayAlertText( "GAME OVER", 5 )
	--self.cl.gameOverEffect = sm.effect.createEffect("SurvivalMusic")
	--self.cl.gameOverEffect:setPosition(sm.localPlayer.getPlayer().character.worldPosition)
	--self.cl.gameOverEffect:setAutoPlay(true)
	--sm.event.sendToWorld(data.overworld, "cl_w_onGameOver")
end
------



function SurvivalGame.sv_onInitRound( self )
	--self.sv.betterTimer:createNewTimer(40, self, SurvivalGame.sv_onResetRound)

	if self.sv.isRoundStarted == false then
		self:sv_e_onInitImpostor()
		self.sv.betterTimer:createNewTimer(5, self, SurvivalGame.sv_e_onInitTask)
		self:sv_e_onInitMetting()

		self.sv.isRoundStarted = true
		sm.log.info("[AMONG SCRAP] INFO: New round has been started !")
	else
		sm.log.warning("[AMONG SCRAP] WARNING : You can't start 2 times.")
	end
end

function SurvivalGame.sv_onResetRound( self )
	if self.sv.isRoundStarted == true then
		self:sv_e_onResetImpostor()
		self:sv_e_onResetTask()
		self:sv_e_onResetMetting()
		self:sv_onResetDeadUnit()

		self.sv.isRoundStarted = false
		sm.log.info("[AMONG SCRAP] INFO: Game has been reset.")
	else
		sm.log.warning("[AMONG SCRAP] WARNING : You can't reset 2 times.")
	end
end

function SurvivalGame.sv_setPlayerNameTag( self , data )
	data.character = data.player.character
	data.player = {}
	self.network:sendToClients("cl_setPlayerNameTag", data)
end

function SurvivalGame.cl_setPlayerNameTag( self , data )
	data.character:setNameTag(data.name, data.color or sm.color.new(255,255,255), false, data.rd or 4 , 3)
end






-- CHARACTER --


function SurvivalGame.sv_onDeadCharacterUnitCreated( self , data )
	local index = 0
	for i,v in ipairs(self.sv.deadUnits) do
		if data.player == v.player then
			index = i
		end
	end
	self.sv.deadUnits[index].deadUnit.character:setTumbling(true)
	self.sv.deadUnits[index].deadUnit.character:setDowned(true)
	
end

function SurvivalGame.sv_onUnitCreated( self , data )
	table.insert(self.sv.deadUnits, {player = data.player, deadUnit = data.deadUnit})
	self.sv.betterTimer:createNewTimer(5, self, SurvivalGame.sv_onDeadCharacterUnitCreated , data)
end

function SurvivalGame.sv_onResetDeadUnit( self )
	for i,v in ipairs(self.sv.deadUnits) do
		self.sv.deadUnits[i].deadUnit:destroy()
	end
	self.sv.deadUnits = {}
end





-- WORLD --

--[[
Avaliable world in Among Scrap:

	1) Overworld :
		Normal name : Overworld (Or Spawn)
		Function name : Overworld or overworld
		Class name : Overworld
		Str call name : Overworld
		World file : SpawnWorld.lua
		Terrain file : SpawnTerain.lua
		Goto command : /spawnship

	2) WonkShip
		Normal name : WonkShip or WonkShipWorld
		Function name : WonkShip or wonkShip
		Class name : WonkShipWorld
		Str call name : WonkShip
		World file : Wonkship.lua
		Terrain file : WonkShipTerrain.lua
		Goto command : /wonkship

	2.1) WonkShipDead
		Normal name : WonkShipDead or WonkShipWorld
		Function name : WonkShipDead or wonkShipDead
		Class name : WonkShipWorld
		Str call name : WonkShipDead
		World file : Wonkship.lua
		Terrain file : WonkShipTerrain.lua
		Goto command : /wonkshipdead
]]

---Overworld (spawn)
------
function SurvivalGame.sv_onGoToOverworld( self )
	if self.sv.witchWorldPlayersAre == "Overworld" then
		sm.log.warning("[AMONG SCRAP] WARNING : Already on spawn (Overworld) world ! (Game.lua ln1025)")
	else
		self.network:sendToClients("cl_onGoToOverworld")
		local spawnPoint = sm.vec3.new( 0.0, 0.0, 100.0 )
		for _,p in ipairs(sm.player.getAllPlayers()) do
			self.sv.saved.overworld:loadCell( math.floor( spawnPoint.x/64 ), math.floor( spawnPoint.y/64 ), p, "sv_createNewPlayer" )
		end
		self.sv.witchWorldPlayersAre = "Overworld"
	end
end

function SurvivalGame.cl_onGoToOverworld( self )
	sm.gui.startFadeToBlack( 0.2, 0.6 )
end
------



function SurvivalGame.sv_onLeaveOverworld( self )

end
---



---WonkShip
------
function SurvivalGame.sv_onGoToWonkShip( self )
	if self.sv.witchWorldPlayersAre == "WonkShip" then
		sm.log.warning("[AMONG SCRAP] WARNING : Already on WonkShip world ! (Game.lua ln1048)")
	else
		self.network:sendToClients("cl_onGoToWonkShip")
		if self.sv.isWonkShipWorldExist == false then
			self:sv_createWonkShip()
		end
		local spawnPoint = sm.vec3.new( 0.0, 0.0, 100.0 )
		for _,p in ipairs(sm.player.getAllPlayers()) do
			self.sv.wonkShipWorld:loadCell( math.floor( spawnPoint.x/64 ), math.floor( spawnPoint.y/64 ), p, "sv_onCreateNewPlayerOnWonkShip" )
		end
		self.sv.witchWorldPlayersAre = "WonkShip"
		sm.gui.chatMessage("#ff1133 WARNING: you can fall off on the ship (work in progress)")
		sm.gui.chatMessage("#66ff88 Don't forgot to let me know what you think about the ship and about the mod in general, it help me for the developement ! :)")
	end
end

function SurvivalGame.cl_onGoToWonkShip( self )
	--self:cl_e_openMettingGui({player = sm.localPlayer.getPlayer()})
	sm.gui.startFadeToBlack( 0.2, 0.6 )
end
------



function SurvivalGame.sv_createWonkShip( self )
	self.sv.wonkShipWorld = sm.world.createWorld( "$CONTENT_DATA/Scripts/terrain/WonkShip.lua", "WonkShipWorld", { dev = self.sv.saved.data.dev }, self.sv.saved.data.seed )
	self.sv.isWonkShipWorldExist = true
end

function SurvivalGame.sv_onCreateNewPlayerOnWonkShip( self, world, x, y, player )
	local params = { player = player, x = x, y = y }
	sm.event.sendToWorld( self.sv.wonkShipWorld, "sv_spawnNewCharacter", params )
	
	local sendData = {player = player, name = player:getName()}
	self.sv.betterTimer:createNewTimer(7, self, SurvivalGame.sv_setPlayerNameTag, sendData)
end

function SurvivalGame.sv_onLeaveWonkShip( self )

end
---



-- WonkShipDead
------
function SurvivalGame.sv_onGoToWonkShipDead( self , data )
	if self.sv.witchWorldPlayersAre == "WonkShip" then
		self.network:sendToClients("cl_onGoToWonkShipDead")
		if self.sv.isWonkShipDeadWorldExist == false then
			self:sv_createWonkShipDead() 
			self.sv.isWonkShipDeadWorldExist = true
		end
		local spawnPoint = sm.vec3.new( 0.0, 0.0, 100.0 )
		self.sv.wonkShipDeadWorld:loadCell( math.floor( spawnPoint.x/64 ), math.floor( spawnPoint.y/64 ), data.player, "sv_onCreateNewPlayerOnWonkShipDead" )
	else
		sm.log.warning("[AMONG SCRAP] WARNING : Not on WonkShip ! (Game.lua ln1048)")
	end
end

function SurvivalGame.cl_onGoToWonkShipDead( self )
	--self:cl_e_openMettingGui({player = sm.localPlayer.getPlayer()})
	--sm.gui.startFadeToBlack( 0.2, 0.6 )
end
------



function SurvivalGame.sv_createWonkShipDead( self )
	self.sv.wonkShipDeadWorld = sm.world.createWorld( "$CONTENT_DATA/Scripts/terrain/WonkShip.lua", "WonkShipWorld", { dev = self.sv.saved.data.dev }, self.sv.saved.data.seed )
	self.sv.isWonkShipDeadWorldExist = true
end

function SurvivalGame.sv_onCreateNewPlayerOnWonkShipDead( self, world, x, y, player )
	local params = { player = player, x = x, y = y }
	sm.event.sendToWorld( self.sv.wonkShipDeadWorld, "sv_spawnNewCharacter", params )
	
	local sendData = {character = player:getCharacter(), name = player:getName()}
	self.network:sendToClients("cl_setPlayerNameTag", sendData)
end

function SurvivalGame.sv_onLeaveWonkShipDead( self )

end
---






-- METTING --

-------
function SurvivalGame.cl_c_onVoteButtonCallback( self , data )
	local sendData = {}

	for i,v in ipairs({'MettingPlayerUserButton1','MettingPlayerUserButton2','MettingPlayerUserButton3','MettingPlayerUserButton4','MettingPlayerUserButton5','MettingPlayerUserButton6','MettingPlayerUserButton7','MettingPlayerUserButton8','MettingPlayerUserButton9','MettingPlayerUserButton10','MettingPlayerUserSkipButton'}) do
		if data == v then
			sendData.index = i
			break
		end
	end

	local canVote = g_mettingManager:cl_onVoteButtonCallback(sendData)
	if canVote == true then
		sendData.player = sm.localPlayer.getPlayer()
		self.network:sendToServer("sv_c_onVoteButtonCallback", sendData)
	end
end

function SurvivalGame.sv_c_onVoteButtonCallback( self , data )
	g_mettingManager:sv_onVoteButtonCallback(data)
end
------

------
function SurvivalGame.sv_e_onEndingVote( self , data )
	if data.killedIndex < 11 then
		self:sv_e_onPlayerKilled({player = data.killed})
	end
	self.network:sendToClients('cl_e_onEndingVote', data)
	self:sv_onResetDeadUnit()
end

function SurvivalGame.cl_e_onEndingVote( self , data )
	g_mettingManager:cl_onEndingVote(data)
end
------

------
function SurvivalGame.sv_e_onResetMetting( self )
	g_mettingManager:sv_onResetMetting()
	self.network:sendToClients("cl_e_onResetMetting")
end

function SurvivalGame.cl_e_onResetMetting( self )
	g_mettingManager:cl_onResetMetting()
end
------

------
function SurvivalGame.sv_e_onInitMetting( self )
	data = g_mettingManager:sv_onInitMetting()
	self.network:sendToClients("cl_e_onInitMetting", data)
end

function SurvivalGame.cl_e_onInitMetting( self  , data )
	g_mettingManager:cl_onInitMetting(data)
end
------

--------
function SurvivalGame.cl_e_onReport( self , data )
	self.network:sendToServer("sv_e_onReport", data)
end

function SurvivalGame.sv_e_onReport(self , data )
	self.network:sendToClients("cl_e_openMettingGui", data)
end
-------



function  SurvivalGame.sv_e_onEmergencyMetting( self , data )
	self.network:sendToClients("cl_e_openMettingGui", data)
end

function SurvivalGame.cl_c_onCloseMettingGui( self )
	g_mettingManager:cl_onCloseMettingGui()
end

function SurvivalGame.cl_e_openMettingGui( self , data )
	g_mettingManager:cl_openMettingGui(data)
end






-- IMPOSTOR --

-------
function SurvivalGame.sv_e_onSendingImpostor( self , data )
	for _,p in ipairs(sm.player.getAllPlayers()) do
		p:setPublicData({impostor = false})
	end
	self.network:sendToClients("cl_e_onSendingCrewmate")

	for _,p in ipairs(data) do
		p:setPublicData({impostor = true})
		self.network:sendToClient(p, "cl_e_onSendingImpostor", true)
	end
end

function SurvivalGame.cl_e_onSendingImpostor( self , data )
	if data then
		self.cl.isImpostor = data
		g_impostorManager:cl_onSendingImpostor(data)
		sm.event.sendToPlayer(sm.localPlayer.getPlayer(),"cl_onSendingImpostor", data)
	end
end

function SurvivalGame.cl_e_onSendingCrewmate( self )
	sm.event.sendToPlayer(sm.localPlayer.getPlayer(),"cl_onSendingImpostor", false)
end
-------

-------
function SurvivalGame.sv_e_onResetImpostor( self )
	for _,p in ipairs(sm.player.getAllPlayers()) do
		p:setPublicData({impostor = false})
	end
	g_impostorManager:sv_onResetImpostor()
	self.network:sendToClients("cl_e_onResetImpostor")
end


function SurvivalGame.cl_e_onResetImpostor( self )
	self.cl.isImpostor = false
	g_impostorManager:cl_onResetImpostor()
	sm.event.sendToPlayer(sm.localPlayer.getPlayer(),"cl_onResetImpostor")
end
-------

-------
function SurvivalGame.cl_e_onImpostorKill( self , data )
	data.player = data.playerVictim or sm.localPlayer.getPlayer()
	self.network:sendToServer("sv_e_onImpostorKill", data)
end

function SurvivalGame.sv_e_onImpostorKill( self , data )
	--data.playerVictim:setDowned(true) -- !!! should be only for dev !! --
	sm.event.sendToWorld(self.sv.wonkShipWorld, "sv_onPlayerKilled", data.player)
	self:sv_e_onPlayerKilled({player = data.player})
	self.network:sendToClient(data.player, "cl_e_onKillByImpostor", data)
end
-------



function SurvivalGame.cl_e_onKillByImpostor( self , data )
	sm.gui.displayAlertText(string.format("Killed by %s", data.playerKiller:getName()))
end

function SurvivalGame.sv_e_onInitImpostor( self )
	g_impostorManager:sv_onInitImpostor()
end






--- TASK ---

--------- [server function called when task system need to be reset for another round]
function SurvivalGame.sv_e_onResetTask( self )
	self.network:sendToClients("cl_e_onResetTask")
	g_taskManager:sv_onResetTask()
	--print("[AMONG SCRAP] Tasks System has been reset")
end

function SurvivalGame.cl_e_onResetTask( self )
	g_taskManager:cl_onResetTask()
end
---------

--------- [Client function called when a task is finish. (called by TaskInterface.lua)]
function SurvivalGame.cl_e_onTaskFinished( self , data )
	data.player = sm.localPlayer.getPlayer()
	self.network:sendToServer("sv_e_onTaskFinished", data)
	local isPlayerTaskAllFinish = g_taskManager:cl_onTaskFinished(data)
	if isPlayerTaskAllFinish == true then
		g_taskManager:cl_onPlayerFinishAllTask()
	end
end

function SurvivalGame.sv_e_onTaskFinished( self , data )
	g_taskManager:sv_onTaskFinished(data)
end
---------

--------- [Server function called when the task need to be send to the clients. (called by TaskManager.lua)]
function SurvivalGame.sv_e_onSendingTask( self , data )
	for i,v in ipairs(data.allTasks) do
		local sendData = {tasks = v.tasks, taskPerPlayer = data.taskPerPlayer, impostor = v.impostor}
		self.network:sendToClient(v.player,"cl_e_onSendingTask", sendData)
	end
end
function SurvivalGame.cl_e_onSendingTask( self , data )
	g_taskManager:cl_onSendingTask(data)
end
---------

-------- [Server function called by the taskInterface when it init. send its object (called by TaskInterface.lua)]
function SurvivalGame.sv_e_receiveTaskInterfaceInteractable( self , data )
	g_taskManager:sv_receiveTaskInterfaceInteractable(data)
	self.network:sendToClients("cl_e_receiveTaskInterfaceInteractable", data)
end
function SurvivalGame.cl_e_receiveTaskInterfaceInteractable( self , data )
	g_taskManager:cl_receiveTaskInterfaceInteractable(data)
end
-------

-------
function SurvivalGame.sv_e_onTaskInterfaceDestroy( self , data )
	g_taskManager:sv_onTaskInterfaceDestroy(data)
end

function SurvivalGame.cl_e_onTaskInterfaceDestroy( self , data )
	g_taskManager:cl_onTaskInterfaceDestroy(data)
end
-------

-------
function SurvivalGame.sv_e_onRefreshTaskProgressionBar( self , data )
	self.network:sendToClients("cl_e_onRefreshTaskProgressionBar", data)
end

function SurvivalGame.cl_e_onRefreshTaskProgressionBar( self , data )
	sm.event.sendToPlayer(sm.localPlayer.getPlayer(), "cl_refreshTaskProgressionBar", data)
end
--------



function SurvivalGame.sv_e_onAllTasksFinished( self )
	self:sv_onGameOver({gameOverReason = "allTaskFinished"})
end

function SurvivalGame.sv_e_onInitTask( self ) -- Init all task (for one round only)
	g_taskManager:sv_onInitTask()
end


