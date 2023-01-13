dofile("$CONTENT_DATA/Scripts/game/Interactables/BaseTaskInterface.lua")

TemplateTaskInterface = class(BaseTaskInterface)

--[[
BaseTaskInterface Table: {
    shape = {
        <Shape>, 
        id = id
    }, 

    taskState = bool,
    storage = {
        <Storage>, 
        id = id
    }, 

    data = {SS
        TaskName = str
    }, 

    network = {
        <Network>, 
        id = id
    }, 
   
    cl = {
        TaskInterfaceGui = {
            <GuiInterface>,
             id = id 
            }, 
        taskState = bool, 
        playerTasks = table, 
        taskId = str, 
        TaskInterfaceIcon = {
            <GuiInterface>, 
            id = id
            }
        }
    }, 
   
    interactable = {
        <Interactable>,
        id = id
    }, 
    
    sv = {
        taskId = str,
        taskState = bool
    }
}
]]

-- SERVER --

-- function TemplateTaskInterface.server_onCreate( self ) BaseTaskInterface.server_onCreate(self) end

-- function TemplateTaskInterface.server_onRefresh( self ) BaseTaskInterface.server_onRefresh(self) end

-- function TemplateTaskInterface.server_onDestroy( self ) BaseTaskInterface.server_onDestroy(self) end



-- CONTENT -- 
-- function TemplateTaskInterface.sv_onResetTask( self , data ) BaseTaskInterface.sv_onResetTask(self, data) end

-- slave 
-- function TemplateTaskInterface.sv_receiveTaskState( self , data ) BaseTaskInterface.sv_receiveTaskState(self, data) end







-- CLIENT -- 
-- function TemplateTaskInterface.client_onCreate( self ) BaseTaskInterface.client_onCreate(self) end

-- function TemplateTaskInterface.client_onRefresh( self ) BaseTaskInterface.client_onRefresh(self) end

-- function TemplateTaskInterface.client_onInteract( self , character , state ) BaseTaskInterface.client_onInteract(self, character, state) end

-- function TemplateTaskInterface.client_canInteract( self , character ) BaseTaskInterface.client_canInteract(self, character) end

-- function TemplateTaskInterface.client_onDestroy( self ) BaseTaskInterface.client_onDestroy(self) end



-- CONTENT --
-- function TemplateTaskInterface.cl_onTaskFinished( self ) BaseTaskInterface.cl_onTaskFinished(self) end

-- function TemplateTaskInterface.cl_onResetTask( self ) BaseTaskInterface.cl_onResetTask(self) end


-- slave
-- function TemplateTaskInterface.cl_receiveTaskId( self , data ) BaseTaskInterface.cl_receiveTaskId(self, data) end

-- function TemplateTaskInterface.cl_receiveTaskState( self , data ) BaseTaskInterface.cl_receiveTaskState(self, data) end

-- function TemplateTaskInterface.cl_receiveTask( self , data ) BaseTaskInterface.cl_receiveTask(self, data) end 



-- GUI CALLBACK --
-- function TemplateTaskInterface.cl_onHudTaskButton( self ) BaseTaskInterface.cl_onHudTaskButton(self) end
