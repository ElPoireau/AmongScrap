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

    data = {
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

-- CONTENT -- 


-- CLIENT -- 

-- CONTENT --

-- CALLBACK --
