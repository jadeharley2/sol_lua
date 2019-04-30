
 
function ENT:Init()  
	self:SetSpaceEnabled(false)
	self:SetSizepower(1000)
	self.model = self:AddComponent(CTYPE_MODEL)

	
	local light = self:AddComponent(CTYPE_LIGHT)  
	local scolor = Vector(1,1,1)
	light:SetColor(scolor)
	light:SetBrightness(10) 
	self.light = light
	
end 
function ENT:Spawn()
	local m = self:GetParameter(VARTYPE_MODEL) or "models/primitives/box.stmd"
	local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	self:SetModel(m,modelscale)

	self.cam = ents.CreateCamera() 
	self.cam:SetParent(self)
	self.cam:Spawn()	
end
function ENT:Load()
	local m = self:GetParameter(VARTYPE_MODEL) or "models/primitives/box.stmd"
	local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	self:SetModel(m,modelscale)
end

function ENT:SetModel(mdl,scale) 
	local model = self.model
	local world = matrix.Scaling(scale*0.001)
	 
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(mdl)  
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	model:SetMatrix( world) 
	  
end 
