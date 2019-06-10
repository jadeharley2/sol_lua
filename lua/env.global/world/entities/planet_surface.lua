
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
	render.SetGroupMode(RENDERGROUP_RINGS,RENDERMODE_ENABLED) 
	render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_ENABLED)  
	render.SetGroupMode(RENDERGROUP_CURRENTPLANET,RENDERMODE_ENABLED)  
end

function ENT:Leave()   
	self.surface:SetRenderGroup(RENDERGROUP_PLANET)
	if self.modelA then
		self.modelA:SetRenderGroup(RENDERGROUP_PLANET)
		self.model:SetRenderGroup(RENDERGROUP_PLANET)
		self.modelB:SetRenderGroup(RENDERGROUP_PLANET)
	end
	if self.atmosphere then
		self.atmosphere:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
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

		render.SetGroupMode(RENDERGROUP_RINGS,RENDERMODE_ENABLED) 
		render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_ENABLED)  
		render.SetGroupMode(RENDERGROUP_CURRENTPLANET,RENDERMODE_ENABLED)  
	end
end
function ENT:Think()
--	--MsgN("d") 
	--self.constrot:SetParams(0.001,0,matrix.Rotation(0.1,0,0))
--	--cr:SetPostOffset()
	if CLIENT then
		local cam = GetCamera()
		if cam:GetParent()==self then
			render.ClearShadowMaps()
		end
	end
end