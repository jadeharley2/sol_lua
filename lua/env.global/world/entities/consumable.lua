 
ENT.info = "Item"
ENT._interact = {
	use={text="use",action= function (self,user)
		 
	end},
}
  
function ENT:Init()  
	self:SetSizepower(1)
	self:SetSpaceEnabled(false)
	local phys = self:AddComponent(CTYPE_PHYSOBJ)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.phys = phys
	self:AddTag(TAG_PHYSSIMULATED) 
	self:AddTag(TAG_STOREABLE) 
end 
function ENT:LoadData() 
	local data =  forms.ReadForm(self[VARTYPE_FORM])
	self.data = data
	if data.name then self:SetName(data.name) self.info = data.name end

end

function ENT:LoadModel() 
	local data = self.data or {}
	local model_scale = data.scale or self:GetParameter(VARTYPE_MODELSCALE) or 0.03
	local model_path = data.model or self:GetParameter(VARTYPE_MODEL) or 'models/clutter/lab/vase.stmd'
	local model = self.model
	local world = matrix.Scaling(model_scale)-- * matrix.Rotation(-90,0,0)
	if data.rotation then
		world = world * matrix.Rotation(data.rotation[1],data.rotation[2],data.rotation[3])
	end
	 
	local phys =  self.phys  
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(model_path) 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	
	
	if(model:HasCollision()) then
		phys:SetShapeFromModel(world * matrix.Scaling(1) ) 
		phys:SetMass(data.mass or 1)   
	end  
	model:SetMatrix( world ) 
end
function ENT:Load()
	self:LoadData()
	self:LoadModel()  
end
function ENT:Spawn() 
	self:LoadData()
	self:LoadModel() 
	self.phys:SoundCallbacks()
	self.phys:SetMaterial("wood")
end 
hook.Add("item_properties",'consumable',function(item,context,storage,itempanel)
	if item.formid and string.starts(item.formid,'consumable') then
		local user = storage:GetNode()
		context[#context+1] = {
			text = 'use',
			action = function(c)
				hook.Call('itemuse.consumable',user,item.formid,item,storage)
			end
		}
	end
end)
hook.Add('formspawn.consumable','spawn',function(form,parent,arguments)  

	local ent = ents.Create("consumable") 
	ent[VARTYPE_MODELSCALE] = 0.03
	ent[VARTYPE_FORM] = form  
	ent:SetParent(parent) 
	ent:SetSeed(arguments.seed or 0)
	ent:Spawn()
	ent:SetPos(arguments.pos or Vector(0,0,0))  
	return ent
end)
hook.Add('formcreate.consumable','create',function(form,parent,arguments)  

	local ent = ents.Create("consumable") 
	ent[VARTYPE_MODELSCALE] = 0.03
	ent[VARTYPE_FORM] = form 
	ent:SetParent(parent) 
	ent:SetSeed(arguments.seed or 0)
	ent:Create()
	ent:SetPos(arguments.pos or Vector(0,0,0))  
	return ent
end)
hook.Add('newitem.consumable',"new",function(formid,seed)
	local j = forms.ReadForm(formid)--json.Read(type) 
	if not j then return nil end 
	local t = {
		sizepower=1, 
		seed= seed, 
		updatespace= 0,
		parameters =  {
			luaenttype = "consumable",
			name = j.name,
			form = formid,
			icon = j.icon, 
			seed = seed, 
		}, 
	}
	return  json.ToJson(t)
end)
hook.Add('itemuse.consumable','use',function(user,formid,data,storage)
	local j = forms.ReadForm(formid) 
	if not j then return nil end 
	local con = j.contents
	if con then
		local ucon =  user.contents or {}
		user.contents = ucon
		for key, value in pairs(con) do
			local holder = ucon[value.type] or {}
			holder.amount = (holder.amount or 0) + value.amount
			ucon[value.type] = holder
		end 
		storage:RemoveFormItem(formid,1)
		hook.Call("contents.update",user)
	end
	if j.effects then  
		for k,v in pairs(j.effects) do
			MsgN("EF",k,v,v.effect)
			local eff = Effect(v.effect or k,v)
			if eff then
				eff:Start(user,user,pos) 
			end  
		end 
	end
end)
 
hook.Add("contents.update","actor",function(actor)
	local contents = actor.contents
	if contents then
		for key, value in pairs(contents) do
			if value and value.amount>0 then
				local form = forms.ReadForm(key) 
				if form and form.effects then  
					for k,v in pairs(form.effects) do
						MsgN("EF",k,v,v.effect)
						local eff = Effect(v.effect or k,v)
						if eff then
							eff:Start(actor,actor,pos) 
						end  
					end 
				end
			end
		end
	end
end)
console.AddCmd("contents",function (targ)
	local actor = LocalPlayer()
	local contents = actor.contents
	if contents then
		PrintTable(contents)
	end
end)
console.AddCmd("contents_clear",function (targ)
	local actor = LocalPlayer()
	local contents = actor.contents
	if contents then
		actor.contents = {}
	end
end)