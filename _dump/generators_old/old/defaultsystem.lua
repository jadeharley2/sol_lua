
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
	 
	seed = self.seed
	local star = sCelestialBody()--ents.Create("star")
	star.name = self.name  
	star.radius = 6.9551E8
	star.mass = 1.9891E30
	star.color = self.color
	star.sizepower = star.radius * 20000
	star:SetParent(self)
	star:Spawn() 
	
	local rnd = Random(seed + 3218979)
	local planetrnd = Random(seed + 346234208)
	local planetcount = rnd:Next(0, 10)
	for i=0,planetcount do
		local body = sCelestialBody()
		body.seed = planetrnd:Next()
		body.name = star.name .. " " .. NameGenerator.GetChar(i)
		body.mass = 0.33E24 * NextFloat(rnd, 0.1, 20)
		body.radius = 1000000 * NextFloat(rnd, 0.1, 20) 
		
		body.orbit = SpaceOrbit()
		body.orbit.a = 46 * 1E9 * math.pow(2, i + NextFloat(rnd,-0.1, 0.1))
		body.orbit.e = NextFloat(rnd, 0, 0.2)
		body.orbit.inclination = NextFloat(rnd, 0, 0.2)
		body.orbit.periargument = NextFloat(rnd, 0, 0.2)
		body.orbit.ascendinglongitude = NextFloat(rnd, 0, 30)
		
		body:SetParent(star)
		body.sizepower = body.hillSphereRadius  
		body:Spawn()
		body:SetUpdating()
		
		GEN.GenerateMoons(body,body.seed)
	end
	
	--dofile("data/lua/autorun/testenttype.lua") 
	--local testent = ents.Create("testent")
	--
	--testent:SetParent(star)
	--testent:Spawn()
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
			moon:Spawn()
			moon:SetUpdating()
		end
	end
end

return GEN
 