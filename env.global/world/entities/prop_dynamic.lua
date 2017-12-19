
function SpawnDO(model,ent,pos,scale)
	local e = ents.Create("prop_dynamic")
	
	e:SetModel(model,scale)
	e:SetSizepower(1)
	e:SetParent(ent)
	e:SetPos(pos) 
	e:Spawn()
	return e
end

function ENT:Init()  
	local phys = self:AddComponent(CTYPE_PHYSMESH)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.phys = phys 
	self:SetSpaceEnabled(false) 
end
function ENT:SetModel(mdl,scale) 
	scale = scale or 1
	local model = self.model
	local world = matrix.Scaling(scale) * matrix.Rotation(-90,0,0)
	
	 
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(mdl)   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	model:SetMatrix(world)
	 
	local phys =  self.phys 
	if(model:HasCollision()) then
		phys:SetShapeFromModel(matrix.Scaling(1 ) * matrix.Rotation(-90,0,0) ) 
	else
		phys:SetShape(mdl,matrix.Scaling(1 ) * matrix.Rotation(-90,0,0) ) 
	end
end 