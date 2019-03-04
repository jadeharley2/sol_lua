
local rdtex = LoadTexture("space/star_sprites.png")
function ENT:Init()  
	self:SetSpaceEnabled(true,1)
end
function ENT:Spawn()  
	local star = self:GetParent()
	
	local scolor =  star:GetParameter(VARTYPE_COLOR) or star.color or Vector(0.2,0.6,1.2)
	
	local model = self:AddComponent(CTYPE_MODEL)  
	model:SetRenderGroup(RENDERGROUP_STARSYSTEM)
	model:SetModel("engine/csphere_36.stmd")
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED) 
	model:SetMatrix(matrix.Scaling(1))
	model:SetFullbright(true)
	model:SetBrightness(10)
	model:SetFadeBounds(0,99999,0)  
	model:SetColor(scolor)
	model:SetMaxRenderDistance(100000)
	model:SetFlare(true)
  
	if star:GetParameter(VARTYPE_TYPE)==NTYPE_BLACKHOLE then
		model:SetMaterial("textures/space/star/blackhole.json") 
	else
		model:SetMaterial("textures/space/star/teststar.json") 
		local particlesys2 = self:AddComponent(CTYPE_PARTICLESYSTEM2) 
		particlesys2:SetRenderGroup(RENDERGROUP_STARSYSTEM)
		particlesys2:SetBlendMode(BLEND_ADD) 
		particlesys2:SetRasterizerMode(RASTER_DETPHSOLID) 
		particlesys2:SetDepthStencillMode(DEPTH_READ)  
		particlesys2:Set("particles/star.particle")
		particlesys2:SetSpeed(0.1)--0.1)
		particlesys2:SetColor(scolor)
		self.particlesys2 = particlesys2 
	end
	
	--local particlesys = self:AddComponent(CTYPE_PARTICLESYSTEM) 
	--particlesys:SetRenderGroup(RENDERGROUP_STARSYSTEM)
	--particlesys:SetNodeMode(false)
	--particlesys:AddNode(1)
	--particlesys:SetNodeStates(1,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_READ) 
	--particlesys:SetTexture(1,rdtex)
	--particlesys:AddParticle(1,Vector(0,0,0),scolor,10,0) 
	--particlesys:SetMaxRenderDistance(100000)
	--
	--self.particlesys = particlesys
	self.model = model 
	
	--local constrot  = self:AddComponent(CTYPE_CONSTROT) 
	--constrot:SetParams(1,0,matrix.Rotation(0.1,0.1,0.2))
	--self.constrot = constrot
	--self:SetUpdating(true,1000)
end

--function ENT:Think()  
--	self:SetAng(self:GetMatrixAng()* matrix.Rotation(0.01,0.01,0))
--	
--end

function ENT:Enter() 
	if self:GetSizepower()<1000000000 then 
		self.model:SetRenderGroup(RENDERGROUP_PLANET)
		if self.particlesys2 then
			self.particlesys2:SetRenderGroup(RENDERGROUP_PLANET)
		end
	end
	
end

function ENT:Leave()    
	self.model:SetRenderGroup(RENDERGROUP_STARSYSTEM)
	if self.particlesys2 then
		self.particlesys2:SetRenderGroup(RENDERGROUP_STARSYSTEM)
	end
	--self:RemoveComponents(CTYPE_PARTICLESYSTEM2)
end