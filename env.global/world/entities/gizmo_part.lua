EVENT_RESCALE = 23001


--[[
	
	params:
	.constraint 
	.constraint2 
]]--
function ENT:Init()   
	self:SetSizepower(1000)
	self:SetSpaceEnabled(false)
	
	model = self:AddComponent(CTYPE_MODEL)
	self.model = model 
	coll = self:AddComponent(CTYPE_STATICCOLLISION)
	self.coll = coll
	
	--local model = self:AddComponent(CTYPE_MODEL)
	--self.model = model 
	--local coll = self:AddComponent(CTYPE_STATICCOLLISION)
	--self.coll = coll
	
	--self:AddEventListener(EVENT_RESCALE,"event",function() 
	--	self:Rescale()
	--end)
end
--function ENT:Spawn()
--	--self:Load()
--end
function ENT:Spawn()
	--MsgN("res")
	local model = self.model
	local coll = self.coll
	--if model then self:RemoveComponent(model) end
	--if coll then self:RemoveComponent(coll) end
	
	
	local mdl = self:GetParameter( VARTYPE_MODEL, "engine/gismo/arrow.smd") 
	local color = self:GetParameter(VARTYPE_COLOR,Vector(1,1,1))
	local world = matrix.Scaling(0.001) * matrix.Rotation(-90,0,0)
	model:SetRenderGroup(RENDERGROUP_OVERLAY)
	model:SetModel(mdl) 
	if self.gtype == "rotation" then
		model:SetMaterial("models/engine/gizmo/circle.json") 
	else
		model:SetMaterial("textures/debug/white.json") 
	end
	model:SetBlendMode(BLEND_ADD) 
	model:SetRasterizerMode(RASTER_NODETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_DISABLED) 
	model:SetMatrix(world) 
	model:SetBrightness(1)
	model:SetColor(color)
	model:SetFullbright(true)
	model:SetFadeBounds(0,99999,0)
	
	coll:SetShape(mdl, matrix.Scaling(self:GetSizepower()*1.5) * world ) 
	
	self:SetPos(self:GetPos())
end
function ENT:OnClick()
	self.root:StartDrag(self)
end