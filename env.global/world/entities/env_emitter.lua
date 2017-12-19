

function SpawnParticles(parent,type,pos,time,size,speed)
	time = time or 1 
	local e = ents.Create("env_emitter")
	e.speed = speed or 1
	e:SetParent(parent)
	e:SetParameter(VARTYPE_CHARACTER,type or "explosion")
	e:SetSizepower(size or 1)
	if pos then e:SetPos(pos) end
	e:Spawn()
	if time>0 then
		debug.Delayed(time*1000, function()
			e:Despawn()
		end)
	end
	return e
end

--lua_run SpawnParticlesStarsystem(Entity(1065632697),"explosion_void",Vector(0,0,0),100,1000000000)
function SpawnParticlesStarsystem(parent,type,pos,time,size,speed)
	time = time or 1 
	local e = ents.Create("env_emitter")
	e.speed = speed or 1
	e.rgroup = RENDERGROUP_STARSYSTEM
	e:SetParent(parent)
	e:SetParameter(VARTYPE_CHARACTER,type or "explosion")
	e:SetSizepower(size or 1)
	if pos then e:SetPos(pos) end
	e:Spawn()
	if time>0 then
		debug.Delayed(time*1000, function()
			e:Despawn()
		end)
	end
	return e
end
function SpawnParticlesSpace(parent,type,pos,time,size,speed)
	time = time or 1 
	local e = ents.Create("env_emitter")
	e.speed = speed or 1
	e.rgroup = RENDERGROUP_DEEPSPACE
	e.dmode = DEPTH_NONE
	e:SetParent(parent)
	e:SetParameter(VARTYPE_CHARACTER,type or "explosion")
	e:SetSizepower(size or 1)
	if pos then e:SetPos(pos) end
	e:Spawn()
	if time>0 then
		debug.Delayed(time*1000, function()
			e:Despawn()
		end)
	end
	return e
end

function ENT:Init()  
end

function ENT:Spawn(c)  
	self:SetSpaceEnabled(false) 
	
	local type = self:GetParameter(VARTYPE_CHARACTER,"magic_explosion")
	
	local particlesys2 = self:AddComponent(CTYPE_PARTICLESYSTEM2) 
	particlesys2:SetSpeed(self.speed or 1)
	particlesys2:SetRenderGroup(self.rgroup or RENDERGROUP_LOCAL)
	particlesys2:SetBlendMode(BLEND_ADD) 
	particlesys2:SetRasterizerMode(RASTER_DETPHSOLID) 
	if self.dmode ~=nil then
		particlesys2:SetDepthStencillMode(self.dmode)  
	else
		particlesys2:SetDepthStencillMode(DEPTH_READ)  
	end
	particlesys2:Set("data/particles/"..type..".json")
	self.particlesys2 = particlesys2 
	 
end 