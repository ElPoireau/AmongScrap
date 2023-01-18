-- MeetingBlock.lua --
-- ElPoireau 2023 

MeetingBlock= class()

MeetingBlock.maxParentCount = 0
MeetingBlock.maxChildCount = 0
MeetingBlock.connectionInput = sm.interactable.connectionType.none
MeetingBlock.connectionOutput = sm.interactable.connectionType.none
MeetingBlock.poseWeightCount = 1



-- SERVER -- 

function MeetingBlock.server_onCreate( self )
    print("[AMONG SCRAP] MeetingBlock.server_onCreate")
    self.sv = {}
    self.sv.isRoundStarted = false
    sm.event.sendToGame("sv_onInitMeetingBlock", self.interactable)
end

function MeetingBlock.server_onDestroy( self )
    sm.event.sendToGame("sv_onResetMeetingBlock", self.interactable)
end

function MeetingBlock.server_onRefresh( self )
	print("[AMONG SCRAP] MeetingBlock.server_onRefresh")
end

-- content -- 
function MeetingBlock.sv_onInitMeetingBlock( self , data )
    if data == true then
        self.network:sendToClients("cl_onInitMeeting")
    end
end

function MeetingBlock.sv_setMeetingCooldown( self , data )
    if self.sv.isRoundStarted == true then
        self.network:sendToClients("cl_setMeetingCooldown", data)
    end
end

function MeetingBlock.sv_onInitMeeting( self )
    self.sv.isRoundStarted = true
    self.network:sendToClients("cl_onInitMeeting")
end

function MeetingBlock.sv_onResetMeeting( self )
    self.sv.isRoundStarted = false
    self.network:sendToClients("cl_onResetMeeting")
end

function MeetingBlock.sv_setMeetingCooldownTime( self , data )
    self.network:sendToClients("cl_setMeetingCooldownTime", data)
end

function MeetingBlock.sv_onEmergencyMeeting( self , data )
    sm.event.sendToGame("sv_e_onEmergencyMetting", data)
end













-- CLIENT -- 

function MeetingBlock.client_onCreate( self )
    self.cl = {}
    self.meetingCooldown = false
    self.meetingCooldownTime = 10

    self.cl.isRoundStarted = false

    self.cl.betterTimer = BetterTimer()
    self.cl.betterTimer:onCreate()

    self.cl.meetingPopUp = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/PopUp/PopUp_MeetingBlock.layout",false, {isHud = false, isInteractive = true, needsCursor = true, })
    self.cl.meetingPopUp:setButtonCallback("CallOff", "cl_onCallOffCallback")
    self.cl.meetingPopUp:setButtonCallback("CallOn", "cl_onCallOnCallback")
    self.cl.meetingPopUp:setButtonCallback("Cancel", "cl_onCancelCallback")  

    self.cl.meetingPopUp:setVisible("CallOff", false)
    self.cl.meetingPopUp:setVisible("CallOn", true )
end

function MeetingBlock.client_onDestroy( self )
    self.cl.meetingPopUp:close()
end 

function MeetingBlock.client_onFixedUpdate( self )
    self.cl.betterTimer:onFixedUpdate()
    if self.cl.meetingCooldown == true then
        self.cl.meetingPopUp:setText( "Time", tostring( math.floor( ( self.meetingCooldownTime * 40 - self.cl.betterTimer:getCurrentTickByTag("meetingCooldown") ) / 40 )) .. " " .. g_Language:cl_getTraduction("UNIT_SECOND"))
    end

end

function MeetingBlock.client_onRefresh( self ) 

end
    
function MeetingBlock.client_onInteract( self , character , state )
    if state == true then
	    self.cl.meetingPopUp:open()
    end
end

function MeetingBlock.client_canInteract( self , character )
    sm.gui.setCenterIcon( "Use" )
    local keyBindingText = sm.gui.getKeyBinding( "Use", true )
    sm.gui.setInteractionText("", keyBindingText, "Open" )
    return true
end


-- content -- 

function MeetingBlock.cl_onInitMeeting( self )
    self.cl.isRoundStarted = true
    self:cl_setMeetingCooldown({state = true})
end

function MeetingBlock.cl_onResetMeeting( self )
    self.cl.isRoundStarted = false
    self:cl_setMeetingCooldown({state = false})
end

function MeetingBlock.cl_setMeetingCooldownTime( self , data )
    self.meetingCooldownTime = data 
end

function MeetingBlock.cl_setMeetingCooldown( self , data )
    if data.state == true then
        if self.cl.isRoundStarted == true then
            self.cl.meetingCooldown = true
            self.cl.betterTimer:createNewTimer(self.meetingCooldownTime * 40, self, MeetingBlock.cl_setMeetingCooldown, {state = false}, "meetingCooldown")
            self.cl.meetingPopUp:setVisible("CallOff", true)
            self.cl.meetingPopUp:setVisible("CallOn", false)
            
            self.cl.meetingPopUp:setVisible("Message", true)
            self.cl.meetingPopUp:setVisible("Time", true)
        end
        
    elseif data.state == false then
        self.cl.meetingCooldown = false
        self.cl.meetingPopUp:setVisible("CallOff", false)
        self.cl.meetingPopUp:setVisible("CallOn", true)
        
        self.cl.meetingPopUp:setVisible("Message", false)
        self.cl.meetingPopUp:setVisible("Time", false)
        self.cl.meetingPopUp:setText("Time", "")
    end
end




-- callback -- 

function MeetingBlock.cl_onCallOffCallback( self )
    sm.event.sendToWorld(sm.localPlayer.getPlayer().character:getWorld(), "cl_playEffect", {effect = "Gui - UnboxItem", type = "effect" })
end

function MeetingBlock.cl_onCallOnCallback( self )
    self.network:sendToServer("sv_onEmergencyMeeting", {player = sm.localPlayer.getPlayer()})
    self.cl.meetingPopUp:close()
end

function MeetingBlock.cl_onCancelCallback( self )
    self.cl.meetingPopUp:close()
end