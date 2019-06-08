

function ENT:Init()  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model 
	local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	self.coll = coll 

	local sspace = self:AddComponent(CTYPE_PHYSSPACE)  
	sspace:SetGravity(Vector(0,-4,0))
	self.space = sspace

	self:SetSpaceEnabled(false)
end
function ENT:Spawn()
	self:LoadBSP() 
	self:LoadModel()
	if CLIENT then
		self:GenerateNavmesh()
	end
	self:LoadEnts()   
end
function ENT:GenerateNavmesh()
	MsgN("[BSP] Nav generation")
	self:RemoveComponents(CTYPE_NAVIGATION)
	local nav = self:AddComponent(CTYPE_NAVIGATION) 
	for k,v in pairs(self:GetChildren()) do  
		if v and IsValidEnt(v) then
			nav:AddStaticMesh(v)
		end
	end
	nav:Generate()
	self.nav = nav
end

function ENT:LoadBSP()
	module.Require('sourceengine')

	local path = "gmod/maps/"..self[VARTYPE_FORM]..".bsp"
	MsgN("[BSP] Loading",path)
	self.bsp = sourceengine.LoadBSP(path,"gmod/materials")--"textures/debug/") 
end

function ENT:LoadModel() 
	if not self.bsp then return end
	--self.bsp:GenerateModel("tempbspmap.stmd",false)
	MsgN("[BSP] Loading resources")
	self.bsp:MountResources("gmod/")
	MsgN("[BSP] Map model generation")
	local mcou = self.bsp:GenerateModels("tempbspmap_",".stmd",false)

	local scale = 0.01905 -- 0.75 * 0.0254 (metres per inch) 
	
	local model = self.model
	local world = matrix.Scaling(scale*0.001) * matrix.Rotation(-90,0,0) 
	
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	--model:SetRenderGroup(RENDERGROUP_LOCAL)
	--model:SetModel("tempbspmap.stmd")   
	--model:SetBlendMode(BLEND_OPAQUE) 
	--model:SetRasterizerMode(RASTER_DETPHSOLID) 
	--model:SetDepthStencillMode(DEPTH_ENABLED)  
	--model:SetBrightness(1)
	--model:SetFadeBounds(0,9e20,0)  
	--model:SetMatrix(world) 
	--local coll =  self.coll 
	--if(model:HasCollision()) then
	--	coll:SetShapeFromModel(matrix.Scaling(scale)* matrix.Rotation(-90,0,0)) 
	--end 
	self.modelcom = true
	--self.incol = SpawnSO("tempbspmap.stmd",self,Vector(0,0,0),0.01905)
	MsgN("[BSP] Map model spawn. Total part count:",mcou)
	for k=0,mcou-1 do
		local so = SpawnSO("tempbspmap_"..k..".stmd",self,Vector(0,0,0),0.01905)
		so:AddFlag(320230)--FLAG_EDITOR_HIDE
	end
end 



function LoadSkybox(bpath)
	bpath = bpath or "sky_day01_05"
	if string.ends(bpath,"_hdr") then
		bpath = string.sub(bpath,1,#bpath-4)
	end
	bpath =  "gmod/materials/skybox/".. bpath
	
	local amc = EnvmapFromTextures(
		bpath.."ft.vtf", bpath.."bk.vtf",
		bpath.."up.vtf", bpath.."dn.vtf",
		bpath.."rt.vtf", bpath.."lf.vtf"
	)
	if amc then
		local mat = LoadMaterial("vlv.toolsskybox.vmt")
		SetMaterialProperty(mat,"g_SkyTexture",amc)
		return amc
	end
end
 
function ENT:LoadEnts()
	if not self.bsp then return end
	MsgN("[BSP] Prop Static spawn")
	local staticlist = json.FromJson(self.bsp:GetStatics())
	local pcoeff = 0.01905*0.001
	for k,v in pairs(staticlist) do
		MsgN("spawn: ",k,v.model)
		local pos = Vector(v.origin[1],v.origin[3],-v.origin[2]) * pcoeff 
		local angles = Vector(v.angles[3],v.angles[2],-v.angles[1])
		local e = SpawnSO("gmod/"..v.model,self,pos,1/5)  
		e:SetAng(angles)
		e:AddFlag(77723) 
	end
 
	MsgN("[BSP] Entity spawn")
	local entlist = json.FromJson(self.bsp:GetEntList())
	for k,v in pairs(entlist) do
		--Msg(v.classname)
		local e = false
		if v.classname == "info_player_start" then
			local pos = self:GetEntOrigin(v.origin)
			e = ents.Create("spawnpoint")
			e:SetPos(pos)-- SpawnSO("primitives/sphere.stmd",self,pos,0.75)
			e:AddFlag(77723)
			e:SetParent(self)
			e:Spawn()
			e:SetPlayerSpawn()
		elseif v.classname == "light" then
			local pos = self:GetEntOrigin(v.origin)
			local clrb = self:GetNumberTable(v._light)
			e = self:CreateStaticLight(pos,Vector(clrb[1]/255,clrb[2]/255,clrb[3]/255), clrb[4]/100) 
			--SpawnSO("primitives/sphere.stmd",self,pos,0.75)
		elseif v.classname == "info_node" and false then 
			local pos = self:GetEntOrigin(v.origin)
			local e = ents.Create()
			e:SetPos(pos)-- SpawnSO("primitives/sphere.stmd",self,pos,0.75)
			e:SetSizepower(2)
			e:SetParent(self)
			e:SetSpaceEnabled(false)
			e:Spawn()
			--debug.ShapeBoxCreate(30300+tonumber(v.nodeid),self,
			--	matrix.Translation(Vector(-0.5,-0.5,-0.5)) 
			--	*matrix.Scaling(0.2/self:GetSizepower())
			--	*matrix.Translation(pos))
		elseif v.classname == "ambient_generic" then
			
			--PrintTable(v) 
			local pos = self:GetEntOrigin(v.origin)
			e = ents.Create("ambient_sound")
			e:SetPos(pos)-- SpawnSO("primitives/sphere.stmd",self,pos,0.75) 
			e:SetParent(self)
			if band(v.spawnflags,16)==0 then -- starts enabled
				e.list = {'gmod/sound/'..v.message}
				MsgN("PLAY",v.message)
			else
				e.list = {}
			end 
			e:Spawn() 
		elseif v.classname == "worldspawn" then
			if v.skyname then
				LoadSkybox(v.skyname)
			end
		elseif v.classname == "prop_dynamic" or v.classname == "prop_physics" then
			local pos = self:GetEntOrigin(v.origin)
			local angles = self:GetNumberTable(v.angles)
			e = SpawnSO("gmod/"..v.model,self,pos,1/5)  
			if v.classname == "prop_dynamic" then
				e:SetAng(Vector(angles[3],angles[2]+0,-angles[1]))
			else
				e:SetAng(Vector(angles[3],angles[2],-angles[1]))
			end
			e:AddFlag(77723) 
		elseif v.classname == "env_sun" then
			local color = self:GetNumberTable(v.rendercolor)
			local angles = self:GetNumberTable(v.angles)
			local pos = Vector(1,0,0):Rotate(Vector(angles[1],angles[2],angles[3]))
			local sun = ents.GetByName("source.sun")--self:CreateStaticLight(pos*100,Vector(color[1],color[2],color[3])/255,190000000 * 100)  
			--sun.light:SetShadow(true)
			if sun then	
				MsgN("sun found")
				sun:SetPos(pos*10)
				sun:SetColor(Vector(color[1],color[2],color[3])/255)
			end
			--sun:SetName("sun")
			--self.sun = sun
			--e = sun
			
			--if CLIENT then
			--	local eshadow = ents.Create("test_shadowmap2")  
			--	eshadow.light = sun
			--	eshadow:AddFlag(77723)
			--	eshadow:SetParent(space) 
			--	eshadow:Spawn() 
			--	self.shadow = eshadow
			--end
		end
		if e then
			e:AddFlag(77723)
			if v.targetname then
				e:SetName(v.targetname)
			end
		end
	end
	
end
function ENT:ClearEnts() 
	for k,v in pairs(self:GetChildren()) do
		if v:HasFlag(77723) then
			v:Despawn()
		end
	end
end 
  

function ENT:GetEntOrigin(str)
	local coeff = 0.01905*0.001
	local p = string.split(str,' ')
	return Vector(tonumber(p[1])*coeff,tonumber(p[3])*coeff,tonumber(p[2])*-coeff)
end
function ENT:GetNumberTable(str) --"_light" "255 255 255 400"
	local p = string.split(str,' ')
	local t = {}
	for k,v in pairs(p) do t[k] = tonumber(v) end
	return t
end

function ENT:CreateStaticLight( pos, color,power)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2) 
	lighttest:SetParent(self)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn() 
	if power then lighttest:SetBrightness(power) end
	lighttest:SetPos(pos)  
	return lighttest
end