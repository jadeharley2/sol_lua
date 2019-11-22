 
 
function TSPC()
	local pa = LocalPlayer()
	local pp = pa:GetParent()
	local veh = ents.Create("base_vehicle")
	veh:SetParent(pp)
	veh:SetSizepower(10) 
	veh:SetSeed(103)
	veh:Spawn()
	veh:SetPos(pa:GetPos()+Vector(0,3,0)/pp:GetSizepower())
	--constraint.RevoluteAngular(veh.phys,nil,Vector(0,1,0))
	veh.phys:ApplyImpulse(Vector(0,4,40)/10)
	veh:SetUpdateSpace(true)
	
end 

ENT.mountpoints = {
	{pos = Vector(0.02,0.06,0),ang = Vector(0,0,0)}
}
function ENT:Init()  
	self:SetSizepower(10) 
	self:AddTag(TAG_PHYSSIMULATED)
end 
function self:Trottle(dir)
	local pp = self:GetParent()
	local sz = pp:GetSizepower()
	local f = self:Right()*10000*dir
	self.phys:ApplyImpulse(f/sz) 
end
function self:Turn(dir) 
	local f = self:Up()*dir*100-- Vector(0,0,dir*100)
	self.phys:ApplyAngularImpulse(f) 
end
function self:Turn2(dir) 
	local f = self:Right()*dir*100-- Vector(0,0,dir*100)
	self.phys:ApplyAngularImpulse(f) 
end

function ENT:Spawn(c)  
 
	
	
	local world = matrix.Scaling(0.03*0.1) * matrix.Rotation(Vector(-90,90,0))
	 
	local model = self:AddComponent(CTYPE_MODEL)  
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel("test/vehicle/vehtest.json") 
	model:SetMaterial("textures/debug/white.json") 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	
	self.model =  model
	
	local phys = self:AddComponent(CTYPE_PHYSOBJ) 
	phys:SetShape("test/vehicle/phy.SMD",world*matrix.Scaling(10/0.75) )--"test/vehicle/phy.SMD", world)
	phys:SetMass(100) 
	phys:UpdateSpace()
	local sppoint = -phys:GetMassCenter()*0.01
	model:SetMatrix(world*matrix.Translation(sppoint))
	
	
	phys:SetGravity(Vector(0,-4,0))
	self.phys = phys
	
	--local particlesys = self:AddComponent(CTYPE_PARTICLESYSTEM) 
	--particlesys:SetRenderGroup(RENDERGROUP_LOCAL)
	--particlesys:SetNodeMode(false)
	--particlesys:AddNode(1) 
	--particlesys:SetNodeStates(1,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_ENABLED) 
	--particlesys:SetTexture(1,rdtex)
	--particlesys:AddParticle(1,Vector(0,0,0),scolor,10,0) 
	--
	--self.particlesys = particlesys
	
	self:SetUpdating(true)
	self:SetSpaceEnabled(false) 
	 
	self:AddTag(TAG_USEABLE)
	
	constraint.RevoluteAngular(phys,nil,Vector(0,1,0)) 
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