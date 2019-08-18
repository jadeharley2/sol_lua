
function SpawnButton(parent,model,pos,ang,action,seed,scale)
	local e = ents.Create("use_button")  
	e:SetSizepower(1)
	e:SetParent(parent)
	e:SetModel(model,scale or 1)
	e:SetPos(pos) 
	e:SetAng(ang or Vector(0,0,0)) 
	e.OnPress = action
	e:SetSeed(seed)
	e:Spawn()
	return e
end

ENT.usetype = "button"

function ENT:Init()   
	local model = self:AddComponent(CTYPE_MODEL)  
	local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	self.model = model 
	self.coll = coll 
	self:SetSpaceEnabled(false)  
	
end
function ENT:Load()
	local modelval = self:GetParameter(VARTYPE_MODEL)
	local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	if modelval then 
		self:SetModel(modelval,modelscale)
	else
		MsgN("no model specified for button model at spawn time")
	end  
end  
function ENT:Spawn()  
	local modelcom = self.modelcom
	if not modelcom then
		local modelval = self:GetParameter(VARTYPE_MODEL)
		local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
		if modelval then 
			self:SetModel(modelval,modelscale)
		else
			error("no model specified for button model at spawn time")
		end
	end 
	self:AddTag(TAG_USEABLE) 
	
end

 
function ENT:SetModel(mdl,scale) 
	scale = scale or 1
	local model = self.model
	local world = matrix.Scaling(scale) * matrix.Rotation(-90,0,0)
	
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	--model:SetRenderOrder(1)
	model:SetModel(mdl)   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world)
	 
	self.coll:SetShapeFromModel(matrix.Scaling(scale) ) 
	
	self.modelcom = true
end 


function ENT:Press(user) 
	local act = self.OnPress 
	if act then act(self,user) end
	if CLIENT then
		self:EmitSound("events/lamp-switch.ogg",1)
	end
end

ENT._typeevents = {
	[EVENT_USE] = {networked = true, f = ENT.Press},
}