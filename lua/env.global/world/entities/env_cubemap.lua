function SpawnCubemap(parent,pos,size,target) 
	local cubemap = ents.Create("env_cubemap")
	cubemap.target = target
	cubemap.size = size
	cubemap:SetSizepower(1000)
	cubemap:SetParent(parent)
	cubemap:SetPos(pos)
	cubemap:Spawn()
	return cubemap
end
function ENT:Init() 
	self:SetSpaceEnabled(false)
	self:SetSizepower(1000)
end
function ENT:SetupData(data)
	if data.target then
		if data.target=='parent'then
			self.target = self:GetParent()
		end
	end
	if data.delay then
		self.delay = data.delay
	end 
	if data.projection then
		local projection = self:RequireComponent(CTYPE_PROJECTEDCUBEMAP)
		self.projection = projection 
		projection:set_size(JVector(data.projection.size,Vector(1,1,1)))
	end
end
function ENT:Spawn()  
	 
	
	local cubemap = self:RequireComponent(CTYPE_CUBEMAP)  
	self.cubemap = cubemap
	--local skybox = self:AddComponent(CTYPE_SKYBOX) 
	cubemap:SetSize(self.size or 1024)
	--self.skybox = skybox 
	if self.projection then 
		cubemap:SetTarget(self.projection)
	else
		cubemap:SetTarget(nil,self.target)
	end
	if self.delay then
		MsgN("delayed draw ",self.delay)
		debug.Delayed(self.delay,function() 
			self.cubemap:RequestDraw()
		end)
	end
end 


function ENT:RequestDraw(fast) 
	if self and IsValidEnt(self) then
		local cubemap = self.cubemap
		if cubemap then
			cubemap:RequestDraw()
			--render.SetCurrentEnvmap(cubemap,fast)
		end
	else
		hook.Remove("cubemap_render","last_cubemap")
	end
end
 
function GlobalSetCubemap(cb,fast)
	hook.Remove("cubemap_render","last_cubemap")
	if cb then
		cb:RequestDraw(fast)
		hook.Add("cubemap_render","last_cubemap",function() cb:RequestDraw() end)
	end
	
end

 