
function ENT:Spawn()  
	
	local cubemap = self:AddComponent(CTYPE_CUBEMAP)  
	self.cubemap = cubemap
	local skybox = self:AddComponent(CTYPE_SKYBOX) 
	cubemap:SetTarget(skybox)
	self.skybox = skybox
end

function ENT:RequestDraw() 
	self.cubemap:RequestDraw()
end
 