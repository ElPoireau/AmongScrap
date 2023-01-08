-- TaskInterface.lua

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

TaskInterface = class()

TaskInterface.maxParentCount = 0
TaskInterface.maxChildCount = 0
TaskInterface.connectionInput = sm.interactable.connectionType.none
TaskInterface.connectionOutput = sm.interactable.connectionType.none
TaskInterface.poseWeightCount = 1



--SERVER--

function TaskInterface.server_onCreate( self )
	print("[AMONG SCRAP] TaskInterface.server_onCreate")
	self.sv = {}

	self.sv.taskId = ""
	self.sv.taskState = false

	local sendToClData = {}

	local taskName = nil
	local taskId = nil
	local hasTaskInit = false

	taskName = "Task 1 - 01"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "1_1"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 1 - 02"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "1_2"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 2 - 01"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "2_1"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 3 - 01"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "3_1"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 4 - 01"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "4_1"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 5 - 01"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "5_1"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 5 - 02"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "5_2"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 5 - 03"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "5_3"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 5 - 04"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "5_4"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 6 - 01"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "6_1"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 6 - 02"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "6_2"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 7 - 01"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "7_1"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 8 - 01"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "8_1"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 9 - 01"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "9_1"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 10 - 01"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "10_1"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	taskName = "Task 11 - 01"
	if self.data.TaskName == string.format("%s", taskName) then
		print(string.format("[AMONG SCRAP] %s Block initialization", taskName))
		taskId = "11_1"
		sendToClData.taskId = taskId
		self.sv.taskId = taskId
		self.network:sendToClients("cl_receiveTaskId", sendToClData)
		hasTaskInit = true
	end

	if hasTaskInit == false then
		sm.log.error("[AMONG SCRAP] ERROR: task dosen't exist (TaskInterface.lua - ln214)")
	elseif hasTaskInit == true then
		sm.event.sendToGame("sv_e_receiveTaskInterfaceInteractable", self.shape:getInteractable())
	end
end



function TaskInterface.server_onRefresh( self )
	print("[AMONG SCRAP] TaskInterface.server_onRefresh")
	--self:server_onCreate()
end

function TaskInterface.server_onDestroy( self )
	sm.event.sendToGame("sv_e_onTaskInterfaceDestroy", self.interactable)
end

--- CONTENT ---
function TaskInterface.sv_onResetTask( self , data )
	self.taskState = false --?
	self.network:sendToClients("cl_onResetTask")

end


-- slave ---
function TaskInterface.sv_receiveTaskState( self , data )
	self.taskState = data
	self.network:sendToClients("cl_receiveTaskState", data)
end









--CLIENT--
function TaskInterface.client_onCreate( self )
	print("[AMONG SCRAP] TaskInterface.client_onCreate")
	self.cl = {}
	self.cl.taskState = false
	self.cl.taskId = ""

	self.cl.g_taskInterfaceIcon = sm.gui.createWorldIconGui(50, 50, "$GAME_DATA/Gui/Layouts/Hud/Hud_WorldIcon.layout")
	self.cl.g_taskInterfaceIcon:setWorldPosition(self.shape:getWorldPosition())
	self.cl.g_taskInterfaceIcon:setImage("Icon", "gui_icon_popup_alert.png")
	---!!! can be nice to add becon icon (with the thing on cl_onRefresh) for wold icon !!!!---

	if self.data.TaskName == "Task 1 - 01" then
		self.cl.taskInterfaceHud = sm.gui.createGuiFromLayout("$GAME_DATA/Gui/Layouts/Interactable/Interactable_CraftBot.layout", false, {isHud = false, isInteractive = true, needsCursor = true})
		self.cl.taskInterfaceHud:setButtonCallback("Craft","cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("Craft", "FINISH TASK")

	elseif self.data.TaskName == "Task 1 - 02" then
		self.cl.taskInterfaceHud = sm.gui.createGuiFromLayout("$GAME_DATA/Gui/Layouts/Interactable/Interactable_CraftBot.layout", false, {isHud = false, isInteractive = true, needsCursor = true})
		self.cl.taskInterfaceHud:setButtonCallback("Craft","cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("Craft", "FINISH TASK")

	elseif self.data.TaskName == "Task 2 - 01" then
		self.cl.taskInterfaceHud = sm.gui.createEngineGui() ---sm.gui.createGuiFromLayout("$GAME_DATA/Gui/Layouts/Interactable/Interactable_Engine.layout", false, {isHud = false, isInteractive = true, needsCursor = true})
		self.cl.taskInterfaceHud:setOnCloseCallback("cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("UpgradeInfo", "FINISH TASK ->")
		self.cl.taskInterfaceHud:setVisible("Upgrade", true)

	elseif self.data.TaskName == "Task 3 - 01" then
		self.cl.taskInterfaceHud = sm.gui.createEngineGui() ---sm.gui.createGuiFromLayout("$GAME_DATA/Gui/Layouts/Interactable/Interactable_Engine.layout", false, {isHud = false, isInteractive = true, needsCursor = true})
		self.cl.taskInterfaceHud:setOnCloseCallback("cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("UpgradeInfo", "FINISH TASK ->")
		self.cl.taskInterfaceHud:setVisible("Upgrade", true)

	elseif self.data.TaskName == "Task 4 - 01" then
		self.cl.taskInterfaceHud = sm.gui.createEngineGui() ---sm.gui.createGuiFromLayout("$GAME_DATA/Gui/Layouts/Interactable/Interactable_Engine.layout", false, {isHud = false, isInteractive = true, needsCursor = true})
		self.cl.taskInterfaceHud:setOnCloseCallback("cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("UpgradeInfo", "FINISH TASK ->")
		self.cl.taskInterfaceHud:setVisible("Upgrade", true)

	elseif self.data.TaskName == "Task 5 - 01" then
		self.cl.taskInterfaceHud = sm.gui.createChemicalContainerGui()
		self.cl.taskInterfaceHud:setOnCloseCallback("cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("UpperName", "CLOSE TO FINISH TASK")

	elseif self.data.TaskName == "Task 5 - 02" then
		self.cl.taskInterfaceHud = sm.gui.createChemicalContainerGui()
		self.cl.taskInterfaceHud:setOnCloseCallback("cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("UpperName", "CLOSE TO FINISH TASK")

	elseif self.data.TaskName == "Task 5 - 03" then
		self.cl.taskInterfaceHud = sm.gui.createChemicalContainerGui()
		self.cl.taskInterfaceHud:setOnCloseCallback("cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("UpperName", "CLOSE TO FINISH TASK")

	elseif self.data.TaskName == "Task 5 - 04" then
		self.cl.taskInterfaceHud = sm.gui.createChemicalContainerGui()
		self.cl.taskInterfaceHud:setOnCloseCallback("cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("UpperName", "CLOSE TO FINISH TASK")

	elseif self.data.TaskName == "Task 6 - 01" then
		self.cl.taskInterfaceHud = sm.gui.createGuiFromLayout("$GAME_DATA/Gui/Layouts/Interactable/Interactable_CookBot.layout", false, {isHud = false, isInteractive = true, needsCursor = true})
		self.cl.taskInterfaceHud:setButtonCallback("Revival","cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("Revival", "FINISH TASK")

	elseif self.data.TaskName == "Task 6 - 02" then
		self.cl.taskInterfaceHud = sm.gui.createGuiFromLayout("$GAME_DATA/Gui/Layouts/Interactable/Interactable_CookBot.layout", false, {isHud = false, isInteractive = true, needsCursor = true})
		self.cl.taskInterfaceHud:setButtonCallback("Revival","cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("Revival", "FINISH TASK")

	elseif self.data.TaskName == "Task 7 - 01" then
		self.cl.taskInterfaceHud = sm.gui.createWaterContainerGui()
		self.cl.taskInterfaceHud:setOnCloseCallback("cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("UpperName", "CLOSE TO FINISH TASK")

	elseif self.data.TaskName == "Task 8 - 01" then
		self.cl.taskInterfaceHud = sm.gui.createWorkbenchGui()
		self.cl.taskInterfaceHud:setOnCloseCallback("cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("Craft", "CLOSE TO FINISH TASK")

	elseif self.data.TaskName == "Task 9 - 01" then
		self.cl.taskInterfaceHud = sm.gui.createGasContainerGui()
		self.cl.taskInterfaceHud:setOnCloseCallback("cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("UpperName", "CLOSE TO FINISH TASK")

	elseif self.data.TaskName == "Task 10 - 01" then
		self.cl.taskInterfaceHud = sm.gui.createLogbookGui()
		self.cl.taskInterfaceHud:setButtonCallback("WaypointButton","cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("Description", "CLICK ON THE BUTTON SET WAYPOINT TO FINISH TASK")

	elseif self.data.TaskName == "Task 11 - 01" then
		self.cl.taskInterfaceHud = sm.gui.createBatteryContainerGui()
		self.cl.taskInterfaceHud:setOnCloseCallback("cl_onHudTaskButton")
		self.cl.taskInterfaceHud:setText("UpperName", "CLOSE TO FINISH TASK")

	else
		sm.log.error("[AMONG SCRAP] ERROR: task dosen't exist on client side (TaskInterface.lua - ln322)")
	end
end

function TaskInterface.client_onInteract( self , character , state )
	--sm.effect.createEffect("Fire - gradual", self.interactable):start()
	if state == true then
		self.cl.taskInterfaceHud:open()
		return true
	end
	return false
end

function TaskInterface.client_canInteract( self , character )
	local player = character:getPlayer()
	if player:getClientPublicData().impostor == nil then
		if self.cl.taskState == true then

			if self.cl.playerTasks == nil then
				sm.log.error("[AMONG SCRAP] ERROR : tasks aren't send or tasks table syntax error ! (TaskInterface.lua - ln341)")
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
					sm.gui.setInteractionText("", keyBindingText, "Open" )
					return true
				else
					sm.gui.setCenterIcon( "Use" )
					local keyBindingText = sm.gui.getKeyBinding( "", true )
					sm.gui.setInteractionText("<img spacing='0'>IconChallengeCompleted.png</img>","","Task already completed")
					return false
				end
			else
				sm.gui.setCenterIcon( "Use" )
				local keyBindingText = sm.gui.getKeyBinding( "", true )
				sm.gui.setInteractionText("<img spacing='0'>icon_mainquest_medium.png</img>","","you don't have this task !")
				return false
			end
		else
			sm.gui.setCenterIcon( "Use" )
			local keyBindingText = sm.gui.getKeyBinding( "", true )
			sm.gui.setInteractionText("<img spacing='0'>icon_mainquest_medium.png</img>","","you don't have task !")
			return false
		end
	end
	return false
end

function TaskInterface.client_onRefresh( self )
	--self.cl.g_taskInterfaceIcon:setImage("Icon", "BeaconIconMap1")
	--self:client_onCreate()
	--self.cl.g_taskInterfaceIcon:setItemIcon( "Icon", "BeaconIconMap", "BeaconIconMap", "11")
	--self.cl.taskInterfaceHud = sm.gui.createGuiFromLayout("$GAME_DATA/Gui/Layouts/Interactable/Interactable_CraftBot.layout", false, {isHud = false, isInteractive = true, needsCursor = true})
end

function TaskInterface.client_onDestroy( self )
	sm.event.sendToGame("cl_e_onTaskInterfaceDestroy", self.interactable)
end

-- CONTENT ---

function TaskInterface.cl_onHudTaskButton( self )
	local isFinish = self:cl_onTaskFinished()
	if isFinish == true then
		self.cl.taskInterfaceHud:close()
	end
end

function TaskInterface.cl_onTaskFinished( self )
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
			self.cl.g_taskInterfaceIcon:close()
			return true
		end
	end
	return false
end

function TaskInterface.cl_onResetTask( self )
	self.cl.playerTasks = nil
	self.cl.taskState = false

	self.cl.g_taskInterfaceIcon:close()
end



-- slave (receving) function --
function TaskInterface.cl_receiveTaskId( self , data )
	self.cl.taskId = data.taskId

end

function TaskInterface.cl_receiveTaskState( self , data )
	self.cl.taskState = data
end

function TaskInterface.cl_receiveTask( self , data )
	self.cl.playerTasks = data
	if data then
		local haveTheTask = false
		for i,v in ipairs(self.cl.playerTasks) do
			if self.cl.taskId == v.taskId then
				taskIndex = i
				haveTheTask = true
				break
			end
		end
		if haveTheTask == true then
			self.cl.g_taskInterfaceIcon:open()
		end
	end
end
