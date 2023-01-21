-- copy of BaseCharacter.lua without fucking speed change



UselessBaseCharacter = class( nil )




















function UselessBaseCharacter.server_onCreate( self )
	self.character.publicData = {}
	self.sv = {}





end

function UselessBaseCharacter.server_onFixedUpdate( self, timeStep )
	-- Transfer server public data of water movement to client
	--self.cl.waterMovementSpeedFraction = 1.0
	--if self.character.publicData and self.character.publicData.waterMovementSpeedFraction then
	--	self.cl.waterMovementSpeedFraction = self.character.publicData.waterMovementSpeedFraction
	--end





















end













function UselessBaseCharacter.client_onCreate( self )
	self.character.clientPublicData = {}
	self.cl = {}
	self.cl.waterMovementSpeedFraction = 1.0

	local player = self.character:getPlayer()
	if sm.exists( player ) then
		if player ~= sm.localPlayer.getPlayer() then
			local name = player:getName()
			self.character:setNameTag( name )
		else
			-- if setNameTag is called here you will be able to see your own name, can be changed during runtime
		end
	end
end









function UselessBaseCharacter.client_onGraphicsLoaded( self )
	self.graphicsLoaded = true




























end

function UselessBaseCharacter.client_onGraphicsUnloaded( self )
	self.graphicsLoaded = false











end

function UselessBaseCharacter.client_onFixedUpdate( self, deltaTime )
	if not sm.isHost then
		--self.cl.waterMovementSpeedFraction = 1.0
		--if self.character.clientPublicData and self.character.clientPublicData.waterMovementSpeedFraction then
		--	self.cl.waterMovementSpeedFraction = self.character.clientPublicData.waterMovementSpeedFraction
	--end
	end
end

function UselessBaseCharacter.client_onUpdate( self, deltaTime )



































































































	--local totalMovementSpeedFraction = self.cl.waterMovementSpeedFraction
	--self.character.movementSpeedFraction = totalMovementSpeedFraction

	if not self.graphicsLoaded then
		return
	end

end
