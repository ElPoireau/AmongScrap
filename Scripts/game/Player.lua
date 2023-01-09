dofile( "$GAME_DATA/Scripts/game/BasePlayer.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/survival_camera.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/survival_constants.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/util/Timer.lua" )
dofile( "$SURVIVAL_DATA/Scripts/util.lua" )

SurvivalPlayer = class( BasePlayer )

local StatsTickRate = 40

local PerSecond = StatsTickRate / 40
local PerMinute = StatsTickRate / ( 40 * 60 )

local FoodRecoveryThreshold = 5 -- Recover hp when food is above this value
local FastFoodRecoveryThreshold = 50 -- Recover hp fast when food is above this value
local HpRecovery = 50 * PerMinute
local FastHpRecovery = 75 * PerMinute
local FoodCostPerHpRecovery = 0.2
local FastFoodCostPerHpRecovery = 0.2

local FoodCostPerStamina = 0.02
local WaterCostPerStamina = 0.1
local SprintStaminaCost = 0.7 / 40 -- Per tick while sprinting
local CarryStaminaCost = 1.4 / 40 -- Per tick while carrying

local FoodLostPerSecond = 100 / 3.5 / 24 / 60
local WaterLostPerSecond = 100 / 2.5 / 24 / 60

local BreathLostPerTick = ( 100 / 60 ) / 40

local FatigueDamageHp = 1 * PerSecond
local FatigueDamageWater = 2 * PerSecond
local DrownDamage = 5
local DrownDamageCooldown = 40

local RespawnTimeout = 60 * 40

local RespawnFadeDuration = 0.45
local RespawnEndFadeDuration = 0.45

local RespawnFadeTimeout = 5.0
local RespawnDelay = RespawnFadeDuration * 40
local RespawnEndDelay = 1.0 * 40

local BaguetteSteps = 0

function SurvivalPlayer.server_onCreate( self )
	self.sv = {}
	self.sv.saved = self.storage:load()
	self.sv.saved = self.sv.saved or {}
	self.sv.saved.stats = self.sv.saved.stats or {
		hp = 100, maxhp = 100,
		food = 100, maxfood = 100,
		water = 100, maxwater = 100,
		breath = 100, maxbreath = 100
	}
	self.sv.saved.isConscious = self.sv.saved.isConscious or true
	self.sv.saved.hasRevivalItem = self.sv.saved.hasRevivalItem or false
	self.sv.saved.isNewPlayer = self.sv.saved.isNewPlayer or true
	self.sv.saved.inChemical = self.sv.saved.inChemical or false
	self.sv.saved.inOil = self.sv.saved.inOil or false
	--self.sv.saved.tutorialsWatched = self.sv.saved.tutorialsWatched or {}
	self.storage:save( self.sv.saved )

	self:sv_init()
	self.network:setClientData( self.sv.saved )
end

function SurvivalPlayer.server_onRefresh( self )
	self:sv_init()
	self.network:setClientData( self.sv.saved )
end

function SurvivalPlayer.sv_init( self )
	BasePlayer.sv_init( self )
	self.sv.staminaSpend = 0

	self.sv.statsTimer = Timer()
	self.sv.statsTimer:start( StatsTickRate )

	self.sv.drownTimer = Timer()
	self.sv.drownTimer:stop()

	self.sv.spawnparams = {}
end

function SurvivalPlayer.client_onCreate( self )
	BasePlayer.client_onCreate( self )
	self.cl = self.cl or {}

	self.cl.canKill = false
	self.cl.canReport = false

	if self.player == sm.localPlayer.getPlayer() then
		if g_survivalHudTaskBar then
			g_survivalHudTaskBar:open()
			g_survivalHudTaskList:open()
			g_survivalHudImpostor:open()
			self:cl_refreshImpostorGui(nil)
			--g_survivalHudAmongScrap:open()
		end

		--SetMovementSpeedFraction(self.player:getCharacter(), 100090)
		self.cl.hungryEffect = sm.effect.createEffect( "Mechanic - StatusHungry" )
		self.cl.thirstyEffect = sm.effect.createEffect( "Mechanic - StatusThirsty" )
		self.cl.underwaterEffect = sm.effect.createEffect( "Mechanic - StatusUnderwater" )
		self.cl.followCutscene = 0.0
		--self.cl.tutorialsWatched = {}

		-----------------------------------------------------------------
		----------------------      CHANGELOG      ----------------------
		-----------------------------------------------------------------

		sm.gui.chatMessage("============================================")
		sm.gui.chatMessage("Welcome in Among Scrap (Version 0.2.0)")
		sm.gui.chatMessage("============================================")
		sm.gui.chatMessage([[
		-- CHANGELOG (0.2.0) --
-- General :
	· Added mysterious ambiance
	· Make some crash test in multiplayer
	· Task progression now work

-- Mapping :
	· Added new spawn
	· New map : Wonk ship (Work in progress)
	· Added test template on WonkShip

-- In the code :
	· Player are now alaways a new player when he join
	· Improve the code to be multiplayer friendly
	· TaskInterfaceIcon now close on destroy
	· A downed player can no longer vote in metting
	· Added new sounds when tasks are finish or complete
	· Added new text when task are complete
	· Added new Fadein and FadeOut when onGameOver and onGoToWorld

-- Fix :
	· Fix taskTable pointer problem
	· Fix the impostor random status
	· Fix tasks in multiplayer

-- New command :
	· "/spawnship" - go to Spawn ship map
	· "/wonkship" - go to Wonk ship map

]])

--[[
		-- CHANGELOG (0.1.8) --
-- General :
	· Happy new year !
	· All the system are functionnal, you can play to Among Scrap now !

-- In the code :
	· Added icon that show where is Task interface (Work in progress)
	· Added Task labels and HUD (Work in progress)
	· Added kill and report function
	· Remove g_survivalHudAmongScrap HUD
	· impostor system should be work !
	· Metting system should be work !

-- New command
	· '/metting' - it initalize the metting system
	· '/vote' - it open the voting GUI
	· '/start' - it start a round
	· '/impostornum'
]]--

--[[		-- CHANGELOG (0.1.7) --
-- General :
	· now working on the mod again !
	· new changelog displaying

-- In the code :
	· '/impostor' command added
	· '/reset' command added - it reseting the task system
	· New interactable part : Task interface
	· added tasks structure
	· Task system should now work as well, try it using task interface part and the command '/task' !
	· improve the normalization of all variables and functions namespace
	· added random (random in scrap like to be not working so well... )
	]]
	end
	self:cl_init()
end

function SurvivalPlayer.client_onRefresh( self )
	self:cl_init()

	sm.gui.hideGui( false )
	sm.camera.setCameraState( sm.camera.state.default )
	sm.localPlayer.setLockedControls( false )
end

function SurvivalPlayer.cl_init( self )
	self.useCutsceneCamera = false
	self.progress = 0
	self.nodeIndex = 1
	self.currentCutscene = {}
	self.cl.revivalChewCount = 0

	self.taskHasJob = false
	self.taskMenuOpen = false
end

function SurvivalPlayer.client_onClientDataUpdate( self, data )
	BasePlayer.client_onClientDataUpdate( self, data )
	if sm.localPlayer.getPlayer() == self.player then

		if self.cl.stats == nil then self.cl.stats = data.stats end -- First time copy to avoid nil errors

		if g_survivalHudTaskBar then
		end

		if self.cl.hasRevivalItem ~= data.hasRevivalItem then
			self.cl.revivalChewCount = 0
		end

		if self.player.character then
			local charParam = self.player:isMale() and 1 or 2
			self.cl.underwaterEffect:setParameter( "char", charParam )
			self.cl.hungryEffect:setParameter( "char", charParam )
			self.cl.thirstyEffect:setParameter( "char", charParam )

			if data.stats.breath <= 15 and not self.cl.underwaterEffect:isPlaying() and data.isConscious then
				self.cl.underwaterEffect:start()
			elseif ( data.stats.breath > 15 or not data.isConscious ) and self.cl.underwaterEffect:isPlaying() then
				self.cl.underwaterEffect:stop()
			end
			if data.stats.food <= 5 and not self.cl.hungryEffect:isPlaying() and data.isConscious then
				self.cl.hungryEffect:start()
			elseif ( data.stats.food > 5 or not data.isConscious ) and self.cl.hungryEffect:isPlaying() then
				self.cl.hungryEffect:stop()
			end
			if data.stats.water <= 5 and not self.cl.thirstyEffect:isPlaying() and data.isConscious then
				self.cl.thirstyEffect:start()
			elseif ( data.stats.water > 5 or not data.isConscious ) and self.cl.thirstyEffect:isPlaying() then
				self.cl.thirstyEffect:stop()
			end
		end

		if data.stats.food <= 5 and self.cl.stats.food > 5 then
			sm.gui.displayAlertText( "#{ALERT_HUNGER}", 5 )
		end
		if data.stats.water <= 5 and self.cl.stats.water > 5 then
			sm.gui.displayAlertText( "#{ALERT_THIRST}", 5 )
		end

		if data.stats.hp < self.cl.stats.hp and data.stats.breath == 0 then
			sm.gui.displayAlertText( "#{DAMAGE_BREATH}", 1 )
		elseif data.stats.hp < self.cl.stats.hp and data.stats.food == 0 then
			sm.gui.displayAlertText( "#{DAMAGE_HUNGER}", 1 )
		elseif data.stats.hp < self.cl.stats.hp and data.stats.water == 0 then
			sm.gui.displayAlertText( "#{DAMAGE_THIRST}", 1 )
		end

		self.cl.stats = data.stats
		self.cl.isConscious = data.isConscious
		self.cl.hasRevivalItem = data.hasRevivalItem
		sm.localPlayer.setBlockSprinting( data.stats.food == 0 or data.stats.water == 0 )
	end
end

function SurvivalPlayer.cl_localPlayerUpdate( self, dt )
	BasePlayer.cl_localPlayerUpdate( self, dt )
	--self:cl_updateCamera( dt )

	local character = self.player:getCharacter()
	if character and not self.cl.isConscious then
		local keyBindingText =  sm.gui.getKeyBinding( "Use", true )
		if self.cl.hasRevivalItem then
			if self.cl.revivalChewCount < BaguetteSteps then
				sm.gui.setInteractionText( "", keyBindingText, "#{INTERACTION_EAT} ("..self.cl.revivalChewCount.."/10)" )
			else
				sm.gui.setInteractionText( "", keyBindingText, "#{INTERACTION_REVIVE}" )
			end
		else
			sm.gui.setInteractionText( "", keyBindingText, "#{INTERACTION_RESPAWN}" )
		end
	end

	if character then
		self.cl.underwaterEffect:setPosition( character.worldPosition )
		self.cl.hungryEffect:setPosition( character.worldPosition )
		self.cl.thirstyEffect:setPosition( character.worldPosition )
	end
end

function SurvivalPlayer.client_onUpdate( self )
	if self.cl.isConscious then
		local FuckingUselessWhyTheDevsAddThisReturn, result = sm.localPlayer.getRaycast( 15 )
		if result.type == "character" then
			local character = result:getCharacter()
			if character:isDowned() then
				sm.gui.setCenterIcon( "Use" )
				local keyBindingText =  sm.gui.getKeyBinding( "Use", true )
				sm.gui.setInteractionText( "", keyBindingText, "Report" )
				self.cl.canReport = true
				self.cl.canKill = false
				self.cl.impostorVictim = false
			else
				if self.cl.isImpostor == true then
					sm.gui.setCenterIcon( "Use" )
					local keyBindingText =  sm.gui.getKeyBinding( "Use", true )
					sm.gui.setInteractionText( "", keyBindingText, "Kill" )
					self.cl.canKill = true
					self.cl.impostorVictim = character:getPlayer()
				else
					self.cl.canReport = false
				end
			end
		else
			self.cl.canReport = false
			self.cl.canKill = false
			self.cl.impostorVictim = false
		end
	end
end

function SurvivalPlayer.client_onInteract( self, character, state )
	if state == true then
		if not self.cl.isConscious then
			if self.cl.hasRevivalItem then
				if self.cl.revivalChewCount >= BaguetteSteps then
					self.network:sendToServer( "sv_n_revive" )
				end
				self.cl.revivalChewCount = self.cl.revivalChewCount + 1
				self.network:sendToServer( "sv_onEvent", { type = "character", data = "chew" } )
			else
				self.network:sendToServer( "sv_n_tryRespawn" )
			end
			--- CONTENT ---
		else
			if self.cl.canReport then
				self:cl_i_onReport({player = sm.localPlayer.getPlayer()})

			elseif self.cl.canKill then
				sendData = {playerKiller = sm.localPlayer.getPlayer(), playerVictim = self.cl.impostorVictim}
				self:cl_i_onImpostorKill(sendData)
			end
		end
	end
end

function SurvivalPlayer.server_onFixedUpdate( self, dt )
	BasePlayer.server_onFixedUpdate( self, dt )

	if g_survivalDev and not self.sv.saved.isConscious and not self.sv.saved.hasRevivalItem then
		if sm.container.canSpend( self.player:getInventory(), obj_consumable_longsandwich, 1 ) then
			if sm.container.beginTransaction() then
				sm.container.spend( self.player:getInventory(), obj_consumable_longsandwich, 1, true )
				if sm.container.endTransaction() then
					self.sv.saved.hasRevivalItem = true
					--self.player:sendCharacterEvent( "baguette" )
					self.network:setClientData( self.sv.saved )
				end
			end
		end
	end

	-- Delays the respawn so clients have time to fade to black
	if self.sv.respawnDelayTimer then
		self.sv.respawnDelayTimer:tick()
		if self.sv.respawnDelayTimer:done() then
			self:sv_e_respawn()
			self.sv.respawnDelayTimer = nil
		end
	end

	-- End of respawn sequence
	if self.sv.respawnEndTimer then
		self.sv.respawnEndTimer:tick()
		if self.sv.respawnEndTimer:done() then
			self.network:sendToClient( self.player, "cl_n_endFadeToBlack", { duration = RespawnEndFadeDuration } )
			self.sv.respawnEndTimer = nil;
		end
	end

	-- If respawn failed, restore the character
	if self.sv.respawnTimeoutTimer then
		self.sv.respawnTimeoutTimer:tick()
		if self.sv.respawnTimeoutTimer:done() then
			self:sv_e_onSpawnCharacter()
		end
	end

	local character = self.player:getCharacter()
	-- Update breathing
--[[]]--
	if character then
		if character:isDiving() then
			self.sv.saved.stats.breath = math.max( self.sv.saved.stats.breath - BreathLostPerTick, 0 )
			if self.sv.saved.stats.breath == 0 then
				self.sv.drownTimer:tick()
				if self.sv.drownTimer:done() then
					if self.sv.saved.isConscious then
						print( "'SurvivalPlayer' is drowning!" )
						self:sv_takeDamage( DrownDamage, "drown" )
					end
					self.sv.drownTimer:start( DrownDamageCooldown )
				end
			end
		else
			self.sv.saved.stats.breath = self.sv.saved.stats.maxbreath
			self.sv.drownTimer:start( DrownDamageCooldown )
		end

		-- Spend stamina on sprinting
		if character:isSprinting() then
			self.sv.staminaSpend = self.sv.staminaSpend + SprintStaminaCost
		end

		-- Spend stamina on carrying
		if not self.player:getCarry():isEmpty() then
			self.sv.staminaSpend = self.sv.staminaSpend + CarryStaminaCost
		end
	end
end


function SurvivalPlayer.server_onInventoryChanges( self, container, changes )
	--QuestManager.Sv_OnEvent( QuestEvent.InventoryChanges, { container = container, changes = changes } )

	--local obj_interactive_builderguide = sm.uuid.new( "e83a22c5-8783-413f-a199-46bc30ca8dac" )
	if not g_survivalDev then
		if FindInventoryChange( changes, obj_interactive_builderguide ) > 0 then
			self.network:sendToClient( self.player, "cl_n_onMessage", { message = "#{ALERT_BUILDERGUIDE_NOT_ON_LIFT}", displayTime = 3 } )
			--QuestManager.Sv_TryActivateQuest( "quest_builder_guide" )
		end
		--if FindInventoryChange( changes, blk_scrapwood ) > 0 then
		--	QuestManager.Sv_TryActivateQuest( "quest_acquire_test" )
		--end
	end
end

function SurvivalPlayer.sv_e_staminaSpend( self, stamina )
	if not g_godMode then
		if stamina > 0 then
			self.sv.staminaSpend = self.sv.staminaSpend + stamina
		end
	end
end

function SurvivalPlayer.sv_takeDamage( self, damage, source )
	if damage > 0 then
		damage = damage * GetDifficultySettings().playerTakeDamageMultiplier
		local character = self.player:getCharacter()
		local lockingInteractable = character:getLockingInteractable()
		if lockingInteractable and lockingInteractable:hasSeat() then
			lockingInteractable:setSeatCharacter( character )
		end

		if not g_godMode and self.sv.damageCooldown:done() then
			if self.sv.saved.isConscious then
				self.sv.saved.stats.hp = math.max( self.sv.saved.stats.hp - damage, 0 )

				print( "'SurvivalPlayer' took:", damage, "damage.", self.sv.saved.stats.hp, "/", self.sv.saved.stats.maxhp, "HP" )

				if source then
					self.network:sendToClients( "cl_n_onEvent", { event = source, pos = character:getWorldPosition(), damage = damage * 0.01 } )
				else
					self.player:sendCharacterEvent( "hit" )
				end

				if self.sv.saved.stats.hp <= 0 then
					print( "'SurvivalPlayer' knocked out!" )
					self.sv.respawnInteractionAttempted = false
					self.sv.saved.isConscious = false
					character:setTumbling( true )
					character:setDowned( true )
				end

				self.storage:save( self.sv.saved )
				self.network:setClientData( self.sv.saved )
			end
		else
			print( "'SurvivalPlayer' resisted", damage, "damage" )
		end
	end
end

function SurvivalPlayer.sv_n_revive( self )
	local character = self.player:getCharacter()
	if not self.sv.saved.isConscious and self.sv.saved.hasRevivalItem and not self.sv.spawnparams.respawn then
		print( "SurvivalPlayer", self.player.id, "revived" )
		self.sv.saved.stats.hp = self.sv.saved.stats.maxhp
		self.sv.saved.stats.food = self.sv.saved.stats.maxfood
		self.sv.saved.stats.water = self.sv.saved.stats.maxwater
		self.sv.saved.isConscious = true
		self.sv.saved.hasRevivalItem = false
		self.storage:save( self.sv.saved )
		self.network:setClientData( self.sv.saved )
		self.network:sendToClient( self.player, "cl_n_onEffect", { name = "Eat - EatFinish", host = self.player.character } )
		if character then
			character:setTumbling( false )
			character:setDowned( false )
		end
		self.sv.damageCooldown:start( 40 )
		self.player:sendCharacterEvent( "revive" )
	end
end

function SurvivalPlayer.sv_e_respawn( self )
	if self.sv.spawnparams.respawn then
		if not self.sv.respawnTimeoutTimer then
			self.sv.respawnTimeoutTimer = Timer()
			self.sv.respawnTimeoutTimer:start( RespawnTimeout )
		end
		return
	end
	if not self.sv.saved.isConscious then
		g_respawnManager:sv_performItemLoss( self.player )
		self.sv.spawnparams.respawn = true

		sm.event.sendToGame( "sv_e_respawn", { player = self.player } )
	else
		print( "SurvivalPlayer must be unconscious to respawn" )
	end
end

function SurvivalPlayer.sv_n_tryRespawn( self )
	if not self.sv.saved.isConscious and not self.sv.respawnDelayTimer and not self.sv.respawnInteractionAttempted then
		self.sv.respawnInteractionAttempted = true
		self.sv.respawnEndTimer = nil;
		self.network:sendToClient( self.player, "cl_n_startFadeToBlack", { duration = RespawnFadeDuration, timeout = RespawnFadeTimeout } )

		self.sv.respawnDelayTimer = Timer()
		self.sv.respawnDelayTimer:start( RespawnDelay )
	end
end

function SurvivalPlayer.sv_e_onSpawnCharacter( self )
	if self.sv.saved.isNewPlayer then
		-- Intro cutscene for new player
		if not g_survivalDev then
			--self:sv_e_startLocalCutscene( "camera_approach_crash" )
		end
	elseif self.sv.spawnparams.respawn then
		local playerBed = g_respawnManager:sv_getPlayerBed( self.player )
		if playerBed and playerBed.shape and sm.exists( playerBed.shape ) and playerBed.shape.body:getWorld() == self.player.character:getWorld() then
			-- Attempt to seat the respawned character in a bed
			self.network:sendToClient( self.player, "cl_seatCharacter", { shape = playerBed.shape  } )
		else
			-- Respawned without a bed
			--self:sv_e_startLocalCutscene( "camera_wakeup_ground" )
		end

		self.sv.respawnEndTimer = Timer()
		self.sv.respawnEndTimer:start( RespawnEndDelay )

	end

	if self.sv.saved.isNewPlayer or self.sv.spawnparams.respawn then
		print( "SurvivalPlayer", self.player.id, "spawned" )
		if self.sv.saved.isNewPlayer then
			self.sv.saved.stats.hp = self.sv.saved.stats.maxhp
			self.sv.saved.stats.food = self.sv.saved.stats.maxfood
			self.sv.saved.stats.water = self.sv.saved.stats.maxwater
		else
			self.sv.saved.stats.hp = 30
			self.sv.saved.stats.food = 30
			self.sv.saved.stats.water = 30
		end
		self.sv.saved.isConscious = true
		self.sv.saved.hasRevivalItem = false
		self.sv.saved.isNewPlayer = false
		self.storage:save( self.sv.saved )
		self.network:setClientData( self.sv.saved )

		self.player.character:setTumbling( false )
		self.player.character:setDowned( false )
		self.sv.damageCooldown:start( 40 )
	else
		-- SurvivalPlayer rejoined the game
		if self.sv.saved.stats.hp <= 0 or not self.sv.saved.isConscious then
			self.player.character:setTumbling( true )
			self.player.character:setDowned( true )
		end
	end

	self.sv.respawnInteractionAttempted = false
	self.sv.respawnDelayTimer = nil
	self.sv.respawnTimeoutTimer = nil
	self.sv.spawnparams = {}

	sm.event.sendToGame( "sv_e_onSpawnPlayerCharacter", self.player )
end

function SurvivalPlayer.cl_seatCharacter( self, params )
	if sm.exists( params.shape ) then
		params.shape.interactable:setSeatCharacter( self.player.character )
	end
end

function SurvivalPlayer.sv_e_debug( self, params )
	if params.hp then
		self.sv.saved.stats.hp = params.hp
	end
	if params.water then
		self.sv.saved.stats.water = params.water
	end
	if params.food then
		self.sv.saved.stats.food = params.food
	end
	self.storage:save( self.sv.saved )
	self.network:setClientData( self.sv.saved )
end

function SurvivalPlayer.sv_e_eat( self, edibleParams )
	if edibleParams.hpGain then
		self:sv_restoreHealth( edibleParams.hpGain )
	end
	if edibleParams.foodGain then
		self:sv_restoreFood( edibleParams.foodGain )

		self.network:sendToClient( self.player, "cl_n_onEffect", { name = "Eat - EatFinish", host = self.player.character } )
	end
	if edibleParams.waterGain then
		self:sv_restoreWater( edibleParams.waterGain )
		-- self.network:sendToClient( self.player, "cl_n_onEffect", { name = "Eat - DrinkFinish", host = self.player.character } )
	end
	self.storage:save( self.sv.saved )
	self.network:setClientData( self.sv.saved )
end

function SurvivalPlayer.sv_e_feed( self, params )
	if not self.sv.saved.isConscious and not self.sv.saved.hasRevivalItem then
		if sm.container.beginTransaction() then
			sm.container.spend( params.playerInventory, params.foodUuid, 1, true )
			if sm.container.endTransaction() then
				self.sv.saved.hasRevivalItem = true
				--self.player:sendCharacterEvent( "baguette" )
				self.network:setClientData( self.sv.saved )
			end
		end
	end
end

function SurvivalPlayer.sv_restoreHealth( self, health )
	if self.sv.saved.isConscious then
		self.sv.saved.stats.hp = self.sv.saved.stats.hp + health
		self.sv.saved.stats.hp = math.min( self.sv.saved.stats.hp, self.sv.saved.stats.maxhp )
		print( "'SurvivalPlayer' restored:", health, "health.", self.sv.saved.stats.hp, "/", self.sv.saved.stats.maxhp, "HP" )
	end
end

function SurvivalPlayer.sv_restoreFood( self, food )
	if self.sv.saved.isConscious then
		food = food * ( 0.8 + ( self.sv.saved.stats.maxfood - self.sv.saved.stats.food ) / self.sv.saved.stats.maxfood * 0.2 )
		self.sv.saved.stats.food = self.sv.saved.stats.food + food
		self.sv.saved.stats.food = math.min( self.sv.saved.stats.food, self.sv.saved.stats.maxfood )
		print( "'SurvivalPlayer' restored:", food, "food.", self.sv.saved.stats.food, "/", self.sv.saved.stats.maxfood, "FOOD" )
	end
end

function SurvivalPlayer.sv_restoreWater( self, water )
	if self.sv.saved.isConscious then
		water = water * ( 0.8 + ( self.sv.saved.stats.maxwater - self.sv.saved.stats.water ) / self.sv.saved.stats.maxwater * 0.2 )
		self.sv.saved.stats.water = self.sv.saved.stats.water + water
		self.sv.saved.stats.water = math.min( self.sv.saved.stats.water, self.sv.saved.stats.maxwater )
		print( "'SurvivalPlayer' restored:", water, "water.", self.sv.saved.stats.water, "/", self.sv.saved.stats.maxwater, "WATER" )
	end
end

function SurvivalPlayer.server_onShapeRemoved( self, removedShapes )
	local numParts = 0
	local numBlocks = 0
	local numJoints = 0

	for _, removedShapeType in ipairs( removedShapes ) do
		if removedShapeType.type == "block"  then
			numBlocks = numBlocks + removedShapeType.amount
		elseif removedShapeType.type == "part"  then
			numParts = numParts + removedShapeType.amount
		elseif removedShapeType.type == "joint"  then
			numJoints = numJoints + removedShapeType.amoun
		end
	end

	local staminaSpend = numParts + numJoints + math.sqrt( numBlocks )
	--self:sv_e_staminaSpend( staminaSpend )
end

function SurvivalPlayer.client_onCancel( self )
	BasePlayer.client_onCancel( self )
	--g_effectManager:cl_cancelAllCinematics()
end

function SurvivalPlayer.client_onReload( self )
	if not self.taskMenuOpen then
		g_survivalHudTaskList:setVisible("TaskListBarNotification", false)
		g_survivalHudTaskList:setVisible("TaskListBar", false)
		g_survivalHudTaskList:setVisible("TaskList", true)
		sm.audio.play("Handbook - Equip")
		self.taskMenuOpen = true
	else
		g_survivalHudTaskList:setVisible("TaskList", false)
		g_survivalHudTaskList:setVisible("TaskListBar", true)
		sm.audio.play("Handbook - Unequip")
		if self.taskHasJob then
			g_survivalHudTaskList:setVisible("TaskListBarNotification", true)
		end
		self.taskMenuOpen = false
	end
end

function SurvivalPlayer.sv_n_fireMsg( self ) end

--CONTENT


--- METTING --
function SurvivalPlayer.cl_i_onReport( self , data )
	sm.event.sendToGame("cl_e_onReport", data)
end



-- IMPOSTOR --

function SurvivalPlayer.cl_i_onImpostorKill( self , data )
	sm.event.sendToGame("cl_e_onImpostorKill", data)
end



function SurvivalPlayer.cl_onSendingImpostor( self , data )
	self.cl.isImpostor = data

	if self.cl.isImpostor == true then
		self:cl_refreshImpostorGui(true)
	elseif self.cl.isImpostor == false then
		self:cl_refreshImpostorGui(false)
	end
end

function SurvivalPlayer.cl_onResetImpostor( self )
		self.cl.isImpostor = false
		self:cl_refreshImpostorGui(nil)
end

function SurvivalPlayer.cl_refreshImpostorGui( self , data )
	if data == true then
		g_survivalHudImpostor:setVisible("NotText", false)
		g_survivalHudImpostor:setVisible("CrewmateText", false)
		g_survivalHudImpostor:setVisible("ImpostorText", true)

	elseif data == false then
		g_survivalHudImpostor:setVisible("NotText", false)
		g_survivalHudImpostor:setVisible("ImpostorText", false)
		g_survivalHudImpostor:setVisible("CrewmateText", true)
	elseif data == nil then
		g_survivalHudImpostor:setVisible("NotText", true)
		g_survivalHudImpostor:setVisible("ImpostorText", false)
		g_survivalHudImpostor:setVisible("CrewmateText", false)
	end
end



-- TASK --


function SurvivalPlayer.cl_refreshTaskProgressionBar( self , data )
	if data == nil then
		for i = 1, 12 do
			g_survivalHudTaskBar:setVisible(string.format("TaskGreen%d", i), false)
		end
	else
		for i = 1, data.taskProgression do
			g_survivalHudTaskBar:setVisible(string.format("TaskGreen%d", i), true)
		end
	end
end

function SurvivalPlayer.cl_refreshTaskText( self , data )
	if data then
		self.cl.taskPerPlayer = data.taskPerPlayer
		if data.impostor == true then
			g_survivalHudTaskList:setVisible('WTaskText1', false)
			g_survivalHudTaskList:setVisible('YTaskText1', true)
			g_survivalHudTaskList:setVisible('GTaskText1', false)

			g_survivalHudTaskList:setText('YTaskText1', "You're an impostor, kill and sabotage to win!")
		else
			if not self.taskMenuOpen then
				g_survivalHudTaskList:setVisible("TaskListBarNotification", true)
			end
			self.taskHasJob = true

			local grandParentTaskIndex = 0
			local guiTaskTextIndex = 0
			local taskLabel = ""

			for iA,v in ipairs(data.tasks) do
				local isFinishedInt = 0
				if data.tasks[iA].hasManyState == true then
					if data.tasks[iA].parentTaskIndex == iA then
						grandParentTaskIndex  = iA
						guiTaskTextIndex = guiTaskTextIndex + 1
						taskLabel = string.format("%s (%d/%d)",data.tasks[grandParentTaskIndex].taskLabel, data.tasks[grandParentTaskIndex].childTaskInfo.howManyFinished, data.tasks[grandParentTaskIndex].childTaskInfo.howManyTasks)
						isFinishedInt = data.tasks[grandParentTaskIndex].childTaskInfo.howManyFinished

						if data.tasks[grandParentTaskIndex].childTaskInfo.howManyFinished == data.tasks[grandParentTaskIndex].childTaskInfo.howManyTasks then
							isFinishedInt = 2

						elseif data.tasks[grandParentTaskIndex].childTaskInfo.howManyFinished > 0 then
							isFinishedInt = 1
						end
					else
						grandParentTaskIndex  = data.tasks[iA].grandParentTaskIndex
						taskLabel = string.format("%s (%d/%d)",data.tasks[grandParentTaskIndex].taskLabel, data.tasks[grandParentTaskIndex].childTaskInfo.howManyFinished, data.tasks[grandParentTaskIndex].childTaskInfo.howManyTasks)

						if data.tasks[grandParentTaskIndex].childTaskInfo.howManyFinished == data.tasks[grandParentTaskIndex].childTaskInfo.howManyTasks then
							isFinishedInt = 2

						elseif data.tasks[grandParentTaskIndex].childTaskInfo.howManyFinished > 0 then
							isFinishedInt = 1
						end
					end
				else
					grandParentTaskIndex = iA
					guiTaskTextIndex = guiTaskTextIndex + 1
					taskLabel = data.tasks[grandParentTaskIndex].taskLabel
					if data.tasks[grandParentTaskIndex].isFinished == true then
						isFinishedInt = 2
					end
				end

				local WTaskText = string.format("WTaskText%d",guiTaskTextIndex)
				local YTaskText = string.format("YTaskText%d",guiTaskTextIndex)
				local GTaskText = string.format("GTaskText%d",guiTaskTextIndex)

				if isFinishedInt == 2 then
					g_survivalHudTaskList:setVisible(WTaskText, false)
					g_survivalHudTaskList:setVisible(YTaskText, false)
					g_survivalHudTaskList:setVisible(GTaskText, true)

					g_survivalHudTaskList:setText(GTaskText, taskLabel)

				elseif isFinishedInt == 1 then
				g_survivalHudTaskList:setVisible(WTaskText, false)
				g_survivalHudTaskList:setVisible(YTaskText, true)
				g_survivalHudTaskList:setVisible(GTaskText, false)

				g_survivalHudTaskList:setText(YTaskText, taskLabel)

				elseif isFinishedInt == 0 then
					g_survivalHudTaskList:setVisible(WTaskText, true)
					g_survivalHudTaskList:setVisible(YTaskText, false)
					g_survivalHudTaskList:setVisible(GTaskText, false)

					g_survivalHudTaskList:setText(WTaskText,taskLabel)
				end
			end
		end
	else
		g_survivalHudTaskList:setVisible("TaskListBarNotification", false)
		self.taskHasJob = false
		if self.cl.taskPerPlayer then
			for v = 1, self.cl.taskPerPlayer do
				local WTaskText = string.format("WTaskText%d",v)
				local YTaskText = string.format("YTaskText%d",v)
				local GTaskText = string.format("GTaskText%d",v)

				g_survivalHudTaskList:setVisible(WTaskText, false)
				g_survivalHudTaskList:setVisible(YTaskText, false)
				g_survivalHudTaskList:setVisible(GTaskText, false)
			end
		end
	end
end
