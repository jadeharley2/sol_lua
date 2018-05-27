function SpawnCubemap(parent,pos,size) 
	local cubemap = ents.Create("env_cubemap")
	cubemap.size = size
	cubemap:SetSizepower(1000)
	cubemap:SetParent(parent)
	cubemap:SetPos(pos)
	cubemap:Spawn()
	return cubemap
end

function ENT:Spawn()  
	
	self:SetSpaceEnabled(false)
	
	local cubemap = self:AddComponent(CTYPE_CUBEMAP)  
	self.cubemap = cubemap
	--local skybox = self:AddComponent(CTYPE_SKYBOX) 
	cubemap:SetSize(self.size or 1024)
	cubemap:SetTarget()--skybox)
	--self.skybox = skybox
	hook.Add("cubemap_render","last_cubemap",function() self:RequestDraw() end)
end 

function ENT:RequestDraw() 
	if self and IsValidEnt(self) then
		local cubemap = self.cubemap
		if cubemap then
			cubemap:RequestDraw()
			render.SetCurrentEnvmap(cubemap)
		end
	else
		hook.Remove("cubemap_render","last_cubemap")
	end
end
 