-- ImpostorManager.lua --

ImpostorManager = class( nil )

--SERVER
function ImpostorManager.sv_onCreate( self )

	self.sv = {}
	self.sv.allImpostor = {}

	self.sv.howManyImpostor = 0
end

function ImpostorManager.sv_onInitImpostor( self )

	local players = sm.player.getAllPlayers()
	local playerIndex = 0
	for i,v in ipairs(players) do
		playerIndex = playerIndex + 1
		playerIndex = i
	end
	for i1 = 1, self.sv.howManyImpostor do
		local impostor = nil
		repeat
			local isPlayerAlreadyImpostor = false
			impostor = players[sm.noise.randomRange(1, playerIndex)]
			for i2,v2 in ipairs(self.sv.allImpostor) do
				if v2 == impostor then
					isPlayerAlreadyImpostor = true
				end
			end
		until isPlayerAlreadyImpostor == false

		table.insert(self.sv.allImpostor, impostor)
	end
	sm.event.sendToGame("sv_e_onSendingImpostor", self.sv.allImpostor)
	print(self.sv.allImpostor)
end

function ImpostorManager.sv_onResetImpostor( self )
	self.sv.allImpostor = {}
end


--- COMMAND ---

function ImpostorManager.sv_changeImpostorNumber( self , number )
	self.sv.howManyImpostor = number
end







--CLIENT
function ImpostorManager.cl_onCreate( self )

	self.cl = {}
	self.cl.isImpostor = false

end

function ImpostorManager.cl_onSendingImpostor( self , data )
	print(data)
	self.cl.isImpostor = data
end

function ImpostorManager.cl_onResetImpostor( self )
	self.cl.isImpostor = false
end
