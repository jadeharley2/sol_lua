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
	modelb = self:AddComponent(CTYPE_MODEL)
	self.modelb = modelb 
	coll = self:AddComponent(CTYPE_STATICCOLLISION)
	self.coll = coll
	
	self.scale = 1
	self.isenabled = true
	self:SetDonotsave(true)
	
	--local model = self:AddComponent(CTYPE_MODEL)
	--self.model = model 
	--local coll = self:AddComponent(CTYPE_STATICCOLLISION)
	--self.coll = coll
	
	--self:AddEventListener(EVENT_RESCALE,"event",function(self) 
	--	self:Rescale()
	--end)
end
function ENT:Load()
	--MsgN("res")
	local model = self.model
	local modelb = self.modelb
	local coll = self.coll
	local scale = self.scale
	local enabled = self.isenabled 
	if enabled == nil then enabled = false end
	
	--if model then self:RemoveComponent(model) end
	if coll then self:RemoveComponent(coll) end
	coll = self:AddComponent(CTYPE_STATICCOLLISION)
	self.coll = coll
	
	
	local mdl = self:GetParameter( VARTYPE_MODEL, "engine/gismo/arrow.smd") 
	local color = self:GetParameter(VARTYPE_COLOR,Vector(1,1,1))
	local world = matrix.Scaling(0.001*scale) * matrix.Rotation(-90,0,0)
	model:SetRenderGroup(RENDERGROUP_OVERLAY)
	model:SetModel(mdl) 
	if self.gtype == "rotation" then
		model:SetMaterial("models/engine/gizmo/circle.json") 
		modelb:SetMaterial("models/engine/gizmo/circle.json") 
	else
		model:SetMaterial("textures/debug/white.json") 
		modelb:SetMaterial("textures/debug/white.json") 
	end
	model:SetBlendMode(BLEND_ADD) 
	model:SetRasterizerMode(RASTER_NODETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_DISABLED) 
	model:SetMatrix(world) 
	model:SetBrightness(0.1)
	model:SetColor(color)
	model:SetFullbright(true)
	model:SetFadeBounds(0,99999,0)
	model:Enable(enabled)
	
	modelb:SetRenderGroup(RENDERGROUP_LOCAL)
	modelb:SetModel(mdl)  
	modelb:SetBlendMode(BLEND_ADD) 
	modelb:SetRasterizerMode(RASTER_DETPHSOLID) 
	modelb:SetDepthStencillMode(DEPTH_READ) 
	modelb:SetMatrix(world) 
	modelb:SetBrightness(0.5)
	modelb:SetColor(color)
	modelb:SetFullbright(true)
	modelb:SetFadeBounds(0,99999,0)
	modelb:Enable(enabled)
	
	
	
	
	if(enabled)then
		coll:SetShape(mdl, matrix.Scaling(self:GetSizepower()*1.5) * world ) 
		coll:SetGroup(CGROUP_NOCOLLIDE_PHYSICS)
	end
	
	self:SetPos(self:GetPos())
end
function ENT:Spawn()
	self:Load()
end
function ENT:Enable(enabled)
	self.isenabled = enabled
	if enabled then
		self:Load()
	else
		local model = self.model
		local modelb = self.modelb
		local coll = self.coll
		if coll then self:RemoveComponent(coll) end
		if model then model:Enable(false) end
		if modelb then modelb:Enable(false) end
	end
end
function ENT:OnClick()
	self.root:StartDrag(self)
end
function ENT:Highlight(en)
	if en then
		self.model:SetBlendMode(BLEND_OPAQUE) 
		self.modelb:SetBlendMode(BLEND_OPAQUE) 
		self.model:SetBrightness(0.5)
		self.modelb:SetBrightness(1)
	else
		self.model:SetBlendMode(BLEND_ADD) 
		self.modelb:SetBlendMode(BLEND_ADD) 
		self.model:SetBrightness(0.1)
		self.modelb:SetBrightness(0.3)
	end
end 
function ENT:Rescale(scale)
	self.scale = scale
	self:Load()
end