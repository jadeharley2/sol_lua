
function SpawnButton(parent,model,pos,ang,action,seed)
	local e = ents.Create("use_button")  
	e:SetModel(model,1)
	e:SetSizepower(1)
	e:SetParent(parent)
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
	self.model = model 
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
	self:AddEventListener(EVENT_USE,"use_event",function(user) self:Press(user) end)
	self:SetNetworkedEvent(EVENT_USE)
	self:AddFlag(FLAG_USEABLE) 
	
end

 
function ENT:SetModel(mdl,scale) 
	scale = scale or 1
	local model = self.model
	local world = matrix.Scaling(scale) * matrix.Rotation(-90,0,0)
	
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
	  
	self.modelcom = true
end 


function ENT:Press(user) 
	local act = self.OnPress 
	if act then act(self,user) end
end