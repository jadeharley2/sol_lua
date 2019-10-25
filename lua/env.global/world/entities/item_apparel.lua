

DeclareEnumValue("variable","icon",					33210) 

function ItemIA(type,seed,modtable)
	local j = forms.ReadForm(type)--json.Read(type) 
	if not j then return nil end 
	local t = {
		sizepower=1, 
		seed= seed, 
		updatespace= 0,
		parameters =  {
			luaenttype = "item_apparel",
			name = j.name,
			form = type,
			icon = j.icon,
			slot = j.slot,
			seed = seed,
			actions = j.actions
		}, 
	}
	if modtable then table.Merge(modtable,t,true) end
	return json.ToJson(t)
end

function SpawnIA(type,ent,pos,seed)
	local data = ItemIA("forms/apparel/"..type..".json",seed,{})
	MsgN("data",data,type)
	local e = ents.FromData(data,ent,pos)  
	return e 
end
--function CreateIA(type,ent,pos,seed)
--	if not seed or seed == 0 then error("seed is nil") end
--	local data = json.Read("forms/apparel/"..type..".json")
--	if data then
--		local e = ents.Create("item_apparel") 
--		e.slot = data.slot
--		e.info = data.name or type
--		e.icon = data.icon
--		e.skinmodel = data.model
--		e:SetName(data.name or type)
--		e:SetModel(data.worldmodel)
--		e:SetModelScale(data.worldmodelscale or 0.75)
--		e:SetSizepower(1)
--		e:SetParent(ent)
--		e:SetSeed(seed) -- error on 0
--		e:SetPos(pos) 
--		if data.worldmaterials then
--			local bmatdir = data.worldbasematdir
--			for k,v in pairs(data.materials) do
--				local id = tonumber(k)
--				local mat = dynmateial.LoadDynMaterial(v,bmatdir)
--				e.model:SetMaterial(mat,id)
--			end
--		end
--		e:Create()
--		return e
--	end
--end

ENT.slot = "neck"
function ENT:Init()  
	local phys =  self:GetComponent(CTYPE_PHYSOBJ) or self:AddComponent(CTYPE_PHYSOBJ)  
	local model = self:GetComponent(CTYPE_MODEL) or self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.phys = phys
	self:SetSpaceEnabled(false)
	self:AddTag(TAG_PHYSSIMULATED) 
	
	
	--self:AddEventListener(EVENT_USE,"use_event",function(user) 
	--	if self:IsEquipped() then
	--		user:Unequip(self.slot) 
	--	else
	--		user:Equip(self) 
	--	end
	--end)
	--self:SetNetworkedEvent(EVENT_USE)
	self:AddTag(TAG_USEABLE) 
	self:AddTag(TAG_STOREABLE)
end
function ENT:LoadData()
	local type = self:GetParameter(VARTYPE_FORM)
	local data = forms.ReadForm(type)--json.Read(type)
	if data then
		self.data = data 

		self.slot = data.slot
		self.info = data.name or type
		self.icon = data.icon
		self.skinmodel = data.model
		if data.worldmodel then
			self:SetParameter(VARTYPE_MODEL,data.worldmodel) 
			self:SetParameter(VARTYPE_MODELSCALE,data.worldmodelscale or 1) 
		else
			self:SetParameter(VARTYPE_MODEL,"models/clutter/misc/smallitembox.stmd") 
			self:SetParameter(VARTYPE_MODELSCALE,0.06) 
			
		end
	end
end
function ENT:GetSkelModel(target)
	local sm = self.skinmodel
	if istable(sm) then
		PrintTable(sm)
		local vid = target.variation_id
		if vid then
			return sm[vid]
		else
			return nil
		end 
	else
		return sm
	end
	
end
function ENT:LoadModel() 
	local model_file = self:GetParameter(VARTYPE_MODEL)
	if model_file then
		local model_scale = self:GetParameter(VARTYPE_MODELSCALE) or 1
		
		local model = self.model
		local world = matrix.Scaling(model_scale) * matrix.Rotation(-90,0,0)
		
		local phys =  self.phys
		local amul = 0.8
		
		
		model:SetRenderGroup(RENDERGROUP_LOCAL)
		model:SetModel(model_file) 
		model:SetBlendMode(BLEND_OPAQUE) 
		model:SetRasterizerMode(RASTER_DETPHSOLID) 
		model:SetDepthStencillMode(DEPTH_ENABLED)  
		model:SetBrightness(1)
		model:SetFadeBounds(0,99999,0)  
		MsgN("fas",model_file)
		model:SetMatrix( world)
		
		if phys then
			if(model:HasCollision()) then
				phys:SetShapeFromModel(world  ) 
			else
				--phys:SetShape(mdl,world * matrix.Scaling(1/amul) ) 
			end
			
			
			phys:SetMass(10) 
			
			--model:SetMatrix( world* matrix.Translation(-phys:GetMassCenter()*amul )) 
		end
	end
end
function ENT:Load()
	self:LoadData()
	self:LoadModel() 
	self:SetPos(self:GetPos())
end
function ENT:Spawn() 
	self:LoadData()
	if self.phys then self.phys:SetMaterial("cloth") end
	self:LoadModel() 
	if self.phys then self.phys:SoundCallbacks() end 
end
function ENT:SetModel(mdl)
	self:SetParameter(VARTYPE_MODEL,mdl) 
end
function ENT:SetModelScale(scale) 
	self:SetParameter(VARTYPE_MODELSCALE,scale)
end

function ENT:OnEquipped(actor)
	self.actor = actor
end
function ENT:OnUnequipped(actor)
	self.actor = nil
end
function ENT:IsEquipped()
	return self.actor ~= nil
end
function ENT:OnDrop()
	if self:IsEquipped() then
		self.actor:Unequip(self.slot)
	end
end



hook.Remove("item_properties","item_apparel")
--hook.Add("item_properties","item_apparel",function(data,context,storage,item) 
--	if data.data:Read("/parameters/luaenttype") == "item_apparel" then
--		node = storage:GetNode()
--		if node and node.equipment then 
--			local iseq = node.equipment:IsEquipped(data.data)--data.data:Read("/parameters/isequipped") or false 
--			if iseq then 
--				context[#context+1] = {text = "unequip",action = function(i) 
--					node:SendEvent(EVENT_UNEQUIP,data.data) 
--					--data.data:Write("/parameters/isequipped",false) 
--					MsgN(i)
--				end}
--			else
--				context[#context+1] = {text = "equip",action = function(i) 
--					node:SendEvent(EVENT_EQUIP,data.data)
--					--data.data:Write("/parameters/isequipped",true) 
--					MsgN(i)
--				end}
--			end
--		end
--	end
--end) 