-- BaseTaskInterface.lua

--[[
TASK LIST:
ID 1.1 : Craftbot Task 1 - repair the craftbot - can be in cargo
ID 1.2 : Craftbot task 2 - repair the craftbot - can be in electrical

ID 2 : Motor stabilization - stabilize the motors - can be in control
ID 3 : Motor Speedup - increase the speed of the motors - can be in control
ID 4 : Motor speedDown - lower the speed of the motors - can be in control

ID 5.1 : Oil level check 1 - check the oil level of motor 1 - Motor 1
ID 5.2 : Oil level check 2 - check the oil level of motor 2 - Motor 2
ID 5.3 : Oil level check 3 - check the oil level of motor 3 - Motor 3
ID 5.4 : Oil level check 4 - check the oil level of motor 4 - Motor 4

ID 6.1 : Cookbot Task 1 - Order food - in main room
ID 6.2 : Cookbot Task 2 - prepare baguette - in medbay

ID 7 : Hydrolics - check the Hydrolics of the ship - Hydrolics
ID 8 : O2 bottles - full bottles of o2 - in o2
ID 9 : air gaz level - fix the level of gaz in the ship - in 02
ID 10 : key - push the key of ship - spawn
ID 11 : battery - change the battery - Electrical

]]

BaseTaskInterface = class()

BaseTaskInterface.maxParentCount = 0
BaseTaskInterface.maxChildCount = 0
BaseTaskInterface.connectionInput = sm.interactable.connectionType.none
BaseTaskInterface.connectionOutput = sm.interactable.connectionType.none
BaseTaskInterface.poseWeightCount = 1


--SERVER--

function BaseTaskInterface.server_onCreate( self )
	print("[AMONG SCRAP] BaseTaskInterface.server_onCreate")
	self.sv = {}

	self.sv.taskState = false
	self.sv.taskId = self.data.TaskName
	
	self.network:sendToClients("cl_receiveTaskId", {taskId = self.data.TaskName})
	sm.event.sendToGame("sv_e_receiveTaskInterfaceInteractable", self.interactable)	
end

function BaseTaskInterface.server_onRefresh( self )
	print("[AMONG SCRAP] BaseTaskInterface.server_onRefresh")
	--self:server_onCreate()
end

function BaseTaskInterface.server_onDestroy( self )
	--print(self)
	sm.event.sendToGame("sv_e_onTaskInterfaceDestroy", self.interactable)
end



--- CONTENT ---
function BaseTaskInterface.sv_onResetTask( self , data )
	self.taskState = false --?
	self.network:sendToClients("cl_onResetTask")
end

-- slave ---
function BaseTaskInterface.sv_receiveTaskState( self , data )
	self.taskState = data
	self.network:sendToClients("cl_receiveTaskState", data)
end









--CLIENT--
function BaseTaskInterface.client_onCreate( self )
	print("[AMONG SCRAP] BaseTaskInterface.client_onCreate")
	self.cl = {}
	self.cl.taskState = false
	self.cl.taskId = ""

	self.cl.TaskInterfaceIcon = sm.gui.createWorldIconGui(50, 50, "$GAME_DATA/Gui/Layouts/Hud/Hud_WorldIcon.layout")
	self.cl.TaskInterfaceIcon:setWorldPosition(self.shape:getWorldPosition())
	self.cl.TaskInterfaceIcon:setImage("Icon", "gui_icon_popup_alert.png")
	---!!! can be nice to add becon icon (with the thing on cl_onRefresh) for wold icon !!!!---

	self.cl.TaskInterfaceGui = sm.gui.createGuiFromLayout("$GAME_DATA/Gui/Layouts/Interactable/Interactable_CraftBot.layout", false, {isHud = false, isInteractive = true, needsCursor = true})
	self.cl.TaskInterfaceGui:setButtonCallback("Craft","cl_onHudTaskButton")
	self.cl.TaskInterfaceGui:setText("Craft", "FINISH TASK")
end

function BaseTaskInterface.client_onInteract( self , character , state )
	--sm.effect.createEffect("Fire - gradual", self.interactable):start()
	if state == true then
		self.cl.TaskInterfaceGui:open()
		return true
	end
	return false
end

function BaseTaskInterface.client_canInteract( self , character )
	local player = character:getPlayer()
	if player:getClientPublicData().impostor == nil then
		if self.cl.taskState == true then

			if self.cl.playerTasks == nil then
				sm.log.error("[AMONG SCRAP] ERROR : tasks aren't send or tasks table syntax error ! (BaseTaskInterface.lua - ln341)")
				return false
			end

			local haveTheTask = false
			local isFinish = false
			for i,v in ipairs(self.cl.playerTasks) do
				if self.cl.taskId == v.taskId then
					haveTheTask = true
					if v.isFinished == true then
						isFinish = true
						break
					end
				end
			end
			if haveTheTask == true then
				if isFinish == false then
					sm.gui.setCenterIcon( "Use" )
					local keyBindingText = sm.gui.getKeyBinding( "Use", true )
					sm.gui.setInteractionText("", keyBindingText, g_Language:cl_getTraduction("HUD_INTERACTION_OPEN") )
					return true
				else
					sm.gui.setCenterIcon( "Use" )
					local keyBindingText = sm.gui.getKeyBinding( "", true )
					sm.gui.setInteractionText("<img spacing='0'>IconChallengeCompleted.png</img>","",g_Language:cl_getTraduction("HUD_INTERACTION_TASK_ALREADY_COMPLETED"))
					return false
				end
			else
				sm.gui.setCenterIcon( "Use" )
				local keyBindingText = sm.gui.getKeyBinding( "", true )
				sm.gui.setInteractionText("<img spacing='0'>icon_mainquest_medium.png</img>","", g_Language:cl_getTraduction("HUD_INTERACTION_CANT_OPEN"))
				return false
			end
		else
			sm.gui.setCenterIcon( "Use" )
			local keyBindingText = sm.gui.getKeyBinding( "", true )
			sm.gui.setInteractionText("<img spacing='0'>icon_mainquest_medium.png</img>","", g_Language:cl_getTraduction("HUD_INTERACTION_CANT_OPEN"))
			return false
		end
	end
	return false
end

function BaseTaskInterface.client_onRefresh( self )
	--self.cl.TaskInterfaceIcon:setImage("Icon", "BeaconIconMap1")
	--self:client_onCreate()
	--self.cl.TaskInterfaceIcon:setItemIcon( "Icon", "BeaconIconMap", "BeaconIconMap", "11")
	--self.cl.TaskInterfaceGui = sm.gui.createGuiFromLayout("$GAME_DATA/Gui/Layouts/Interactable/Interactable_CraftBot.layout", false, {isHud = false, isInteractive = true, needsCursor = true})
end

function BaseTaskInterface.client_onDestroy( self )
	sm.event.sendToGame("cl_e_onTaskInterfaceDestroy", self.interactable)
	self.cl.TaskInterfaceIcon:close()
end



-- CONTENT ---
function BaseTaskInterface.cl_onTaskFinished( self )
	local taskIndex = nil
	local haveTheTask = false
	for i,v in ipairs(self.cl.playerTasks) do
		if self.cl.taskId == v.taskId then
			taskIndex = i
			haveTheTask = true
			break
		end
	end
	if haveTheTask == true then
		if self.cl.playerTasks[taskIndex].isFinished == false then

			self.cl.playerTasks[taskIndex].isFinished = true
			local data = {taskId = self.cl.taskId}
			sm.event.sendToGame("cl_e_onTaskFinished", data)

			self.cl.TaskInterfaceIcon:close()
			self.cl.TaskInterfaceGui:close()
			sm.gui.displayAlertText("Task completed", 2)
			sm.audio.play("Phaser")
		end
	end
end

function BaseTaskInterface.cl_onResetTask( self )
	self.cl.playerTasks = nil
	self.cl.taskState = false

	self.cl.TaskInterfaceIcon:close()
end



-- slave (receving) function --
function BaseTaskInterface.cl_receiveTaskId( self , data )
	self.cl.taskId = data.taskId
end

function BaseTaskInterface.cl_receiveTaskState( self , data )
	self.cl.taskState = data
end

function BaseTaskInterface.cl_receiveTask( self , data )
	self.cl.playerTasks = data
	if data then
		local haveTheTask = false
		local isFinished = false
		for i,v in ipairs(self.cl.playerTasks) do
			if self.cl.taskId == v.taskId then
				--taskIndex = i
				haveTheTask = true
				isFinished = v.isFinished
				break
			end
		end
		if haveTheTask == true and isFinished == false then
			self.cl.TaskInterfaceIcon:open()
		end
	end
end



-- BUTTTON CALLBACK

function BaseTaskInterface.cl_onHudTaskButton( self )
	self:cl_onTaskFinished()
end
