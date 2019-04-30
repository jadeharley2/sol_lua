ENT.name = "Void"
ENT.hidden = true
 

function ENT:Init() 
	self:SetSizepower(10000)
	self:SetSeed(322323)  
end
function ENT:Spawn() 

	-- all worlds must have minimum 1 subspace 
	-- 
	local space = ents.Create()
	space:SetLoadMode(1)
	space:SetSeed(self.subseed or 9900002)
	space:SetParent(self) 
	space:SetSizepower(1000) 
	space:Spawn()   
 
	self.space = space
end
 
function ENT:GetSpawn() 
	local space = self.space 
	return self.space, Vector(0,0,0)
end 