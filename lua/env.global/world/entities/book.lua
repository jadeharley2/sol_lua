 

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
	if data.name then self:SetName(data.name) end

end

function ENT:LoadModel() 
	local data = self.data or {}
	local model_scale = data.scale or self:GetParameter(VARTYPE_MODELSCALE) or 0.03
	local model_path = data.model or self:GetParameter(VARTYPE_MODEL) or 'models/clutter/lab/book.stmd'
	local model = self.model
	local world = matrix.Scaling(model_scale)-- * matrix.Rotation(-90,0,0)
	 
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
hook.Add("item_properties",'book',function(item,context,storage,itempanel)
	if item.formid and string.starts(item.formid,'book') then
		local user = storage:GetNode()
		context[#context+1] = {
			text = 'read',
			action = function(c)
				hook.Call('itemuse.book',user,item.formid)
			end
		}
	end
end)
hook.Add('formspawn.book','spawn',function(form,parent,arguments)  

	local ent = ents.Create("book") 
	ent[VARTYPE_MODELSCALE] = 0.03
	ent[VARTYPE_FORM] = form 
	ent:SetParent(parent) 
	ent:SetSeed(arguments.seed or 0)
	ent:Spawn()
	ent:SetPos(arguments.pos or Vector(0,0,0))  
	return ent
end)
hook.Add('newitem.book',"new",function(formid,seed)
	local j = forms.ReadForm(formid)--json.Read(type) 
	if not j then return nil end 
	local t = {
		sizepower=1, 
		seed= seed, 
		updatespace= 0,
		parameters =  {
			luaenttype = "book",
			name = j.name,
			form = formid,
			icon = j.icon, 
			seed = seed, 
		}, 
	}
	return  json.ToJson(t)
end)
hook.Add('itemuse.book','use',function(user,formid,data)
	local book = panel.Create('book_page')
	book:SetForm(formid)
	actor_panels.AddPanel(book,true)
	book:Show()
end)
 