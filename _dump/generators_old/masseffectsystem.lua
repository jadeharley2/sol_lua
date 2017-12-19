 
luanet.load_assembly("System")
luanet.load_assembly("SolMain")
Random=luanet.import_type("System.Random") 
sCelestialBody=luanet.import_type("SolMain.sCelestialBody")
LogNormalDistribution=luanet.import_type("SolMain.LogNormalDistribution")
NameGenerator=luanet.import_type("SolMain.NameGenerator")
SpaceOrbit=luanet.import_type("SolMain.SpaceOrbit") 
Atmosphere=luanet.import_type("SolMain.Atmosphere") 

include("masseffect/world.lua")
include("masseffect/systems.lua")
local systemlist = MassEffectData.world.systems
local habitableplanetlist = file.ReadLines("data/lua/env.global/generators/masseffect/habitableworlds.txt");

local TSTD = ToStandardUnits

local GEN = {}
 
local function NextFloat(rnd,min,max)
	return rnd:NextDouble()*(max-min)+min
end

function GEN:Generate()
	local system = self
	local seed = system.seed
	local sid = system:GetValue2("sysid") 
	MsgN(sid)
	local sdata = systemlist[sid]
	
	if sdata then 
	--PrintTable(sdata)
		local stdata = sdata.star
		local star = sCelestialBody()--ents.Create("star")
		--table.HasValue(
		star.name = stdata.name
		star.mass = TSTD(stdata.mass)
		if star.mass == 0 then star.mass = CONST_SunMass end
		star.radius = CONST_SunRadius
		star.color = system.color
		star.sizepower = star.radius * 20000
		star:SetValue("typename","star")
		star:SetParent(system)
		star:Spawn() 
		local id =1
		for k,v in pairs(sdata.planets) do
			GEN.GeneratePlanet(star,v, seed+23979+id*3279)
			id = id + 1
		end
	end
end  
function GEN.GeneratePlanet(star, data, seed)

	local rnd = Random(seed + 435566)
	local planetrnd = Random(seed + 346234208) 
	 
	local body = sCelestialBody()
	body.seed = planetrnd:Next()
	body.name = data.name
	body.mass = TSTD(data.mass) or (0.33E24 * NextFloat(rnd, 0.1, 20))
	body.radius = TSTD(data.radius) or (1000000 * NextFloat(rnd, 0.1, 20)) 
	
	body.orbit = SpaceOrbit() 
	body.orbit.a = TSTD(data.orbit.a)
	if body.orbit.a == 0 then body.orbit.a = CONST_AstronomicalUnit end
	body.orbit.e = NextFloat(rnd, 0, 0.08)
	body.orbit.inclination = NextFloat(rnd, 0, 0.08)
	body.orbit.periargument = NextFloat(rnd, 0, 0.08)
	body.orbit.ascendinglongitude = NextFloat(rnd, 0, 30)
	
	if data.atmoshphere then
		body.atmosphere = Atmosphere()
	end
	
	body:SetValue("typename","planet")
	body:SetValue("temperature",TSTD(data.temp) or 0)
	body:SetParent(star)
	body.sizepower = body.hillSphereRadius  
	body:Spawn()
	body:SetUpdating()
		 
end
return GEN
 