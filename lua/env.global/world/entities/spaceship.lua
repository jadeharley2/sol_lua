EVENT_WARPJUMP = 11001
EVENT_DOCK = 11002
EVENT_DOCK_FINISH = 11003
EVENT_HYPERJUMP = 11004

function SpawnSS(type,pos,ent)
	
end

function ENT:CreateStaticLight( pos, color,power)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2) 
	lighttest:SetParent(self)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest.hasflare = false
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn() 
	if power then lighttest:SetBrightness(power) end
	lighttest:SetPos(pos)  
	return lighttest
end
function CreateLight(ship, pos, color, vel)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2)
	local phys = lighttest:AddComponent(CTYPE_PHYSOBJ) 
	phys:SetShape("engine/gsphere_2.SMD",world* matrix.Scaling(0.4))
	phys:SetMass(100) 
	lighttest:SetParent(ship)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn()
	
	--lighttest.model:SetMatrix(world*matrix.Translation(-phys:GetMassCenter()))
	lighttest.phys = phys
	
	lighttest:SetPos(pos) 
	lighttest:AddFlag(FLAG_STOREABLE)
	phys:ApplyImpulse(vel or Vector(0,4,40))
	return lighttest
end 



function ENT:Init()  
	
	self:SetSeed(2397131)
	self:SetSizepower(1000)--750)
	self:SetState("flight")
	local space = self:AddComponent(CTYPE_PHYSSPACE) 
	
	space:SetGravity(Vector(0,-9.5,0))
	self.space = space
	 
	
	local smd = "shiptest/ship_all.SMD"
	local world = matrix.Scaling(0.001) * matrix.Rotation(-90,0,0)

	local model = self:AddComponent(CTYPE_MODEL)  
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	--model:SetModel(smd) 
	--model:SetMaterial("textures/debug/white.json") 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED) 
	model:SetMatrix(world) 
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	model:SetMaxRenderDistance(1000000)
	self.model = model
	
	local collsmd = "shiptest/outer_coll.SMD"--"shiptest/bridge_floor.SMD"
	local coll = self:AddComponent(CTYPE_STATICCOLLISION) 
	coll:SetShape(collsmd, matrix.Scaling(1000) * world ) 
	self.coll = coll
	 
	
end
function ENT:Spawn()
	
	if CLIENT then
		local vsize = GetViewportSize() 
		
		local rt1 = CreateRenderTarget(512,512,"@rt01:Texture2D")
		self.rt1 = rt1
		local rt2 = CreateRenderTarget(512,512,"@rt02:Texture2D")
		self.rt2 = rt2 
	end
	
	local char = self:GetParameter(VARTYPE_CHARACTER)
	local shipdata = json.Read("forms/spaceships/"..char..".json")
	if shipdata then
		self.shipdata = shipdata
		if shipdata.hull then
			local hso = SpawnSO(shipdata.hull.model,self,Vector(0,0,0),shipdata.hull.scale) 
			if hso and hso.model then
				hso.model:SetMaxRenderDistance(1000000)
			end
		end
	end
	
	
	--SpawnSO("shiptest/ship_surface.stmd",self,Vector(0,0,0),0.75) 
	self.velocity = Vector(0,0,0)
	self.angvelocity = Vector(0,0,0)
	--self:SetUpdateSpace(true)
	self:SetSpaceEnabled(false)
	--self:SEnter()
	self:SetUpdating(true,15)
end
function ENT:Load()
	local char = self:GetParameter(VARTYPE_CHARACTER)
	local shipdata = json.Read("forms/spaceships/"..char..".json")
	
	if shipdata then
		self.shipdata = shipdata
		if shipdata.hull then
			SpawnSO(shipdata.hull.model,self,Vector(0,0,0),shipdata.hull.scale) 
		end
	end
	local state = self:GetParameter(VARTYPE_STATE)
	if state == "docked" then
		local parent = self:GetParent()
		if parent then
			self:DockLinkAirlocks(parent.station)
		end
	end
	
	self.velocity = Vector(0,0,0)
	self.angvelocity = Vector(0,0,0)
	--self:SetUpdateSpace(true)
	self:SetSpaceEnabled(false)
	--self:SEnter()
	self:SetUpdating(true,15)
end
function ENT:Despawn()  
	self:DDFreeAll() 
	MsgN("ship despawn!")
	MsgN(debug.traceback())
	brk()
end
function ENT:SEnter()  
	TSHIP = self
	local shipmodelmul = 0.001
	if not self.loaded then
		
		local function ToShipVector(v)
			return Vector(v.x*shipmodelmul,v.z*shipmodelmul,-v.y*shipmodelmul)
		end
		local function ToShipRay(v)
			return v[1]*shipmodelmul,v[3]*shipmodelmul,-v[2]*shipmodelmul
		end
		local function ToShipRVector(x,y,z)
			return Vector(x*shipmodelmul,z*shipmodelmul,-y*shipmodelmul)
		end
		
		 
		local nav = self:AddComponent(CTYPE_NAVIGATION)  
		--aatest:SetParent(space) 
		--aatest:Spawn() 
		self.nav = nav
		
		local shipdata = self.shipdata
		local namedEnts = {}
		if shipdata then   
			if shipdata.load then
				for k,v in pairs(shipdata.load) do
					engine.LoadNode(self,v)
				end
			end
			if shipdata.interior then  
				local posmul = (shipdata.posmul or 1)
				
				local cc = shipdata.commandchair
				if cc then
					local chair = SpawnSPCH(cc.model,self,JVector(cc.pos)*posmul,cc.scale)  
					chair:SetSeed(cc.seed or (self:GetSeed()+38012))
					if cc.variables then 
						local b, rlv = AutoConvert(cc.variables)
						for k,v in pairs(rlv) do
							chair[k] = v
						end 
					end
				end
				local tp = shipdata.teleporter
				if tp then 
					local e = CreateTeleporter(self,JVector(tp.pos)*posmul)
					if tp.name then
						e:SetName(tp.name)
						namedEnts[tp.name] = e
					end
					e:SetSeed(tp.seed)
					self.teleporter = e
				end 
				local exh = shipdata.exhaust
				if exh then
					local engines = SpawnSO(exh.model,self,JVector(exh.pos)*posmul,exh.scale) 
					local em = engines.model 
					em:SetMaterial("models/space/ships/midnight/tex/engine.json") 
					em:SetBlendMode(BLEND_ADD) 
					em:SetRasterizerMode(RASTER_DETPHSOLID) 
					em:SetDepthStencillMode(DEPTH_ENABLED)  
					em:SetMatrix( matrix.Scaling(0.75)* matrix.Rotation(-90,0,0))    
					em:SetBrightness(1)
					self.enginem = em
				end
 
				for k,v in pairs(shipdata.interior.static) do  
					local sm = SpawnSO(v.model,self,JVector(v.pos)*posmul,v.scale)  
					nav:AddStaticMesh(sm)
				end 
				for k,room in pairs(shipdata.interior.rooms or {}) do
					for k,v in pairs(room.static or {}) do  
						local sm = SpawnSO(v.model,self,JVector(v.pos)*posmul,v.scale)  
						nav:AddStaticMesh(sm)
					end 
					for k,v in pairs(room.doors or {}) do  
						local e = SpawnDoor(v.model,self,JVector(v.pos)*posmul,JVector(v.ang),v.scale,v.seed) 
						if v.name then
							e:SetName(v.name)
							namedEnts[v.name] = e
						end
						if v.seed then e:SetSeed(v.seed) end
					end 
					for k,v in pairs(room.props or {}) do
						local e = SpawnPV(v.type,self,JVector(v.pos)*posmul,JVector(v.ang))
						if v.name then
							e:SetName(v.name)
							namedEnts[v.name] = e
						end
						if v.seed then e:SetSeed(v.seed) end
					end
					for k,v in pairs(room.wire or {}) do
						local from = namedEnts[v[1]]
						local to = namedEnts[v[3]]
						WireLink(from,v[2],to,v[4])
					end
				end
				self.airlocks = {}
				for k,lock in pairs(shipdata.interior.airlocks or {}) do
					local ddi = lock.door_in
					local ddo = lock.door_out
					local door_in = SpawnDoor(ddi.model,self,JVector(ddi.pos)*posmul,JVector(ddi.ang),ddi.scale,ddi.seed)
					local door_out = SpawnDoor(ddo.model,self,JVector(ddo.pos)*posmul,JVector(ddo.ang),ddo.scale,ddo.seed)
					local airlock = Airlock(door_in,door_out)
					self.airlocks[k] = airlock
					for k,v in pairs(lock.static or {}) do  
						local sm = SpawnSO(v.model,self,JVector(v.pos)*posmul,v.scale)  
						nav:AddStaticMesh(sm)
					end 
				end
				self.lifts = {}
				for k,lift in pairs(shipdata.interior.lifts or {}) do
					MsgN("LIFT")
					local pn = {}
					for k,v in pairs(lift.nodes) do
						pn[k] = {p =JVector(v.p)*posmul,n=v.n,s=v.s,c=v.c}
					end
					pn.links = lift.links
					pn.currentid = lift.spawnnodeid
					MsgN("~~~~s")
					--PrintTable(pn)
					self.lifts[k] = SpawnLift(self,lift.seed,pn) 
				end
				for k,v in pairs(shipdata.interior.props or {}) do
					local e = SpawnPV(v.type,self,JVector(v.pos)*posmul,JVector(v.ang))
					if v.name then
						e:SetName(v.name)
						namedEnts[v.name] = e
					end
				end
				

				for k,v in pairs(shipdata.interior.wire or {}) do
					local from = namedEnts[v[1]]
					local to = namedEnts[v[3]]
					WireLink(from,v[2],to,v[4])
				end
				
			end  
		end
		self.named = namedEnts
		
		--[[
		--------------------------------------------------------------------------------
		--LIGHTS
		--------------------------------------------------------------------------------
		local lightlist_mirrored = {
			--bridge
			{11.743,-242.318,19.969},
			{12.67,-243.916,19.969},
			{15.235,-245.17,19.969},
			{17.707,-245.203,19.969},
			{19.215,-246.777,20.146},
			{19.215,-249.197,20.424},
			--tricor
			{11.921,-237.357,20.82},
			{14.255,-233.419,20.82},
			{16.555,-229.389,20.811},
			{18.279,-226.32,20.811},
			
			{8.683,-235.515,20.82},
			{10.992,-231.544,20.82},
			--maproom
			{10.934,-194.259,26.603},
			{10.758,-180.327,28.187}, 
			--portalroom
			{6.526,-174.643,30.971},
			{11.53,-167.939,33.333},
			{11.53,-160.718,33.333},
			{9.975,-153.574,33.333},
			
			--seqroom
			{13.949,-61.933,53.84, 4 , g = "seqroom"},
			{13.949,-46.57,55.47, 4 , g = "seqroom"},
			{9.987,-39.183,58.274, 4 , g = "seqroom"},
			{6.216,-46.57,59.257, 4 , g = "seqroom"},
			{6.174,-61.933,58.602, 4 , g = "seqroom"},
		}
		local lightlist = {
			 
		}
		local lgroups = {["seqroom"]={}}
		
		for k,v in pairs(lightlist_mirrored) do
			local mul = v[4] or 1
			local pos1 = Vector(v[1]*shipmodelmul,v[3]*shipmodelmul,-v[2]*shipmodelmul)
			local pos2 = Vector(-v[1]*shipmodelmul,v[3]*shipmodelmul,-v[2]*shipmodelmul)
			local col = Vector(0.3,0.3,0.3) * mul
			local l1 = self:CreateStaticLight(pos1,col)
			local l2 = self:CreateStaticLight(pos2,col)
			
			local lgroup = v["g"]
			if lgroup then
				local g = lgroups[lgroup]
				g[#g+1] = l1
				g[#g+1] = l2
			end
		end
		for k,v in pairs(lightlist) do
			local mul = v[4] or 1
			local pos1 = Vector(v[1]*shipmodelmul,v[3]*shipmodelmul,-v[2]*shipmodelmul) 
			local col = Vector(0.3,0.3,0.3) * mul
			self:CreateStaticLight(pos1,col) 
		end
		CreateLight(self,Vector(0.004475257 ,0.02119615,0.2454512),Vector(1,1,1))
		CreateLight(self,Vector(0.0006991078,0.02573425,0.2324287),Vector(0.2,0.5,1))
		CreateLight(self,Vector(0.0016991078,0.02573425,0.2324287),Vector(0.2,1,0.5))
		
		--------------------------------------------------------------------------------
		--SCREENS
		--------------------------------------------------------------------------------
		local sm = SpawnSO("shiptest/debugscreen.stmd",self,Vector(0,0,0),0.75).model
		if CLIENT then
			local wn = panel.Create("window_console") 
			wn:SetPos(0,0) 
			wn:SetTitle("ConsoleWindow") 
			self.camera1 = SpawnScreen(self.rt1,self,wn,sm)
			--sm:SetMaterial("textures/target/webrt.json") 
		end
		]]
		--------------------------------------------------------------------------------
		--SHIP PARTS
		--------------------------------------------------------------------------------
		local shipdeftex = "models/shiptest/tex/default_texture.json"
		
		
		--SpawnSO("space/ships/ship02.stmd",self,Vector(200,0,0)*shipmodelmul,0.5) 
		
		--SpawnSO("shiptest/bridge_floor.stmd",self,Vector(0,15.789,255.621)*shipmodelmul,0.75) 
		--[[
		SpawnSO("shiptest/bridge_walls.stmd",self,Vector(0,22.12,251.181)*shipmodelmul,0.75) 
		
		SpawnSO("shiptest/bridge_second_chairs.stmd",self,Vector(0,0,0),0.75).model:SetMaterial(shipdeftex) 
		SpawnSO("shiptest/bridge_tubes.stmd",self,Vector(0,0,0),0.75).model:SetMaterial(shipdeftex) 
		SpawnSO("shiptest/bridge_rails.stmd",self,Vector(0,0,0),0.75).model:SetMaterial(shipdeftex) 
		SpawnSO("shiptest/bridge_lights.stmd",self,Vector(0,0,0),0.75).model:SetMaterial(shipdeftex) 
		SpawnSO("shiptest/maproom.stmd",self,Vector(0,26.197,197.172)*shipmodelmul,0.75)--.model:SetMaterial(shipdeftex) 
		SpawnSO("shiptest/portalroom.stmd",self,Vector(0,32.511,159.471)*shipmodelmul,0.75)--.model:SetMaterial(shipdeftex) 
		SpawnSO("shiptest/interior_all_textured_v2.stmd",self,Vector(0,0,0),0.75).model:SetMaterial(shipdeftex) 
		SpawnSO("shiptest/dockslot.stmd",self,Vector(0,19.166,223.265)*shipmodelmul,0.75)
		SpawnSO("shiptest/bridge_middle.stmd",self,Vector(0,0,0),0.75).model:SetMaterial(shipdeftex) 
		SpawnSO("shiptest/portaleffect.stmd",self,Vector(0,0,0),0.75).model:SetMaterial("models/shiptest/tex/target01.json") 
		local chair = SpawnSPCH("shiptest/chair1.stmd",self,Vector(0,17,254.5)*shipmodelmul,0.75)  
		chair:SetSeed(self:GetSeed()+38012)
		
		local debugwhite = "textures/debug/white_5.json"
		
		--SpawnSO("test/prison/block.json",self,Vector(0.5,0,0),0.04)  
		
		
		SpawnSO("shiptest/reactor.stmd",self,Vector(0,45.797,-6.641)*shipmodelmul,0.75)  
		SpawnSO("shiptest/reactor_tonnels.stmd",self,Vector(0,0,0),0.75).model:SetMaterial(shipdeftex) 
		
		
		local targetpos_ship = Vector(0,27.971,146.933)*shipmodelmul
		CreateTeleporter(self,targetpos_ship)
		 
		if false and CLIENT then
			local beacon = ents.Create("beacon")
			beacon:SetParent(self:GetParent())--planet
			beacon:SetSizepower(1000) 
			beacon:SetSpaceEnabled(false) 
			beacon:SetUpdateSpace(true)
			beacon:Spawn()
			
			
			if CLIENT then
				local cam = GetCamera()
				RemoveOrigin(cam)
				cam:SetUpdateSpace(false)
			end
			
			AddOrigin(beacon)
			SendTo(beacon,"s2008650333;0.803679,0.07456001,-0.4183209")--planet surface
			beacon:SetUpdateSpace(false)
			local bsz = beacon:GetParent():GetSizepower()
			local targetpos3 = Vector(0.4952006, -0.002508848, 0.03225554)+Vector(0,2,0)/bsz
			local targetpos_ship = Vector(0,27.971,146.933)*0.001
			---Vector(0.4954455, -0.002244724, 0.02894697)+(Vector(20,0,0))/beacon:GetParent():GetSizepower()
			beacon:SetPos(targetpos3)
			beacon:SetAng(Vector(0,90,0))
			beacon.target = self
			beacon.target_pos = targetpos_ship
			PPM_P(self,targetpos_ship,beacon:GetParent(),targetpos3)--Vector(0,17,104.5)*0.001)
			--+Vector(0,2,0)/bsz
			
			if CLIENT then
				local cam = GetCamera()
				cam:SetPos(Vector(0,0,0))
				cam:SetUpdateSpace(true)
				AddOrigin(cam)
			end
			
		end 
		
		 
		 
		--SpawnTPS(self,Vector(0.0026991078,0.02573425,0.2324287))  
		-- range 1000km ...  0.5 ly
		
		--SpawnSO("test/tiletestsurface2.smd",self,Vector(0,0,0),0.75) 
		
		SpawnSO("shiptest/corridors_tri.stmd",self,Vector(0,18.755,227.373)*shipmodelmul,0.75)--.model:SetMaterial("textures/debug/white.json")

		--local sst = SpawnSO("station/all_ref.smd",self,Vector(0,0,0),0.75)
		--sst.model:SetMaterial("textures/debug/white.json")  
		--SpawnSO("corridors/Corridortype1tubes.smd",self,Vector(0,0,0)*sz,0.75).model:SetMaterial("textures/debug/white.json") 
		
		--ESpawnCorr(self,2308,Vector(0,-80,0),15)
		CURENT_CORNODE = self
		
		--if CLIENT then 
		--end
		
		--------------------------------------------------------------------------------
		--WARP & ENGINE EFFECTS
		--------------------------------------------------------------------------------
		
		local engines = SpawnSO("shiptest/engine.stmd",self,Vector(0,0,0),1) 
		local em = engines.model
		em:SetMaterial("models/shiptest/tex/engine.json") 
		em:SetBlendMode(BLEND_ADD) 
		em:SetRasterizerMode(RASTER_DETPHSOLID) 
		em:SetDepthStencillMode(DEPTH_ENABLED)  
		em:SetMatrix( matrix.Scaling(0.75)* matrix.Rotation(-90,0,0))    
		em:SetBrightness(1)
		self.enginem = em
		]]
		--0,20,254.5
		local warps = SpawnSO("engine/gsphere_24_inv.stmd",self,Vector(0,0,0)*shipmodelmul,1) 
		local wm = warps.model
		wm:SetMaterial("textures/space/warp/warp.json") 
		wm:SetBlendMode(BLEND_ADD) 
		wm:SetRasterizerMode(RASTER_NODETPHSOLID) 
		wm:SetDepthStencillMode(DEPTH_ENABLED)     
		wm:SetDrawShadow(false)     
		wm:SetMatrix( matrix.Scaling(Vector(10000,10000,100000)) * matrix.Rotation(0,0,0)) 
		wm:SetBrightness(0)
		wm:SetMaxRenderDistance(100000)
		wm:Enable(false)
		self.warpm = wm
		--[[
		--------------------------------------------------------------------------------
		--AIRLOCK
		-------------------------------------------------------------------------------- 
		
		local dds1 ={ SpawnDoor("door/door.stmd",self,Vector(14.218,16.502,217.146)*shipmodelmul,Vector(0,90,0),0.75,999005),
					SpawnDoor("door/door.stmd",self,Vector(-14.218,16.502,217.146)*shipmodelmul,Vector(0,90,0),0.75,999006)}
		--for k,v in pairs(dds1) do  v:SetAng(Vector(0,90,0))  end
		SpawnDoor("door/door.stmd",self,Vector(8.84,16.502,238.92)*shipmodelmul,Vector(0,60,0),0.75,999007)--:SetAng(Vector(0,60,0))
		SpawnDoor("door/door.stmd",self,Vector(-8.84,16.502,238.92)*shipmodelmul,Vector(0,-60,0),0.75,999008)--:SetAng(Vector(0,-60,0))
		
													--  22,276  -223,01  16,502
		local al2 = SpawnDoor("door/door.stmd",self,Vector(28.325,16.502,223.01)*shipmodelmul,Vector(0,0,0),0.75,999001)
		local al1 = SpawnDoor("door/door.stmd",self,Vector(22.276,16.502,223.01)*shipmodelmul,Vector(0,0,0),0.75,999002)
		local ar1 = SpawnDoor("door/door.stmd",self,Vector(-28.325,16.502,223.01)*shipmodelmul,Vector(0,0,0),0.75,999003)
		local ar2 = SpawnDoor("door/door.stmd",self,Vector(-22.276,16.502,223.01)*shipmodelmul,Vector(0,0,0),0.75,999004)
		local meta_airlock = {
			Open = function(s) s.d1:Unlock() s.d2:Unlock() s.d1:Open()  end,
			Close = function(s) s.d1:Close() s.d2:Close() s.d1:Lock() s.d2:Lock()  end,
			--Reset = function(s) s.d1:Open() s.d2:Close() s.d2:Lock() end,
			Set = function(s)  
				s.d2.OnUse = function(a,e) if not s.d1.locked and not s.d2.locked then s.d1:Close() s.d2:Open() if CLIENT then e:Eject() end end end 
				s.d1.OnUse = function(a,e) if not s.d1.locked and not s.d2.locked then s.d2:Close() s.d1:Open() end end 
				s:Close()
			end,
		}
		meta_airlock.__index = meta_airlock
		
		self.airlock_left = setmetatable({d1 = al1,d2 = al2}, meta_airlock)
		self.airlock_right = setmetatable({d1 = ar1,d2 = ar2}, meta_airlock)
		self.airlock_left:Set()
		self.airlock_right:Set()
		
		
		--------------------------------------------------------------------------------
		--LIFT
		--------------------------------------------------------------------------------
		
		local pn = {}
		-- x, z, -y
		pn[1] = {p = Vector(0,22.764,223.011)*0.001,n ="upbridge",s=true,c=1}
		pn[2] = {p = Vector(0,16.685,223.011)*0.001,n ="bridge",s=true,c=1}
		pn[3] = {p = Vector(0,8.162,223.011)*0.001}
		pn[4] = {p = Vector(0,15.303,170.021)*0.001}
		pn[5] = {p = Vector(0,17.983,138.173)*0.001,a = function(s,p)  end}
		pn[6] = {p = Vector(0,17.983,138.173)*0.001}
		pn[7] = {p = Vector(0,19.504,109.83)*0.001}
		pn[8] = {p = Vector(0,27.702,109.83)*0.001,n ="middle1",s=true,c=2}
		pn[9] = {p = Vector(0,35.773,109.83)*0.001,n ="middle2",s=true,c=2}
		pn[10] = {p = Vector(0,41.209,109.83)*0.001,n ="middle3",s=true,c=2}
		
		pn[11] = {p = Vector(0,16.893,26.454)*0.001,n ="back0/cargobay",s=true,c=3}
		pn[12] = {p = Vector(0,27.717,26.454)*0.001,n ="back1",s=true,c=3}
		pn[13] = {p = Vector(0,35.783,26.454)*0.001,n ="back2",s=true,c=3}
		pn[14] = {p = Vector(0,41.209,26.454)*0.001,n ="back3",s=true,c=3}
		pn[15] = {p = Vector(0,48.878,26.454)*0.001,n ="back4",s=true,c=3}
		
		pn.links = {{1,2,3,4,5,6,7,8,9,10},{7,11,12,13,14,15}}
		pn.currentid = 2
		
		self.lift = SpawnLift(self,325402,pn)
		
		--------------------------------------------------------------------------------
		--CINEMA ROOM
		--------------------------------------------------------------------------------
		SpawnButton(self,"useables/button.stmd",ToShipRVector(14.359,-63.487,48.099),Vector(0,180,0),
			function(b,u)
				for k,v in pairs(lgroups.seqroom) do
					v:Toggle()
				end 
			end,3204202)
		SpawnSO("shiptest/seqroom.stmd",self,Vector(0,52.969,54.228)*shipmodelmul,0.75)--.model:SetMaterial(shipdeftex) 
		SpawnSO("shiptest/seq_seat_test.stmd",self,Vector(0,0,0)*shipmodelmul,0.75)--.model:SetMaterial(shipdeftex) 
		
		local ws = SpawnWScreen(self,3248910,"shiptest/screen.stmd",ToShipRVector(0,-69.051,47.521),Vector(0,0,0))
		hook.Add("chat.msg.received", "webreceivecommands", function(u, text)
			if string.starts(text,"/") then
				if string.starts(text,"/wurl") then
					ws:SendEvent(EVENT_SETURL,string.sub(text,6))
				end
			end
		end)
		--ESpawnCorrv2(self,2325, Vector(0,-80,0),Vector(0,0,0),20,"tonnel_sub")
		]]
		self.loaded = true
	end
	
	if CLIENT then
		render.SetGroupBounds(RENDERGROUP_STARSYSTEM,1e8,0.5*UNIT_LY)
		render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_BACKGROUND)
		
		render.SetGroupBounds(RENDERGROUP_PLANET,1e2,1e10)
		render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_BACKGROUND)
		
		--self.shadow = CreateTestShadowMapRenderer(self,Vector(0,0,0))
		
		self.cubemap = SpawnCubemap(self,Vector(0,0.9,0),512,self)
		self.cubemap:SetAng(Vector(0,180,0))
		self.cubemap:RequestDraw() 

		self:Timer("cubemap_refresh",1100,1100,-1,function()
			if self and self.cubemap then
				self.cubemap:RequestDraw() 
			end
		end)
	end 
end

function ENT:Enter()
	
	self:SEnter()
	--local starmap = TEST_CGM(self,Vector(0,23.182+1,199.078)*0.001)
	--starmap:SetSeed(1010011)
	--self.starmap = starmap
	if CLIENT then
		render.SetGroupBounds(RENDERGROUP_STARSYSTEM,1e8,0.5*UNIT_LY)
		render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_BACKGROUND)
		
		render.SetGroupBounds(RENDERGROUP_PLANET,1e2,1e10)
		render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_BACKGROUND)
		
		
		self:Delayed("reloadsky",1000,function() 
			local system = self:GetParentWith(NTYPE_STARSYSTEM)
			if system then 
				if system.ReloadSkybox then system:ReloadSkybox() end 
			end 
		end)
	end
end
function ENT:Leave()   
	--render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_ENABLED)
	--render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_ENABLED)
	--self:UnloadSubs()
	if CLIENT then
		local sm = self.shadow
		if sm then
			sm:Despawn()
			self.shadow = nil
		end
	end
end
--local uup = {}
function ENT:Think()   
	local curthink = CurTime()
	local lastthink = self.lastthink or curthink
	local dt = curthink - lastthink
	self.lastthink = curthink
	--if #uup < 1000 then
	--	uup[#uup+1] = CurTime()
	--else
	--	MsgN("upd: ")
	--	PrintTable(uup)
	--	MsgN((uup[1000]-uup[1])/1000)
	--	uup = {}
	--end

	local wpm = self.warpm
	--if wpm then
	----	--MsgN("aa")
	--	wpm:SetMaterial("textures/space/warp/warp.json") 
	--	wpm:SetBlendMode(BLEND_ADD) 
	----	wpm:SetRasterizerMode(RASTER_NODETPHSOLID) 
	----	wpm:SetDepthStencillMode(DEPTH_ENABLED)     
	----	wpm:SetDrawShadow(false)  
	--  
	--	wpm:SetMatrix( matrix.Scaling(Vector(100,100,100))) --* matrix.Rotation(0,0,0)) 
	----	
	--	wpm:SetBrightness(1)
	--	wpm:Enable(true) 
	--end

	local tpv = self.throttlepow or 0
	local engm = self.enginem
	if engm then 
		engm:SetBrightness(tpv)
		engm:Enable( tpv>0.001)

	end
	if tpv > 0 then tpv = tpv - 0.02 end
	self.throttlepow = tpv
	
	self:RunTaskStep()
	--if CLIENT then
	local lastparent =  self.last_parent 
	
	local parent = self:GetParent()
	if parent then
		local parent_sz = parent:GetSizepower()
		
		
		self.velocity = self:GetNWVector("velocity",self.velocity or Vector(0,0,0)) 
		
		local pos = self:GetPos()
		local vel = self.velocity or Vector(0,0,0)
		local angvel = self.angvelocity
		
		
		if lastparent ~= parent then
			if lastparent ~= nil and IsValidEnt(lastparent) then
				MsgN(parent,lastparent)
				local transform =parent :GetLocalSpace(lastparent)
				local sizediff =parent:GetSizepower()/ lastparent:GetSizepower()
				local newVel = vel:TransformN(transform)*sizediff
				vel = newVel
			end
			self.last_parent = parent
		end
		
		if self.warpmode then
			local planet = self:GetParentWithFlag(FLAG_PLANET) 
			 
			if planet then
				local dist = self:GetDistance(planet)
				local radius = planet.radius
				if radius then
					local sealevel_height = dist-radius
			
					local pdir = (parent:GetLocalCoordinates(planet)-parent:GetLocalCoordinates(self)):Normalized()
					vel = vel + pdir*-1000000000/ math.max(1, sealevel_height/10)
				end
			end
		end
		
		local F = self:Forward():Normalized()
		local R = self:Right():Normalized()
		local U = self:Up():Normalized()
		local rvel = vel * (1/parent_sz) * dt-- -F*(vel.x/parent_sz)+U*(vel.y/parent_sz)+R*(vel.z/parent_sz)
		
		local currentpmsp = self.pmsp or 1
		
		local pmsp = parent.maxshipspeed  
		if pmsp then
			currentpmsp = currentpmsp + (pmsp - currentpmsp) /3
			rvel = rvel * currentpmsp 
		else
			currentpmsp = currentpmsp + (1 - currentpmsp) /3
		end
		self.pmsp = currentpmsp
		
		self:SetPos(pos + rvel)
		
		if self.warpmode then
			vel = vel*0.01
		end
		
		self.velocity = vel * 0.95 --auto decceleration
		self.angvelocity = angvel * 0.95
		self:RotateAroundAxis(Vector(1,0,0), angvel.x/100*dt)
		self:RotateAroundAxis(Vector(0,1,0), angvel.y/100*dt)
		self:RotateAroundAxis(Vector(0,0,1), angvel.z/100*dt)
		
		self:SetNWVector("velocity",self.velocity) 
		--end
		
		self:BendSpacetime(vel:Length()*0.00000001)
		 
	end
	
	
	if CLIENT then
		local lp = LocalPlayer()
		if lp and IsValidEnt(lp) and lp:GetParent()==self then
			local plp = lp:GetPos():Length()
			if plp > (self.shipdata.fallbackdistance or 1) then
				local tpr = self.teleporter
				tpr:TeleportStartup(lp,nil,nil,true)
				
				--lp:SetPos(JVector(self.shipdata.fallbackpos,Vector(0,0,0)))
				MsgInfo("Fallback protection activated")
			end
		end
	end
	 
	return true
end

function ENT:EnteredNewSystem()
	--self.starmap:ReloadMapFromCurrentSystem()
	local system = self:GetParentWith(NTYPE_STARSYSTEM)
	if system then 
		if system.ReloadSkybox then system:ReloadSkybox() end
		if self.starmap then self.starmap:AddVisitedSystem(system) end
	end 
end
if CLIENT then
	function ENS() 
		local system = GetCamera():GetParentWith(NTYPE_STARSYSTEM)
		if system then 
			if system.ReloadSkybox then system:ReloadSkybox() end 
		end 
	end 
end

function ENT:Throttle(dir,warp_mode)  
	warp_mode = warp_mode or false
	
	local parent = self:GetParent()
	local parent_sz = parent:GetSizepower()
	
	local maxspeed = 500000000 
	local planet = self:GetParentWithFlag(FLAG_PLANET) 
	
	local vel = self.velocity
	
	if not self.warpmode then
		if planet then
			local dist = self:GetDistance(planet)
			local radius = planet.radius
			if radius then
				local sealevel_height =dist-radius
				
				--if warp_mode then
				--else
					--maxspeed = math.min(maxspeed,math.max(0.001, sealevel_height)/1000) -- 10 for per second
					--maxspeed = math.min(maxspeed,math.max(0.001, sealevel_height*sealevel_height)/100000000)
					maxspeed = math.min(maxspeed,math.max(0.001, sealevel_height/8))
					 -- 100m height = 10mt vel
					 -- 10km height = 1kmt vel
				--end
				
			end
		end
	end
	
	--local Forward = Vector(1,0,0)---self:Forward():Normalized()
	local Forward = -self:Forward():Normalized()
	local fd = Forward*dir* maxspeed *self:GetScale()  --5000*
	self.velocity = vel + fd
	
	--for k,v in pairs(self:GetChildren()) do
	--	local phys = v:GetComponent(CTYPE_PHYSOBJ) 
	--	if phys then
	--		local nv = Vector(0,0,fd.y)  /100
	--		phys:ApplyImpulse(nv)
	--	end
	--end
	
	local tpw = (self.throttlepow or 0)
	self.throttlepow = tpw + (2 - tpw)/20
	
	
	self:SetNWVector("velocity",self.velocity)
end
function ENT:Turn(dir) 
	local angvel = self.angvelocity
	self.angvelocity = angvel + Vector(0,1,0) * dir
end
function ENT:Turn2(dir)   
	local angvel = self.angvelocity 
	self.angvelocity = angvel + Vector(0,0,1) * -dir
end
function ENT:Turn3(dir)   
	local angvel = self.angvelocity 
	self.angvelocity = angvel + Vector(1,0,0) * -dir
end
function ENT:HandleDriving(actor)  
	local R,F= input.KeyPressed(KEYS_R),input.KeyPressed(KEYS_F)
	
	if R then
		self:Turn3(1)
	end
	if F then
		self:Turn3(-1)
	end
end

function ENT:RunTaskStep()
	local thread = self.thread
	if thread == nil then
		thread = coroutine.create(function(ship)
			local task = ship.task
			while true do	
				task = ship.task
				if task then
					task.t(ship)  
					ship.task = nil
				else
					local q = self.taskqueue
					if q then
						local nt = q:First()
						if nt then 
							task = nt
							self.task = task
							q:Remove(nt)
							if q:Count() == 0 then
								self.taskqueue = nil
							end
							MsgN("Current ship task: ",nt.n)
						end
					end
				end 
				coroutine.yield()
			end
		end)
		self.thread = thread
	end
	if thread then 
		local status =  coroutine.status( thread )  
		if ( status == "dead" ) then
			MsgN( self, " Warning: spaceship thread has finished executing\n" ) 
			self.thread = nil
			self.taskqueue = nil
			self.task = nil
			return 
		end
		if (status=="suspended") then
			local ok, message = coroutine.resume(thread, self )
			if ( ok == false ) then 
				ErrorNoHalt( self, " Error: ", message, "\n" ) 
				self.thread = nil 
			end  
		end
	end
end
function ENT:GetHeadingElevation(dir) 
	local rad = dir:Length()
	local polar = math.atan(dir.z/dir.x)
	if dir.x < 0 then polar = polar + 3.1415926 end
	local elev = math.asin(dir.y/rad)
	return rad,polar,elev
end
function ENT:AddTask(task,name)
	local q = self.taskqueue or List()
	self.taskqueue = q
	q:Add({t =task,n = name or "[unknown]"})
	if CLIENT and name then
		local ply = LocalPlayer()
		if ply and ply:GetParent()==self then
			MsgInfo("ship status: "..name)
		end
	end
end
function ENT:AbortAllTasks()
	self.taskqueue = nil
	self.task = nil
	self.thread = nil
	
end

function ENT:DisableWarpMode() 
	self:SetScale(Vector(1,1,1))
	local wm = self.warpm
	wm:SetBrightness(0) 
	wm:Enable(false)
	MsgN("warp mode disabled")
	self.warpmode = false
	if SERVER then
		--network.RemoveNode(self)
		network.BroadcastCall("ship_jump_end",ship)
	end
end

function ENT:RotateLookAtStep(coord,speedmul) 
	speedmul = speedmul or 1
	local origin = coord[1]
	local pos = coord[2]
	
	local dir = Coordinate(self):Position(coord)--self:GetLocalCoordinates(origin) 
	local len = dir:Length()
	if len > 2 then
		DrawPoint(1000,self,dir/len*100,10000)
	else
		DrawPoint(1000,self,dir,10000)
	end
	local rad,polar,elev = self:GetHeadingElevation(dir)
	polar = polar / 3.1415926 * 180 - 90
	elev = elev / 3.1415926 * 180
	local dist = math.sqrt(polar*polar + elev*elev)
	--MsgN(polar)
	if(dist>0.3)then 
		self:Turn(polar/-300*speedmul)
		self:Turn3(elev/100*speedmul)
		return false
	else
		return true
	end
end

function ENT:TaskRotateLookAt(target)
	return function(ship)
		while true do
			if self:RotateLookAtStep(target) then
				return true
			end
			coroutine.yield( "loop" )
		end
	end
end
function ENT:BendSpacetime(power)
	local wm = self.warpm
	if wm then
		wm:SetBrightness(math.min(2,power*4)*0.5)
		--wm:SetBrightness(1)
		--wm:Enable(true)
		local maxbnd = math.min(1000000,1000000)--10000+1000000*power*power)
		wm:SetMatrix(matrix.Scaling(Vector(1000,1000,maxbnd)))
		--wm:SetMatrix(matrix.Scaling(Vector(1000,1000,1000)))
		if power > 0 then wm:Enable(true) else wm:Enable(false) end
		if self.warpmode then
			self:SetScale(Vector(1,1,math.max(0.00001,1-power)))
		else
			self:SetScale(Vector(1,1,1))
		end
	end
end
function ENT:TaskWarpTo(coord)   
	--if not self.task then 
	if SERVER then
		--network.AddNode(self)
	end
	local dtt = 100
	 
	return function(ship)
		
		local origin = coord[1]
		local pos = coord[2]
		
		local shipparent = ship:GetParent()
		
		local start_sz = shipparent:GetSizepower()
		local start_scpos = shipparent:GetLocalCoordinates(ship) 
		local start_pcpos = shipparent:GetLocalCoordinates(origin)--pos
		local start_dir = start_pcpos-start_scpos
	--MsgN("CO: ",sz)
		local start_ldist =start_scpos:Distance(start_pcpos) *start_sz 
		local warp_meanspeed = 5000--1 * CONST_AstronomicalUnit --1000
		--0.1 * CONST_AstronomicalUnit -- 0.1 au per second
		local warp_eda = CurTime()
		local warp_eft = start_ldist / warp_meanspeed
		local warp_eta = warp_eda + warp_eft
		MsgN("warp target asquired")
		MsgN("warp total distance: ",start_ldist/CONST_AstronomicalUnit, " au")
		MsgN("warp estimated total time: ",warp_eft, " seconds")
		MsgN("warp mode enabled")
		self.warpmode = true
		--BP(1,1,2,"sas")
		--BP(2,1,2,"sas",Vector(1,1,2))
		--BP(3,1,2,"sas",Vector(1,1,2),STARMAP==nil)
		--BP(4,1,2,"sas",Vector(1,1,2),STARMAP==nil,STARMAP)
		--BP(2,STARMAP)
		--MsgN("hm ",STARMAP)
		local warpspeed = 0
		local warpspeed_max =-1
		while true do
			local cshipparent = ship:GetParent()
			local sz = cshipparent:GetSizepower()
			local scpos = cshipparent:GetLocalCoordinates(ship) 
			local pcpos = cshipparent:GetLocalCoordinates(origin)--pos
			local dir = pcpos-scpos
			DrawPoint(1000,self,dir:Normalized()*100,10000)
		--MsgN("CO: ",sz)
			local ldist =scpos:Distance(pcpos) 
			local realdist = ldist*sz 
			--ship:LookAt(-dir:Normalized())
			ship:TaskRotateLookAt(coord,100)
			
			local percent_completed = --(CurTime() - warp_eda)/warp_eft 
			math.max(0.0001,math.min(1, 1-realdist/start_ldist))
			if realdist > start_ldist/2 then
				warpspeed = warpspeed + 0.01
			else
				if warpspeed_max<0 then warpspeed_max = warpspeed end
				--xnwarpspeed = math.max(0,warpspeed - 0.01)
				warpspeed = math.max(0,realdist/start_ldist*2)*warpspeed_max*20
			end
			if realdist > 4*UNIT_MM then
				local maxedwarpspeed = math.min(20,warpspeed)
				--local warpspeed = math.sin(percent_completed*3.1415926)
				ship:Throttle(maxedwarpspeed*maxedwarpspeed*warp_meanspeed,true) --*1000*4 --*maxedwarpspeed
				ship:BendSpacetime(maxedwarpspeed/8)
				--self.warpm:SetBrightness(math.min(1,warpspeed*4)*0.5)
				--self:SetScale(Vector(1,1,math.max(0.01,1-warpspeed/2)))
			else
				MsgN("warp destination reached") 
				self:DisableWarpMode() 
				break
			end
			if dtt <0 then
				local td,un = DistanceNormalize(realdist)
				MsgN(ship:GetParent()," - ",ship," - ",origin)
				MsgN("d: ",td," ",un," v: ",self.velocity:Length()," p: ",percent_completed)
				dtt = 100
			else
				dtt = dtt - 1
			end
			if percent_completed>0.5 then
				self.velocity = self.velocity*0.1
				ship:LookAt(-dir:Normalized())
				--MsgN("??? ",self.velocity:Length())
			end
			coroutine.yield("wot")
		end
		coroutine.yield( "what" )
	end
	--end
end
function ENT:TaskMoveTo(coord,precision)  
	precision = precision or 10
	return function(ship)
		while true do
			local current_coord = Coordinate(ship) 
			local curdist = current_coord:RealDistance(coord)
			
			if (curdist>precision) then
				self:RotateLookAtStep(coord) 
				local dt = math.min(0.05,curdist/2000)
				--if curdist < 10 then
				--	dt = math.min(0.1,curdist/10000)
				--end
				--MsgN(curdist," ", dt)
				self:Throttle(dt) 
				coroutine.yield()
			else
				break
			end
		end
	end
end

function ENT:TaskHyperjumpTo(coord)
	
	return function(ship)
		
		local origin = coord[1]
		local pos = coord[2]
		
		local shipparent = ship:GetParent()
		
		local start_sz = shipparent:GetSizepower()
		local start_scpos = shipparent:GetLocalCoordinates(ship) 
		local start_pcpos = shipparent:GetLocalCoordinates(origin)--pos
		local end_ppos = origin:GetLocalCoordinates(ship):Normalized()--pos
		local start_dir = start_pcpos-start_scpos
		
		local start_ldist =start_scpos:Distance(start_pcpos) *start_sz 
		local warp_meanspeed = 10000 * CONST_AstronomicalUnit
		
		local warp_eda = CurTime()
		local warp_eft = start_ldist / warp_meanspeed
		local warp_eta = warp_eda + warp_eft
		MsgN("jump target asquired")
		MsgN("jump total distance: ",start_ldist/CONST_LightYear, " ly")
		MsgN("jump estimated total time: ",warp_eft, " seconds")
		MsgN("jump mode enabled")
		
		local stage = 1
		local timerend = 0
		local warpspeed = 0
		MsgN("STAGE ",stage)
		while true do
			local cshipparent = ship:GetParent()
			local sz = cshipparent:GetSizepower()
			local scpos = cshipparent:GetLocalCoordinates(ship) 
			local pcpos = cshipparent:GetLocalCoordinates(origin)--pos
			local dir = pcpos-scpos
			DrawPoint(1000,self,dir:Normalized()*100,10000)
		--MsgN("CO: ",sz)
			local ldist =scpos:Distance(pcpos) 
			local realdist = ldist*sz 
			--ship:LookAt(-dir:Normalized())
			ship:TaskRotateLookAt(coord,100)
			
			local percent_completed = --(CurTime() - warp_eda)/warp_eft 
			math.max(0.0001,math.min(1, 1-realdist/start_ldist))
			
			if stage==1 then
				warpspeed = math.min(1, warpspeed + 0.002) 
				if warpspeed>=1 then
					local oldparent = self:GetParent()
					self:SetParent(origin)
					if (olparent~=origin) then
						oldparent:Leave()
						origin:Enter()
					end
					self:SetParent(origin)
					self:SetPos(end_ppos/100000000)--Vector(0.00001,0,0))--end_ppos/100000)
					self:EnteredNewSystem()
					stage = 2
					MsgN("STAGE ",stage)
					timerend = CurTime()+math.min(60, warp_eft)
				end
			elseif stage==2 then
				MsgN("eta ",timerend-CurTime())
				if timerend<=CurTime() then
					stage = 3 
					MsgN("STAGE ",stage)
				end
			elseif stage==3 then
				warpspeed = math.max(0, warpspeed - 0.002)
				
				if warpspeed<=0 then 
					stage = 4
					MsgN("STAGE ",stage)
					MsgN("jump destination reached") 
					self:DisableWarpMode() 
					break
				end
			
			end
			ship:Throttle(1000,true) --*1000*4
			ship:BendSpacetime(warpspeed)
			--self.warpm:SetBrightness(math.min(2,warpspeed*4)*0.5) 
			--self.warpm:SetMatrix(matrix.Scaling(Vector(1000,1000,10000+
			--1000000*warpspeed*warpspeed)))
			--self:SetScale(Vector(1,1,math.max(0.00001,1-warpspeed)))
			 
			
			coroutine.yield()
		end
	end
end

function ENT:WarpSequence(coord)--origin,pos
	--self:AbortAllTasks()
	if self:IsDocked() then
		self:UndockSequence()
	end
	self:AddTask(self:TaskRotateLookAt(coord),"warp target centering")
	self:AddTask(self:TaskWarpTo(coord),"warp jump")
end
function ENT:InstaDock(station)
	local dock_coord  = station.dock_coord
	self:SetParent(dock_coord[1])
	self:SetPos(dock_coord[2]) 
	self:SetAng(Vector(0,180,0)) 
	self:SendEvent(EVENT_DOCK_FINISH,station)
end
function ENT:DockSequence(station)
	--if CLIENT then return nil end
	local approach_coord = station.approach_coord
	local dock_coord  = station.dock_coord
	local aligna_coord  = station.aligna_coord
	local alignb_coord  = station.alignb_coord
	local alignc_coord  = station.alignc_coord
	
	self:AbortAllTasks()
	self:AddTask(self:TaskRotateLookAt(approach_coord),"warp centering")
	self:AddTask(self:TaskMoveTo(approach_coord,1000),"warp approach")
	self:AddTask(self:TaskRotateLookAt(approach_coord),"local centering")
	self:AddTask(self:TaskMoveTo(approach_coord),"local approach")
	self:AddTask(self:TaskRotateLookAt(aligna_coord),"align 1 centering")
	self:AddTask(self:TaskMoveTo(aligna_coord),"align 1 approach")
	self:AddTask(self:TaskRotateLookAt(alignb_coord),"align 2 centering")
	self:AddTask(self:TaskMoveTo(alignb_coord),"align 2 approach")
	self:AddTask(self:TaskRotateLookAt(dock_coord),"dock centering") 
	self:AddTask(self:TaskMoveTo(dock_coord,1),"dock approach")
	self:AddTask(self:TaskRotateLookAt(alignc_coord),"final align")
	self:AddTask(function(ship) 
		ship:SetPos(dock_coord[2]) 
		ship:SetAng(Vector(0,180,0)) 
		ship:SendEvent(EVENT_DOCK_FINISH,station)
	end,"docking")
	--lua_run LocalPlayer():GetParent():DockSequence(ents.GetById(-2147483648))
end
function ENT:UndockSequence()
	local station = self.dockedto
	if station then
		local approach_coord = station.approach_coord
		--local dock_coord  = station.dock_coord
		--local aligna_coord  = station.aligna_coord
		--local alignb_coord  = station.alignb_coord
		--local alignc_coord  = station.alignc_coord
		
		--self:AbortAllTasks()
		self:AddTask(function(ship) 
			ship:DockUnlinkAirlocks()
			for k=1,100 do coroutine.yield() end
			for k=1,100 do 
				ship:Throttle(-0.5)
				coroutine.yield()
			end
		end,"undocking")
		self:AddTask(self:TaskRotateLookAt(approach_coord),"exitnode centering")
		self:AddTask(self:TaskMoveTo(approach_coord),"exitnode approach")
		self:AddTask(function(ship) ship:SetState("flight") end,"undock finished")
		
	
	end
end
function ENT:HyperjumpSequence(coord)
	self:AbortAllTasks()
	self:AddTask(self:TaskRotateLookAt(coord),"hyperjump centering")
	self:AddTask(self:TaskHyperjumpTo(coord),"hyperjump")
end

function ENT:DockLinkAirlocks(station) 
	local dock = station.dock
	local shippos = self:GetPos()
	local airlock_left = self.airlock_left
	--local airlock_copy = SpawnSO("shiptest/dockslot.stmd",station,shippos,0.75)
	--airlock_left.copy = airlock_copy
	
	--											--  22,276  -223,01  16,502
	--local al2 = SpawnDoor("door/door.stmd",self,Vector(28.325,16.502,223.01)*0.001,0.75)
	--local al1 = SpawnDoor("door/door.stmd",self,Vector(22.276,16.502,223.01)*0.001,0.75)
	local activator_ent = ents.Create()
	activator_ent:SetSizepower(1000)
	activator_ent:SetSpaceEnabled(false)
	activator_ent:SetParent(dock)
	activator_ent:SetPos(shippos-Vector(22.276,-16.502,223.01)*0.001)
	activator_ent:AddEventListener(EVENT_USE,"use_event",function(self,user)  
		local dt = self:GetLocalSpace(user)
		user:SetParent(self)
		user:SetPos(dt:Position()) 
		user:SetAng(dt) 
		airlock_left.d2:Close()  
		airlock_left.d1:Open()
	end)
	activator_ent:AddFlag(FLAG_USEABLE) 
	activator_ent:Spawn()
	airlock_left.copy = activator_ent
	airlock_left:Open()
	self.dockedto = station
	self:SetState("docked")
	MsgN("copied ",activator_ent)
end
function ENT:DockUnlinkAirlocks() 
	local airlock_left = self.airlock_left
	airlock_left:Close()
	if airlock_left.copy then
		airlock_left.copy:Despawn()
		airlock_left.copy = nil
	end
	self.dockedto = nil
end
function ENT:IsDocked()
	return self.dockedto~=nil
end
function ENT:SetState(st)
	self:SetParameter(VARTYPE_STATE,st)
end
function ENT:GetState()
	return self:GetParameter(VARTYPE_STATE)
end

--[[
if SERVER then
	
	hook.Add("umsg.ship_jump","0",function(ship,target)
		MsgN("jump request received! ",ship, " => ",target)
		network.AssignNode(ship,0)
		ship:WarpSequence(Coordinate(target)) 
		network.BroadcastCall("ship_jump",ship,target)
	end) 
else -- CLIENT

	hook.Add("umsg.ship_jump","0",function(ship,target)
		MsgN("jump request accepted! ",ship, " => ",target) 
		ship:WarpSequence(Coordinate(target))  
	end) 
	hook.Add("umsg.ship_jump_end","0",function(ship) 
		ship.task = nil 
		ship:SetScale(Vector(1,1,1))
		ship.warpm:SetBrightness(0)
		ship.warpmode = false
	end) 
end
]]

ENT._typeevents = {
	[EVENT_WARPJUMP] = {networked = true, f = function(self,target) 
		self:WarpSequence(Coordinate(target)) end},
	[EVENT_HYPERJUMP] = {networked = true, f = function(self,target)  
		self:HyperjumpSequence(Coordinate(target)) end},
	[EVENT_DOCK] = {networked = true, f = ENT.DockSequence},
	[EVENT_DOCK_FINISH] = {networked = true, f = ENT.DockLinkAirlocks},
}
 