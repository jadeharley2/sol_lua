
function SpawnPM(model,ent,pos)
	local e = ents.Create("prop_static") 
	e:SetSizepower(1)
	e:SetParent(ent)
	e:SetPos(pos) 
	e:Spawn()
	return e
end

function ENT:Init()  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self:SetSpaceEnabled(true) 
	
end
function ENT:Spawn() 
	self:SetModel("proc",1) 
end

function ENT:SetModel(mdl,scale) 
	scale = scale or 1
	local model = self.model
	local world = matrix.Scaling(scale) * matrix.Rotation(-90,0,0)
	 
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetTestModel()   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world)
	  
end 