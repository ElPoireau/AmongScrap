# Among Scrap 

Among Scrap is a custom game for Scrap Mechanic based on the game Among Us.

STEAM WORKSHOP : steam://openurl/https://steamcommunity.com/sharedfiles/filedetails/?id=2811583960
**FileID: 2811583960**


## VERSION CHANGELOG (0.1.7 and later)

##### **CHANGELOG (0.2.1)** (Actual version)

-- General :
- New language support (Work in progress)
- New savable game settings support 

-- Mapping :
- Add the first version of Wonk Ship
- add the dead player teleport system
- Overworld no longer saved

-- In the code :
- Make a full revision of the tasks storage 
-  New folder 'Tasks' that contain all tasks dataset
- Tasks script are now unique with a common script 'baseTaskInterface' 
- Tasks are now more modulable 
- New timer better than the dev timer
- add new world for dead players
- Add new unit character when pepole be killed
- Add new name tag for impostor and player
- Add kill cooldown for impostor 
- add lockingControls on loading
- add fadeOut on loading
- Improve the metting looks

-- Fix :	
- Fix the player restrictions on all maps
- Fix the active tasks tables in multiplayer
- Fix the problem when only one vote can kill a player in meeting
- Fix a bug when complete task can occure a division by 0

-- New block:
- Option block 
- Start block

##### **CHANGELOG (0.2.0)**

-- General :
- Added mysterious ambiance
- Make some crash test in multiplayer
- Task progression now work

-- Mapping :
- Added new spawn
- New map : Wonk ship (Work in progress)
- Added test template on WonkShip

-- In the code :
- Player are now alaways a new player when he join
- Improve the code to be multiplayer friendly
- TaskInterfaceIcon now close on destroy
- A downed player can no longer vote in metting
- Added new sounds when tasks are finish or complete
- Added new text when task are complete
- Added new Fadein and FadeOut when onGameOver and onGoToWorld

-- Fix :
- Fix taskTable pointer problem
- Fix the impostor random status
- Fix tasks in multiplayer

-- New command :
- "/spawnship" - go to Spawn ship map
- "/wonkship" - go to Wonk ship map



##### **CHANGELOG (0.1.8)**

General :
- Happy new year !
- All the system are functionnal, you can play to Among Scrap now !

-- In the code :
- Added icon that show where is Task interface (Work in progress)
- Added Task labels and HUD (Work in progress)
- Added kill and report function
- Remove g_survivalHudAmongScrap HUD
- impostor system should be work !
- Metting system should be work !

-- New command \n
- '/metting' - it initalize the metting system
- '/vote' - it open the voting GUI
- '/start' - it start a round
- '/impostornum'



##### **CHANGELOG (0.1.7)**
-- General :
- now working on the mod again !
- new changelog displaying

-- In the code :
- '/impostor' command added
- '/reset' command added - it reseting the task system
- New interactable part : Task interface
- added tasks structure
- Task system should now work as well, try it using task interface part and the command '/task' !
- improve the normalization of all variables and functions namespace
- added random (random in scrap like to be not working so well... )
