ENT.name = "Flat grass"


function ENT:CreateStaticLight( pos, color,power)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2) 
	lighttest:SetParent(self)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn() 
	if power then lighttest:SetBrightness(power) end
	lighttest:SetPos(pos)  
	return lighttest
end

function ENT:Init()

	self:SetSizepower(10000)
	self:SetSeed(9900001)
	self:SetGlobalName("u1_room") 

end
function ENT:Spawn()

	-- all worlds must have minimum 1 subspace 
	-- 
	local space = ents.Create()
	space:SetLoadMode(1)
	space:SetSeed(9900002)
	space:SetParent(self) 
	space:SetSizepower(1000)
	space:SetGlobalName("u1_room.space")
	space:Spawn()  
	local sspace = space:AddComponent(CTYPE_PHYSSPACE)  
	sspace:SetGravity(Vector(0,-4,0))
	space.space = sspace

	SpawnSO("map/01/01.json",space,Vector(0,0,0),0.75) 
	--def:190000000
	--local light = self:CreateStaticLight(Vector(-1.3,1.2,-2.5)/2*10,Vector(140,161,178)/255,190000000)
	local light = self:CreateStaticLight(Vector(-1.3,1.2,-2.5)/2*10,Vector(200,200,200)/255,190000000 * 100)
	
	local pp = SpawnWeapon("tool_physgun",space,Vector(-0.001,0.003,0),939001)--0.006
	local pp2 = SpawnWeapon("tool_propspawner",space,Vector(-0.002,0.003,0),939002)--0.006
	local pp3 = SpawnWeapon("tool_weld",space,Vector(-0.003,0.003,0),939003)--0.006
	local pp4 = SpawnWeapon("weapon_energy",space,Vector(-0.004,0.003,0),939004)--0.006
	local pp5 = SpawnWeapon("staff_nami",space,Vector(-0.005,0.003,0),939005)--0.006
	local pp5 = SpawnWeapon("bow_kindred",space,Vector(-0.006,0.003,0),939006)--0.006
	self.space = space
	
	SpawnIA("mlp_shoes_luna",space,Vector(0,0.01,0)) 
	SpawnIA("mlp_crown_luna",space,Vector(0,0.01,0)) 
	SpawnIA("mlp_shoes_tempest",space,Vector(0.002,0.01,0)) 
	SpawnIA("mlp_armor_tempest",space,Vector(0.004,0.01,0)) 
	SpawnIA("mlp_armor_tempest2",space,Vector(0.006,0.01,0)) 
	SpawnIA("mlp_necklace_luna",space,Vector(0.008,0.01,0)) 
	
	local ambient = ents.Create("ambient_sound")
	ambient:SetParent(space)
	ambient:Spawn()
	self.ambient = ambient
	
	SpawnMirror(space,Vector(0.0005589276, 0.001217313, -0.01491671))
end

function ENT:GetSpawn() 
	return self.space, Vector(0,0.01,0)
end