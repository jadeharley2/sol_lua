
function SPP() 
	
	local pa = LocalPlayer()
	local pp = pa:GetParent()
	local veh = ents.Create("beacon")
	veh:SetParent(pp)
	veh:SetSizepower(10) 
	veh:Spawn()
	veh:SetPos(pa:GetPos()+Vector(0,0.2,0)/pp:GetSizepower())   
	
	local spaceship = ents.GetById(2397131)
	if not spaceship.entered then
		spaceship:Enter()
		spaceship.entered = true
	end
	
	
	local m =  ents.Create("portal")
	m:SetParent(pp)
	m:SetSizepower(1) 
	m:SetSpaceEnabled(false) 
	m:SetPos(veh:GetPos()+Vector(0,2,0)/pp:GetSizepower())  
	--Vector(0.004475257 ,0.02119615,0.2454512)
	m.target = spaceship
	m.target_pos = Vector(-0.004016188, 0.01787391, 0.006022569)
	m:Spawn()
	if PPPP then
		PPPP:Despawn()
	end
	PPPP = m
	
	
	local veh2 = ents.Create("beacon")
	veh2:SetParent(spaceship)
	veh2:SetSizepower(10) 
	veh2:Spawn()
	veh2:SetPos(m.target_pos+(Vector(0,0.2-2,0))/1000)   
	
	
end
function SDP()
	if PPPP then
		PPPP:Despawn()
	end
end

function ENT:Init()  
	--local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	--self.coll = coll
end
function ENT:Spawn()
	
	local world = matrix.Scaling(0.001) * matrix.Rotation(-90,90,0)-- matrix.Scaling(0.03*0.1) * matrix.Rotation(Vector(-90,90,0))
	 
	local model = self:AddComponent(CTYPE_MODEL)  
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel("test/portalbeacon/beacon.json") 
	model:SetMaterial("textures/debug/white.json") 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	
	self.model =  model
	
	--local coll = self.coll
	--coll:SetShape("test/portalbeacon/ref.SMD",world*matrix.Scaling(10/0.75) )  
	
	model:SetMatrix(world)
	
	self:SetSpaceEnabled(false) 
	
	
	self:AddEventListener(EVENT_USE,"use_event",function(self,user)
		MsgN(self," is used by aaa: ",user)
		user:SetParent(self.target)
		user:SetPos(self.target_pos)
	end)
	self:AddFlag(FLAG_USEABLE)
	
end
 