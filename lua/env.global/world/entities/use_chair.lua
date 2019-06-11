 
function SpawnChair(model,ent,pos,scale)
	local e = ents.Create("use_chair") 
	e:SetModel(model,scale)
	e:SetSizepower(1)
	e:SetParent(ent)
	e.ship = ent
	e:SetPos(pos) 
	e:Spawn()
	return e
end

ENT.mountpoints = {
	{pos = Vector(0,13,0)/10,ang = Vector(0,-90,0),state="sit.capchair"}
}

ENT.usetype = "sit"

function ENT:Init()   
	self:SetSizepower(1) 
	
	
	local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.coll = coll 
	
end
function ENT:Load() 
	local modelval = self:GetParameter(VARTYPE_MODEL)
	local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	if modelval then 
		self:SetModel(modelval,modelscale)
	else
		MsgN("no model specified for static model at spawn time")
	end
	self:AddTag(TAG_USEABLE)
end
function ENT:Spawn(c)  
  
	local world = matrix.Scaling(0.03*0.1) * matrix.Rotation(Vector(-90,90,0))
	   
	self:SetSpaceEnabled(false) 
	
	local modelval = self:GetParameter(VARTYPE_MODEL)
	local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	if modelval then 
		self:SetModel(modelval,modelscale)
	else
		MsgN("no model specified for static model at spawn time")
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
	model:SetModel(mdl)   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world)
	 
	local coll =  self.coll 
	if(model:HasCollision()) then
		coll:SetShapeFromModel(matrix.Scaling(scale/0.75 ) * matrix.Rotation(-90,0,0) ) 
	else
		coll:SetShape(mdl,matrix.Scaling(scale/0.75 ) * matrix.Rotation(-90,0,0) ) 
	end
	self.modelcom = true
end 


function ENT:Throttle(dir)  
end
function ENT:Turn(dir)   
end
function ENT:Turn2(dir)   
end
function ENT:HandleDriving(actor)   
end 
function ENT:GetFreeMountpoint() 
	for k,v in pairs(self.mountpoints) do
		if v.ent == nil then
			return k
		end
	end
	return false
end 

ENT._typeevents = {
	[EVENT_USE] = {networked = true, f = function(self,user)
		local mp = self:GetFreeMountpoint()
		if mp then
			user:SendEvent(EVENT_SET_VEHICLE,self,mp)
		else
			local oump = self.mountpoints[1]
			if oump then 
				if oump.ent:HasTag(TAG_USEABLE) then
					oump.ent:SendEvent(EVENT_USE,user)
				end
			end
		end
	end},
} 
