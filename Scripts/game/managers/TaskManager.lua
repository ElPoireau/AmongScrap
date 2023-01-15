-- TaskManager.lua --

--[[
--------------------------------------------------------------------------------
----------------------------------- TASK TABLE ---------------------------------
--------------------------------------------------------------------------------

{
taskId : str, The id of the task .(Should be like that : "[taskId]_[stateId]")
taskLabel : str, The text to be showed on task board.
isFinished : bool, Say if the task is finished by the player.
HasManyState : bool, Say if there are many step of this task to be finish.

parentTaskIndex : str of false, taskId of the parentTask - False if parent

childTaskInfo = {howManyFinished = n, howManyTasks = n*} info about his child tasks - Only in grandparent

grandParentTaskIndex = str, taskId of the grandparent - Only in childs
isParentNeedToBeFinish = bool, True if parent need to be finish before us - Only in childs
}
]]--

TaskManager = class( nil )

obj_interactive_task_interface_id_s_1_1 = sm.uuid.new( "0135d97f-13b4-4840-a901-2a9880fcc536" )
obj_interactive_task_interface_id_s_2_1 = sm.uuid.new( "394f0ec0-d35d-4f24-9b95-195f300d6159" )
obj_interactive_task_interface_id_s_3_1 = sm.uuid.new( "7f3f944a-a416-4157-808a-e5ce06a3b0ca" )
obj_interactive_task_interface_id_s_4_1 = sm.uuid.new( "0d6ce332-8a3c-4990-9b89-60652bbaeb1a" )
obj_interactive_task_interface_id_s_5_1 = sm.uuid.new( "9a5ad5d3-3d89-48f8-a557-b31b21884171" )
obj_interactive_task_interface_id_s_6_1 = sm.uuid.new( "3f6bdb04-f7cb-4acf-a436-95e1abf45e4b" )
obj_interactive_task_interface_id_s_7_1 = sm.uuid.new( "174163a9-9311-485e-b1e7-0031e988c04a" )
obj_interactive_task_interface_id_s_8_1 = sm.uuid.new( "899324f3-8764-45e0-a45b-0e0eba68b6f3" )

obj_interactive_task_interface_id_n_1_1 = sm.uuid.new( "77562545-1e95-47a5-9567-9c41dea12eaf" )
obj_interactive_task_interface_id_n_1_2 = sm.uuid.new( "c9f30707-12e6-4685-9f95-cde4afc7ac8b" )
obj_interactive_task_interface_id_n_2_1 = sm.uuid.new( "1286b2d5-e4a8-4e15-ac35-fd6143ee1cb2" )
obj_interactive_task_interface_id_n_2_2 = sm.uuid.new( "f9a9fb6c-59e1-4f36-b02e-418beffa1948" )

obj_interactive_task_interface_id_l_1_1 = sm.uuid.new( "7163188b-bca3-493c-8b49-5d0a60298d86" )
obj_interactive_task_interface_id_l_1_2 = sm.uuid.new( "4987c710-fce0-4607-8e73-f5efc9cea24d" )
obj_interactive_task_interface_id_l_1_3 = sm.uuid.new( "f22e50df-d566-4e56-9038-dd662a884609" )
obj_interactive_task_interface_id_l_1_4 = sm.uuid.new( "eac8a967-9e1a-4432-ac0b-ad1c16fae188" )

-- SERVER --
function TaskManager.sv_onCreate( self )

	self.sv = {}

	local shortTasksTable = sm.json.open("$CONTENT_DATA/Tasks/shorttaskset.json")
	self.sv.numOfShortTask_Table = 0
	for _ in pairs(shortTasksTable.shortTaskSet) do self.sv.numOfShortTask_Table = self.sv.numOfShortTask_Table + 1 end

	local normalTasksTable = sm.json.open("$CONTENT_DATA/Tasks/normaltaskset.json")
	self.sv.numOfNormalTask_Table = 0
	for _ in pairs(normalTasksTable.normalTaskSet) do self.sv.numOfNormalTask_Table = self.sv.numOfNormalTask_Table + 1 end

	local longTasksTable = sm.json.open("$CONTENT_DATA/Tasks/longtaskset.json")
	self.sv.numOfLongTask_Table = 0
	for _ in pairs(longTasksTable.longTaskSet) do self.sv.numOfLongTask_Table = self.sv.numOfLongTask_Table + 1 end

	self.sv.numOfShortTask_PerRound = 0
	self.sv.numOfNormalTask_PerRound = 0
	self.sv.numOfLongTask_PerRound = 0

	self.sv.howManyTaskPerPlayer = self.sv.numOfShortTask_PerRound + (self.sv.numOfNormalTask_PerRound * 2) + (self.sv.numOfLongTask_PerRound * 4) or 1

	self.sv.totalTask = 0
	self.sv.totalPlayer = 0
	self.sv.taskFinished = 0
	self.sv.hasGivenTaskToPlayer = false

	self.sv.taskInterfaceInteractables = {}

	self.sv.activeTask = {}
end

function TaskManager.sv_onRefresh( self )
	print("[AMONG SCRAP] TaskManager.server_onRefresh")
end

--- CONTENT ---

function TaskManager.sv_getTaskTable( self , data )
	if data == "Short task" then
		local shortTasksTable = sm.json.open("$CONTENT_DATA/Tasks/shorttaskset.json")
		local randomNumber = math.floor(sm.noise.randomRange(1, self.sv.numOfShortTask_Table+1))
		local task = shortTasksTable.shortTaskSet[randomNumber]
		return shallowcopy(task)

	elseif data == "Normal task" then
		local normalTasksTable = sm.json.open("$CONTENT_DATA/Tasks/normaltaskset.json")
		local randomNumber = math.floor(sm.noise.randomRange(1, self.sv.numOfNormalTask_Table+1))
		local task = normalTasksTable.normalTaskSet[randomNumber]
		return shallowcopy(task)

	elseif data == "Long task" then
		local longTasksTable = sm.json.open("$CONTENT_DATA/Tasks/longtaskset.json")
		local randomNumber = math.floor(sm.noise.randomRange(1,self.sv.numOfLongTask_Table+1))
		local task = longTasksTable.longTaskSet[randomNumber]
		return shallowcopy(task)
	end
end

function TaskManager.sv_onInitTask( self )
	local task = {}
	local isTaskRepeat = false

	local players = sm.player.getAllPlayers()

	for i1,v1 in ipairs(players) do

		self.sv.activeTask[i1] = {player = v1, tasks = {}}
		for n = 1,self.sv.numOfShortTask_PerRound do
			repeat
				isTaskRepeat = false
				task = self:sv_getTaskTable("Short task")
				for i,v in ipairs(self.sv.activeTask[i1].tasks) do
					if task[1].taskId == v.taskId then
						isTaskRepeat = true
					end
				end
			until isTaskRepeat == false

			for _,v in ipairs(task) do
				v.isFinished = false
				table.insert(self.sv.activeTask[i1].tasks, v)
			end
		end

		for n = 1,self.sv.numOfNormalTask_PerRound do
			repeat
				isTaskRepeat = false
				task = self:sv_getTaskTable("Normal task")
				for i,v in ipairs(self.sv.activeTask[i1].tasks) do
					if task[1].taskId == v.taskId then
						isTaskRepeat = true
					end
				end
			until isTaskRepeat == false

			for _,v in ipairs(task) do
				v.isFinished = false
				table.insert(self.sv.activeTask[i1].tasks, v)
			end
		end

		for n = 1,self.sv.numOfLongTask_PerRound do
			repeat
				isTaskRepeat = false
				task = self:sv_getTaskTable("Long task")
				for i,v in ipairs(self.sv.activeTask[i1].tasks) do
					if task[1].taskId == v.taskId then
						isTaskRepeat = true
					end
				end
			until isTaskRepeat == false

			for _,v in ipairs(task) do
				v.isFinished = false
				table.insert(self.sv.activeTask[i1].tasks, v)
			end
		end

		if v1:getPublicData().impostor then
			if v1:getPublicData().impostor == true then
				--self.sv.PlayerPlaying = i
				self.sv.activeTask[i1] = {player = v1, tasks = {}, impostor = true}
			else
				self.sv.totalTask = self.sv.totalTask + self.sv.howManyTaskPerPlayer
			end
		else
			--self.sv.PlayerPlaying = i
			self.sv.totalTask = self.sv.totalTask + self.sv.howManyTaskPerPlayer
		end
		--print(self.sv.activeTask)
	end

	local data = {allTasks = self.sv.activeTask, taskPerPlayer = self.sv.howManyTaskPerPlayer}

	sm.event.sendToGame("sv_e_onSendingTask", data)

	for i,v in ipairs(self.sv.taskInterfaceInteractables) do
		sm.event.sendToInteractable(v, "sv_receiveTaskState", true)

	end
	self.sv.hasGivenTaskToPlayer = true
	--print(data)
end

function TaskManager.sv_receiveTaskInterfaceInteractable( self , data )
	table.insert(self.sv.taskInterfaceInteractables, data)
	sm.event.sendToInteractable(data, "sv_receiveTaskState", self.sv.hasGivenTaskToPlayer)
end

function TaskManager.sv_onResetTask( self )
	self.sv.activeTask = {}

	self.sv.totalTask = 0
	self.sv.totalPlayer = 0
	self.sv.taskFinished = 0
	self.sv.hasGivenTaskToPlayer = false

	for i,v in ipairs(self.sv.taskInterfaceInteractables) do
		sm.event.sendToInteractable(v, "sv_receiveTaskState", false)
		sm.event.sendToInteractable(v, "sv_onResetTask", false)
	end
	sm.event.sendToGame("sv_e_onRefreshTaskProgressionBar", nil)
end

function TaskManager.sv_onTaskFinished( self , data )
	--print(self.sv.activeTask)
	local player = data.player

	local haveTheTask = false
	local playerIndex = nil
	local taskIndex = nil

	for i,v in ipairs(self.sv.activeTask) do
		if player == v.player then
			playerIndex = i
			break
		end
	end

	for i,v in ipairs(self.sv.activeTask[playerIndex].tasks) do
		if data.taskId == v.taskId then
			haveTheTask = true
			taskIndex = i
			break
		end
	end

	--[[print(data.taskId)
	print(playerIndex)
	print(taskIndex)
	print(self.sv.activeTask)
	print(self.sv.activeTask[playerIndex].tasks[taskIndex].isFinished)]]
	--print(self.sv.activeTask[playerIndex].tasks[taskIndex].isFinished)
	if haveTheTask == true then
		if self.sv.activeTask[playerIndex].tasks[taskIndex].isFinished == false then
			self.sv.activeTask[playerIndex].tasks[taskIndex].isFinished = true
			self.sv.taskFinished = self.sv.taskFinished + 1
			sm.event.sendToGame("sv_e_onRefreshTaskProgressionBar", {taskProgression = math.floor((self.sv.taskFinished / self.sv.totalTask)* 10)}) -- WARNING DIVIDE BY 0
		end
	end
	if self.sv.taskFinished == self.sv.totalTask then
		self:sv_onAllTasksFinished()
	end
end

function TaskManager.sv_onTaskInterfaceDestroy( self , data )
	local interfaceIndex
	for i,v in ipairs(self.sv.taskInterfaceInteractables) do
		if v == data then
			interfaceIndex = i
		end
	end
	table.remove(self.sv.taskInterfaceInteractables, interfaceIndex)
end

function TaskManager.sv_onAllTasksFinished( self )
	sm.event.sendToGame("sv_e_onAllTasksFinished")
end


function TaskManager.sv_setHowManyTasks(self , data )
	self.sv.numOfShortTask_PerRound = data.shortTasks
	self.sv.numOfNormalTask_PerRound = data.normalTasks
	self.sv.numOfLongTask_PerRound = data.longTasks
	self.sv.howManyTaskPerPlayer = self.sv.numOfShortTask_PerRound + (self.sv.numOfNormalTask_PerRound * 2) + (self.sv.numOfLongTask_PerRound * 4) or 1
end



-- CLIENT --
function TaskManager.cl_onCreate( self , id )
	self.cl = {}

	self.cl.howManyTaskPerPlayer = 0
	self.cl.finishedClientTask = 0
	self.cl.AllTaskFinished = false
	self.cl.haveTask = false

	self.cl.activeClientTask = {}
	self.cl.taskInterfaceInteractables = {}

	---sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Tasks/Gui_TaskTemplateCraftBot.layout",false, {isHud = false, isInteractive = true, needsCursor = true})
end



--CONTENT--

function TaskManager.cl_onTaskFinished( self , data )
	local haveTheTask = false
	local taskIndex = nil

	for i,v in ipairs(self.cl.activeClientTask.tasks) do
		if data.taskId == v.taskId then
			haveTheTask = true
			taskIndex = i
			break
		end
	end
	if haveTheTask then
		if self.cl.activeClientTask.tasks[taskIndex].isFinished == false then
			self.cl.activeClientTask.tasks[taskIndex].isFinished = true
			if self.cl.activeClientTask.tasks[taskIndex].hasManyState == true then
				if self.cl.activeClientTask.tasks[taskIndex].parentTaskIndex == taskIndex then
					local aShorterVar = self.cl.activeClientTask.tasks[self.cl.activeClientTask.tasks[taskIndex].parentTaskIndex].childTaskInfo.howManyFinished
					self.cl.activeClientTask.tasks[self.cl.activeClientTask.tasks[taskIndex].parentTaskIndex].childTaskInfo.howManyFinished = aShorterVar + 1
				else
					local aShorterVar = self.cl.activeClientTask.tasks[self.cl.activeClientTask.tasks[taskIndex].grandParentTaskIndex].childTaskInfo.howManyFinished
					self.cl.activeClientTask.tasks[self.cl.activeClientTask.tasks[taskIndex].grandParentTaskIndex].childTaskInfo.howManyFinished = aShorterVar + 1
				end
			end
			self.cl.finishedClientTask = self.cl.finishedClientTask + 1
			sm.event.sendToPlayer(sm.localPlayer.getPlayer(), "cl_refreshTaskText", self.cl.activeClientTask)
			if self.cl.finishedClientTask == self.cl.howManyTaskPerPlayer then
				return true
			end
		end
	end
	return false
end

function TaskManager.cl_onPlayerFinishAllTask( self )
	self.cl.allTaskFinished = true
	--sm.event.sendToGame("cl_e_taskFinished")
end

function TaskManager.cl_receiveTaskInterfaceInteractable( self , data )
	table.insert(self.cl.taskInterfaceInteractables, data)
	sm.event.sendToInteractable(data, "cl_receiveTask", self.cl.activeClientTask.tasks)
end

function TaskManager.cl_onSendingTask( self , data )
	self.cl.activeClientTask = data
	self.cl.howManyTaskPerPlayer = data.taskPerPlayer

	for iA,vA in ipairs(self.cl.activeClientTask.tasks) do
		if vA.hasManyState == true then
			if not vA.parentTaskIndex == false then
				for iB,vB in ipairs(self.cl.activeClientTask.tasks) do
					if vB.taskId == vA.parentTaskIndex then
						self.cl.activeClientTask.tasks[iA].parentTaskIndex = iB
						break
					end
				end
				for iB,vB in ipairs(self.cl.activeClientTask.tasks) do
					if vB.taskId == vA.grandParentTaskIndex then
						self.cl.activeClientTask.tasks[iA].grandParentTaskIndex = iB
						break
					end
				end
			elseif vA.parentTaskIndex == false then
				self.cl.activeClientTask.tasks[iA].parentTaskIndex = iA
			end
		end
	end
	self.cl.haveTask = true
	sm.event.sendToPlayer(sm.localPlayer.getPlayer(), "cl_refreshTaskText", self.cl.activeClientTask)

	for i,v in ipairs(self.cl.taskInterfaceInteractables) do
		sm.event.sendToInteractable(v, "cl_receiveTask", self.cl.activeClientTask.tasks)
	end
end

function TaskManager.cl_onResetTask( self )
	self.cl.activeClientTask = {}

	self.cl.finishedClientTask = 0
	self.cl.AllTaskFinished = false
	self.cl.haveTask = false

	sm.event.sendToPlayer(sm.localPlayer.getPlayer(), "cl_refreshTaskText", nil)
end

function TaskManager.cl_onTaskInterfaceDestroy( self , data )
	local interfaceIndex = nil 
	for i,v in ipairs(self.cl.taskInterfaceInteractables) do
		if v == data then
			interfaceIndex = i
		end
	end
	table.remove(self.cl.taskInterfaceInteractables, interfaceIndex)
end
