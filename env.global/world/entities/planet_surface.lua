
function ENT:Init()
	local constrot  = self:AddComponent(CTYPE_CONSTROT) 
	constrot:SetParams(0.001,0,matrix.Rotation(0.1,0,0))
	self.constrot = constrot
	self:SetSpaceEnabled(true,1)
end
function ENT:Spawn()  
	
	local partition = self:AddComponent(CTYPE_PARTITION2D) 
	local surfacecom = self:AddComponent(CTYPE_SURFACE)  
	local space = self:AddComponent(CTYPE_PHYSSPACE) 
	
	local arch = self:GetParameter(VARTYPE_ARCHETYPE)
	if arch then
		surfacecom:SetArchetype(arch)
	end
	if self.surfacenodelevel then
		surfacecom:LinkToPartition(self.surfacenodelevel)
	else
		surfacecom:LinkToPartition()
	end
	surfacecom:SetRenderGroup(RENDERGROUP_PLANET)
	
	self.partition = partition
	self.surface = surfacecom  
	self.space = space
	
	if(surfacecom:HasAtmosphere() and false )then
		local modelA = self:AddComponent(CTYPE_MODEL) 
		local model = self:AddComponent(CTYPE_MODEL) 
		local modelB = self:AddComponent(CTYPE_MODEL) 
	
	
		--0.9096
		local world= matrix.Scaling(2*0.91) * matrix.Rotation(90,0,0)
		local world2= matrix.Scaling(Vector(-1,1,1)*2*0.91) * matrix.Rotation(90,0,0)
		----[[
		--- cloud layer 1
		modelA:SetRenderGroup(RENDERGROUP_PLANET)
		modelA:SetModel("engine/csphere_36_cylproj.SMD") 
		modelA:SetMaterial("textures/atmosphere/clouds.json") 
		modelA:SetBlendMode(BLEND_ADD) 
		modelA:SetRasterizerMode(RASTER_NODETPHSOLID) 
		modelA:SetDepthStencillMode(DEPTH_DISABLED)  
		modelA:SetMatrix(world)
		modelA:SetBrightness(0.4)
		modelA:SetFadeBounds(0.02,99999,0.02) 
		modelA:SetDrawShadow(false)
		self.modelA = modelA
		
		--- cloud layer 2
		model:SetRenderGroup(RENDERGROUP_PLANET)
		model:SetModel("engine/csphere_36_cylproj.SMD") 
		model:SetMaterial("textures/atmosphere/clouds.json") 
		model:SetBlendMode(BLEND_ALPHA) 
		model:SetRasterizerMode(RASTER_NODETPHSOLID) 
		model:SetDepthStencillMode(DEPTH_DISABLED)  
		model:SetMatrix(world)
		model:SetBrightness(2)
		model:SetFadeBounds(0.02,99999,0.02)  
		model:SetDrawShadow(false)
		self.model = model
		--model:Enable(false)
		
		---inverted cloud layer
		
		modelB:SetRenderGroup(RENDERGROUP_PLANET)
		modelB:SetModel("engine/csphere_36_cylproj.SMD") 
		modelB:SetMaterial("textures/atmosphere/clouds.json") 
		modelB:SetBlendMode(BLEND_ALPHA) 
		modelB:SetRasterizerMode(RASTER_DETPHSOLID) 
		modelB:SetDepthStencillMode(DEPTH_ENABLED)  
		modelB:SetMatrix(world2)
		modelB:SetBrightness(2)
		modelB:SetFadeBounds(0.02,99999,0.02) --0.0002,99999,0.0002) 
		modelB:SetDrawShadow(false)
		self.modelB = modelB
		--]]
	end
	
	
	
end

function ENT:Enter() 
	--render.SetGroupBounds(RENDERGROUP_CURRENTPLANET,1e8,0.5*UNIT_LY)
	render.SetGroupBounds(RENDERGROUP_PLANET,1e4,1000e8)
	render.SetGroupBounds(RENDERGROUP_CURRENTPLANET,10,1e8)
	self.surface:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
	if self.modelA then
		self.modelA:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
		self.model:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
		self.modelB:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
	end
end

function ENT:Leave()   
	self.surface:SetRenderGroup(RENDERGROUP_PLANET)
	if self.modelA then
		self.modelA:SetRenderGroup(RENDERGROUP_PLANET)
		self.model:SetRenderGroup(RENDERGROUP_PLANET)
		self.modelB:SetRenderGroup(RENDERGROUP_PLANET)
	end
	
	--render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_ENABLED) 
	--render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_ENABLED) 
	self:UnloadSubs()
end