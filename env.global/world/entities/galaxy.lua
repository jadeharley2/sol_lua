local CONST_SPACE_LIGHT_MULTIPLIER=50*2

function ENT:Init()  
	self:AddFlag(FLAG_GALAXY)
	self:SetParameter(VARTYPE_TYPE,NTYPE_GALAXY)
end
function ENT:Spawn() 
	local model = self:AddComponent(CTYPE_MODEL) 
	model:SetRenderGroup(RENDERGROUP_DEEPSPACE)
	model:SetModel("space/galaxy_add.stmd")
	local rtex = tostring(math.random(1,3))
	if(self:GetSeed()==1712499733) then
		rtex = 1
	end
	model:SetMaterial("textures/space/galaxies/0"..rtex..".json")--eso1339g.jpg")-- eso1339gc.jpg")
	model:SetBlendMode(BLEND_ADD)--BLEND_ADD 
	model:SetRasterizerMode(RASTER_NODETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_DISABLED) 
	model:SetMatrix(matrix.Scaling(1.8) * matrix.Rotation(90,0,0))
	model:SetBrightness(0.0003*CONST_SPACE_LIGHT_MULTIPLIER)--0.3)--0.8
	model:SetFadeBounds(0.05,100,0.1)  
end

function ENT:Enter()  
	if not self.loaded then
		--local model = self:AddComponent(CTYPE_MODEL) 
		local particlesys = self:AddComponent(CTYPE_PARTICLESYSTEM)
		local partition = self:AddComponent(CTYPE_PARTITION3D)
		local generator = self:AddComponent(CTYPE_PROCEDURAL) 
		
		partition:SetBBoxPower(2.5)
		partition:SetPowerLimit(16)
		
		generator:AddEvent(EVENT_GENERATOR_SETUP)
		generator:AddEvent(EVENT_PARTITION_CREATE)
		generator:AddEvent(EVENT_PARTITION_COLLAPSE)
		generator:SetGenerator("com.galaxy.spiral")
		
		particlesys:SetRenderGroup(RENDERGROUP_DEEPSPACE)
		particlesys:SetBrightness(0.5)--0.3
		
		--model:SetFullbright(true)
		--self.partition = partition
		--self.generator = generator
		--self.particlesys = particlesys
		
		--local test = ents.Create("nebula")
		--test:SetSizepower(self:GetSizepower()/100)
		--test:SetPos(Vector(0.4,0,0))
		--test:SetParent(self)
		--test:Spawn()
		
		self.loaded = true
	end
	console.Call("r_maxexposure 5") 
end

function ENT:Leave() 
	--self:RemoveComponents(CTYPE_MODEL) 
	self:RemoveComponents(CTYPE_PARTICLESYSTEM)
	self:RemoveComponents(CTYPE_PARTITION3D)
	self:RemoveComponents(CTYPE_PROCEDURAL) 
	self.loaded = nil
	console.Call("r_maxexposure 20") 
end