ENT.name = "Sol universe root"


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
	 
	origin_loader = GetCamera()
	AddOrigin(origin_loader)
	origin_loader:SetUpdateSpace(true)
	OL = origin_loader
	engine.SendTo(origin_loader,"@u1.mc;-0.002718567,0.0005680526,0.004285494,1712499733",function(e) 
	
	
	
		origin_loader:SetPos(Vector(-0.3,0,0)) 

		local ship = origin_loader:GetParent()
		local targetpos = Vector(-0.3,0,0)
		self.spawnnode = ship
		self.spawnpos = targetpos
		self.loaded = true
		hook.Call("world.loaded", ship, targetpos)
	
		debug.Delayed(3000,function() TSYSTEM:ReloadSkybox() end)
	
	
	end,function()
		hook.Call("world.load.error")
	end) 
end

function ENT:OnPlayerSpawn()
	SetController("freecamera") 
	if CLIENT then
		render.SetGroupBounds(RENDERGROUP_STARSYSTEM,1e8,0.5*UNIT_LY)
		render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_BACKGROUND)
		
		render.SetGroupBounds(RENDERGROUP_PLANET,1e2,1e10)
		render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_BACKGROUND)
		
	end
end