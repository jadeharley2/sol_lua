ENT.name = "Sol universe"


function ENT:Init()
 
	self:SetSizepower(math.pow(2,88))
	self:SetSeed(1000001)
	self:SetGlobalName("u1") 


end
function ENT:Spawn()

	
	local space = ents.Create("spaceCluster") 
	space:SetSeed(1000002)
	space:SetParent(self) 
	space:SetSizepower(math.pow(2,86))
	space:SetGlobalName("u1.mc")
	space:Spawn()
	if SERVER then
		network.AddNode(space)
	end
 
	self.space = space
end
function ENT:LoadSpawnpoint()
	
	local origin_loader = ents.Create()
	origin_loader:SetGlobalName("origin")
	origin_loader:SetParent(universe)
	origin_loader:Spawn()

	AddOrigin(origin_loader)
	origin_loader:SetUpdateSpace(true)
	OL = origin_loader
	SendTo(origin_loader,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333;s2397131")--0.02,0,0")--
	--SendTo(origin_loader,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333;s2008650333;0.803679,0.07456001,-0.4183209")--

	origin_loader:SetPos(Vector(0,0,0))
	--OL = ents.Create() OL:SetGlobalName("origin") OL:SetParent(U) OL:Spawn() 
	--SendTo(OL,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333;s2008650333;0.8044567, 0.07306096, -0.4171545")--

	local ship = origin_loader:GetParent()
	local targetpos = Vector(0.003537618,0.01925059,0.2446546)
	local targetpos2 = Vector(0.003008218, -0.07939442, -0.02011958)
	local targetpos3 = Vector(0.4954455, -0.002244724, 0.02894697)
	self.spawnnode = ship
	self.spawnpos = targetpos
	self.loaded = true
	return ship, targetpos
end

function ENT:GetSpawn() 
	if not self.loaded then 
		self:LoadSpawnpoint()
	end
	return self.spawnnode, self.spawnpos
end