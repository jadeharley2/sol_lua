
local rdtex = LoadTexture("space/star_sprites.png")
--function ENT:Init()  
--end
function ENT:Spawn()  
	local star = self:GetParent()
	
	local scolor =  star:GetParameter(VARTYPE_COLOR) or star.color or Vector(0.2,0.6,1.2)
	
	local model = self:AddComponent(CTYPE_MODEL)  
	model:SetRenderGroup(RENDERGROUP_STARSYSTEM)
	model:SetModel("engine/csphere_36.SMD") 
	model:SetMaterial("textures/space/star/teststar.json") 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED) 
	model:SetMatrix(matrix.Scaling(2))
	model:SetFullbright(true)
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	model:SetColor(scolor)
	model:SetMaxRenderDistance(100000)
	

	local particlesys = self:AddComponent(CTYPE_PARTICLESYSTEM) 
	particlesys:SetRenderGroup(RENDERGROUP_STARSYSTEM)
	particlesys:SetNodeMode(false)
	particlesys:AddNode(1)
	particlesys:SetNodeStates(1,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_READ) 
	particlesys:SetTexture(1,rdtex)
	particlesys:AddParticle(1,Vector(0,0,0),scolor,10,0) 
	particlesys:SetMaxRenderDistance(100000)
	
	self.particlesys = particlesys
	self.model = model
	
end

function ENT:Enter()  
end

function ENT:Leave()    
end