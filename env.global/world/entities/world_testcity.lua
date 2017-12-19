ENT.name = "Test city"

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
	self:SetGlobalName("u1_city") 

end
function ENT:Spawn()

	-- all worlds must have minimum 1 subspace 
	-- 
	local space = ents.Create()
	space:SetLoadMode(1)
	space:SetSeed(9900002)
	space:SetParent(self) 
	space:SetSizepower(1000)
	space:SetGlobalName("u1_city.space")
	space:Spawn()  
	local sspace = space:AddComponent(CTYPE_PHYSSPACE)  
	sspace:SetGravity(Vector(0,-4,0))
	space.space = sspace

	--def:1900000000
	local light = self:CreateStaticLight(Vector(-1.6,106.2,124.6)/10/2*10,Vector(140,161,178)/255,50500000000)
	--local light = CreateStaticLight(space,Vector(-1.6,106.2,124.6)/10/2*10,Vector(140,161,178)/255,20000000000)
	SpawnSO("map/citytest/sky.json",space,Vector(0,0,0),5,NO_COLLISION) 
	--SpawnSO("map/citytest/fountain.json",space,Vector(0,0,0),1) 
	
	--[[
	
	SpawnSO("map/citytest/roads.json",space,Vector(0,0,0),1) 
	SpawnSO("map/citytest/buildings.json",space,Vector(0,0,0),1) 
	SpawnSO("map/citytest/buildings_2.json",space,Vector(0,0,0),1) 
	SpawnSO("map/citytest/buildings_3.json",space,Vector(0,0,0),1) 
	SpawnSO("map/citytest/buildings_4.json",space,Vector(0,0,0),1) 
	SpawnSO("map/citytest/buildings_5.json",space,Vector(0,0,0),1) 
	SpawnSO("map/citytest/canals.json",space,Vector(0,0,0),1) 
	SpawnSO("map/citytest/rway.json",space,Vector(0,0,0),1) 
	SpawnSO("map/citytest/rway_sub.json",space,Vector(0,0,0),1) 
	
	SpawnSO("map/citytest/docks.json",space,Vector(0,0,0),1) 
	SpawnSO("map/citytest/docks_buildings_1.json",space,Vector(0,0,0),1) 
	
	SpawnSO("map/citytest/lamps.json",space,Vector(0,0,0),1) 
	local lamppost_light_list = 
	{
		{-29.856,-1.777,10.792}, 
		{-57.314,1.898,10.792},
		
		{-1.722,29.836,10.792},  
		{1.689,57.272,10.792},
		
		{-3.384,89.289,10.792},
		{32.056,100.276,10.792},
		{52.529,69.776,10.792},
		{69.144,34.107,10.792},
		
		{-22.542,111.224,10.792},
		{-52.145,118.23,10.792},
		{-76.911,121.307,10.792},
	}
	local lamppost_light_color = Vector(255,255,201)/255 
	for k,v in pairs(lamppost_light_list) do 
		CreateStaticLight(space,Vector(v[1],v[3],-v[2])*0.001,lamppost_light_color,100)
	end
	]]
	 
	
	engine.LoadMap("city",space)
	
	local pp1 = SpawnWeapon("tool_propspawner",space,Vector(-0.002,0.003,0),939002)--0.006
	local pp2 = SpawnWeapon("tool_weld",space,Vector(-0.003,0.003,0),939003)--0.006
	local pp3 = SpawnWeapon("tool_physgun",space,Vector(-0.004,0.003,0),939001)--0.006
	local pp4 = SpawnWeapon("weapon_energy",space,Vector(-0.005,0.003,0),939001)--0.006
	
	self.space = space
	
	--SpawnMirror(space,Vector(0.0005589276, 0.001217313, -0.01491671))
end

function ENT:GetSpawn() 
	return self.space, Vector(0,0.01,0)
end