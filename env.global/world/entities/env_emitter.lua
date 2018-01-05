

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
function SpawnParticlesCustom(parent,type,pos,time,size,speed)
	time = time or 1 
	local e = ents.Create("env_emitter")
	e.speed = speed or 1
	e:SetParent(parent)
	e.customtype = type 
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
function ENT:SetCustom(effect)
	self.customtype = effect
end


function ENT:Spawn(c)  
	self:SetSpaceEnabled(false) 
	
	local customtype = self.customtype
	
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
	if customtype then
		particlesys2:Set(customtype)
	else
		local type = self:GetParameter(VARTYPE_CHARACTER,"magic_explosion")
		particlesys2:Set("particles/"..type..".json")
	end
	self.particlesys2 = particlesys2 
	 
end 