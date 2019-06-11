 
function SpawnSPCH(model,ent,pos,scale)
	local e = ents.Create("spaceship_chair") 
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

function ENT:Init()   
	self:SetSizepower(10) 
	
	
	local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.coll = coll 
	
end

function ENT:Spawn(c)  
 
	
	
	local world = matrix.Scaling(0.03*0.1) * matrix.Rotation(Vector(-90,90,0))
	  
	
	--local phys = self:AddComponent(CTYPE_PHYSOBJ) 
	--phys:SetShape("test/vehicle/phy.SMD",world*matrix.Scaling(10/0.75) )--"test/vehicle/phy.SMD", world)
	--phys:SetMass(100) 
	--phys:UpdateSpace()
	--local mountpoint = -phys:GetMassCenter()*0.01
	--model:SetMatrix(world*matrix.Translation(mountpoint))
	--self.mountpoint = mountpoint
	--phys:SetGravity(Vector(0,-4,0))
	--self.phys = phys
	 
	--local mountpoint = Vector(0,1,0)/10
	
	--self:SetUpdating(true)
	self:SetSpaceEnabled(false) 
	
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
		coll:SetShapeFromModel(matrix.Scaling(scale ) * matrix.Rotation(-90,0,0) ) 
	else
		--coll:SetShape(mdl,matrix.Scaling(scale ) * matrix.Rotation(-90,0,0) ) 
	end
	self.modelcom = true
end 
function ENT:SetColor(c) 
	self.light:SetColor(c) 
end
function ENT:SetBrightness(c) 
	self.light:SetBrightness(c) 
end
function ENT:Enable(c) 
	self.light:Enable(c) 
end

function ENT:Throttle(dir) 
	local alt = input.KeyPressed(KEYS_ALT)
	if alt then
		self.ship:Throttle(dir/1) 
	else
		self.ship:Throttle(dir/10)  
	end
end
function ENT:Turn(dir)   
	if self.ship and self.ship.Turn then  
		self.ship:Turn(dir) 
	end
end
function ENT:Turn2(dir)
	if self.ship and self.ship.Turn2 then  
		self.ship:Turn2(dir) 
	end
end
function ENT:HandleDriving(actor) 
	if self.ship and self.ship.HandleDriving then
		self.ship:HandleDriving(actor) 
	end
end

function ENT:Think()  
end

if CLIENT then
	function ENT:OnActorKeyDown(actor,key)
		if input.KeyPressed(KEYS_M) then
			if self.ship and self.ship.starmap then
				self.ship.starmap:OpenMap(actor,"system")
			end 
		elseif input.KeyPressed(KEYS_N) then
			if self.ship and self.ship.starmap then
				self.ship.starmap:OpenMap(actor,"galaxy")
			end
		end
	end
end

ENT._typeevents = {
	[EVENT_USE] = {networked = true, f = function(self,user)
		MsgN(self," is used by: ",user," for ",self.ship) 
		user:SendEvent(EVENT_SET_VEHICLE,self,1,self.ship)--SetVehicle(self,1,self.ship) 
	end},
}  