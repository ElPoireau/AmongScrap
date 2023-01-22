-- Options.lua --
-- ElPoireau 2023

-- some useful func for Among Scrap settings files

function loadAmongScrapSettingsFile( settingsFile ) -- return gameOption and OptionMenu or false
	local gameOptions = {}
	local optionsMenu = {}

	if sm.json.fileExists(settingsFile) == true then

		local settings = sm.json.open(settingsFile)

		gameOptions = settings.options
		optionsMenu = settings.menu 

		gameOptions.null = false
		for i,v in ipairs(optionsMenu) do
			if not v.optionsVarRef then
				v.optionsVarRef = "null"
				optionsMenu[i].optionsVarRef = "null"
			end
			optionsMenu[i].value = gameOptions[v.optionsVarRef]
		end
		--self.storage:save( self.sv.saved )
		return gameOptions, optionsMenu

	elseif sm.json.fileExists(settingsFile) == false then
		return false, false
	end
end

function getAmongScrapSettingsDbTag( database ) --wip
    local tag = {}
   
    if sm.json.fileExists(database) == true then
        local dbFile = sm.json.open( database )
        
        for i,v in ipairs(dbFile.settingsFile) do
            table.insert(tag, sm.json.open(v).metadata.tag)
        end 
        return tag
 
    elseif sm.json.fileExists(database) == false then
        return false
    end
end
