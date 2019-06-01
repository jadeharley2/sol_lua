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

	if CLIENT then
		origin_loader = GetCamera()
	else
		origin_loader = ents.Create()
		origin_loader:SetSpaceEnabled(false)
	end

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
		ship:SetSizepower(1000)
		ship:SetName("The ship")
		ship:SetParent(origin_loader:GetParent())
		ship:SetPos(Vector(0.0129999995529652, 0, 0))
		ship:SetParameter(VARTYPE_CHARACTER,"sevneka")--,"libra")
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

if SERVER then
	function ENT:GetSpawn() 
		if not self.loaded then 
			--self:LoadSpawnpoint()

			--network.AddNodeImmediate(ship)
			
			local ship = ents.Create("spaceship")
			ship:SetSeed(2397131)
			ship:SetSizepower(1000)
			ship:SetName("The ship")
			ship:SetParent(LOBBY)

			local targetpos = Vector(0.003537618,0.01925059,0.2446546) 
			self.spawnnode = ship
			self.spawnpos = targetpos
			self.loaded = true

			
			origin_loader = ents.Create()
			origin_loader:SetSpaceEnabled(false) 

			AddOrigin(origin_loader)
			origin_loader:SetUpdateSpace(true)
			OL = origin_loader
			engine.SendTo(origin_loader,"@u1.mc;-0.002718567,0.0005680526,0.004285494,1712499733;0.3089897,0.02846826,0.06682603,1062413718;s1065632697;s2008649333", function(e)
				--s2397131
				--ship:SetParent(LOBBY)
				ship:SetParent(origin_loader:GetParent())
				ship:SetPos(Vector(0.0129999995529652, 0, 0))
				ship:SetParameter(VARTYPE_CHARACTER,"sevneka")
				ship:Create()
				ship:Enter()
				ship:SetUpdateSpace(true)
				AddOrigin(ship)


				--network.AddNodeImmediate(ship)
				--origin_loader:Despawn() 
			end,function()
				--hook.Call("world.load.error")
			end)
		end
		return self.spawnnode, self.spawnpos
	end
end

ENT.options = {
	--character = {
	--	text = "Debug mode",
	--	selected = function(self,origin)
	--		
	--	end
	--},
	free = {
		text = "Debug mode",
		location = "@u1.mc;-0.002718567,0.0005680526,0.004285494,1712499733;0.3089897,0.02846826,0.06682603,1062413718;s1065632697;s2008649333",
		position = Vector(-0.3,0,0),
		controller = "freecamera"
	},
	free2 = {
		text = "Debug mode: Galaxy",
		location = "@u1.mc;-0.002718567,0.0005680526,0.004285494,1712499733",
		position = Vector(-0.3,0,0),
		controller = "freecamera"
	},
	
	spaceship = {
		text = "Spaceship start",
		location = "@u1.mc;-0.002718567,0.0005680526,0.004285494,1712499733;0.3089897,0.02846826,0.06682603,1062413718;s1065632697;s2008649333",
		onload = function(self,origin) 
			local ship = ents.Create("spaceship")
			ship:SetSeed(2397131)
			ship:SetSizepower(1000)
			ship:SetName("The ship")
			ship:SetParent(origin:GetParent())
			ship:SetPos(Vector(0.0129999995529652, 0, 0))
			ship:SetParameter(VARTYPE_CHARACTER,"libra")
			ship:Create()
			ship:Enter()
			ship:SetUpdateSpace(true)

			local targetpos = Vector(0.003537618,0.01925059,0.2446546) 
			self.spawnnode = ship
			self.spawnpos = targetpos
			self.loaded = true

			SpawnPlayerChar(targetpos,ship)

			hook.Call("world.loaded", ship, targetpos) 
			return true
		end
	},
	spacelab = {
		text = "Spacelab",
		location = "@u1.mc;-0.002718567,0.0005680526,0.004285494,1712499733;0.3089897,0.02846826,0.06682603,1062413718;s1065632697;s2008649333",--s995462352
		onload = function(self,origin)
			
 
			origin:SetPos(Vector(-0.3,0,0)) 

			local ship = origin:GetParent()
	
	
			local labnode_outer = ents.Create()
			labnode_outer:SetLoadMode(1)
			labnode_outer:SetSeed(995462355)
			labnode_outer:SetParent(ship) 
			labnode_outer:SetPos(Vector(-0.1,0,0))
			labnode_outer:SetSizepower(10000)
			labnode_outer:SetAng(Vector(80,40,40))
			labnode_outer:SetGlobalName("spacelab_outer")
			labnode_outer:Spawn( )  
			local sspace = labnode_outer:AddComponent(CTYPE_PHYSSPACE)   
			labnode_outer.space = sspace
	
			local cam = GetCamera()
			cam.cursst = labnode_outer
	
			local labnode = ents.Create()
			labnode:SetLoadMode(1)
			labnode:SetSeed(995462352)
			labnode:SetParent(labnode_outer) 
			--labnode:SetPos(Vector(-0.1,0,0))
			labnode:SetSizepower(1000)
			--labnode:SetAng(Vector(80,40,40))
			labnode:SetGlobalName("spacelab")
			labnode:Spawn( )  
			local sspace = labnode:AddComponent(CTYPE_PHYSSPACE)  
			sspace:SetGravity(Vector(0,-4,0))
			labnode.space = sspace
	
			
			local data = json.Load("models/space/stations/spacelab/lab_node.dnmd")
			local b = procedural.Builder()
			b:BuildNode(data,labnode)
		
			--local map = SpawnSO("models/space/stations/spacelab/the_lab.dnmd",labnode,Vector(0,0,0),0.75) 
			local targetpos = Vector(0,0,0)
	
	
		
		
			if CLIENT then
				local eshadow = ents.Create("test_shadowmap2")  
				local star = labnode:GetParentWithFlag(FLAG_STAR)
				eshadow.light = star
				eshadow:SetParent(labnode) 
				eshadow:Spawn() 
				self.shadow = eshadow
				 
				local cbm =  labnode:AddComponent(CTYPE_CUBEMAP)
				cbm:SetSize(1024)
				cbm:SetTarget() 
				self.cubemap = cbm
				
				--local cbm = SpawnCubemap(labnode,Vector(0,1,0)/10000,512)
				--self.cubemap = cbm
				labnode:AddNativeEventListener(EVENT_ENTER,"cubmapset",function() 
					cbm:RequestDraw()
					--GlobalSetCubemap(cbm,true) 
					--ambient:Start()
				end)
				--labnode:AddNativeEventListener(EVENT_LEAVE,"dt",function()   
				--	--ambient:Stop()
				--end)
				self.cubemap:RequestDraw()
			end
			
	
	
			self.spawnnode = labnode
			self.spawnpos = targetpos
			self.loaded = true

			SpawnPlayerChar(targetpos,labnode) 
			hook.Call("world.loaded", labnode, targetpos)
		
			debug.Delayed(3000,function() TSYSTEM:ReloadSkybox() end)

			if CLIENT then
				render.SetGroupBounds(RENDERGROUP_STARSYSTEM,1e8,0.5*UNIT_LY)
				render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_BACKGROUND)
				
				render.SetGroupBounds(RENDERGROUP_PLANET,1e2,1e10)
				render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_BACKGROUND)
			end

			return true
		end
	},
	gensokyo = {
		text = "Gensokyo",
		anchor = "gensokyo", 
		onload = function(self,origin) 
			SpawnPlayerChar(origin:GetPos(),origin:GetParent())
			return true
		end
	},
}



local function _ReloadSST(iid)
	if CLIENT then 
		if string.ends(iid,"models/space/stations/spacelab/lab_node.dnmd") then 
			MsgN("huh reload ",iid)
			local cam = GetCamera()
			local cursst = cursst or cam.cursst
			if cursst then
				MsgN("sst reload ",iid,cursst)
				
				local pl = LocalPlayer() or GetCamera()
				if pl then
					engine.PausePhysics()
					
					local tempspace = ents.Create("world_void")
					tempspace:Spawn()
					local cp = pl:GetPos()
					pl:SetParent(tempspace) 
					if cursst and IsValidEnt(cursst) then
						for k,v in pairs(cursst:GetChildren()) do
							v:Despawn()
						end
					end
					
					
					
					local labnode = ents.Create()
					labnode:SetLoadMode(1)
					labnode:SetSeed(995462352)
					labnode:SetParent(cursst) 
					--labnode:SetPos(Vector(-0.1,0,0))
					labnode:SetSizepower(1000)
					--labnode:SetAng(Vector(80,40,40))
					labnode:SetGlobalName("spacelab")
					labnode:Spawn( )  
					local sspace = labnode:AddComponent(CTYPE_PHYSSPACE)  
					sspace:SetGravity(Vector(0,-4,0))
					labnode.space = sspace

					
					local data = json.Load("models/space/stations/spacelab/lab_node.dnmd")
					local b = procedural.Builder()
					b:BuildNode(data,labnode)
					
					
					
					if labnode then 
						pl:SetParent(labnode)
						pl:SetPos(cp)--+Vector(0,0.2,0)/int.space:GetSizepower())
						
						tempspace:Despawn()
					end 
					debug.Delayed(100,function()
						engine.ResumePhysics()
						if pl.phys then
							pl.phys:SetVelocity(Vector(0,0,0))
						end 
						pl:SetPos(cp+Vector(0,0.1,0)/labnode:GetSizepower())
					end)
				end 
			end
		end
	end
end

hook.Add("file.reload","spacelab_autoreload",_ReloadSST)