 

function ENT:Init()   
	self:SetSeed(4346908)
	self:SetSizepower(10000)--10km
	local space = self:AddComponent(CTYPE_PHYSSPACE) 
	space:SetGravity(Vector(0,-0.000001,0))
	self.space = space
	
end

function ENT:Spawn()  

	
	
	
		
end
function ENT:Think()   
	
	-- 1 turn per 100 sec
	self.ring:SetAng(Vector(0,0,CurTime()*360/100))
end
function ENT:Enter()

	local dock = ents.Create() 
	dock:SetSizepower(750)
	dock:SetSeed(6230948)
	dock:SetParent(self)
	local dspace = dock:AddComponent(CTYPE_PHYSSPACE) 
	dspace:SetGravity(Vector(0,-9.5,0))
	self.space = space
	
	self.dock = dock
	
	local ring = ents.Create() 
	ring:SetSizepower(750)
	ring:SetSeed(6098203)
	ring:SetSpaceEnabled(false) 
	ring:SetParent(self)
	self.ring = ring
	
	local rspace = ring:AddComponent(CTYPE_PHYSSPACE) 
	--rspace:SetGravity(Vector(0,-9.5,0))
	rspace:SetRadialGravity(100)
	ring.space = space
	
	ring.station = self
	dock.station = self
	
	dock:Spawn()
	ring:Spawn()
	
	
	
	local dock_model = SpawnSO("space/stations/dring/dock_ref.stmd",dock,Vector(0,0,0),0.75)
	dock_model.model:SetMaterial("textures/debug/white.json") 
	self.dock_model = dock_model
	
	local ring_model = SpawnSO("space/stations/dring/ring_ref.stmd",ring,Vector(0,0,0),0.75)
	ring_model.model:SetMaterial("textures/debug/white.json") 
	self.ring_model = ring_model
	 
	local ring_interior_model = SpawnSO("space/stations/dring/ring_interior_1.stmd",ring,Vector(0,0,0),0.75)
	 
	local mul = 0.75 / 750 
	self.dock_coord = Coordinate(self.dock,Vector(94.161,-17.097,361.39)*mul)
	self.approach_coord  = Coordinate(self.dock,Vector(94.161,-17.097,361.39+2000)*mul)
	
	self.aligna_coord = Coordinate(self.dock,Vector(94.161,-17.097,361.39+500)*mul)
	self.alignb_coord = Coordinate(self.dock,Vector(94.161,-17.097,361.39+250)*mul)
	self.alignc_coord = Coordinate(self.dock,Vector(94.161,-17.097,361.39-250)*mul)
	
	self.maxshipspeed = 0.001
	self.dock.maxshipspeed = 0.0001
	
	self:SetUpdating(true,20)
	
	
	local function pcon(x,y,z)
		return Vector(x,z,-y)*0.001
	end
	
	--LIFT
	local pn = {}
	-- x, z, -y
	pn[1] = {p = pcon(-195.992,0,-1.511),n ="docks",s=true,c=1}  
	pn[2] = {p = pcon(-212.355,0,-1.511)}
	pn[3] = {p = pcon(-279.661,0,-1.511),a = function(s,p) 
		local spar = s:GetParent()
		if spar==dock then s:SetParent(ring) else s:SetParent(dock) end
	end}
	pn[4] = {p = pcon(-262.797,0,-151.889)}
	pn[5] = {p = pcon(-104.702,0,-289.225)}
	pn[6] = {p = pcon(-104.702,0,-1251.806)}
	pn[7] = {p = pcon(-309.971,0,-2611.363)}
	pn[8] = {p = pcon(-345.602,0,-2975.906)}
	pn[9] = {p = pcon(-345.602,0,-2975.906)}
	pn[10] = {p = pcon(-345.602,0,-3239.451),n ="tower A lobby",s=true,c=1} 
	  
	pn.links = {{1,2,3,4,5,6,7,8,9,10}}
	pn.currentid = 1
	
	self.lift = SpawnLift(dock,328502,pn,"space/stations/dring/lift_ref.stmd")
	self.lift .speed = 100
	









	local ss = SpawnSO("space/ships/cargo1/all_ref.stmd",self.dock,Vector(0.8,0,0.8),0.75)
	ss:SetAng(Vector(130,130,130))
	ss.model:SetMaterial("textures/debug/white.json") 
	
	self.unload = {ss}
end
function ENT:Leave()
	for	k,v in pairs(self.unload) do
		v:Despawn()
	end
end