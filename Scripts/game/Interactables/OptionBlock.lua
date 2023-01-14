-- OptionBlock.lua --

--[[ Game Options table :
options = {

    pos[n] = {

        type = str
        onSetCall = SurvivalGame function
        varRef = options Index (str)  
    }

    howManyImpostor = int 
    
    howManyShortTasks = int
    howManyNormalTasks = int
    HowManyLongTasks = int 

    onWhichMap = str

}






]]





OptionBlock = class()

OptionBlock.maxParentCount = 0
OptionBlock.maxChildCount = 0
OptionBlock.connectionInput = sm.interactable.connectionType.none
OptionBlock.connectionOutput = sm.interactable.connectionType.none
OptionBlock.poseWeightCount = 1


--SERVER--

function OptionBlock.server_onCreate( self )
	print("[AMONG SCRAP] OptionBlock.server_onCreate")
end

function OptionBlock.server_onRefresh( self )
	print("[AMONG SCRAP] OptionBlock.server_onRefresh")
	--self:server_onCreate()
end

function OptionBlock.server_onDestroy( self )

end

-- CONTENT --

function OptionBlock.sv_setOptions( self , data )
    self.network:sendToClients("cl_setOptions", data)
end






--  CLIENT  --
function OptionBlock.client_onCreate( self )
    self.cl = {}

    self.cl.optionGui = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Options/Options_MainMenu.layout",false, {isHud = false, isInteractive = true, needsCursor = true, })
    self.cl.optionGui:setText("TextHeader", g_Language:cl_getTraduction("OPTION_HEADER"))
   
    self:cl_onInitPos1()
    self:cl_onInitPos2()

    self.cl.optionWorldText = sm.gui.createNameTagGui(false)
	self.cl.optionWorldText:setWorldPosition(self.shape:getWorldPosition())
	self.cl.optionWorldText:setText("Text", "OPTIONS")
    self.cl.optionWorldText:open()
end

function OptionBlock.client_onInteract( self , character , state )
    if state == true then
	    self.cl.optionGui:open()
    end
end

function OptionBlock.client_canInteract( self , character )
    sm.gui.setCenterIcon( "Use" )
    local keyBindingText = sm.gui.getKeyBinding( "Use", true )
    sm.gui.setInteractionText("", keyBindingText, "Open" )
    return true
end

function OptionBlock.client_onDestroy( self )
    self.cl.optionWorldText:close()
    self.cl.optionGui:close()
end

function OptionBlock.client_onRefresh( self )

end




-- CONTENT --

function OptionBlock.cl_setOptions( self , data ) 
    self.cl.options = data
end

-- GUI CALLBACK --

-- POS 1 --
function OptionBlock.cl_onInitPos1( self )
    self.cl.pos1ButtonState = false

    self.cl.optionGui:setButtonCallback("Pos1ButtonOn", "cl_onPos1ButtonOnCallback")
    self.cl.optionGui:setButtonCallback("Pos1ButtonOff", "cl_onPos1ButtonOffCallback")

    self.cl.optionGui:setButtonState("Pos1ButtonOn", false)
    self.cl.optionGui:setButtonState("Pos1ButtonOff", true)

    self.cl.optionGui:setText("Pos1Text", g_Language:cl_getTraduction("OPTION_POS_1"))
end

function OptionBlock.cl_onPos1ButtonOnCallback( self )
    if self.cl.pos1ButtonState == false then
        self.cl.optionGui:setButtonState("Pos1ButtonOn", true)
        self.cl.optionGui:setButtonState("Pos1ButtonOff", false)
        self.cl.pos1ButtonState = true
    end
end

function OptionBlock.cl_onPos1ButtonOffCallback( self )
    if self.cl.pos1ButtonState == true then
        self.cl.optionGui:setButtonState("Pos1ButtonOn", false)
        self.cl.optionGui:setButtonState("Pos1ButtonOff", true)
        self.cl.pos1ButtonState = false
    end
end

-- POS 2 --
function OptionBlock.cl_onInitPos2( self )
    self.cl.pos2SliderValue = 0

    self.cl.optionGui:createHorizontalSlider( "Pos2Slider", 10, self.cl.pos2SliderValue, "cl_onPos2SliderCallback" )

    self.cl.optionGui:setText("Pos2Text", g_Language:cl_getTraduction("OPTION_POS_2"))
    self.cl.optionGui:setText("Pos2SliderValue", tostring( self.cl.pos2SliderValue))
end

function OptionBlock.cl_onPos2SliderCallback( self , value )
    self.cl.pos2SliderValue = value
    self.cl.optionGui:setText("Pos2SliderValue", tostring( self.cl.pos2SliderValue))
end

-- POS 3 --
function OptionBlock.cl_onInitPos3( self )
    self.cl.optionGui:setText("Pos3Text", g_Language:cl_getTraduction("OPTION_POS_3"))
end