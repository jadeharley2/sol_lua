
function ENT:Init()
	self:AddFlag(FLAG_PLANET_SURFACE)
	local constrot  = self:AddComponent(CTYPE_CONSTROT) 
	constrot:SetParams(0.00001,0,matrix.Rotation(0.1,0,0))
	--constrot:SetParams(0.1,0,matrix.Rotation(0.1,0,0)) 
	--constrot:SetSpeed(0.001)
	self.constrot = constrot
	self:SetSpaceEnabled(true,1)
	self:SetUpdating(true,50)
end
function ENT:Spawn()  
	
	
	local partition = self:AddComponent(CTYPE_PARTITION2D) 
	local surfacecom = self:AddComponent(CTYPE_SURFACE)  
	local space = self:AddComponent(CTYPE_PHYSSPACE) 
	
	local arch = self:GetParameter(VARTYPE_ARCHETYPE)
	if arch then
		surfacecom:SetArchetype(arch)
	end
	if arch == "earth" then--TODO: add set mapdata source
		local mapdata = self:AddComponent(CTYPE_MAPDATA)
		self.mapdata = mapdata
	end
	--local testmod = ents.Create("planet_surface_mod")
	--testmod:SetSizepower(100000) 
	--testmod:SetParameter(VARTYPE_CHARACTER,"test_earth") 
	--testmod:SetParent(self) 
	--testmod:SetPos(Vector(0,0,0))-- Vector(1,-0.15,0)*0.90908)
	----testmod:SetAng(Vector(0,-90,0))
	--testmod:Spawn() 
	
	
	if self.surfacenodelevel then
		surfacecom:LinkToPartition(self.surfacenodelevel)
	else
		surfacecom:LinkToPartition()
	end
	surfacecom:SetRenderGroup(RENDERGROUP_PLANET)
	
	self.partition = partition
	self.surface = surfacecom  
	self.space = space
	
	if(surfacecom:HasAtmosphere() )then
		local atmosphere = self:AddComponent(CTYPE_ATMOSPHERE)  
		atmosphere:SetRenderGroup(RENDERGROUP_PLANET)
		self.atmosphere = atmosphere
	end
	if(surfacecom:HasAtmosphere() and false )then -- TODO:DELETE
		local modelA = self:AddComponent(CTYPE_MODEL) 
		local model = self:AddComponent(CTYPE_MODEL) 
		local modelB = self:AddComponent(CTYPE_MODEL) 
	
	
		
		
		--0.9096
		local world= matrix.Scaling(2*0.91) * matrix.Rotation(90,0,0)
		local world2= matrix.Scaling(Vector(-1,1,1)*2*0.91) * matrix.Rotation(90,0,0)
		
		local cloud_mat = "textures/atmosphere/clouds.json"
		----[[
		--- cloud layer 1
		modelA:SetRenderGroup(RENDERGROUP_PLANET)
		modelA:SetModel("engine/csphere_36_cylproj.json") 
		modelA:SetMaterial(cloud_mat) 
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
		model:SetModel("engine/csphere_36_cylproj.json") 
		model:SetMaterial(cloud_mat) 
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
		modelB:SetModel("engine/csphere_36_cylproj.json") 
		modelB:SetMaterial(cloud_mat) 
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
	
	
	--self:SetUpdating(true,20)
	
	
end

function ENT:Enter() 
	--render.SetGroupBounds(RENDERGROUP_CURRENTPLANET,1e8,0.5*UNIT_LY)
	render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_BACKGROUND)  
	render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_BACKGROUND) 
	render.SetGroupBounds(RENDERGROUP_PLANET,1e4,1000e8) 
	render.SetGroupBounds(RENDERGROUP_CURRENTPLANET,10,1e8)
	self.surface:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
	if self.modelA then
		self.modelA:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
		self.model:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
		self.modelB:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
	end
	if self.atmosphere then
		self.atmosphere:SetRenderGroup(RENDERGROUP_LOCAL)
	end
end

function ENT:Leave()   
	self.surface:SetRenderGroup(RENDERGROUP_PLANET)
	render.SetGroupMode(RENDERGROUP_RINGS,RENDERMODE_BACKGROUND) 
	if self.modelA then
		self.modelA:SetRenderGroup(RENDERGROUP_PLANET)
		self.model:SetRenderGroup(RENDERGROUP_PLANET)
		self.modelB:SetRenderGroup(RENDERGROUP_PLANET)
	end
	if self.atmosphere then
		self.atmosphere:SetRenderGroup(RENDERGROUP_PLANET)
	end
	
	--render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_ENABLED) 
	--render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_ENABLED) 
	--self:UnloadSubs()
	
	if CLIENT then
		local system =  self:GetParentWith(NTYPE_STARSYSTEM) 
		--MsgN("ad",system)
		--if system and system.cubemap then
		--	render.SetCurrentEnvmap(system.cubemap)
		--else
		--	render.SetCurrentEnvmap()
		--end
		render.SetCurrentEnvmap()
		render.ClearShadowMaps()
	end
end
function ENT:Think()
--	--MsgN("d") 
	self.constrot:SetParams(0.001,0,matrix.Rotation(0.1,0,0))
--	--cr:SetPostOffset()
end