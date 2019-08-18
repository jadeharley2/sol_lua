local NO_COLLISION = NO_COLLISION or 2
local COLLISION_ONLY = COLLISION_ONLY or 1 
 


function SpawnSO(model,ent,pos,scale,collonly,norotation)
	local e = ents.Create("prop_static") 
	e.collonly = collonly
	e:SetSizepower(1)
	e:SetParent(ent)
	e:SetParameter(VARTYPE_MODEL,model)
	e:SetParameter(VARTYPE_MODELSCALE,scale)
	--e:SetModel(model,scale,norotation)
	e:SetPos(pos) 
	e:Spawn()
	return e
end

function ENT:Init()  
	local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.coll = coll 
	self:SetSpaceEnabled(false) 
	
end
function ENT:Load()
	local modelcom = self.modelcom
	if not modelcom then
		local modelval = self:GetParameter(VARTYPE_MODEL)
		local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
		if modelval then 
			self:SetModel(modelval,modelscale)
		else
			MsgN("no model specified for static model at spawn time")
		end
	end
	--MsgN("dfa")
end  
function ENT:Spawn() 
	--MsgN("spawning static object at ",self:GetPos())
	local modelcom = self.modelcom
	if not modelcom then
		local modelval = self:GetParameter(VARTYPE_MODEL)
		local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
		if modelval then
			--MsgN("with model: ",modelval," and scale: ", modelscale)
			self:SetModel(modelval,modelscale)
		else
			error("no model specified for static model at spawn time")
		end
	end
end

function ENT:SetModel(mdl,scale,norotation) 
	scale = scale or 1
	norotation = norotation or false
	local model = self.model
	local world = matrix.Scaling(scale)
	if not norotation then
		world = world * matrix.Rotation(-90,0,0)
	end
	 
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
	 
	if self.collonly ~= NO_COLLISION then
		local coll =  self.coll 
		if norotation then
			if(model:HasCollision()) then
				coll:SetShapeFromModel(matrix.Scaling(scale))--matrix.Scaling(scale/0.75 )  ) 
			else
				--coll:SetShape(mdl,matrix.Scaling(scale))--matrix.Scaling(scale/0.75 ) ) 
			end
		else
			if(model:HasCollision()) then
				coll:SetShapeFromModel(matrix.Scaling(scale)* matrix.Rotation(-90,0,0))--matrix.Scaling(scale/0.75 ) * matrix.Rotation(-90,0,0) ) 
			else
				--coll:SetShape(mdl,matrix.Scaling(scale)* matrix.Rotation(-90,0,0))--matrix.Scaling(scale/0.75 ) * matrix.Rotation(-90,0,0) ) 
			end
		end
		if self.collonly then
			model:Enable(false)
		end
	end
	self.modelcom = true
end 
