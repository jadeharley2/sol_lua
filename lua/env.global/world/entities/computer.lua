 
ENT.info = "Computer"
ENT._interact = {
	use={text="use",action= function (self,user)
		if CLIENT and user==LocalPlayer() then
			hook.Call('itemuse.computer',user,self[VARTYPE_FORM])
		end
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
	local model_path = data.model or self:GetParameter(VARTYPE_MODEL) or 'models/items/space/tablet.stmd'
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
hook.Add("item_properties",'computer',function(item,context,storage,itempanel)
	if item.formid and string.starts(item.formid,'computer') then
		local user = storage:GetNode()
		context[#context+1] = {
			text = 'use',
			action = function(c)
				hook.Call('itemuse.computer',user,item.formid)
			end
		}
	end
end)  
hook.Add('itemuse.computer','use',function(user,formid,data)
	--local book = panel.Create('book_page')
	--book:SetForm(formid)
	--actor_panels.AddPanel(book,true)
	--book:Show()
end)
 