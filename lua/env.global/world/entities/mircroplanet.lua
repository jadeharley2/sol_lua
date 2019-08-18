 
function ENT:Init()  
	local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	local model = self:AddComponent(CTYPE_MODEL)  
	local space = self:AddComponent(CTYPE_PHYSSPACE)
	self.model = model
	self.coll = coll 
	self.space = space
	self:SetSizepower(100)
	self:SetSpaceEnabled(true,1)  
	
end
function ENT:Load() 
	--self:SetModel( 'primitives/sphere.stmd',1.9)
	self.space:SetRadialGravity(-0.1)
	--self.coll:SetupNodeTransfer()
end  
function ENT:Spawn()  
	--self:SetModel( 'primitives/sphere.stmd',1.9)
	self.space:SetRadialGravity(-1)

	self.cc = SpawnSO('primitives/sphere.stmd',self,Vector(0,0,0),19) 
	--self.coll:SetupNodeTransfer()
	MsgN("huh?") 
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
			end
		else
			if(model:HasCollision()) then
				coll:SetShapeFromModel(matrix.Scaling(scale)* matrix.Rotation(-90,0,0))--matrix.Scaling(scale/0.75 ) * matrix.Rotation(-90,0,0) ) 
			end 
		end
	end
	self.modelcom = true
end 
