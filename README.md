# AmongScrap

Among Scrap is a mod for Scrap Mechanic.

STEAM WORKSHOP : https://steamcommunity.com/sharedfiles/filedetails/?id=2811583960

VERSION CHANGELOG (0.1.7 and later)


-- CHANGELOG (0.2.0) -- (Actual version)
-- General :
	· Added mysterious ambiance
	· Make some crash test in multiplayer
	· Task progression now work

-- Mapping :
	· Added new spawn
	· New map : Wonk ship (Work in progress)
	· Added test template on WonkShip

-- In the code :
	· Player are now alaways a new player when he join
	· Improve the code to be multiplayer friendly
	· TaskInterfaceIcon now close on destroy
	· A downed player can no longer vote in metting
	· Added new sounds when tasks are finish or complete
	· Added new text when task are complete
	· Added new Fadein and FadeOut when onGameOver and onGoToWorld

-- Fix :
	· Fix taskTable pointer problem
	· Fix the impostor random status
	· Fix tasks in multiplayer

-- New command :
	· "/spawnship" - go to Spawn ship map
	· "/wonkship" - go to Wonk ship map



-- CHANGELOG (0.1.8) --
-- General :
	· Happy new year !
	· All the system are functionnal, you can play to Among Scrap now !

-- In the code :
	· Added icon that show where is Task interface (Work in progress)
	· Added Task labels and HUD (Work in progress)
	· Added kill and report function
	· Remove g_survivalHudAmongScrap HUD
	· impostor system should be work !
	· Metting system should be work !

-- New command
	· '/metting' - it initalize the metting system
	· '/vote' - it open the voting GUI
	· '/start' - it start a round
	· '/impostornum'



-- CHANGELOG (0.1.7) --
-- General :
	· now working on the mod again !
	· new changelog displaying

-- In the code :
	· '/impostor' command added
	· '/reset' command added - it reseting the task system
	· New interactable part : Task interface
	· added tasks structure
	· Task system should now work as well, try it using task interface part and the command '/task' !
	· improve the normalization of all variables and functions namespace
	· added random (random in scrap like to be not working so well... )
