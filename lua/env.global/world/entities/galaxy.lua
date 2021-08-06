local CONST_SPACE_LIGHT_MULTIPLIER=50*2
local rdtex = LoadTexture("space/star_sprites.png")

function ENT:Init()  
	self:AddTag(TAG_GALAXY)
	self:SetParameter(VARTYPE_TYPE,NTYPE_GALAXY)
end
function ENT:Spawn()
	local seed = self:GetSeed()
	if math.mod(seed,2) == 0 or seed==1712499733 then 
		local model = self:AddComponent(CTYPE_MODEL) 
		model:SetRenderGroup(RENDERGROUP_DEEPSPACE)
		model:SetModel("space/galaxy_add.stmd")
		local rtex = tostring(math.random(1,3))
		if(seed==1712499733) then
			rtex = 1
		end
		model:SetMaterial("textures/space/galaxies/0"..rtex..".json")--eso1339g.jpg")-- eso1339gc.jpg")
		model:SetBlendMode(BLEND_ADD)--BLEND_ADD 
		model:SetRasterizerMode(RASTER_NODETPHSOLID) 
		model:SetDepthStencillMode(DEPTH_DISABLED) 
		model:SetMatrix(matrix.Scaling(1.8) * matrix.Rotation(90,0,0))
		model:SetBrightness(0.0003*CONST_SPACE_LIGHT_MULTIPLIER)--0.3)--0.8
		model:SetFadeBounds(0.05,10000,0.1) 
		
		
	else
		local particlesys = self:AddComponent(CTYPE_PARTICLESYSTEM) 
		particlesys:SetRenderGroup(RENDERGROUP_DEEPSPACE)
		particlesys:SetNodeMode(false)
		particlesys:AddNode(8)
		particlesys:SetNodeStates(8,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_READ) 
		particlesys:SetTexture(8,rdtex)
		particlesys:AddParticle(8,Vector(0,0,0), Vector(1, 244 / 255, 232 / 255)*0.001,1,0) 
		particlesys:SetMaxRenderDistance(100000)
		self.psys = particlesys
	end

	local supermassiveCenter = ents.Create("starsystem")
	supermassiveCenter:SetSizepower(9.46073E16 / 5 * 0.1)
	supermassiveCenter:SetParent(self)
	supermassiveCenter:SetPos(Vector(0,0,0)) 
	supermassiveCenter.color = Vector(1,1,1)
	supermassiveCenter:SetSeed(seed+4820)
	supermassiveCenter:SetParameter(VARTYPE_GENERATOR,"com.system.galaxycenter")
	supermassiveCenter:SetName("Galactic center")

end

function ENT:Enter()  
	if not self.loaded then
		--local model = self:AddComponent(CTYPE_MODEL) 
		local particlesys = self.psys or self:AddComponent(CTYPE_PARTICLESYSTEM)
		local partition = self:AddComponent(CTYPE_PARTITION3D)
		local generator = self:AddComponent(CTYPE_PROCEDURAL) 
		
		partition:SetBBoxPower(2.5)
		partition:SetPowerLimit(16)
		
		generator:AddEvent(EVENT_GENERATOR_SETUP)
		generator:AddEvent(EVENT_PARTITION_CREATE)
		generator:AddEvent(EVENT_PARTITION_COLLAPSE)
		generator:AddEvent(EVENT_PARTITION_DESTROY)
		local seed = self:GetSeed()
		if math.mod(seed,2)== 0 or seed==1712499733 then
			generator:SetGenerator("com.galaxy.spiral")
		else
			generator:SetGenerator("com.galaxy.spherical")
		end
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
		
		
		if self:GetSeed()==1712499733 then 
			--temp: spawn starsystems
			self:SpawnMWay()
		end

		self.loaded = true
	end
	console.Call("r_maxexposure 5") 
end

function ENT:Leave()  
	local particlesys = self.psys 
	if particlesys then
		particlesys:DelNode(0)
		particlesys:DelNode(1)
		particlesys:DelNode(2) 
	else
		self:RemoveComponents(CTYPE_PARTICLESYSTEM)
	end 
	self:RemoveComponents(CTYPE_PARTITION3D)
	self:RemoveComponents(CTYPE_PROCEDURAL) 
	self.loaded = nil
	console.Call("r_maxexposure 20") 
	if self:GetSeed()==1712499733 then 
		--temp: spawn starsystems
		self:ClearMWay()
	end
end

local pi2 = math.pi * 2
local piby180 = math.pi / 180

local function VCyl(r,t,y)
	return Vector(math.cos(t) * r, y, math.sin(t) * r)
end

function ENT:SpawnMWay()
	local systems = forms.GetList('starsystem')
	local t = 0
	for k,v in pairs(systems) do
		print('SPAWNss',k,v)
		local e = SpawnStarsystem(self,"com.system.custom",0,k)-- forms.Spawn(k,self,{}) 
		if e then
			local data = forms.GetData("starsystem",k)
			local location = data.location
			if location then

				local spos = VCyl(location.dist/200 ,(location.lon-90)* piby180,(location.height or 0)/200)
				e:SetPos(spos)
			end

		end
		t = t + 1
	end
end
function ENT:ClearMWay()
	for k,v in pairs(self:GetChildren()) do
		if v[VARTYPE_GENERATOR]=="com.system.custom"  then
			v:Despawn()
		end
	end
end