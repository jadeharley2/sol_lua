


function SpawnIA(type,ent,pos)
	local data = json.Read("forms/apparel/"..type..".json")
	if data then
		local e = ents.Create("item_apparel") 
		e.slot = data.slot
		e.info = data.name or type
		e.icon = data.icon
		e.skinmodel = data.model
		e:SetName(data.name or type)
		e:SetModel(data.worldmodel)
		e:SetModelScale(data.worldmodelscale or 0.75)
		e:SetSizepower(1)
		e:SetParent(ent)
		e:SetPos(pos) 
		e:Spawn()
		return e
	end
end

ENT.slot = "neck"
function ENT:Init()  
	local phys = self:AddComponent(CTYPE_PHYSOBJ)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.phys = phys
	self:SetSpaceEnabled(false)
	self:AddFlag(FLAG_PHYSSIMULATED) 
	
	
	self:AddEventListener(EVENT_USE,"use_event",function(user) 
		if self:IsEquipped() then
			user:Unequip(self.slot) 
		else
			user:Equip(self) 
		end
	end)
	self:SetNetworkedEvent(EVENT_USE)
	self:AddFlag(FLAG_USEABLE) 
	self:AddFlag(FLAG_STOREABLE)
end
function ENT:GetSkelModel()
	return self.skinmodel
end
function ENT:LoadModel() 
	local model_scale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	
	local model = self.model
	local world = matrix.Scaling(model_scale)-- * matrix.Rotation(-90,0,0)
	 
	local phys =  self.phys
	local amul = 0.8
	
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(self:GetParameter(VARTYPE_MODEL)) 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	
	
	if(model:HasCollision()) then
		phys:SetShapeFromModel(world * matrix.Scaling(1/amul) ) 
	else
		phys:SetShape(mdl,world * matrix.Scaling(1/amul) ) 
	end
	
	phys:SetMass(10) 
	
	model:SetMatrix( world* matrix.Translation(-phys:GetMassCenter()*amul ))
	
end
function ENT:Load()
	self:LoadModel() 
	self:SetPos(self:GetPos())
end
function ENT:Spawn() 
	self:LoadModel() 
	self.phys:SoundCallbacks()
	self.phys:SetMaterial("wood")
	
	
	
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