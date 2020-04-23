 
 
function TSPC()
	local pa = LocalPlayer()
	local pp = pa:GetParent()
	local veh = ents.Create("base_vehicle")
	veh:SetParent(pp)
	veh:SetSizepower(1) 
	veh:SetSpaceEnabled(false)
	veh:SetSeed(103)
	veh:Spawn()
	veh:SetPos(pa:GetPos()+Vector(0,3,0)/pp:GetSizepower())
	--constraint.RevoluteAngular(veh.phys,nil,Vector(0,1,0))
	--veh.phys:ApplyImpulse(Vector(0,4,40)/10)
	veh:SetUpdateSpace(true)
	 
end 

ENT.mountpoints = {
	{pos = Vector(-2.9,0.5,0.815532),ang = Vector(0,180,0)}
} 
ENT.info = "vehicle"
ENT._interact = {
	sit={text="sit",
	action = function (self,user) 
		MsgN(self," is used by aaa: ",user)
		user:SendEvent(EVENT_SET_VEHICLE,self,1,self)--SetVehicle(self,1,self) 
	end},
}
function ENT:Init()  
	self:SetSizepower(1) 
	self:AddTag(TAG_PHYSSIMULATED)
	self:SetSpaceEnabled(false)
end 
function ENT:Throttle(dir)
	local pp = self:GetParent()
	local sz = pp:GetSizepower()
	local f = self:Right()*1000*-dir
--	self.phys:SetSpeed(dir*10)--:ApplyImpulse(f/sz)  
end
function ENT:Turn(dir) 
	local f = self:Up()*dir*100*10-- Vector(0,0,dir*100)
	self.phys:ApplyAngularImpulse(f)  
end
function ENT:Turn2(dir) 
	local f = self:Right()*dir*100*10-- Vector(0,0,dir*100)
	self.phys:ApplyAngularImpulse(f) 
end

function ENT:HandleDriving(actor)
	local W,A,S,D,Q,E= input.KeyPressed(KEYS_W),input.KeyPressed(KEYS_A),input.KeyPressed(KEYS_S),input.KeyPressed(KEYS_D),input.KeyPressed(KEYS_Q),input.KeyPressed(KEYS_E)
	if W then
		self.phys:SetSpeed(10)--:ApplyImpulse(f/sz)  
	elseif S then
		self.phys:SetSpeed(-10)--:ApplyImpulse(f/sz)  
	else
		self.phys:SetSpeed(0)--:ApplyImpulse(f/sz)  
	end

	if input.KeyPressed(KEYS_SPACE) then
		local pp = self:GetParent()
		local sz = pp:GetSizepower()
		self.phys:ApplyImpulse(self:Right()*-1000/sz)
	end
end
function ENT:Spawn(c)  
 
	
	
	local world = matrix.Scaling(1) * matrix.Rotation(Vector(-90,90,0))
	 
	local model = self:AddComponent(CTYPE_MODEL)  
	model:SetModel("models/vehicles/fr01.stmd")  
	model:SetMatrix(world)
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)   
	self.model =  model
	
	local phys = self:AddComponent(CTYPE_WHEELEDVEHICLE)  
	self.phys = phys
	
	
	--phys:Initialize() 
	phys:BuildStart()
	phys:AddBody(Vector(0,0,0),Vector(3.32139, 9.49289, 2.19992),100)
	
	local horiz = 1.7545568943023682
	local vv1 = Vector(-1.3391491174697876, 2.804790496826172, 0.8065710663795471 - horiz)  
	local vv2 = Vector(-1.3391491174697876, -1.4928523302078247, 0.8065710663795471 - horiz)  
	local vv3 = Vector(-1.3391491174697876, -3.340611457824707, 0.8065710663795471 - horiz)   
	local wrad = 0.87
	local wwdt = 0.57
	local wmd = matrix.Identity()
	local whmodel = "models/vehicles/fr01_wheel.stmd"

	self:AddWheel(Vector(-vv1.y,vv1.z,vv1.x),wrad,wwdt,1,wmd,whmodel,false,true)
	self:AddWheel(Vector(-vv2.y,vv2.z,vv2.x),wrad,wwdt,1,wmd,whmodel,false,true)
	self:AddWheel(Vector(-vv3.y,vv3.z,vv3.x),wrad,wwdt,1,wmd,whmodel,false,true)

	self:AddWheel(Vector(-vv1.y,vv1.z,-vv1.x),wrad,wwdt,1,wmd,whmodel,false,true)
	self:AddWheel(Vector(-vv2.y,vv2.z,-vv2.x),wrad,wwdt,1,wmd,whmodel,false,true)
	self:AddWheel(Vector(-vv3.y,vv3.z,-vv3.x),wrad,wwdt,1,wmd,whmodel,false,true)
 
	phys:BuildFinish(1000)

	phys:UpdateSpace()  
	
	self:SetUpdating(true)
	self:SetSpaceEnabled(false) 
	 
	self:AddTag(TAG_USEABLE)
	 
end
function ENT:AddWheel(pos,  radius,  width,  dt,  rotation, mpath,  steering,  motor) 
	local world = matrix.Scaling(1) * matrix.Rotation(Vector(-90,90,0))
	local model = self:AddComponent(CTYPE_MODEL)  
	model:SetModel(mpath)  
	model:SetMatrix(world)
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0) 
	self.phys:AddWheel( pos,  radius,  width,  dt,  rotation,  model,  steering,  motor)
	--AddWheelModel(model)  
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

function ENT:Think() 
end


ENT._typeevents = {
	[EVENT_USE] = {networked = true, f = function(self,user)
		MsgN(self," is used by aaa: ",user)
		user:SendEvent(EVENT_SET_VEHICLE,self,1,self)--SetVehicle(self,1,self) 
	end},
}