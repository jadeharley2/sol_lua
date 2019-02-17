

function SpawnCONT(model,parent,pos)
	local e = ents.Create("use_container")
	MsgN("lol"..model)
	e:SetSizepower(1)
	e:SetParent(parent)
	e:SetModel(model) 
	e:SetPos(pos) 
	e:SetSeed(43589)
	e:Create()
	return e
end

ENT.usetype = "open container"

function ENT:Init()  
	local phys = self:AddComponent(CTYPE_PHYSOBJ)  
	local model = self:AddComponent(CTYPE_MODEL)  
	local storage = self:AddComponent(CTYPE_STORAGE)  
	self.model = model
	self.phys = phys
	self.storage = storage
	self:SetSpaceEnabled(false)
	self:AddFlag(FLAG_PHYSSIMULATED)
	 
	self:AddFlag(FLAG_USEABLE)

	--phys:SetMass(10)  
	
end
function ENT:LoadModel() 
	local model_scale = self:GetParameter(VARTYPE_MODELSCALE) or 0.2	--0.2
	
	local model = self.model
	local world = matrix.Scaling(model_scale)-- * matrix.Rotation(-90,0,0)
	 
	local phys =  self.phys
	local amul = 8
	
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(self:GetParameter(VARTYPE_MODEL)) 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	model:SetMatrix(world)
	
	if(model:HasCollision()) then
		phys:SetShapeFromModel(world) 
	else
		phys:SetShape(mdl,world) 
	end
	--phys:SetShape(phymodel,world * matrix.Scaling(1/amul) )
	phys:SetMass(10) 
	
	--model:SetMatrix( world* matrix.Translation(-phys:GetMassCenter()*amul*10 ))
	
	--MsgN("model    "..tostring(phys:GetMassCenter()) )
end
function ENT:Load()
	self:LoadModel() 
	self:SetPos(self:GetPos())
end
function ENT:Spawn() 
	self:LoadModel() 
	self.phys:SoundCallbacks()
	self.phys:SetMaterial("wood")
end
function ENT:SetModel(mdl)
	self:SetParameter(VARTYPE_MODEL,mdl) 
end
function ENT:SetModelScale(scale) 
	self:SetParameter(VARTYPE_MODELSCALE,scale)
end
--function ENT:Think()
--	--MsgN(self.phys:OnGround())
--	--if input.KeyPressed(KEYS_K) then
--		--self.phys:SetStance(STANCE_STANDING)
--		--self.phys:SetMovementDirection(Vector(100,0,100))
--		--self.phys:SetStandingSpeed(1000) 
--		--self.phys:SetAirSpeed(1000) 
--	--else
--	--	self.phys:SetMovementDirection(Vector(0,0,0))
--	--end
--end
 
ENT._typeevents = { 
	[EVENT_USE] = {networked = true, f = function(self,user)   
		self.isopened = not self.isopened 
		if self.isopened then
			self:EmitSound("events/storage-open.ogg",1)
			if CLIENT and LocalPlayer() == user then OpenInventoryWindow(self) end
		else
			self:EmitSound("events/storage-close.ogg",1)
			if CLIENT and LocalPlayer() == user then CloseInventoryWindow(self) end
		end
	end},
}  