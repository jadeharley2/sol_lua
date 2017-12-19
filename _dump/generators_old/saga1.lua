 
luanet.load_assembly("System")
luanet.load_assembly("SolMain")
Random=luanet.import_type("System.Random") 
sCelestialBody=luanet.import_type("SolMain.sCelestialBody")
LogNormalDistribution=luanet.import_type("SolMain.LogNormalDistribution")
NameGenerator=luanet.import_type("SolMain.NameGenerator")
SpaceOrbit=luanet.import_type("SolMain.SpaceOrbit") 

local GEN = {}
local G = 6.674E-11
local c = 299792458
local function SchRadius(mass)
	return (2 * mass * G)/(c*c)
end

local function NextFloat(rnd,min,max)
	return rnd:NextDouble()*(max-min)+min
end

function GEN:Generate()
	local system = self
	local seed = system.seed
	
	--local rnd = Random(seed + 3218979)
	
	local star = sCelestialBody()--ents.Create("star")
	star.name = "Sagittarius A*"
	star.mass = 4.1E6 * 1.98855E30
	star.radius = SchRadius(star.mass)
	star.color = system.color
	star.sizepower = star.radius * 20000
	star:SetValue("typename","blackhole")
	star:SetParent(system)
	star:Spawn() 
	  
	--local sol = sCelestialBody()--ents.Create("star")
	--sol.name = "Sol"
	--sol.mass = 1.98855E30
	--sol.radius = 6.9551E8
	--sol.color =  system.color
	--sol.sizepower = star.radius * 20000
	--sol:SetValue("typename","star")
	--sol:SetParent(star)
	--sol:Spawn() 
	--
	--sol.orbit = SpaceOrbit()
	--sol.orbit.a = star.radius * 20.3 
	--sol.orbit.e = 0
	--sol.orbit.inclination = 0
	--sol.orbit.periargument = 0
	--sol.orbit.ascendinglongitude = 0
	--sol:SetUpdating()
end 

return GEN
 