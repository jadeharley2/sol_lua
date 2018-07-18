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
	
	--local origin_loader = ents.Create()
	--origin_loader:SetGlobalName("origin")
	--origin_loader:SetParent(universe)
	--origin_loader:Spawn()

	origin_loader = GetCamera()
	
	AddOrigin(origin_loader)
	origin_loader:SetUpdateSpace(true)
	OL = origin_loader
	engine.SendTo(origin_loader,"@u1.mc;-0.002718567,0.0005680526,0.004285494,1712499733;0.3089897,0.02846826,0.06682603,1062413718;s1065632697;s2008649333", function(e)
		--s2397131
		origin_loader:SetPos(Vector(0,0,0))
		--OL = ents.Create() OL:SetGlobalName("origin") OL:SetParent(U) OL:Spawn() 
		--SendTo(OL,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333;s2008650333;0.8044567, 0.07306096, -0.4171545")--

		local ship = ents.Create("spaceship")
		ship:SetSeed(2397131)
		ship:SetSizepower(750)
		ship:SetName("The ship")
		ship:SetParent(origin_loader:GetParent())
		ship:SetPos(Vector(0.0129999995529652, 0, 0))
		ship:SetParameter(VARTYPE_CHARACTER,"libra")
		ship:Create()
		ship:Enter()
		ship:SetUpdateSpace(true)
	--		"type" : 0,
	--		"typename" : "none",
	--		"seed" : 2397131,
	--		"abssize" : 750,
	--		"name" : "the ship",
	--		"position" : [0.0129999995529652, 0, 0, "vec3"],
	--		"rotation" : [0, 1, 0, 0, "quat"],
	--		"scale" : [1, 1, 1, "vec3"],
	--		"luaenttype" : "spaceship",
	--		"character" : "libra",
		
		--local ship = origin_loader:GetParent()
		
		local targetpos = Vector(0.003537618,0.01925059,0.2446546) 
		self.spawnnode = ship
		self.spawnpos = targetpos
		self.loaded = true
		hook.Call("world.loaded", ship, targetpos)
		
	
	end,function()
		hook.Call("world.load.error")
	end)--0.02,0,0")--
	--SendTo(origin_loader,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333;s2008650333;0.803679,0.07456001,-0.4183209")--

	
	--return ship, targetpos
end

--function ENT:GetSpawn() 
--	if not self.loaded then 
--		self:LoadSpawnpoint()
--	end
--	return self.spawnnode, self.spawnpos
--end