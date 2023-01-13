-- Language.lua --
--ElPoireau 2023 

local clientCurrentLanguage = sm.gui.getCurrentLanguage()
local traductionTable = {}

function cl_loadLanguage()
    traductionTable = sm.json.open("$CONTENT_DATA/Gui/Language/".. clientCurrentLanguage .."/AmongScrapGuiText.json")
end

function cl_getTraduction( tag )
    return traductionTable[tag]
end