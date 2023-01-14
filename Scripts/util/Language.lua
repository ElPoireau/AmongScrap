-- Language.lua --
--ElPoireau 2023 

Language = class()

function Language.cl_loadLanguage( self )
    self.clientCurrentLanguage = sm.gui.getCurrentLanguage()

    if sm.json.fileExists("$CONTENT_DATA/Gui/Language/".. self.clientCurrentLanguage .."/AmongScrapGuiText.jsonc") then 
        self.traductionTable = sm.json.open("$CONTENT_DATA/Gui/Language/".. self.clientCurrentLanguage .."/AmongScrapGuiText.jsonc")
    else
        self.traductionTable = sm.json.open("$CONTENT_DATA/Gui/Language/English/AmongScrapGuiText.jsonc")
    end
end

function Language.cl_getTraduction( self , tag )
    return self.traductionTable.languageTable[tag] or "[AMONG SCRAP] LANGUAGE ERROR"
end