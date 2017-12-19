ENT.name = "Sol universe space"


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
	SendTo(origin_loader,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333")--0.02,0,0")--
	 
	origin_loader:SetPos(Vector(-0.3,0,0)) 

	local ship = origin_loader:GetParent()
	local targetpos = Vector(-0.3,0,0)
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