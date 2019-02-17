if not GspcInit then 
	GspcInit = LoadTexture("space/galaxy_sprites.png")
end


--[[
local function OnPCreate(self, eid, pos, level, seed, width)
	
	local pdt = self.pdt
	
	local rnd = Random(seed + 3218979)
	
	if(rnd:NextFloat()>0.8) then
		local rVec = pos + Vector(rnd:NextFloat(-1,1), rnd:NextFloat(-1,1), rnd:NextFloat(-1,1)) * width
		local galaxy = ents.Create("galaxy") 
		galaxy:SetParent(self) 
		galaxy:SetSizepower(9.46073E20)--77371252455336267181195264)
		galaxy:SetPos(rVec)
		galaxy:SetAng(Vector(rnd:NextFloat(-180,180),rnd:NextFloat(-180,180),rnd:NextFloat(-180,180)))
		
		galaxy:Spawn()
		self.particlesys:AddParticle(0,rVec,Vector(1,1,1),0.00001,0)
		pdt[seed] = galaxy
	else
		pdt[seed] = {}
	end
	
end
local function OnPDestroy(self, eid, pos, level, seed, width)
	local pdt = self.pdt
	local pp = pdt[seed]
	if pp and pp.Despawn then
		pp:Despawn()
	end
	pdt[seed] = nil
end
]]

function ENT:Init()   
	local particlesys = self:AddComponent(CTYPE_PARTICLESYSTEM)
	local partition = self:AddComponent(CTYPE_PARTITION3D)  
	local generator = self:AddComponent(CTYPE_PROCEDURAL) 
	
	partition:SetBBoxPower(2)
	partition:SetPowerLimit(16)
	 
	generator:AddEvent(EVENT_PARTITION_CREATE)
	generator:AddEvent(EVENT_PARTITION_COLLAPSE)
	generator:SetGenerator("com.cluster.default")
	
	partition:SetBBoxPower(4)
	partition:SetPowerLimit(11)
	
	particlesys:SetRenderGroup(RENDERGROUP_DEEPSPACE)
	particlesys:AddNode(0)
	particlesys:SetTexture(0,GspcInit)
	particlesys:SetBrightness(0.0001*50*4)--0.2)
	
	--self:AddEventListener(EVENT_PARTITION_CREATE,"space", OnPCreate)
	--self:AddEventListener(EVENT_PARTITION_COLLAPSE,"space", OnPDestroy)
	self.particlesys = particlesys 
	--self.pdt = {}
end
 