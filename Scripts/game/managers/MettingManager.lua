--MettingManager.lua
-- JUST REALIZE I WORTE MEETING "METTING" ALL THE TIME :`(((((((((((((((((((((((("

dofile( "$CONTENT_DATA/Scripts/util/BetterTimer.lua" )

MettingManager = class( nil )

-- server
function MettingManager.sv_onCreate( self )
	self.sv = {}
	self.sv.votes = {}
	self.sv.mettingGuiOrder = {}

	self.sv.howManyPlayers = 0
	self.sv.howManyPlayersAlive = 0
	self.sv.howManyVotes = 0

	--self.sv.betterTimer = BetterTimer()
	--self.sv.betterTimer:onCreate()

	for i = 1,11 do
		self.sv.votes[i] = 0
	end

	self:sv_onInitMetting()
end


--- CONTENT ---

function MettingManager.sv_onInitMetting( self )
	self.sv.mettingGuiOrder = {}

	for i = 1,11 do
		self.sv.mettingGuiOrder[i] = {}
		self.sv.mettingGuiOrder[i].isEmpty = true
		self.sv.mettingGuiOrder[i].player = nil
		self.sv.mettingGuiOrder[i].isAlive = nil
		self.sv.mettingGuiOrder[i].name = nil
	end

	for i,v in ipairs(sm.player.getAllPlayers()) do
		self.sv.howManyPlayers = i
		self.sv.howManyPlayersAlive = i

		self.sv.mettingGuiOrder[i].player = v
		self.sv.mettingGuiOrder[i].name = v:getName()
		self.sv.mettingGuiOrder[i].isEmpty = false
		self.sv.mettingGuiOrder[i].isAlive = true
	end
	return self.sv.mettingGuiOrder
end


function MettingManager.sv_onVote( self , data )
	self.sv.votes[data.index] = self.sv.votes[data.index] + 1
	self.sv.howManyVotes = self.sv.howManyVotes + 1
	if self.sv.howManyVotes == self.sv.howManyPlayersAlive then
		self:sv_onEndingVote()
	end
end

function MettingManager.sv_onVoteButtonCallback( self , data )
	self:sv_onVote(data)
end


function MettingManager.sv_onEndingVote( self )
	local killedValue = 0
	local killedIndex = 0
	local killedReason = "No votes"
	for i,v in ipairs(self.sv.votes) do
		if v > killedValue then
			killedValue = v
			killedIndex = i
			killedReason = "Ejected"
		elseif v == killedValue then
			killedValue = v
			killedIndex = 11
			killReason = "Equality"
		end
		if killedIndex == 11 and killReason == "Ejected" then
			killReason = "Skip"
		end
	end
	local sendData = {allVotes = self.sv.votes, killed = self.sv.mettingGuiOrder[killedIndex].player or nil, killedIndex = killedIndex, killReason = killReason}
	sm.event.sendToGame("sv_e_onEndingVote", sendData)

	for i = 1,11 do
		self.sv.votes[i] = 0
	end

	self.sv.howManyVotes = 0
end

function MettingManager.sv_onResetMetting( self )
	for i = 1,11 do
		self.sv.votes[i] = 0
	end
	self.sv.mettingGuiOrder = {}
	self.sv.howManyPlayers = 0
	self.sv.howManyVotes = 0
	self.sv.howManyPlayersAlive = 0
end


function MettingManager.sv_onPlayerKilled( self , data )
	for i,v in ipairs(self.sv.mettingGuiOrder) do
		if v.isEmpty == false then
			if data.player == v.player then
				self.sv.howManyPlayersAlive = self.sv.howManyPlayersAlive - 1
				self.sv.mettingGuiOrder[i].isAlive = false
			end
		end
	end
end



-- client
function MettingManager.cl_onCreate( self , player )

	self.cl = {}
	self.cl.mettingGuiOrder = {}

	self.cl.isOpen = false
	self.cl.hasVoted = false
	self.cl.isInit = false
	self.cl.canVote = false
	self.cl.HasMetting = false

	self.cl.betterTimer = BetterTimer()
	self.cl.betterTimer:onCreate()

	--g_survivalHudMetting = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Tasks/Gui_TaskTemplateCraftBot.layout",false, {isHud = false, isInteractive = true, needsCursor = true})
	self.cl.g_survivalHudMetting = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Hud/Hud_MettingVotes.layout",false, {isHud = false, isInteractive = true, needsCursor = true, backgroundAlpha = 0.5 })

	self.cl.g_survivalHudMetting:setOnCloseCallback("cl_c_onCloseMettingGui")
	self.cl.g_survivalHudMetting:setButtonCallback("MettingPlayerUserSkipButton","cl_c_onVoteButtonCallback")

	for v1 = 1,11 do
		local tagTextAlert = string.format("MettingPlayerAlert%d",v1)
		self.cl.g_survivalHudMetting:setVisible(tagTextAlert, false)
		self.cl.g_survivalHudMetting:setButtonCallback(string.format("MettingPlayerUserButton%d",v1),"cl_c_onVoteButtonCallback")
		--self.cl.g_survivalHudMetting:setData(string.format("MettingPlayerUserButton%d",v), {index = v})

		for v2 = 1,10 do
			local tagTextVotes = string.format("MettingPlayerVotes%d-%d", v1, v2)
			self.cl.g_survivalHudMetting:setVisible(tagTextVotes, false)
		end
	end

	assert(self.cl.g_survivalHudMetting)
end





--- CONTENT ---

function MettingManager.cl_onInitMetting( self , data )
	self.cl.mettingGuiOrder = data

	for i = 1,10 do
		self.cl.g_survivalHudMetting:setText(string.format("MettingPlayerText%d", i), "")
		self.cl.g_survivalHudMetting:setVisible(string.format("MettingPlayerUserButton%d", i), false)
	end

	for i,v in ipairs(self.cl.mettingGuiOrder) do
		if v.isEmpty == false then
			self.cl.g_survivalHudMetting:setVisible(string.format("MettingPlayerUserButton%d", i), true)
			self.cl.g_survivalHudMetting:setText(string.format("MettingPlayerText%d", i), v.name)
			self.cl.g_survivalHudMetting:setItemIcon(string.format("MettingPlayerIcon%d", i), "CustomizationIconMap", "CustomizationIconMap", "0c6a7c26-3dc6-442d-ab3b-b74cbf402786_male")
		end
	end

	self.cl.isInit = true
	self.cl.canVote = true
	self.cl.HasMetting = false
end

---
function MettingManager.cl_openMettingGui( self , data )
	sm.gui.displayAlertText("EMERGENCY METTING", 2)
	sm.event.sendToWorld(sm.localPlayer.getPlayer().character:getWorld(), "cl_playEffect", {effect = "Horn", type = "audio" })
	
	self.cl.betterTimer:createNewTimer(40, self, MettingManager.cl_delayed_1_openMettingGui, data )
	self.cl.betterTimer:createNewTimer(60, self, MettingManager.cl_delayed_2_openMettingGui, data )
end

function MettingManager.cl_delayed_1_openMettingGui( self , data )
	sm.gui.startFadeToBlack(0.3, 1)
end

function MettingManager.cl_delayed_2_openMettingGui( self , data )
	if self.cl.isInit == true then
		if self.cl.isOpen == false then
			for i,v in ipairs(self.cl.mettingGuiOrder) do
				if data.player == v.player then
					self.cl.g_survivalHudMetting:setVisible(string.format("MettingPlayerAlert%d", i), true)
				end
			end
			self.cl.g_survivalHudMetting:open()
			self.cl.isOpen = true
		end
		self.cl.HasMetting = true
	else
		sm.log.warning("[AMONG SCRAP] WARNING : You can't open the voting GUI without initalize the metting system. (MettingManager.lua ln140)")
		sm.gui.chatMessage("[AMONG SCRAP] WARNING : Initalize the metting system before opening the voting GUI ! (Use '/metting')")
	end
end
---



function MettingManager.cl_onVoteButtonCallback( self , data )
	if self.cl.canVote == true then
		if self.cl.hasVoted == false then
			self.cl.hasVoted = true
			return true
		else
			return false
		end
	else
		return false
	end
end



---
function MettingManager.cl_onEndingVote( self , data )
	for i1,v1 in ipairs(data.allVotes) do
		for i2 = 1,v1 do
			self.cl.betterTimer:createNewTimer(i2 * 5, self, MettingManager.cl_delayed_1_onEndingVote, {i1 = i1, i2 = i2})
		end
	end
	self.cl.betterTimer:createNewTimer(80, self, MettingManager.cl_delayed_2_onEndingVote)
	
	local ejectText = "Someone has been ejected"
	local sendText = ""
	for i = 1, #ejectText do
		self.cl.betterTimer:createNewTimer(120 + (i*4), self, MettingManager.cl_delayed_3_onEndingVote, {text = ejectText:sub(1, i)})
	end
	self.cl.betterTimer:createNewTimer(180 + (#ejectText * 4), self, MettingManager.cl_delayed_2_onEndingVote)

	self.cl.HasMetting = false
	self.cl.betterTimer:createNewTimer(80, self, MettingManager.cl_delayed_2_onEndingVote)
	self.cl.betterTimer:createNewTimer(90, self, MettingManager.cl_onCloseMettingGui)
end

function MettingManager.cl_delayed_1_onEndingVote( self , data )
	self.cl.g_survivalHudMetting:setVisible(string.format("MettingPlayerVotes%d-%d", data.i1, data.i2), true)
end

function MettingManager.cl_delayed_2_onEndingVote( self )
	sm.gui.startFadeToBlack(0.4, 1)
end

function MettingManager.cl_delayed_3_onEndingVote( self , data )
	sm.gui.displayAlertText(data.text, 2)
	sm.event.sendToWorld(sm.localPlayer.getPlayer().character:getWorld(), "cl_playEffect", {effect = "Elevator Button", type = "effect" })
	
end
---




function MettingManager.cl_onCloseMettingGui( self )
	if self.cl.HasMetting ~= true then
		self.cl.g_survivalHudMetting:close()
		self.cl.hasVoted = false

		for v1 = 1,11 do
			self.cl.g_survivalHudMetting:setVisible(string.format("MettingPlayerAlert%d", v1), false)
			for v2 = 1,10 do
				self.cl.g_survivalHudMetting:setVisible(string.format("MettingPlayerVotes%d-%d", v1, v2), false)
			end
		end
		self.cl.isOpen = false
	else
		self.cl.g_survivalHudMetting:open()
	end
end


function MettingManager.cl_onResetMetting( self )
	self.cl.mettingGuiOrder = {}

	self.cl.isOpen = false
	self.cl.hasVoted = false
	self.cl.isInit = false
	self.cl.canVote = false

	for i = 1,10 do
		self.cl.g_survivalHudMetting:setText(string.format("MettingPlayerText%d", i),"")
	end

end

function MettingManager.cl_onPlayerKilled( self , data )
	if data.player == sm.localPlayer.getPlayer() then
		self.cl.canVote = false
	end
	for i,v in ipairs(self.cl.mettingGuiOrder) do
		if v.isEmpty == false then
			if data.player == v.player then
				self.cl.g_survivalHudMetting:setVisible(string.format("MettingPlayerUserButton%d", i), false)
				self.cl.mettingGuiOrder[i].isAlive = false
			end
		end
	end
end
