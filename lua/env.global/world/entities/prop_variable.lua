local NO_COLLISION = NO_COLLISION or 2
local COLLISION_ONLY = COLLISION_ONLY or 1 
 

function ItemPV(type,seed,modtable)
	local j = json.Read(type) 
	if not j then return nil end 
	local t = {
		sizepower=1, 
		seed= seed, 
		updatespace= 0,
		parameters =  {
			luaenttype = "prop_variable",
			name = j.name,
			form = type,
			icon = j.icon,
		}, 
	}
	if modtable then table.Merge(modtable,t,true) end
	return json.ToJson(t)
end
function SpawnPV(type,ent,pos,ang,seed)
	local j = json.Read(type) 
	if not j then return nil end
	
	local tags = {}
	if j.tags then
		for k,v in pairs(j.tags) do
			tags[v] = true
		end
	end 
	
	local r = ang or Vector(0,0,0)
	if j.rotation then r = r + JVector(j.rotation) end
	if tags.random_ry then r = r + Vector(0,math.random(-1800,1800)/10,0) end
	
	local e = ents.Create("prop_variable") 
	e.data = j
	e.tags = tags
	e.collonly = false 
	e:SetParameter(VARTYPE_FORM,type)  
	e:SetSizepower(1)
	e:SetParent(ent)
	e:SetPos(pos) 
	if seed then
		e:SetSeed(seed)
	end
	--if j.modeldata then
	--	e:SetParameter(VARTYPE_MODELDATA, json.ToJson(j.modeldata))
	--end
	--e:SetModel(j.model,j.scale,false)
	e:Spawn()
	e:SetAng(r)
	
	
	return e
end

function ENT:Init()  
	self:SetSpaceEnabled(false) 
	
end
function ENT:Load()
	local compo = self:GetComponents()
	for k,v in pairs(compo) do
		self:RemoveComponent(v)
	end

	self:PreLoadData(true)
	if not self.data.luatype then
		local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
		local phys = self:AddComponent(CTYPE_PHYSOBJ)  
		local model = self:AddComponent(CTYPE_MODEL)  
		self.model = model
		self.coll = coll 
		self.phys = phys

		local modelval = self:GetParameter(VARTYPE_MODEL) or self.data.model
		local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or self.data.scale or 1 
		if modelval then 
			self:SetModel(modelval,modelscale)
		else
			--MsgN("no model specified for static model at spawn time")
		end 
	end
	self:LoadData()
end  
function ENT:Spawn()  
	self:PreLoadData()
	if not self.data.luatype then
		local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
		local phys = self:AddComponent(CTYPE_PHYSOBJ)  
		local model = self:AddComponent(CTYPE_MODEL)  
		self.model = model
		self.coll = coll 
		self.phys = phys
		
		local modelcom = self.modelcom
		if not modelcom then
			local modelval = self:GetParameter(VARTYPE_MODEL) or self.data.model
			local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or self.data.scale or 1 
			if modelval then 
				self:SetModel(modelval,modelscale)
			else
				--error("no model specified for static model at spawn time")
			end
		end
	end
	self:LoadData()
end
function ENT:Despawn()
	local sb = self._secondbase
	if sb and sb._despawn then
		sb._despawn(self)
	end
	self:DDFreeAll() 
end

local function LampInputs(self,f,k,v)
	local light = self.light;
	if light then
		if k == "toggle" then light:Enable(not light:IsEnabled())
		elseif k == "on" then light:Enable(true)
		elseif k == "off"then light:Enable(false) end
	end
end
local function ButtonUse(s,user)
	--local wio = TryGetComponent("wireio",s)
	--if wio then 
	--	wio:SetOutput("out")
	--end
	if s.wireio then
		s.wireio:SetOutput("out")
	end
	if CLIENT then
		s:EmitSound("events/lamp-switch.ogg",1)
	end
end
local function ContainerUse(self,user)
	if not self.isopened then
		self.user = user
		self:EmitSound("events/storage-open.ogg",1)
		if CLIENT and LocalPlayer() == user then 
			OpenInventoryWindow(self) 
		end 
		self.isopened = not self.isopened 
	else
		if self.user == user then
			self.user = nil
			self:EmitSound("events/storage-close.ogg",1)
			if CLIENT and LocalPlayer() == user then 
				CloseInventoryWindow(self) 
			end
			self.isopened = not self.isopened 
		end
	end
end

function AutoConvert(table,level) 
	level=level or 0
	local tcount = 0
	local lastval = nil
	local isnumbers = true
	for k,v in SortedPairs(table) do
		if(istable(v)) then
			local rep,vv = AutoConvert(v,level+1)
			if rep then table[k] = vv end
		end
		--MsgN(level,"=",k,v)
		lastval = v
		tcount = tcount + 1
		if isnumbers and not isnumber(k) then
			isnumbers = false
		end
	end
	--MsgN(level,"-",tcount,lastval,isnumbers)
	if isnumbers and tcount>1 and isstring(lastval) then
		if lastval=="vec3" and tcount>3 then
			--MsgN("tcount,lastval,isnumbers")
			return true, Vector(table[1],table[2],table[3])
		end 
	end
	return false, table
end

function ENT:PreLoadData(isLoad) 
	if not self.data then
		local type = self:GetParameter(VARTYPE_FORM) or self:GetParameter(VARTYPE_CHARACTER)  
		self.data = json.Read(type) 
	end
	if not self.data then
		MsgN("prop_variable error loading type "..tostring(type or "nil"))
	end
	if not self.data then
		local type = self:GetParameter(VARTYPE_FORM) or self:GetParameter(VARTYPE_CHARACTER)  
		MsgN("prop_variable error no type "..tostring(type or "nil"))
	end
	local data = self.data
	if data and data.modeldata then 
		e:SetParameter(VARTYPE_MODELDATA, json.ToJson(data.modeldata))
	end
	if data and data.model then
		self:SetParameter(VARTYPE_MODEL,data.model)
	end
	if data and data.scale then
		self:SetParameter(VARTYPE_MODELSCALE,data.scale)
	end

	if data and data.variables then
		local b, rlv = AutoConvert(data.variables)
		for k,v in pairs(rlv) do 
			self[k] = v
		end
	end

	local lt = data.luatype
	if lt and isstring(lt) then  
		local meta = ents.GetType(lt)
		if meta then
			--for k,v in pairs(meta) do
			--	if k ~= 'Spawn' and k ~= 'Despawn' then
			--		self[k] = v 
			--	end
			--end 
			self._secondbase = meta

			if meta.Init then
				meta.Init(self)
			end
			if meta.PreLoadData then
				meta.PreLoadData(self)
			end
			--MsgN("load!",isLoad)
			if isLoad then
				if meta.Load then 
					meta.Load(self)
				end
			else
				if meta._spawn then 
					meta._spawn(self)
				end
			end
			if meta.Think then 
				self:AddNativeEventListener(EVENT_UPDATE,"think",meta.Think)
			end
		end
	end
end

function ItemsetSpawn(storage,k,v,rnd) 
	local its = forms.ReadForm('itemset.'..k) 
	if its then
		if not v.mode or v.mode == "all" then
			for kk,vv in pairs(its.subsets) do -- groups 
				for k3,v3 in pairs(vv) do -- items
					storage:AddFormItem(v3)
				end
			end
		elseif v.mode == "oneof" then
			local key = table.RandomKey(its.subsets,rnd)
			local group = its.subsets[key]   
			if group then 
				for k3,v3 in pairs(group) do -- items
					storage:AddFormItem(v3)
				end
			end
		end
	end
end
function ENT:LoadData()
	
	local j = self.data
	
	
	local tags = {}
	if j.tags then
		for k,v in pairs(j.tags) do
			tags[v] = true
		end
	end 
	 
	if j.container then
		local storage = self:AddComponent(CTYPE_STORAGE)  
		self.storage = storage
		self.isopened = false 
		self.usetype = "open container"
		self:AddFlag(FLAG_USEABLE)
		self:AddEventListener(EVENT_USE,"a",ContainerUse)
		self:SetNetworkedEvent(EVENT_USE,true)

		--local itemc = r:NextInt(0,3)
		--local items = table.Keys(forms.GetList("apparel"))
		--for k=1,itemc do
		--	local st = table.Random(items)
		--	storage:AddFormItem("apparel",st)
		--end

		--MsgN("eeeeee",self:GetSeed())
		local its = j.container.itemsets
		if its then
			local r = Random(self:GetSeed()) 
			for k,v in pairs(its) do 
				if v.chance then
					if r:NextInt(0,100)<v.chance then
						ItemsetSpawn(storage,k,v,r)
					end
				else
					ItemsetSpawn(storage,k,v,r)
				end
			end
		end
		local its = j.container.items
		if its then
			for k,v in pairs(its) do
				
			end
		end
	end
	if j.light then 
		local color = self[VARTYPE_COLOR] or JVector(j.light.color,Vector(1,1,1))
		local brightness = self[VARTYPE_BRIGHTNESS] or j.light.brightness or 1
		local light = self:AddComponent(CTYPE_LIGHT)  
		light:SetColor(color)
		light:SetBrightness(brightness) 
		if j.light.pos then
			light:SetOffset(JVector(j.light.pos)) 
		end
		self.light = light
		 
		if tags.lamp then
			local wio = self:AddComponent(CTYPE_WIREIO)-- Component("wireio",self)
			wio:AddInput("toggle",LampInputs)
			wio:AddInput("on",LampInputs)
			wio:AddInput("off",LampInputs)
		end
	end 
	if j.button then
		self.usetype = "press button"
		self:AddFlag(FLAG_USEABLE)
		self:AddEventListener(EVENT_USE,"a",ButtonUse)
		self:SetNetworkedEvent(EVENT_USE,true)
		local wio = self:AddComponent(CTYPE_WIREIO)
		wio:AddOutput("out")
	end
	if tags.item then
		self:AddFlag(FLAG_STOREABLE) 
	end
	if j.replacematerial then
		local rmodel = self.model
		for k,v in pairs(j.replacematerial) do
			if isstring(v) then
				rmodel:SetMaterial(LoadMaterial(v),k-1) 
			end
		end
	end
	if j.modmaterial then
		local rmodel = self.model
		for k,v in pairs(j.modmaterial) do  
			local mat = rmodel:GetMaterial(k-1)
			if not nocopy and mat then
				mat = CopyMaterial(mat)
				rmodel:SetMaterial(mat,k-1)
			end
			for kk,vv in pairs(v) do
				if istable(vv) and #vv == 3 then
					SetMaterialProperty(mat,kk,JVector(vv))
				else
					SetMaterialProperty(mat,kk,vv)
				end
			end
		end
	end
	if j.viewdistance then
		--MsgN("mvd",j.viewdistance)
		self.model:SetMaxRenderDistance(j.viewdistance)
	end
end
 
function ENT:SetModel(mdl,scale,norotation) 
	scale = scale or 1
	norotation = norotation or false
	local model = self.model
	local world = matrix.Scaling(scale)
	if not norotation then
		world = world * matrix.Rotation(-90,0,0)
	end
	
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(mdl)   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world) 
	if self.collonly ~= NO_COLLISION then 
		local data = self.data
		if data.phys then
			local phys =  self.phys 
		
			if(model:HasCollision()) then
				phys:SetShapeFromModel(world)  
			end 
			phys:SetMass(data.mass or 10)  
			phys:SoundCallbacks()
			phys:SetMaterial(data.physmaterial or "wood")
		else 
			local coll =  self.coll 
			if norotation then
				if(model:HasCollision()) then
					coll:SetShapeFromModel(matrix.Scaling(scale))--matrix.Scaling(scale/0.75 )  ) 
				end
			else
				if(model:HasCollision()) then
					coll:SetShapeFromModel(matrix.Scaling(scale)* matrix.Rotation(-90,0,0))--matrix.Scaling(scale/0.75 ) * matrix.Rotation(-90,0,0) ) 
				end 
			end
			
			if self.collonly then
				model:Enable(false)
			end
		end
	end
	self.modelcom = true
end 

ENT.editor = {
	name = "Prop Variable",
	properties = {
		type = {text = "type",type="parameter",valtype="string",key=VARTYPE_FORM,reload=true}, 
		 
	},  
	
}
 