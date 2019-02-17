function SpawnSkydome(parent,type) 
	local cubemap = ents.Create("env_skybox")
	cubemap.texture = texture
	cubemap:SetSizepower(1000)
	cubemap:SetParent(parent) 
	cubemap:SetAng(matrix.AxisRotation(Vector(1,0,0),180))
	cubemap:Spawn()
	return cubemap
end 

function ENT:Spawn()   
	self:SetSpaceEnabled(false) 
	if CLIENT then 
	end
end
 
 
 