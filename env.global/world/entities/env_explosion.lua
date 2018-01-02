
local rdtex = LoadTexture("space/star_sprites.png")

ENT.magnitude = 100 -- default

function ENT:Init()  
end

function ENT:Spawn(c) 
	local scolor = self.color or Vector(1,0.4,0.2) -- or Vector(0.2,0.4,1)
	self.color = scolor

	local light = self:AddComponent(CTYPE_LIGHT)  
	light:SetColor(scolor)
	light:SetBrightness(0) 
	self.light = light
	
	 

	--local particlesys = self:AddComponent(CTYPE_PARTICLESYSTEM) 
	--particlesys:SetRenderGroup(RENDERGROUP_LOCAL)
	--particlesys:SetNodeMode(false)
	--particlesys:AddNode(1) 
	--particlesys:SetNodeStates(1,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_READ) 
	--particlesys:SetTexture(1,rdtex)
	--particlesys:AddParticle(1,Vector(0,0,0),scolor,10,0) 
	-- 
	--self.particlesys = particlesys 
	
	local particlesys2 = self:AddComponent(CTYPE_PARTICLESYSTEM2) 
	particlesys2:SetRenderGroup(RENDERGROUP_LOCAL)
	particlesys2:SetBlendMode(BLEND_ADD) 
	particlesys2:SetRasterizerMode(RASTER_DETPHSOLID) 
	particlesys2:SetDepthStencillMode(DEPTH_READ)  
	particlesys2:Set("particles/explosion.json")--lines_test.json")--explosion.json")
	self.particlesys2 = particlesys2 
	
	
	
	
	self:SetSpaceEnabled(false) 
	 
	self.counter = 0
	self:SetUpdating(true,10)
	
	local magn = self.magnitude
	local spos = self:GetPos()
	local parent = self:GetParent()
	local sz = parent:GetSizepower()
	local caugt = GetNodesInRadius(parent,spos,magn/sz)
	for k,v in pairs(caugt) do
		if v ~= self then
			local dir = v:GetPos()-spos
			local dist = dir:Length()*sz
			local M = magn/dist/dist/4
			if M > 0.1 then
				v:SendEvent(EVENT_DAMAGE,M)
				local phys = v.phys
				if phys then
					phys:ApplyImpulse(dir*M*30)
				end
				--MsgN("EXPLOSION DAMAGE to ",v," by ",M)
			end
		end
	end 
	self:EmitSound(table.Random({"explosion/sharp_01.ogg","explosion/sharp_02.ogg","explosion/sharp_03.ogg"}),1*magn,math.min(1,1000/magn))
end
local ccountdown = 1000
function ENT:Think()
	local counter = self.counter
	local magn = self.magnitude
	counter = counter + 1
	self.counter = counter
	if counter<10 then
		local val = math.sin(counter/ccountdown/10*3.1415926)
		self.light:SetBrightness(magn*val) 
	else
		self.light:SetBrightness(0) 
	end
	--self:RemoveComponent(CTYPE_PARTICLESYSTEM) 
	
	--local particlesys = self:AddComponent(CTYPE_PARTICLESYSTEM) 
	--particlesys:SetRenderGroup(RENDERGROUP_LOCAL)
	--particlesys:SetNodeMode(false)
	--particlesys:AddNode(1) 
	--particlesys:SetNodeStates(1,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_READ) 
	--particlesys:SetTexture(1,rdtex) 
	--particlesys:AddParticle(1,Vector(0,0,0),self.color,magn*2*val,0) 
	--self.particlesys = particlesys 
	
	if counter > ccountdown then
		self:Despawn()
	end
end