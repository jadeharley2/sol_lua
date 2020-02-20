local NO_COLLISION = NO_COLLISION or 2
local COLLISION_ONLY = COLLISION_ONLY or 1 
 

function ItemPV(type,seed,modtable)
	local j = forms.ReadForm(type)--json.Read(type) 
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
		flags = {"storeable"}
	}
	if modtable then table.Merge(modtable,t,true) end
	return json.ToJson(t)
end
function InitPV(type,ent,pos,ang,seed,e)
	local j = forms.ReadForm(type)--json.Read(type) 
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
	
	e = e or ents.Create("prop_variable") 
	e.data = j
	e.tags = tags
	e.collonly = false 
	e:SetParameter(VARTYPE_FORM,type)  
	e:SetSizepower(1)
	e:SetParent(ent)
	e:SetPos(pos) 
	e:SetAng(r) 
	if seed then
		e:SetSeed(seed)
	end
	--if j.modeldata then
	--	e:SetParameter(VARTYPE_MODELDATA, json.ToJson(j.modeldata))
	--end
	--e:SetModel(j.model,j.scale,false)
	return e
end
function SpawnPV(type,ent,pos,ang,seed)
	local e = InitPV(type,ent,pos,ang,seed)
	e:Spawn()
	e:SetPos(pos) 
	return e
end
function CreatePV(type,ent,pos,ang,seed)
	local e = InitPV(type,ent,pos,ang,seed)
	e:Create()
	e:SetPos(pos) 
	return e
end

function ENT:Init()  
	self:SetSpaceEnabled(false) 
	
end
function ENT:Load()
--	MsgN("load",self)
	--local compo = self:GetComponents()
	--for k,v in pairs(compo) do
	--	self:RemoveComponent(v)
	--end
	self:Construct()
end  
function ENT:Spawn()  
--	MsgN("spawn",self)
	self:Construct()
end
function ENT:Construct()
	self:PreLoadData()
	if not self.data.luatype then
		local model = self.model or self:AddComponent(CTYPE_MODEL)  
		local coll = self.coll or self:AddComponent(CTYPE_STATICCOLLISION)  
		local phys = self.phys or self:AddComponent(CTYPE_PHYSOBJ)  
		self.model = model
		self.coll = coll 
		self.phys = phys
		
		local modelcom = self.modelcom
		if not modelcom then
			local modelval = self:GetParameter(VARTYPE_MODEL) or self.data.model
			local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or self.data.scale or 1 
			if modelval then 
				if self.data.procedural then
					self:SetupModelParams()
					model:SetMatrix( matrix.Scaling(modelscale) * matrix.Rotation(-90,0,0)) 
					local procgen = self:AddComponent(CTYPE_PROCGEN)  
					self.procgen = procgen
					procgen:SetModel(modelval)
					self:SetupPhysics(matrix.Scaling(modelscale) * matrix.Rotation(-90,0,0),modelscale)
				else
					self:SetModel(modelval,modelscale)
				end
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
		self.data = forms.ReadForm(type)--json.Read(type) 
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
		MsgN(lt,meta)
		if meta then
			MsgN(lt,meta)
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
	if data and isstring(data.name) then
		self:SetName(data.name)
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

	hook.Call("prop.variable.load",self,j,tags)
end
function ENT:SetupModelParams()
	local model = self.model
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
end
function ENT:SetupPhysics(world,scale)	
	if self.collonly ~= NO_COLLISION then 
		local model = self.model
		local data = self.data
		if data.phys then
			local phys =  self.phys 
		
			if(model:HasCollision()) then
				phys:SetShapeFromModel(world)  
			end 
			phys:SetMass(data.mass or 10)  
			phys:SoundCallbacks()
			phys:SetMaterial(data.physmaterial or "wood")
			self:AddTag(TAG_PHYSSIMULATED)
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
	self:SetupModelParams()
	model:SetModel(mdl)   
	model:SetMatrix(world) 
	self:SetupPhysics(world,scale)	
	self.modelcom = true
end 

ENT.editor = {
	name = "Prop Variable",
	properties = {
		type = {text = "type",type="parameter",valtype="string",key=VARTYPE_FORM,reload=true}, 
		reload = {text = "reload form",type="action",action = function(ent)  
			ent:SetUpdating(false)
			ent:_despawn()
			ent._secondbase=nil
			for k,v in pairs(ent:GetComponents()) do
				ent:RemoveComponent(v)
			end
			ent:_spawn() 
		end} 
		
	},  
	
}
 
hook.Add('formspawn.prop','spawn',function(form,parent,arguments)
	return SpawnPV(form,parent,
		arguments.pos or Vector(0,0,0),
		arguments.ang or Vector(0,0,0),
		arguments.seed or 0)
end)
hook.Add('formcreate.prop','spawn',function(form,parent,arguments)
	return CreatePV(form,parent,
		arguments.pos or Vector(0,0,0),
		arguments.ang or Vector(0,0,0),
		arguments.seed or 0)
end)
hook.Add('newitem.prop',"prop",function(formid,seed)
	return ItemPV(formid,seed)
end)

--hook.Add('item_features','propvfeatures',function(formid,data,addfeature)
--     
--end) 

for k,v in pairs(file.GetFiles("lua/env.global/world/propvariable_extensions",'.lua')) do 
	include(v) 
end