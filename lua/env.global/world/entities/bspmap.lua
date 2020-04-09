

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
	local mcou = self.bsp:GenerateModels("bspmap_",".stmd",false)
	local ocou = self.bsp:GenerateOtherModels("bspmodel_",".stmd",false)

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
		local so = SpawnSO("bspmap_"..k..".stmd",self,Vector(0,0,0),0.01905)
		so:AddTag(320230)--TAG_EDITOR_HIDE
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
		local mat2 = LoadMaterial("vlv.toolsskybox2d.vmt")
		if mat then SetMaterialProperty(mat,"g_SkyTexture",amc) end
		if mat2 then SetMaterialProperty(mat2,"g_SkyTexture",amc) end
		return amc
	end
end
console.AddCmd("source_sky",function (bpath)
	LoadSkybox(bpath)
end)
console.AddCmd("source_sun",function (r,g,b)
	sun = ents.GetByName("source.sun")
	if sun then
		sun:SetColor(Vector(tonumber(r),tonumber(g),tonumber(b))/255)
	end
end)
function ENT:EntFire(action)
	if istable(action) then
		for k,v in pairs(action) do
			self:EntFire(v)
		end
		return nil
	end
	MsgN("ENTFIRE",action)
	--MsgInfo("EF "..action)
	local params = string.split(action,',')
	--PrintTable(params)
	local target = params[1]
	local action = params[2]
	local list = self.entsnamed 
	
	local entgroup = list[target]
	if entgroup then
		PrintTable(entgroup)
		for k,v in pairs(entgroup) do
			if IsValidEnt(v) and v[action] then
				v[action](v)
			end
		end
	end 
end
--order: PITCH, -ROLL, YAW
function ENT:FromSourceAngle(values)
	return 
		matrix.AxisRotation(Vector(1,0,0),values[3]) 
		*matrix.AxisRotation(Vector(0,0,1),-values[1])
		*matrix.AxisRotation(Vector(0,1,0),values[2])
end
function ENT:LoadEnts()
	if not self.bsp then return end
	MsgN("[BSP] Prop Static spawn")
	local staticlist = json.FromJson(self.bsp:GetStatics())
	local pcoeff = 0.01905*0.001
	for k,v in pairs(staticlist) do
		--MsgN("spawn: ",k,v.model) 
		local pos = Vector(v.origin[1],v.origin[3],-v.origin[2]) * pcoeff 
		local angles = self:FromSourceAngle(v.angles)
		local e = SpawnSO("gmod/"..v.model,self,pos,1/5)  
		e:SetAng(angles)
		
		e:AddTag(77723) 
	end
 

	MsgN("[BSP] Entity spawn")
	local sun =  ents.GetByName("source.sun")
	if sun then 
		sun:SetColor(Vector(0,0,0))
	end
	local entlist = json.FromJson(self.bsp:GetEntList())
	local named = {}
	self.entsnamed = named
	for k,v in pairs(entlist) do
		--Msg(v.classname)
		local e = hook.Call("source.ent_create",v.classname,v,self)
		
		if e then
			e.sourcedata = v
			e:AddTag(77723)
			if v.targetname then
				e:SetName(v.targetname)
				local er = named[v.targetname]
				if er then
					er[#er+1] = e
				else
					named[v.targetname] = {e}
				end 
			end
			if v.parentname then
				local parentent = named[v.parentname]
				if IsValidEnt(parentent) then 
					e:ChangeParent(parentent)
				end
			end


		end
	end 
	 
end
function ENT:ClearEnts() 
	for k,v in pairs(self:GetChildren()) do
		if IsValidEnt(v) and v:HasTag(77723) then
			v:Despawn()
		end
	end
	self.entsnamed = {}
end 

if CLIENT then
	console.AddCmd("source_ents_reload",function (r,g,b)
		local lp = LocalPlayer():GetParent()
		if lp then
			MsgN("map",lp)
			lp:ClearEnts()
			lp:LoadEnts()
		end
	end)
	console.AddCmd("source_ents_clear",function (r,g,b)
		local lp = LocalPlayer():GetParent()
		if lp then
			lp:ClearEnts() 
		end
	end)
end 

function ENT:GetEntOrigin(str)
	if str==nil then return nil end
	local coeff = 0.01905*0.001
	local p = string.split(str,' ')
	return Vector(tonumber(p[1])*coeff,tonumber(p[3])*coeff,tonumber(p[2])*-coeff)
end
function ENT:GetDirection(str)
	if str==nil then return nil end
	local p = string.split(str,' ')
	return Vector(tonumber(p[1]),tonumber(p[3]),-tonumber(p[2]))
end
function ENT:GetNumberTable(str) --"_light" "255 255 255 400"
	if str==nil then return nil end
	local p = string.split(str,' ')
	local t = {}
	for k,v in pairs(p) do t[k] = tonumber(v) end
	return t
end

vsourcetools =vsourcetools or {} 
function vsourcetools.GetDirection(str)
	if str==nil then return nil end
	local p = string.split(str,' ')
	return Vector(tonumber(p[1]),tonumber(p[3]),-tonumber(p[2]))
end
function vsourcetools.GetNumberTable(str) --"_light" "255 255 255 400"
	if str==nil then return nil end
	local p = string.split(str,' ')
	local t = {}
	for k,v in pairs(p) do t[k] = tonumber(v) end
	return t
end
function vsourcetools.FromSourceAngle(values)
	return 
		matrix.AxisRotation(Vector(1,0,0),values[3]) 
		*matrix.AxisRotation(Vector(0,0,1),-values[1])
		*matrix.AxisRotation(Vector(0,1,0),values[2])
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

hook.RegisterHook("source.ent_create","Loads source entities. Return spawned Entity","entclass:string,data:table,parent:Entity")
 