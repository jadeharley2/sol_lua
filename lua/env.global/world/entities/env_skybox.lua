function SpawnSkybox(parent,texture) 
	local e = ents.Create("env_skybox")
	e.texture = texture
	e:SetSizepower(1000)
	e:SetParent(parent) 
	e:SetAng(matrix.AxisRotation(Vector(1,0,0),180))
	e:Spawn()
	return e
end
--ex: "textures/skybox/spacedefault/space.png"
function ENT:SetupData(data)
	if data.texture then
		self.texture = data.texture
	end
end
function ENT:Spawn()   
	self:SetSpaceEnabled(false) 
	if CLIENT then
		local skybox = self:AddComponent(CTYPE_SKYBOX)  
		self.skybox = skybox 
		skybox:SetRenderGroup(RENDERGROUP_BACKDROP) 
		local tex = self.texture 
		if tex then
			skybox:SetTexture(tex)
		end
	end
end

function ENT:SetWorld(w)
	self.skybox:SetMatrix(matrix.Scaling(10000)*w)
end
 
 
 