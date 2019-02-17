function SpawnSkybox(parent,texture) 
	local cubemap = ents.Create("env_skybox")
	cubemap.texture = texture
	cubemap:SetSizepower(1000)
	cubemap:SetParent(parent) 
	cubemap:SetAng(matrix.AxisRotation(Vector(1,0,0),180))
	cubemap:Spawn()
	return cubemap
end
--ex: "textures/skybox/spacedefault/space.png"

function ENT:Spawn()   
	self:SetSpaceEnabled(false) 
	if CLIENT then
		local skybox = self:AddComponent(CTYPE_SKYBOX)  
		self.skybox = skybox 
		skybox:SetRenderGroup(RENDERGROUP_LOCAL) 
		local tex = self.texture 
		if tex then
			skybox:SetTexture(tex)
		end
	end
end
 
 
 