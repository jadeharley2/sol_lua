function SpawnDynsky(parent) 
	local e = ents.Create("env_dynsky")
	e:SetSizepower(1000)
	e:SetParent(parent) 
	e:SetAng(matrix.AxisRotation(Vector(1,0,0),180))
	e:Spawn()
	return e
end
--ex: "textures/skybox/spacedefault/space.png"

function ENT:Spawn()   
	self:SetSpaceEnabled(false) 
	if CLIENT then
		local skybox = self:AddComponent(CTYPE_DYNAMICSKY)  
		self.skybox = skybox 
		skybox:SetRenderGroup(RENDERGROUP_OVERLAY)
		
	end
end

function ENT:SetWorld(w)
	self.skybox:SetMatrix(matrix.Scaling(10000)*w)
end
 
 
 