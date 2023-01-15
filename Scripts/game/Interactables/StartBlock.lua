-- StartBlock.lua --
-- Elpoireau 2023

StartBlock = class()


StartBlock.maxParentCount = 0
StartBlock.maxChildCount = 0
StartBlock.connectionInput = sm.interactable.connectionType.none
StartBlock.connectionOutput = sm.interactable.connectionType.none
StartBlock.poseWeightCount = 1

-- SERVER --
function StartBlock.server_onCreate( self )
	print("[AMONG SCRAP] StartBlock.server_onCreate")
end

function StartBlock.server_onDestroy( self )

end

function StartBlock.server_onRefresh( self )

end

-- content -- 

function StartBlock.sv_onStart( self )
    sm.event.sendToGame("sv_onStart")
end








-- CLIENT --
function StartBlock.client_onCreate( self )
    self.cl = {}

    self.cl.startWorldText = sm.gui.createNameTagGui(false)
	self.cl.startWorldText:setWorldPosition(self.shape:getWorldPosition())
	self.cl.startWorldText:setText("Text", "START")
    self.cl.startWorldText:open()

    self.cl.startPopUp = sm.gui.createGuiFromLayout("$GAME_DATA/Gui/Layouts/PopUp/PopUp_YNC_NoTitle.layout",false, {isHud = false, isInteractive = true, needsCursor = true, })
    self.cl.startPopUp:setText("Title", "Start the game ?")
    self.cl.startPopUp:setText("Message", "Do you want to start the game ?")
    self.cl.startPopUp:setButtonCallback("Yes", "cl_onYesCallback")
    self.cl.startPopUp:setButtonCallback("No", "cl_onNoCallback")
    self.cl.startPopUp:setButtonCallback("Cancel", "cl_onCancelCallback")
    self.cl.startPopUp:setOnCloseCallback("cl_onCloseStartPopUp")
end

function StartBlock.client_onDestroy( self )
    self.cl.startWorldText:close()
    self.cl.startPopUp:close()
end 

function StartBlock.client_onRefresh( self )
    
end

function StartBlock.client_onInteract( self , character , state )
   if state == true then
    self.cl.startPopUp:open()
   end
end    

function StartBlock.client_canInteract( self , character )
    sm.gui.setCenterIcon( "Use" )
    local keyBindingText = sm.gui.getKeyBinding( "Use", true )
    sm.gui.setInteractionText("", keyBindingText, "Start the game" )
    return true
end

-- content --

function StartBlock.cl_onYesCallback( self )
    self.network:sendToServer("sv_onStart")
    self:cl_onCloseStartPopUp()
end

function StartBlock.cl_onNoCallback( self )
    self:cl_onCloseStartPopUp()
end

function StartBlock.cl_onCancelCallback( self )
    self:cl_onCloseStartPopUp()
end

function StartBlock.cl_onCloseStartPopUp( self )
    self.cl.startPopUp:close()
end