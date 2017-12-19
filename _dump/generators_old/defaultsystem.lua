
luanet.load_assembly("System")
luanet.load_assembly("SolMain")
Random=luanet.import_type("System.Random") 
sCelestialBody=luanet.import_type("SolMain.sCelestialBody")
LogNormalDistribution=luanet.import_type("SolMain.LogNormalDistribution")
NameGenerator=luanet.import_type("SolMain.NameGenerator")
SpaceOrbit=luanet.import_type("SolMain.SpaceOrbit")

local GEN = {}

local function NextFloat(rnd,min,max)
	return rnd:NextDouble()*(max-min)+min
end

function GEN:Generate() -- system(self)
	local seed = self.seed
	
	local rnd = Random(seed + 3452)
	if(NextFloat(rnd, 0,1)>0.90) then
		GEN.GenerateBinarySystem(self, seed) 
	else 
		GEN.GenerateUnarySystem(self, seed) 
	end
end
function GEN.GenerateUnarySystem(system, seed) 
	local seed = system.seed
	
	local rnd = Random(seed + 3218979)
	
	local star = sCelestialBody()--ents.Create("star")
	star.name = system.name  
	star.radius = 6.9551E8*NextFloat(rnd, 0.8, 2.3)
	star.mass = 1.9891E30*NextFloat(rnd, 0.8, 2.3)
	star.color = system.color
	star.sizepower = star.radius * 20000
	if(NextFloat(rnd, 0, 1)>0.999) then
		star:SetValue("typename","blackhole")
	else
		star:SetValue("typename","star")
	end
	star:SetParent(system)
	star:Spawn() 
	
	
	GEN.GeneratePlanets(star,6.9551E8*60,seed)
	
end
function GEN.GenerateBinarySystem(system, seed) 

	local seed = system.seed
	
	local center = sCelestialBody()--ents.Create("star")
	center.name = (system.name or "") .. "_"
	center.radius = 0
	center.mass = 0
	center.sizepower = 6.9551E8 * 20000
	center:SetParent(system)
	center:Spawn() 
	
	local rnd = Random(seed + 3218979)
	
	local starmass = 1.9891E30*NextFloat(rnd, 0.8, 2.3)
	local orbit_a = 1E11*NextFloat(rnd, 0.8, 2.3)
	local orbit_e = NextFloat(rnd, 0, 0.3)
	
	local starA = sCelestialBody()--ents.Create("star")
	starA.name = (system.name or "") .. " A"
	starA.radius = 6.9551E8
	starA.mass = starmass
	starA.color = system.color
	starA.sizepower = starA.radius * 100
	starA:SetValue("typename","star")
	starA:SetParent(center)
	starA:Spawn() 
	
	local starB = sCelestialBody()--ents.Create("star")
	starB.name = system.name .. " B"
	starB.radius = 6.9551E8
	starB.mass = starmass
	starB.color = system.color
	starB.sizepower = starB.radius * 100
	starB:SetValue("typename","star")
	starB:SetParent(center)
	starB:Spawn()  
	
	starA.orbit = SpaceOrbit()
	starA.orbit.a = orbit_a 
	starA.orbit.e = orbit_e
	starA.orbit.inclination = 0
	starA.orbit.periargument = 0
	starA.orbit.ascendinglongitude = 0
		starA:SetUpdating()
	
	starB.orbit = SpaceOrbit()
	starB.orbit.a = orbit_a
	starB.orbit.e = orbit_e
	starB.orbit.inclination = 0
	starB.orbit.periargument = 0
	starB.orbit.ascendinglongitude = 3.1415926
		starB:SetUpdating()
	
	GEN.GeneratePlanets(center, orbit_a* 3, seed+23979)
	
	GEN.GeneratePlanets(starA, 6.9551E8* 10, seed+32789)
	GEN.GeneratePlanets(starB, 6.9551E8* 10, seed-2390719)
end
function GEN.GeneratePlanets(star, spacing, seed)

	local rnd = Random(seed + 435566)
	local planetrnd = Random(seed + 346234208)
	local planetcount = rnd:Next(0, 10)
	for i=0,planetcount do
		local body = sCelestialBody()
		body.seed = planetrnd:Next()
		body.name = (star.name or "") .. " " .. NameGenerator.GetChar(i)
		body.mass = 0.33E24 * NextFloat(rnd, 0.1, 20)
		body.radius = 1000000 * NextFloat(rnd, 0.1, 20) 
		
		body.orbit = SpaceOrbit()
		--body.orbit.a = spacing + 5 * 1E9 * math.pow(2, i + NextFloat(rnd,-0.1, 0.1))
		body.orbit.a = spacing + spacing * math.pow(2, i + NextFloat(rnd,-0.1, 0.1))
		body.orbit.e = NextFloat(rnd, 0, 0.2)
		body.orbit.inclination = NextFloat(rnd, 0, 0.2)
		body.orbit.periargument = NextFloat(rnd, 0, 0.2)
		body.orbit.ascendinglongitude = NextFloat(rnd, 0, 30)
		
		body:SetValue("typename","planet")
		body:SetParent(star)
		body.sizepower = body.hillSphereRadius  
		body:Spawn()
		body:SetUpdating()
		
		GEN.GenerateMoons(body,body.seed)
	end
end
function GEN.GenerateMoons(planet, seed) 
	local rnd = Random(seed)
	if (rnd:NextDouble() > 0.8) then
	
		local mooncount = rnd:Next(1,5) --LogNormalDistribution.Sample(2, 1, rnd) / 10
		for i = 0, mooncount do 
			local moonseed = rnd:Next()
			local moonrnd = Random(moonseed)
			
			local moon = sCelestialBody()
			moon.seed = moonseed
			moon.name = NameGenerator.GeneratePlanetName(moon.seed)
			moon.mass = 0.33E20 * NextFloat(moonrnd, 0.1, 20)
			moon.radius = 10000 * NextFloat(moonrnd, 0.1, 20)
			moon.orbit = SpaceOrbit()
			moon.orbit.a =planet.radius + 46 * 1E5 * math.pow(2, i + NextFloat(moonrnd,-0.7, 0.7))
			moon.orbit.e = NextFloat(moonrnd, 0, 0.2)
			moon.orbit.inclination = NextFloat(moonrnd, 0, 0.2)
			moon.orbit.periargument = NextFloat(moonrnd, 0, 0.2)
			moon.orbit.ascendinglongitude = NextFloat(moonrnd, 0, 30)
			moon:SetParent(planet)
			moon.sizepower = moon.hillSphereRadius
			moon:SetValue("typename","moon")
			moon:Spawn()
			moon:SetUpdating()
		end
	end
end

return GEN
 