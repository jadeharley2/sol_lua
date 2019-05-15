--lua_run TEST_CGM(GetCamera():GetParent())
function TEST_CGM(parent,pos)
	local m =  ents.Create("galaxy_map")
	m:SetParent(parent)
	m:SetSizepower(1) 
	m:SetSpaceEnabled(false) 
	
	m.ship = parent 
	m:LoadSystemMap()
	--m:DataFromRealSystem(parent,parent:GetParentWith(NTYPE_STARSYSTEM))
	 
	
	m:SetPos(pos)  
	m:Spawn() 
	--GetCamera():SetParent(m.system)
	return m
end

function ENT:Init()
	self.holo_center = Vector(0,0,0)
	self.holo_scale = 30 
end

function ENT:CreateRingModel(output,radius,radius2) 
	local mb = procedural.Builder() 
	local pts = {}
	if istable(radius) then
		for k,v in pairs(radius) do
			pts[k] = VectorJ(v) 
		end
	else
		for k=1,36*2+1 do
			local val = Vector(radius,0,0):Rotate(Vector(0,k*5,0))
			pts[k] = VectorJ(val) 
		end 
	end
	local mbp = json.ToJson(
		{
			operations = {
				{ type = "line", out="circle",
					points = pts
				},
				{type = "column",from="circle",out="result",
					r = radius2
				}
			}
		}
	)
	if isstring(output) then
		mb:BuildModel(output,mbp)
	else
		mb:BuildModelAsync(output,mbp)
	end
end
function ENT:CreatePathModel(output,points,radius) 
	local mb = procedural.Builder() 
	local pts = {} 
	for k,v in pairs(points) do
		pts[k] =  VectorJ(v) 
	end
	local mbp = json.ToJson(
		{
			operations = {
				{ type = "line", out="circle",
					points = pts
				},
				{type = "column",from="circle",out="result",
					r = radius
				}
			}
		}
	)
	if isstring(output) then
		mb:BuildModel(output,mbp)
	else
		mb:BuildModelAsync(output,mbp)
	end
end

function ENT:Spawn()
	local system = self:GetParentWith(NTYPE_STARSYSTEM)
	
	local root =  ents.Create()
	root:SetSizepower(2000)
	root:SetSeed(1110222)
	root:SetSpaceEnabled(false) 
	root:Spawn()
	--root:SetParent(self)
	--root:SetScale(Vector(1,1,1)/20000)
	self.root = root
	
	--local cam =  ents.CreateCamera()
	--self.cam = cam
	--cam:SetParent(root)
	--cam:SetSeed(13113)
	--if CLIENT then
	--	cam:SetAspectRatio(GetCamera():GetAspectRatio()) 
	--end
	--cam:Spawn()
	
	local testdata = {
		objects = { 
			{ id = 1, type = "star", radius = 10, color = Vector(1,0,0)},
			{ id = 2, type = "planet", parent = 1, orbit = { a = 25 }, radius = 1, color = Vector(0.4,0.4,0.6)},
			{ id = 3, type = "planet", parent = 1, orbit = { a = 40 }, radius = 0.4, color = Vector(0.4,0.4,0.6)},
			{ id = 4, type = "planet", parent = 1, orbit = { a = 60 }, radius = 6, color = Vector(0.4,0.4,0.6)}
		}
	}
	
	if CLIENT then
		--local vsize = GetViewportSize()  
		--local rt = CreateRenderTarget(vsize.x,vsize.y,"@maprt:Texture2D")
		--self.rt = rt
		--hook.Add("window.resize","updatert",function() 
		--	local cm = GetCamera()
		--	local vsize = GetViewportSize()  
		--	ResizeRenderTarget(rt, vsize.x,vsize.y) 
		--	self.cam:SetAspectRatio(cm:GetAspectRatio()) 
		--end)
		
		
		local skybox = root:AddComponent(CTYPE_SKYBOX) 
		skybox:SetRenderGroup(RENDERGROUP_LOCAL) 
		skybox:SetTexture("textures/cubemap/bluespace.dds")
		self.skybox = skybox

		local root_skyb =  ents.Create()
		root_skyb:SetSizepower(2000)
		root_skyb:SetParent(root)
		root_skyb:SetPos(Vector(0,100,0))
		root_skyb:Spawn()

		local cubemap = root_skyb:AddComponent(CTYPE_CUBEMAP)  
		self.cubemap = cubemap 
		cubemap:SetTarget(nil,root) 
		
	end



	self:CreateRingModel("@selector_ring",1,0.05)
	self:CreateRingModel("@planet_ring",1,0.05)
	--[[
	local mb = MeshBuilder() 
	local pts = {}
	for k=1,36*2+1 do
		local val = Vector(1,0,0):Rotate(Vector(0,k*5,0))
		pts[k] = val 
	end
	mb:AddLine(0.05,4,pts) 
	mb:ToModel("@selector_ring")
	 
	
	local mb2 = MeshBuilder() 
	mb2:AddLine(0.05,4,pts) 
	mb2:ToModel("@planet_ring")
	
	local ptd = {}
	for k=1,36*2+1 do
		local val = Vector(0.05,0,0):Rotate(Vector(0,k*5,0))
		ptd[k] = val 
	end  
	local pts2 = {}
	for k=1,36*2+1 do
		local val = Vector(2,0,0):Rotate(Vector(0,k*5,0))
		pts2[k] = val 
	end 
	local pts3 = {}
	for k=1,36*2+1 do
		local val = Vector(3,0,0):Rotate(Vector(0,k*5,0))
		pts3[k] = val 
	end 
	local pts4 = {}
	for k=1,36*2+1 do
		local val = Vector(4,0,0):Rotate(Vector(0,k*5,0))
		pts4[k] = val 
	end 
	local mb3 = MeshBuilder() 
	mb3:AddLine(0.002,4,ptd)  
	mb3:AddLine(0.002,4,pts)  
	mb3:AddLine(0.002,4,pts2) 
	mb3:AddLine(0.002,4,pts3) 
	mb3:AddLine(0.002,4,pts4) 
	mb3:ToModel("@gal_ring")
	]]
	
	local selector =  ents.Create()
	selector:SetSizepower(5)
	selector:SetParent(self.root)
	selector:SetSpaceEnabled(false) 
	selector:Spawn()
	
	local model3 = selector:AddComponent(CTYPE_MODEL) 
	model3:SetRenderGroup(RENDERGROUP_LOCAL)
	model3:SetModel("@selector_ring") 
	model3:SetMaterial("textures/debug/fullbright.json") 
	model3:SetBlendMode(BLEND_ADD) 
	model3:SetRasterizerMode(RASTER_DETPHSOLID) 
	model3:SetDepthStencillMode(DEPTH_ENABLED)    
	model3:SetMatrix(matrix.Scaling(1.2))
	model3:SetBrightness(1)
	model3:SetFadeBounds(0.000001,99999,0.0000005)  
	model3:SetColor(Vector(1,0.3,0.1)*0.5)
	
	TESTSELECTOR = selector
	
	self:LoadMap(self.dataaa)--testdata)
	self.cubemap:RequestDraw()
	 



	--[[
	local holoBack = self:AddComponent(CTYPE_MODEL) 
	holoBack:SetRenderGroup(RENDERGROUP_LOCAL)
	holoBack:SetModel("engine/gsphere_24_inv.stmd") 
	holoBack:SetMaterial("textures/debug/brightrim.json") 
	holoBack:SetBlendMode(BLEND_SUBTRACT) 
	holoBack:SetRasterizerMode(RASTER_DETPHSOLID) 
	holoBack:SetDepthStencillMode(DEPTH_ENABLED)    
	holoBack:SetBrightness(1)
	holoBack:SetMatrix(matrix.Scaling(3.85))
	holoBack:SetFadeBounds(0.000001,99999,0.0000005)    
	
	 
	local holo = self:AddComponent(CTYPE_MODEL) 
	holo:SetRenderGroup(RENDERGROUP_LOCAL)
	holo:SetModel("engine/gsphere_24_inv.stmd") 
	holo:SetMaterial("textures/target/maprt.json") 
	holo:SetBlendMode(BLEND_ADD) 
	holo:SetRasterizerMode(RASTER_DETPHSOLID) 
	holo:SetDepthStencillMode(DEPTH_ENABLED)    
	holo:SetBrightness(1)
	holo:SetMatrix(matrix.Scaling(3.8))
	holo:SetFadeBounds(0.000001,99999,0.0000005)   
	self.holo = holo
	]]
	
	local origin =  ents.Create()
	origin:SetSizepower(1)
	origin:SetParent(root)
	origin:SetSpaceEnabled(false) 
	origin:Spawn()
	self.origin = origin
	local originmodel = origin:AddComponent(CTYPE_MODEL) 
	originmodel:SetRenderGroup(RENDERGROUP_LOCAL)
	originmodel:SetModel("engine/origin2.stmd") 
	originmodel:SetMaterial("textures/debug/fullbright.json") 
	originmodel:SetBlendMode(BLEND_OPAQUE) 
	originmodel:SetRasterizerMode(RASTER_DETPHSOLID) 
	originmodel:SetDepthStencillMode(DEPTH_ENABLED)    
	originmodel:SetBrightness(1)
	originmodel:SetMatrix(matrix.Scaling(1))
	originmodel:SetFadeBounds(0.000001,99999,0.0000005)   
	
	
	
	--[[
	local light = self:AddComponent(CTYPE_LIGHT)  
	light:SetColor(Vector(0.1,0.2,0.9))
	light:SetBrightness(10) 
	self.light = light
	]]
	
	STARMAP = self
	self.spawned = true
	
	if CLIENT then
		
		--hook.Add("main.postcontroller", "galaxymap"..tostring(seed), function() self:UpdateMap() end)
		--
		--local renderer = self:AddComponent(CTYPE_CAMERA) 
		--self.renderer = renderer
		--renderer:SetCamera(cam)
		--renderer:SetRenderTarget(1,self.rt)
		--renderer:RequestDraw(holo)
		--
		--self:AddEventListener(EVENT_USE,"use_event",function(self,user)
		--	self:Convert(user)
		--end)
		--self:AddFlag(FLAG_USEABLE) 
	end
	
	if system then self:AddVisitedSystem(system) end
end

function ENT:Despawn()
	local root = self.root
	if root then
		root:Despawn()
	end
	hook.Remove("main.postcontroller", "galaxymap"..tostring(seed))
end
function ENT:Think()
	self:UpdateShipPosition()
end

function ENT:OpenMap(user,mode)
	if(CLIENT and user==LocalPlayer()) then
 
		if mode == 'galaxy' then
			self.state = 'galaxy'
			self:LoadGalaxyMap()
		else
			self.state = 'starsystem'
			self:LoadSystemMap()
		end

		if IsValidEnt(self.system)  then
			local camera = GetCamera()
			camera:SetParent(self.system)
			local p = self:UpdateShipPosition()
			if p then
				camera:SetPos(p)
			end
			self:SetUpdating(true,30)

			SetController("starmap")
			STARMAP.cam = camera
			render.DCISetEnabled(true)
		end
	end
end
function ENT:CloseMap(user)
	if(CLIENT and user==LocalPlayer()) then 
		local camera = GetCamera()
		camera:SetParent(user)
		SetController("actor") 
		self:SetUpdating(false)
		render.DCISetEnabled(false)
	end
end

function ENT:Convert(user)
	local s = self.root
	local origin = self.origin 
	if not s.space then
		local space = s:AddComponent(CTYPE_PHYSSPACE)  
		space:SetGravity(Vector(0,-2.5,0))
		s.space = space 
		local coll = s:AddComponent(CTYPE_STATICCOLLISION) 
		coll:SetShape("engine/zplane.stmd", matrix.Scaling(1000) * matrix.Rotation(-90,0,0) ) 
		s.coll = coll
	end
	
	
	user:SetParent(s)
	user:SetPos(origin:GetPos())
	local um = user.model
	um:SetMaterial("models/renamon/tex/SystemMaterial.json")
	--um:SetMaterial("textures/debug/wireframe.json") 
	um:SetBlendMode(BLEND_ADD) 
	um:SetRasterizerMode(RASTER_DETPHSOLID) 
	um:SetDepthStencillMode(DEPTH_ENABLED)    
	um:SetBrightness(1)
	um:SetFadeBounds(0.000001,99999,0.0000005)  
	um:SetColor(Vector(0.1,0.3,1)*0.5)
	
	local sdm = user:AddComponent(CTYPE_MODEL)   
	
	local world = matrix.Scaling(0.03) 
	sdm:SetModel(user:GetParameter(VARTYPE_MODEL))
	sdm:SetMaterial("models/renamon/tex/renamon.json")
	sdm:SetRenderGroup(RENDERGROUP_LOCAL) 
	sdm:SetBlendMode(BLEND_OPAQUE) 
	sdm:SetRasterizerMode(RASTER_DETPHSOLID) 
	sdm:SetDepthStencillMode(DEPTH_ENABLED)  
	sdm:SetBrightness(1)
	sdm:SetFadeBounds(0,99999,0)   
	sdm:SetMatrix(world*matrix.Translation(-user.phys:GetFootOffset()*0.75)*matrix.Scaling(0.001))
	sdm:SetCopyTransforms(um)
	user.sdm = sdm
	local sptext = user:AddComponent(CTYPE_SPRITETEXT)  
	sptext:SetRenderGroup(RENDERGROUP_LOCAL)
	sptext:SetText(user:GetName() or "")
	sptext:SetMaxRenderDistance(1000000)
	user.sptext = sptext 
	
	self.objects[#self.objects+1] = user
	
	local sdd = 1
	local m1 = "models/kindred/tex/DefaultMaterial.json"
	local m2 = "models/kindred/tex/SystemMaterial.json"
	_gmdf = {m1=m1,m2=m2,sdd=1,sdm=sdm,user=user,um=um}
	debug.DelayedTimer(2000,16,1000,function()
		if(_gmdf.sdd>0)then 
			SetMaterialProperty(_gmdf.m1,"noiseclip",true)
			SetMaterialProperty(_gmdf.m2,"noiseclip",true)
			SetMaterialProperty(_gmdf.m1,"noiseclipmul",1) 
			SetMaterialProperty(_gmdf.m2,"noiseclipmul",-1) 
			SetMaterialProperty(_gmdf.m1,"noiseclipedge",1-_gmdf.sdd)
			SetMaterialProperty(_gmdf.m2,"noiseclipedge",_gmdf.sdd-1.05) 
			_gmdf.sdd = _gmdf.sdd -0.001
			
			_gmdf.um:SetUpdateRate(math.lerp(10,60,_gmdf.sdd))
		else
			SetMaterialProperty(_gmdf.m1,"noiseclip",false)
			SetMaterialProperty(_gmdf.m2,"noiseclip",false)
			_gmdf.user:RemoveComponent(_gmdf.sdm)
			_gmdf.um:SetUpdateRate(10)
		--	sdd = 1
			_gmdf = nil
		end
	end)
end
function ENT:UpdateShipPosition() 
	local shipm = self.shipmodel
	if shipm then
		local system = self:GetParentWith(NTYPE_STARSYSTEM)
		local ship = self.ship
		if system then
			local star = system:GetChildren()[1]
			local sz = star:GetSizepower()
			local lp = star:GetLocalCoordinates(ship)--/100*5--sz/UNIT_AU*50*1000 --*sz--/UNIT_AU*50*10000000
			local rpd = lp*(sz/UNIT_AU*50 /1000)
			shipm:SetPos(rpd)
			return rpd
			--MsgN(rpd)
			--*(sz/CONST_AstronomicalUnit*50)
			--for k,v in pairs(self.objects) do
			--	local sv = v.ref
			--	if sv then
			--		local ccc = star:GetLocalCoordinates(sv)
			--		v:SetPos(ccc/10)
			--	end
			--end
		end
	end
end
function ENT:UpdateMap()
	 
	local enstate = self.ens or false
	local s = self:GetScale()
	local dst = self:GetDistance(GetCamera())*s.x 
	if(enstate and dst>11) then 
		self.targets = 0.01
		self.ens = false 
	elseif (not enstate and dst<10) then 
		self.targets = 1 
		self.ens = true 
	end
	local ts = self.targets
	if ts then
		local df = s.x+ (ts-s.x)/20
		self:SetScale(Vector(df,df,df))
		
	end 
	local visible = s.x>0.1
	
	if visible then
		
		
		STARMAP.holo_center = STARMAP:GetNWVector("holo_center",STARMAP.holo_center) 
		STARMAP.holo_scale = STARMAP:GetNWDouble("holo_scale",STARMAP.holo_scale) 
		local realcam = GetCamera()
		local ls =self:GetLocalSpace(realcam)
		local ptc = ls:Position() --realcam:GetPos() - self.holo_center 
		self.cam:SetPos(ptc*0.001*self.holo_scale+self.holo_center)--*self.holo_scale
		--self.cam:CopyAng(realcam)
		self.cam:SetAng(ls)
		self.origin:SetPos(self.holo_center)
		self.renderer:RequestDraw()--self.holo)
		
	end
	
end
function ENT:ReloadCurrentMap()
	local smap = self.state
	if smap == "celestial" then self:LoadCelestialMap() end
	if smap == "starsystem" then self:LoadSystemMap() end
	if smap == "galaxy" then self:LoadGalaxyMap() end 
end
function ENT:LoadCelestialMap(celestial)
	self:UnloadMap()
	self.state = "celestial"
	self.dataaa  = self:GetCelestialData(celestial.ref or self:GetParentWithFlag(FLAG_PLANET))
	
	self:LoadMap(self.dataaa)
end
function ENT:LoadSystemMap(systemid)
	local ship = self:GetParent()
	self.ship = ship
	
	local tempdata = false
	if systemid then
		tempdata = self.savedsystems[systemid]
	else
		local system = self:GetParentWith(NTYPE_STARSYSTEM)
		tempdata = self:DataFromRealSystem(ship,system) 
	end
	
	if ship and tempdata then
		self:UnloadMap()
		self.dataaa = tempdata
		self.state = "starsystem"
		self:LoadMap(self.dataaa)
	end
end
function ENT:LoadGalaxyMap()
	local ship = self:GetParent() 
	self.ship = ship
	--self.system = system
	if ship then 
		self:UnloadMap()
		self.dataaa = self:GetGalaxyMapData(ship)
		self.state = "galaxy"
		self:LoadMap(self.dataaa)
	end
end
local function entHasParent(ent,par)  
	for k,v in pairs(ent:GetHierarchy()) do 
		if(v==par)then  
			return true 
		end
	end
	return false
end

function ENT:GetCelestialData(planet)
	local data = { objects = {} }
	
	data.objects[1] = { id = 1, type = "detailedplanet", ref = planet, pos = Vector(0,0,0) }
	return data
end

function ENT:DataFromRealSystem(ship,system)
	MsgN("### MAP DATA SCAN: ",ship,system)
	if not ship or not system then return nil end
	local data = { objects = {} }
	local star = system:GetChildren()[1]
	for k,v in pairs(system:GetChildren()) do
		if v:HasFlag(FLAG_STAR) then
			star = v
		end
	end

	local plst = star:GetChildren()
	data.objects[1] =
	{ id = 1, type = "star", radius = math.log( math.abs(star.radius or 1)/6371000)/10 , 
		color = star.color, name = star:GetName() } --or Vector(0.8,0.4,0.2)
	for k,v in pairs(plst) do
		if v.iscelestialbody then
			local pid = (#data.objects+1)
			local newplanet = {type = "planet", parent = 1, id = pid}
			newplanet.radius = math.log(math.abs(v.radius or 1)/6371000)/10
			newplanet.pos = v:GetPos() 
			newplanet.name = v:GetName()
			newplanet.isp = entHasParent(ship,v)
			newplanet.ref = v
			local voa = v.orbit:GetParam("a")
			newplanet.orbit = {
				--a =math.abs( math.log(v.orbit:GetParam("a")/UNIT_AU)*100), 
				
				a = voa/UNIT_AU*50, 
				e = v.orbit:GetParam("e"), 
				i = v.orbit:GetParam("i"), 
				p = v.orbit:GetParam("p"),
				al = v.orbit:GetParam("ascendinglongitude"),
			}
			data.objects[newplanet.id] = newplanet
			
			for k2,v2 in pairs(v:GetChildren()) do
				if v2.dock_coord then
					local sid = (#data.objects+1)
					local newstation = {type = "station", parent = pid, id = sid }
					
					newstation.ref = v2
					data.objects[newstation.id] = newstation
				end
			end
			
		end
	end
	--PrintTable(data,999)
	return data
end

function ENT:GetGalaxyMapData(ship)
	local galaxy = ship:GetParentWith(NTYPE_GALAXY)
	local cursystem = ship:GetParentWith(NTYPE_STARSYSTEM)
	local data = { objects = {} }

	if galaxy then -- and cursystem then
		data.objects[1] ={ id = 1, type = "galaxy", } 
		
		local syspos= galaxy:GetLocalCoordinates(ship)
		--local syspos = cursystem:GetPos()
		for k,v in pairs(galaxy:GetChildren()) do
			local offpos = (v:GetPos()-syspos)*10000 
			local isgen =false-- v[VARTYPE_GENERATOR] ~= "com.system.default"
			--if isgen then
			--	MsgN(v)
			--end
			if offpos:LengthSquared() < 1 or isgen then
				local newstarsystem = {type = "system", parent = 1, id = (#data.objects+1)}
				newstarsystem.pos =  offpos
				newstarsystem.ref = v
				newstarsystem.name = v:GetName()
				newstarsystem.color = v:GetParameter(VARTYPE_COLOR)
				data.objects[newstarsystem.id] = newstarsystem
			end
		end 
	end
	return data
end

function ENT:AddVisitedSystem(system)
	local vs = self.visitedsystems or List()
	vs:Add(system:GetPos() )
	self.visitedsystems = vs
	
	debug.Delayed(1,function()
		self:ReloadCurrentMap()
		self.holo_center = Vector(0,0,0)
	end)
end
function ENT:UnloadMap()
	local system = self.system 
	if IsValidEnt(TESTSELECTOR) and IsValidEnt(self.root) then TESTSELECTOR:SetParent(self.root) end
	if system then
		self.objects = nil
		self.system = nil
		system:Despawn()
	end
end

function ENT:LoadMap(data)
	--MsgN("####### MAP DATA #######")
	--PrintTable(data)
	--MsgN("####### END DATA #######")
	if not self.spawned then return false end
	local system =  ents.Create()
	system:SetSizepower(1000) 
	system:SetSeed(1110333)
	system:SetParent(self.root)
	system:SetSpaceEnabled(false) 
	system:Spawn()
	local objects = {}
	for k,v in pairs(data.objects) do
		if v.type == "planet" or  v.type == "star" then
			self:CreateCelestialBody(v,objects,system)
		elseif v.type == "detailedplanet" then
			self:CreateCelestialBodySurface(v,objects,system)
		elseif v.type == "system" then
			self:CreateStarsystem(v,objects,system)
		elseif v.type == "station" then
			self:CreateStation(v,objects,system)
		end
	end 
	self.system = system
	self.objects = objects
	
	
	self.shipmodel = nil
	self.shippath = nil
	local curshipPos = self:GetParentWith(NTYPE_GALAXY):GetLocalCoordinates(self.ship)
	
	if self.state == "galaxy" then
		local vs = self.visitedsystems
		if vs and vs:Count()>1 then
			--if false then
				local cursystem = self:GetParentWith(NTYPE_STARSYSTEM)
				local syspos = cursystem:GetPos()
				local mb = MeshBuilder() 
				local pts = {}
			
				for k,v in list(self.visitedsystems) do 
					pts[#pts+1] = (v-curshipPos)*10000
				end
				if #pts >= 3 then
					--mb:AddLine(0.0005,4,pts) 
					--mb:ToModel("@shippath")
					local shippath = system:AddComponent(CTYPE_MODEL) 
					shippath:SetRenderGroup(RENDERGROUP_LOCAL)
					self:CreatePathModel(shippath,pts,0.0002)
					--shippath:SetModel("@shippath") 
					shippath:SetMaterial("textures/debug/fullbright.json") 
					shippath:SetBlendMode(BLEND_OPAQUE) 
					shippath:SetRasterizerMode(RASTER_DETPHSOLID) 
					shippath:SetDepthStencillMode(DEPTH_ENABLED)  
					shippath:SetMatrix(matrix.Scaling(1))
					shippath:SetBrightness(1)
					shippath:SetFadeBounds(0.000001,99999,0.0000005)  
					shippath:SetColor(Vector(0.1,1,0.1)*3)
					self.shippath = shippath
					MsgN('uu')
				end
			--end
		end
		 
		
	else 
		local shipm =  ents.Create()
		shipm:SetSizepower(1)
		shipm:SetParent(system)
		shipm:SetSpaceEnabled(false) 
		shipm:Spawn()
		
		local shipmodel = shipm:AddComponent(CTYPE_MODEL) 
		shipmodel:SetRenderGroup(RENDERGROUP_LOCAL)
		shipmodel:SetModel("engine/csphere_36_cylproj.stmd") 
		shipmodel:SetMaterial("textures/debug/fullbright.json") 
		shipmodel:SetBlendMode(BLEND_OPAQUE) 
		shipmodel:SetRasterizerMode(RASTER_DETPHSOLID) 
		shipmodel:SetDepthStencillMode(DEPTH_ENABLED)  
		shipmodel:SetMatrix(matrix.Scaling(0.01))
		shipmodel:SetBrightness(1)
		shipmodel:SetFadeBounds(0.000001,99999,0.0000005)  
		shipmodel:SetColor(Vector(0.1,1,0.1)*3)
		shipmodel:SetMaxRenderDistance(1000000)
		
		self.shipmodel = shipm
		
		local sptext = shipm:AddComponent(CTYPE_SPRITETEXT)  
		sptext:SetRenderGroup(RENDERGROUP_LOCAL)
		sptext:SetText("Ship")
		sptext:SetMaxRenderDistance(1000000)
		shipm.sptext = sptext 
	end
	 
	
	local skybox = self.skybox
	
	if self.state == "galaxy" then
		local galmodel = system:AddComponent(CTYPE_MODEL) 
		galmodel:SetRenderGroup(RENDERGROUP_LOCAL)
		galmodel:SetModel("space/galaxy_add.stmd") 
		galmodel:SetMaterial("textures/space/galaxies/01.json")--eso1339g.jpg")-- eso1339gc.jpg")
	    galmodel:SetBlendMode(BLEND_ADD) 
		galmodel:SetRasterizerMode(RASTER_NODETPHSOLID) 
		galmodel:SetDepthStencillMode(DEPTH_DISABLED)    
		galmodel:SetMatrix(matrix.Scaling(15000)* matrix.Rotation(90,50,0)*matrix.Translation(-curshipPos*10000))
		galmodel:SetBrightness(1)
		galmodel:SetFadeBounds(500,99999,500) 
		galmodel:SetMaxRenderDistance(1000000)
	
	--local gring = system:AddComponent(CTYPE_MODEL) 
	--gring:SetRenderGroup(RENDERGROUP_LOCAL)
	--gring:SetModel("@gal_ring") 
	--gring:SetMaterial("textures/debug/fullbright.json") 
	--gring:SetBlendMode(BLEND_ADD) 
	--gring:SetRasterizerMode(RASTER_NODETPHSOLID) 
	--gring:SetDepthStencillMode(DEPTH_DISABLED)    
	--gring:SetMatrix(matrix.Scaling(1000)*matrix.Translation(-cursystem:GetPos()*10000))
	--gring:SetBrightness(1)
	--gring:SetFadeBounds(0.000001,999999999,0.0000005)  
	--gring:SetColor(Vector(0.1,0.3,1)*0.5)
	--gring:SetMaxRenderDistance(1000000)
		 
		
		if skybox then 
			skybox:SetBrightness(0)
		end
	else
		--gring:SetMatrix(matrix.Scaling(1000)*cursystem:GetWorld():Inversed())--matrix.Scaling(1000)*matrix.Translation(-cursystem:GetPos()*10000)*matrix.Rotation(-cursystem:GetAng()))
		--if skybox then 
		--	local ssystem = self:GetParentWith(NTYPE_STARSYSTEM)
		--	if ssystem then
		--		local syssky = ssystem.skybox
		--		if syssky then
		--			syssky:CopyTexture(skybox)
		--		end
		--	end
			skybox:SetBrightness(1)
		--end
	end
	
end

function ENT:CreateCelestialBody(data,objects,root)
	local body =  ents.Create()
	CAMTESTPR = body
	body:SetSizepower(data.radius)
	--if data.parent then body:SetParent(objects[data.parent]) else 
	body:SetParent(root) -- end
	if data.name then body:SetName(data.name) end
	body:SetSpaceEnabled(false) 
	body:Spawn()
	body.selectable = true
	body.ref = data.ref
	objects[data.id or k] = body
	
	if data.orbit then
		----[[
		local orbit = body:AddComponent(CTYPE_ORBIT) 
		 
		--a_diameter, 
		--eccentricity, 
		--inclination, 
		--periargument, 
		--ascendinglongitude, 
		--meanAnomaly, 
		--orbtialspeed
		orbit:SetOrbit(
			data.orbit.a,
			data.orbit.e or 0,
			data.orbit.i or 0,
			data.orbit.p or 0,
			data.orbit.al or 0,
			0, 
			0.1--20000/data.orbit.a
		)
		body.orbit = orbit
		--body:SetPos(body.pos
		
		if data.parent then
			local pd = objects[data.parent] 
			if pd then
				body.orbit:SetParent(pd)
			end
		end
		
		--local mb = MeshBuilder()
		--for f=1, 3 do
			local pts = {}
			for k=1,36*2+1 do
				local val = orbit:GetPosition(k*5) 
				pts[k] = val 
			end
		--	mb:AddLine(0.00004,4,pts)
		--	mb:AddLine(0.0001,4,pts)
		--end
		--mb:ToModel("@testmodel_"..tostring(data.id))
		
		local model3 = root:AddComponent(CTYPE_MODEL) 
		model3:SetRenderGroup(RENDERGROUP_LOCAL)
		--model3:SetModel("@testmodel_"..tostring(data.id)) 
		
		self:CreateRingModel(model3,pts,0.0001)
		model3:SetMaterial("textures/debug/fullbright.json") 
		model3:SetBlendMode(BLEND_ADD) 
		model3:SetRasterizerMode(RASTER_DETPHSOLID) 
		model3:SetDepthStencillMode(DEPTH_READ)   
		model3:SetBrightness(1)
		model3:SetFadeBounds(0.000001,99999,0.0000005)  
		model3:SetColor(Vector(0.1,0.3,1)*0.5)
		model3:SetMaxRenderDistance(1000000)
		--]]
	end
	
	
	local model = body:AddComponent(CTYPE_MODEL) 
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel("engine/csphere_36_cylproj.stmd") 
	model:SetMaterial("textures/debug/fullbright.json") --"textures/debug/white.json") 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED) 
	model:SetMaxRenderDistance(1000000)
	
	model:SetMatrix(matrix.Scaling(2))
	model:SetBrightness(0.8)
	model:SetFadeBounds(0.000001,99999,0.0000005)  
	--model:SetMatrix(matrix.Scaling(-1))
	--model:SetMaterial("textures/space/star/blackhole.json") 
	

	
	-- -- local model4 = body:AddComponent(CTYPE_MODEL) 
	-- -- model4:SetRenderGroup(RENDERGROUP_LOCAL)
	-- -- model4:SetModel("@planet_ring") 
	-- -- model4:SetMaterial("textures/debug/fullbright.json") 
	-- -- model4:SetBlendMode(BLEND_ADD) 
	-- -- model4:SetRasterizerMode(RASTER_DETPHSOLID) 
	-- -- model4:SetDepthStencillMode(DEPTH_ENABLED)    
	-- -- model4:SetMatrix(matrix.Scaling(3))
	-- -- model4:SetBrightness(1)
	-- -- model4:SetFadeBounds(0.000001,99999,0.0000005)  
	-- -- model4:SetColor(Vector(0.1,1,0.3)*3)
	-- -- model4:SetMaxRenderDistance(1000000)
	-- -- if data.isp then 
	-- -- 	model4:SetColor(Vector(1,0,0))
	-- -- end
	
	if data.type == "star" then
		local light = body:AddComponent(CTYPE_LIGHT)  
		light:SetColor(data.color or Vector(1,1,1))
		light:SetBrightness(2000) 
		body.light = light
		
		model:SetColor(data.color or Vector(1,1,1))
		model:SetFullbright(true)
		model:SetBrightness(1)
		
		--self.light:SetColor(data.color or Vector(1,1,1))--Vector(0.1,0.2,0.9))
		
		
	elseif data.type == "planet" and data.id == 3 then
	
	
		local model2 = body:AddComponent(CTYPE_MODEL) 
		model2:SetRenderGroup(RENDERGROUP_LOCAL)
		model2:SetModel("space/rings.stmd") 
		model2:SetMaterial("textures/space/rings_test.json") 
		model2:SetBlendMode(BLEND_OPAQUE) 
		model2:SetRasterizerMode(RASTER_DETPHSOLID) 
		model2:SetDepthStencillMode(DEPTH_ENABLED)  
		model2:SetMatrix(matrix.Scaling(1.5)*matrix.Rotation(90+10,0,20))
		model2:SetBrightness(0.8)
		model2:SetFadeBounds(0.000001,99999,0.0000005) 
		model2:SetMaxRenderDistance(1000000) 
		
	
	end
	
	
	local sptext = body:AddComponent(CTYPE_SPRITETEXT)  
	sptext:SetRenderGroup(RENDERGROUP_LOCAL)
	sptext:SetText(body:GetName() or "")
	sptext:SetMaxRenderDistance(1000000)
	body.sptext = sptext 
	
	body.model = model
	body:SetUpdating(true,1000)
	
end

function ENT:CreateCelestialBodySurface(data,objects,root)
	local body =  ents.Create() 
	local bsz = data.ref:GetSizepower()
	body:SetSizepower(bsz) 
	body:SetParent(root) -- end 
	body:SetSpaceEnabled(false) 
	body:SetPos(data.pos)
	body.type = "system"
	body:SetSeed(data.ref:GetSeed()+1000)
	body:SetScale(Vector(1,1,1)/bsz)
	body:Spawn()
	body:SetName(data.name or "")
	body.ref = data.ref
	objects[data.id or k] = body 
	
	local partition = body:AddComponent(CTYPE_PARTITION2D) 
	local surfacecom = body:AddComponent(CTYPE_SURFACE)   
	
	local arch = body.ref:GetParameter(VARTYPE_ARCHETYPE)
	if arch then
		surfacecom:SetArchetype(arch)
	end
	surfacecom:LinkToPartition()
	surfacecom:SetRenderGroup(RENDERGROUP_LOCAL)
end
function ENT:CreateStarsystem(data,objects,root)
	local body =  ents.Create() 
	body:SetSizepower(1) 
	body:SetParent(root) -- end 
	body:SetSpaceEnabled(false) 
	body:SetPos(data.pos)
	body.type = "system"
	body:Spawn()
	body:SetName(data.name or "")
	body.selectable = true
	body.ref = data.ref
	objects[data.id or k] = body 
	
	--local ri = root.instss
	--if not ri then 
		local model = body:AddComponent(CTYPE_MODEL) 
		model:SetRenderGroup(RENDERGROUP_LOCAL)
		model:SetModel("engine/gsphere_2.stmd") 
		model:SetMaterial("textures/debug/white.json") 
		model:SetBlendMode(BLEND_OPAQUE) 
		model:SetRasterizerMode(RASTER_DETPHSOLID) 
		model:SetDepthStencillMode(DEPTH_READ) 
		
		model:SetMatrix(matrix.Scaling(2)) 
		model:SetFadeBounds(0.000001,99999,0.0000005) 
		
		model:SetFullbright(true) 
		model:SetBrightness(1)
		model:SetMaxRenderDistance(1000000)
		if data.color then model:SetColor(data.color) end
		 
		body.model = model  
		root.instss = model
		--body:SetPos(Vector(0,0,0))
	--else
		--ri:AddInstance(body)
	--end
	---local stn = body:GetName()
	---if stn then 
	---	local sptext = body:AddComponent(CTYPE_SPRITETEXT)  
	---	sptext:SetRenderGroup(RENDERGROUP_LOCAL)
	---	sptext:SetText(stn or "")
	---	sptext:SetMaxRenderDistance(1000000000)
	---	body.sptext = sptext 
	---end
end
function ENT:CreateStation(data,objects,root)
	local body =  ents.Create() 
	body:SetSizepower(1) 
	body:SetParent(root) -- end 
	body:SetSpaceEnabled(false) 
	body:SetPos(Vector(0,0,0))
	body:Spawn()
	body.type = "station"
	body.ref = data.ref
	objects[data.id or k] = body 
	
	local model = body:AddComponent(CTYPE_MODEL) 
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel("station/ring_ref.stmd") 
	model:SetMaterial("textures/debug/white.json") 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED) 
	
	model:SetMatrix(matrix.Scaling(0.00001)*matrix.Rotation(Vector(90,0,0))) 
	model:SetFadeBounds(0.000001,99999,0.0000005) 
	model:SetMaxRenderDistance(1000000)
	 
	if data.color then model:SetColor(data.color) end
	 
	body.model = model  
	

	local orbit = body:AddComponent(CTYPE_ORBIT) 
	 
	--a_diameter, 
	--eccentricity, 
	--inclination, 
	--periargument, 
	--ascendinglongitude, 
	--meanAnomaly, 
	--orbtialspeed
	orbit:SetOrbit(
		1,		0,		0,
		0,		0,		0, 
		0.1--20000/data.orbit.a
	)
	body.orbit = orbit
	if data.parent then
		local pd = objects[data.parent] 
		if pd then
			body.orbit:SetParent(pd)
		end
	end
	
	local model4 = body:AddComponent(CTYPE_MODEL) 
	model4:SetRenderGroup(RENDERGROUP_LOCAL)
	model4:SetModel("@planet_ring") 
	model4:SetMaterial("textures/debug/fullbright.json") 
	model4:SetBlendMode(BLEND_ADD) 
	model4:SetRasterizerMode(RASTER_DETPHSOLID) 
	model4:SetDepthStencillMode(DEPTH_ENABLED)    
	model4:SetMatrix(matrix.Scaling(0.1))
	model4:SetBrightness(1)
	model4:SetFadeBounds(0.000001,99999,0.0000005)  
	model4:SetColor(Vector(0.1,1,0.3)*3)
	model4:SetMaxRenderDistance(1000000)
	if data.isp then 
		model4:SetColor(Vector(1,0,0))
	end
end
