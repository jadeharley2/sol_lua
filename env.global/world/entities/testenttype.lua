
ENT.baseclass = "entity"
ENT.testvalue = "abc"

function ENT:Init()  
	local mst ="furniture/jade/pot_m.SMD"
	local cst ="furniture/jade/pot_c.SMD" 
	local mtr =matrix.Scaling(0.4) * matrix.Rotation(-90,0,0)
	
	local phys = self:AddComponent(CTYPE_PHYSOBJ)
	phys:SetShape(cst,mtr)
	phys:SetMass(100)
	--phys:SetVelocity(Vector(0,0,-0.01))
	self.phys = phys
	
	local model = self:AddComponent(CTYPE_MODEL)
	model:SetModel(mst)
	MsgN(-phys:GetMassCenter())
	model:SetMatrix(mtr*matrix.Translation(-phys:GetMassCenter()))
	self.model = model
end

function ENT:Spawn() 
	MsgN("heh")
	--self.somevalue = "somewtf"
	MsgN(tostring( getmetatable(self)))
	MsgN("heh ".. tostring(self).. tostring(self.somevalue))
end
 
function ENT:Despawn()  
end

function ENT:Think()  
	self.phys:ApplyImpulse(-self:GetPos():Normalized()*400)
end

function ENT:Enter()  
	MsgN("wat ".. tostring(self))
end

function ENT:Leave()  
end