-- OptionBlock.lua --

OptionBlock = class()


OptionBlock.maxParentCount = 0
OptionBlock.maxChildCount = 0
OptionBlock.connectionInput = sm.interactable.connectionType.none
OptionBlock.connectionOutput = sm.interactable.connectionType.none
OptionBlock.poseWeightCount = 1

local POS_INDEX = 4

--SERVER--

function OptionBlock.server_onCreate( self )
	print("[AMONG SCRAP] OptionBlock.server_onCreate")
    self.sv = {}
    self.sv.optionsMenu = nil 

    sm.event.sendToGame("sv_onInitOptionBlock", self.interactable)
end

function OptionBlock.server_onRefresh( self )
	print("[AMONG SCRAP] OptionBlock.server_onRefresh")
	--self:server_onCreate()
end

function OptionBlock.server_onDestroy( self )
    sm.event.sendToGame("sv_onDestroyOptionBlock", self.interactable)
end



-- CONTENT --
function OptionBlock.sv_setOptionsMenu( self , data )
    self.sv.optionsMenu = data
    self.network:sendToClients("cl_setOptionsMenu", data)
end

function OptionBlock.sv_setGameOptions( self , data )
    self.sv.optionsMenu = data
    sm.event.sendToGame("sv_e_setGameOptions", data )
end

function OptionBlock.sv_onNewClient( self , data )
    self.network:sendToClient(data, "cl_setOptionsMenu", self.sv.optionsMenu)
end








--  CLIENT  --
function OptionBlock.client_onCreate( self )
    self.cl = {}
    self.cl.optionsMenu = {}
    self.cl.hasInit = false
    self.cl.hasFirstInit = false
    self.cl.isOpen = false
    self.cl.pageMenu = 1

    self.cl.optionWorldText = sm.gui.createNameTagGui(false)
	self.cl.optionWorldText:setWorldPosition(self.shape:getWorldPosition())
	self.cl.optionWorldText:setText("Text", "OPTIONS")
    self.cl.optionWorldText:open()
    
   self.cl.tempGui = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Options/Options_MainMenu.layout",false, {isHud = true})
   self.cl.tempGui:setText("TextHeader", g_Language:cl_getTraduction("OPTION_HEADER"))
   self.cl.tempGui:setText("TextPage", g_Language:cl_getTraduction("UNIT_PAGE") .. " ".. self.cl.pageMenu)


    self.network:sendToServer("sv_onNewClient", sm.localPlayer.getPlayer())
end


function OptionBlock.client_onInteract( self , character , state )
    if state == true then
	    self.cl.optionGui:open()

        self.cl.isOpen = true
    end
end

function OptionBlock.client_canInteract( self , character )
    if self.cl.optionGui:isActive() == false then
        sm.gui.setCenterIcon( "Use" )
        local keyBindingText = sm.gui.getKeyBinding( "Use", true )
        sm.gui.setInteractionText("", keyBindingText, "Open" )
        return true
    end        
    return false
end

function OptionBlock.client_onDestroy( self )
    self.cl.optionWorldText:close()
    self.cl.optionGui:close()
end

function OptionBlock.client_onRefresh( self )
    
end




-- CONTENT --

function OptionBlock.cl_initGui( self )
    self.cl.tempGui:setText("TextPage", g_Language:cl_getTraduction("UNIT_PAGE") .. " ".. self.cl.pageMenu)
    if self.cl.optionGui then
        self.cl.isOpen = self.cl.optionGui:isActive()
        self.cl.tempGui:open()
        self.cl.optionGui:close()
        self.cl.optionGui:destroy()
    end

    self.cl.optionGui = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Options/Options_MainMenu.layout",false, {isHud = false, isInteractive = true, needsCursor = true, })

    if self.cl.isOpen == true then
        self.cl.optionGui:open()
        self.cl.tempGui:open()
    end

    cl_initSliderFunction(self.cl.optionsMenu)
    self.cl.optionGui:setOnCloseCallback("cl_onCloseOptionGuiCallback")
    
    self.cl.optionGui:setText("TextHeader", g_Language:cl_getTraduction("OPTION_HEADER"))
    self.cl.optionGui:setText("TextPage", g_Language:cl_getTraduction("UNIT_PAGE") .. " ".. self.cl.pageMenu)
    self.cl.optionGui:setButtonCallback("MinusPage", "cl_onMinusPageCallback")
    self.cl.optionGui:setButtonCallback("PlusPage", "cl_onPlusPageCallback")
    
    for i1 = 1,11 do
        local i2 = i1 + ((11 * self.cl.pageMenu) - 11) 
        v = self.cl.optionsMenu[i2] 

        if v then 
            if v.type ~= "Empty" then 
                self["cl_onInit" .. v.type](self, i1, v)
            end
            
        elseif not v then
            break
        end
    end
    self.cl.hasInit = true
    if self.cl.hasFirstInit == false then
        self.cl.hasFirstInit = true
    end
end

function OptionBlock.cl_resetGui( self )
    for index = 1,11 do

        self.cl.optionGui:setVisible("Pos" .. index .. "ButtonOnOff", false)
        self.cl.optionGui:setVisible("Pos" .. index .. "ButtonMultiple2", false)
        self.cl.optionGui:setVisible("Pos" .. index .. "ButtonMultiple3", false)
        self.cl.optionGui:setVisible("Pos" .. index .. "Label", false)
        self.cl.optionGui:setVisible("Pos" .. index .. "Slider", false)
    end
end

function OptionBlock.cl_refreshGui( self )
    for i1 = 1,11 do
        local i2 = i1 + ((11 * self.cl.pageMenu) - 11) 
        v = self.cl.optionsMenu[i2]

        if v then 
            if v.type ~= "Empty" then 
                self["cl_onRefresh" .. v.type](self, i1, v)
            end
        elseif not v then
            break
        end
    end
end


function OptionBlock.cl_onChangePage(self , increment )
    self.cl.hasInit = false
    self.cl.pageMenu = self.cl.pageMenu + increment
    self:cl_resetGui()
    self:cl_initGui()
end

function OptionBlock.cl_setOptionsMenu( self , data ) 
    self.cl.optionsMenu = data
    if data then
        if self.cl.hasInit == false then
            self:cl_initGui()
        elseif self.cl.hasInit == true then 
            self:cl_refreshGui()
        end
    end
end

function OptionBlock.cl_setGameOptions( self )
    self.network:sendToServer("sv_setGameOptions", self.cl.optionsMenu )
end


-- GUI CALLBACK --



-- General -- 

function OptionBlock.cl_onPlusPageCallback( self )
    if self.cl.pageMenu * 11 < #self.cl.optionsMenu then 
        self:cl_onChangePage(1)
    end
end

function OptionBlock.cl_onMinusPageCallback( self )
    if self.cl.pageMenu > 1 then 
        self:cl_onChangePage(-1)
    end
end

function OptionBlock.cl_onCloseOptionGuiCallback( self )
    if self.cl.hasInit == true then
        self.cl.tempGui:close()
        self.cl.isOpen = false
    else 
        self.cl.tempGui:open()
        self.cl.isOpen = true
    end
end



-- OnOffButton --

function OptionBlock.cl_onInitOnOffButton( self , index , data )
    local menuIndex = index + ((11 * self.cl.pageMenu) - 11) 

    self.cl.optionGui:setVisible("Pos" .. index .. "ButtonOnOff", true)
    
    self.cl.optionGui:setButtonCallback("Pos" .. index .. "ButtonOn", "cl_onButtonOnCallback")
    self.cl.optionGui:setButtonCallback("Pos" .. index .. "ButtonOff", "cl_onButtonOffCallback")
    
    self.cl.optionGui:setText("Pos" .. index .. "Text", g_Language:cl_getTraduction(data.textTag ))
    
    if self.cl.optionsMenu[menuIndex].value == false then
        self.cl.optionGui:setButtonState("Pos" .. index .. "ButtonOn", false)
        self.cl.optionGui:setButtonState("Pos" .. index .. "ButtonOff", true)
        
    elseif self.cl.optionsMenu[menuIndex].value == true then
        self.cl.optionGui:setButtonState("Pos" .. index .. "ButtonOn", true)
        self.cl.optionGui:setButtonState("Pos" .. index .. "ButtonOff", false)
        
    else
        self.cl.optionsMenu[menuIndex].value = false 
        self.cl.optionGui:setButtonState("Pos" .. index .. "ButtonOn", false)
        self.cl.optionGui:setButtonState("Pos" .. index .. "ButtonOff", true)
    end
end

function OptionBlock.cl_onRefreshOnOffButton( self , index , data )
    self.cl.optionGui:setButtonState("Pos" .. index .. "ButtonOn", data.value == true)
    self.cl.optionGui:setButtonState("Pos" .. index .. "ButtonOff", data.value == false) 
end



function OptionBlock.cl_onButtonOnCallback( self , tag )
    local posIndex = tonumber(tag:sub(POS_INDEX, POS_INDEX))
    local menuIndex = posIndex + ((11 * self.cl.pageMenu) - 11) 

    if self.cl.optionsMenu[menuIndex].value == false then
        self.cl.optionGui:setButtonState("Pos" .. posIndex .. "ButtonOn", true)
        self.cl.optionGui:setButtonState("Pos" .. posIndex .. "ButtonOff", false)
        self.cl.optionsMenu[menuIndex].value = true
    end
   self:cl_setGameOptions()
end

function OptionBlock.cl_onButtonOffCallback( self , tag )
    local posIndex = tonumber(tag:sub(POS_INDEX, POS_INDEX))
    local menuIndex = posIndex + ((11 * self.cl.pageMenu) - 11) 

    if self.cl.optionsMenu[menuIndex].value == true then
        self.cl.optionGui:setButtonState("Pos" .. posIndex .. "ButtonOn", false)
        self.cl.optionGui:setButtonState("Pos" .. posIndex .. "ButtonOff", true)
        self.cl.optionsMenu[menuIndex].value = false
    end
    self:cl_setGameOptions()
end






-- Button Multiple --

function OptionBlock.cl_onInitMultiple1Button( self , index , data )
    local menuIndex = index + ((11 * self.cl.pageMenu) - 11) 

    self.cl.optionGui:setVisible("Pos" .. index .. "ButtonMultiple2", true)
    self.cl.optionGui:setVisible("Pos" .. index .. "Button2", false)
    
    self.cl.optionGui:setButtonCallback("Pos" .. index .. "Button1", "cl_onButton1Callback")
    
    self.cl.optionGui:setText("Pos" .. index .. "Text", g_Language:cl_getTraduction(data.textTag[1] ))
    self.cl.optionGui:setText("Pos" .. index .. "Button1", g_Language:cl_getTraduction(data.textTag[2] ))

    if data.value == 0 then
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", false)
   
    elseif data.value == 1 then
       self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", true)

    else
        self.cl.optionsMenu[menuIndex].value = 0 
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", false)
    end
end


function OptionBlock.cl_onInitMultiple2Button( self , index , data )
    local menuIndex = index + ((11 * self.cl.pageMenu) - 11) 

    self.cl.optionGui:setVisible("Pos" .. index .. "ButtonMultiple2", true)
    
    self.cl.optionGui:setButtonCallback("Pos" .. index .. "Button1", "cl_onButton1Callback")
    self.cl.optionGui:setButtonCallback("Pos" .. index .. "Button2", "cl_onButton2Callback")

    self.cl.optionGui:setText("Pos" .. index .. "Text", g_Language:cl_getTraduction(data.textTag[1] ))
    self.cl.optionGui:setText("Pos" .. index .. "Button1", g_Language:cl_getTraduction(data.textTag[2] ))
    self.cl.optionGui:setText("Pos" .. index .. "Button2", g_Language:cl_getTraduction(data.textTag[3] ))

    if data.value == 1 then
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", true)
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button2", false)

    elseif data.value == 2 then
       self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", false)
       self.cl.optionGui:setButtonState("Pos" .. index .. "Button2", true)

    else
        self.cl.optionsMenu[menuIndex].value = 1
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", true)
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button2", false)
    end
end

function OptionBlock.cl_onInitMultiple3Button( self , index , data )
    
    self.cl.optionGui:setVisible("Pos" .. index .. "ButtonMultiple3", true)
    
    self.cl.optionGui:setButtonCallback("Pos" .. index .. "Button1", "cl_onButton1Callback")
    self.cl.optionGui:setButtonCallback("Pos" .. index .. "Button2", "cl_onButton2Callback")
    self.cl.optionGui:setButtonCallback("Pos" .. index .. "Button3", "cl_onButton3Callback")

    self.cl.optionGui:setText("Pos" .. index .. "Text", g_Language:cl_getTraduction(data.textTag[1] ))
    self.cl.optionGui:setText("Pos" .. index .. "Button1", g_Language:cl_getTraduction(data.textTag[2] ))
    self.cl.optionGui:setText("Pos" .. index .. "Button2", g_Language:cl_getTraduction(data.textTag[3] ))
    self.cl.optionGui:setText("Pos" .. index .. "Button3", g_Language:cl_getTraduction(data.textTag[4] ))

    if self.cl.optionsMenu[index].value == 1 then
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", true)
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button2", false)
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button3", false)

    elseif self.cl.optionsMenu[index].value == 2 then
       self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", false)
       self.cl.optionGui:setButtonState("Pos" .. index .. "Button2", true)
       self.cl.optionGui:setButtonState("Pos" .. index .. "Button3", false)

    elseif self.cl.optionsMenu[index].value == 3 then
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", false)
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button2", false)
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button3", true)

    else
        self.cl.optionsMenu[index].value = 0
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", false)
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button2", false)
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button2", false)
    end
end


function OptionBlock.cl_onRefreshMultiple1Button( self , index , data )

    if self.cl.optionsMenu[index].value == 1 then
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", true)
    elseif self.cl.optionsMenu[index].value == 0  then
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", false)
    end
end

function OptionBlock.cl_onRefreshMultiple2Button( self , index , data )
    local menuIndex = index + ((11 * self.cl.pageMenu) - 11) 

    self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", false)
    self.cl.optionGui:setButtonState("Pos" .. index .. "Button2", false)
    
    if self.cl.optionsMenu[menuIndex].value == 1 then
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", true)
    elseif self.cl.optionsMenu[menuIndex].value == 2  then
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button2", true)
    end
end

function OptionBlock.cl_onRefreshMultiple3Button( self , index , data )
    local menuIndex = index + ((11 * self.cl.pageMenu) - 11) 

    self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", false)
    self.cl.optionGui:setButtonState("Pos" .. index .. "Button2", false)
    self.cl.optionGui:setButtonState("Pos" .. index .. "Button3", false)

    if self.cl.optionsMenu[menuIndex].value == 1 then
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button1", true)
    elseif self.cl.optionsMenu[menuIndex].value == 2  then
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button2", true)
    elseif self.cl.optionsMenu[menuIndex].value == 3  then
        self.cl.optionGui:setButtonState("Pos" .. index .. "Button3", true)
    end
end




function OptionBlock.cl_onButton1Callback( self , tag )
    local posIndex = tonumber(tag:sub(POS_INDEX, POS_INDEX))
    local menuIndex = posIndex + ((11 * self.cl.pageMenu) - 11) 

    if self.cl.optionsMenu[menuIndex].value == 1 then
        if self.cl.optionsMenu[menuIndex].type == "Multiple1Button" then
            self.cl.optionGui:setButtonState("Pos" .. posIndex .. "Button1", false)
            self.cl.optionsMenu[menuIndex].value = 0
        end
    elseif self.cl.optionsMenu[menuIndex].value ~= 1 then
        self.cl.optionGui:setButtonState("Pos" .. posIndex .. "Button1", true)    
        self.cl.optionsMenu[menuIndex].value = 1
    end
    self.cl.optionGui:setButtonState("Pos" .. posIndex .. "Button2", false)
    self.cl.optionGui:setButtonState("Pos" .. posIndex .. "Button3", false)
    self:cl_setGameOptions()
end

function OptionBlock.cl_onButton2Callback( self , tag )
    local posIndex = tonumber(tag:sub(POS_INDEX, POS_INDEX))
    local menuIndex = posIndex + ((11 * self.cl.pageMenu) - 11) 

    if self.cl.optionsMenu[menuIndex].value ~= 2 then
        self.cl.optionGui:setButtonState("Pos" .. posIndex .. "Button2", true)    
        self.cl.optionsMenu[menuIndex].value = 2
    end
    self.cl.optionGui:setButtonState("Pos" .. posIndex .. "Button1", false)
    self.cl.optionGui:setButtonState("Pos" .. posIndex .. "Button2", false)
    self:cl_setGameOptions()
end

function OptionBlock.cl_onButton3Callback( self , tag )
    local posIndex = tonumber(tag:sub(POS_INDEX, POS_INDEX))
    local menuIndex = posIndex + ((11 * self.cl.pageMenu) - 11) 

    if self.cl.optionsMenu[menuIndex].value ~= 3 then
        self.cl.optionGui:setButtonState("Pos" .. posIndex .. "Button3", true)    
        self.cl.optionsMenu[menuIndex].value = 3
    end
    self.cl.optionGui:setButtonState("Pos" .. posIndex .. "Button1", false)
    self.cl.optionGui:setButtonState("Pos" .. posIndex .. "Button2", false)
    self:cl_setGameOptions()
end






-- Slider --

function OptionBlock.cl_onInitSlider( self , index , data )
    local unit = g_Language:cl_getTraduction(data.unit) or ""
    self.cl.optionGui:setVisible("Pos" .. index .. "Slider", true)

    self.cl.optionGui:createHorizontalSlider( "Pos" .. index .. "Scroll", data.maxValue + 1, data.value, "cl_onPos" .. index .. "SliderCallback" )

    self.cl.optionGui:setText("Pos" .. index .. "Text", g_Language:cl_getTraduction(data.textTag ))
    self.cl.optionGui:setText("Pos" .. index .. "SliderValue", tostring(data.value / (data.divider or 1)) .. " " .. unit)
end

function OptionBlock.cl_onRefreshSlider( self , index , data )
    local unit = g_Language:cl_getTraduction(data.unit) or ""
    self.cl.optionGui:setText("Pos" .. index .. "SliderValue", tostring(data.value / (data.divider or 1)) .. " " .. unit)
    self.cl.optionGui:setSliderPosition("Pos" .. index .. "Scroll", data.value)
end



function cl_initSliderFunction( data ) -- I am raging to to this instead of just PUTTING THE INDEX IN THE ARGS WHY DEEEEVVVSSSS :(
    for i = 1, 11 do
        OptionBlock["cl_onPos" .. i .. "SliderCallback"] = function( self , value , tag )
            local posIndex = i
            local menuIndex = posIndex + ((11 * self.cl.pageMenu) - 11) 
            local unit = g_Language:cl_getTraduction(self.cl.optionsMenu[menuIndex].unit) or ""
            self.cl.optionsMenu[menuIndex].value = value
            self.cl.optionGui:setText("Pos" .. posIndex .. "SliderValue", tostring(self.cl.optionsMenu[menuIndex].value / (data.divider or 1)) .. " " .. unit)
            self:cl_setGameOptions()
        end
    end
end




-- Label --

function OptionBlock.cl_onInitLabel( self , index , data )
    self.cl.optionGui:setVisible("Pos" .. index .. "Label", true)

    self.cl.optionGui:setText("Pos".. index .. "Text", g_Language:cl_getTraduction(data.textTag ))
end

function OptionBlock.cl_onRefreshLabel( self , index , data ) end