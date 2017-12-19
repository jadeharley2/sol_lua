 
 

generator.target = "starSystem"

generator[EVENT_GENERATOR_SETUP] = function(self, node) -- system(self)
	local seed = node:GetSeed()
	
	--local rnd = Random(seed + 3452)
	--if(NextFloat(rnd, 0,1)>0.90) then
		--self:GenerateBinarySystem(node,seed) 
	--else 
		self:GenerateUnarySystem(node,seed) 
	--end
end
function generator:GenerateUnarySystem(system, seed) 
	--local seed = system.seed
	local stars = {}
	local rnd = Random(seed + 3218979)
	
	local star = ents.Create("star") 
	star.szdiff = 20000
	star:SetSeed(seed + 3218979)
	star:SetName(  system:GetName())
	local r = 6.9551E8*rnd:NextFloat( 0.8, 2.3)
	local c = system:GetParameter(VARTYPE_COLOR)
	star:SetParameter(VARTYPE_RADIUS,r)
	star:SetParameter(VARTYPE_COLOR,c)
	star.radius = r
	star.color = c 
	--star:SetMass( 1.9891E30*NextFloat(rnd, 0.8, 2.3))--system.color
	--star:SetParameter("color",system.color)
	star:SetSizepower(r * 20000)
	if(rnd:NextFloat( 0, 1)>0.999) then
		star:SetParameter("typename","blackhole")
	else
		star:SetParameter("typename","star")
	end
	star:SetParent(system)
	star:Spawn() 
	
	stars[1] = star
	
	self:GeneratePlanets(star,6.9551E8*60,seed)
	system.stars = stars
end

 
function generator:GeneratePlanets(star, spacing, seed)

	local planets = {}
	local rnd = Random(seed + 435566)
	local planetrnd = Random(seed + 346234208)
	local planetcount = rnd:NextInt(0, 10)
	for i=0,planetcount do
		local body = ents.Create("planet")
		body.szdiff = 100
		local planetseed = planetrnd:NextInt()
		body:SetSeed(planetseed)
		body:SetName(  (star:GetName() or "") .. " " .. "planet "..tostring(i+1))--NameGenerator.GetChar(i))
		body.mass = 0.33E24 * rnd:NextFloat( 0.1, 20)
		body.radius = 1000000 * rnd:NextFloat( 0.1, 20)  
		body:SetParameter( VARTYPE_RADIUS,body.radius)
		
		--body.orbit.a = spacing + 5 * 1E9 * math.pow(2, i + NextFloat(rnd,-0.1, 0.1))
		
		--a_diameter, 
		--eccentricity, 
		--inclination, 
		--periargument, 
		--ascendinglongitude, 
		--meanAnomaly, 
		--orbtialspeed
		body.orbit:SetOrbit(
			spacing + spacing * math.pow(2, i + rnd:NextFloat(-0.1, 0.1)),
			rnd:NextFloat( 0, 0.2),
			rnd:NextFloat( 0, 0.2),
			rnd:NextFloat( 0, 0.2),
			rnd:NextFloat( 0, 30),
			0,
			0.1
		)
		body.orbitIsSet = true
		 
		--body.orbit.a = spacing + spacing * math.pow(2, i + rnd:NextFloat(-0.1, 0.1))
		--body.orbit.e = rnd:NextFloat( 0, 0.2)
		--body.orbit.inclination = rnd:NextFloat( 0, 0.2)
		--body.orbit.periargument = rnd:NextFloat( 0, 0.2)
		--body.orbit.ascendinglongitude = rnd:NextFloat( 0, 30)
		
		body:SetParameter(NTYPE_TYPENAME,"planet")
		body:SetParent(star)
		body:SetSizepower(body.radius*100)
		
		local ssd = planetseed--body:GetSeed()
		MsgN("?????!")
		if ssd ==2008649333 then
		elseif ssd ==100310535 then 
			--2008649333
			body:SetParameter(VARTYPE_ARCHETYPE,"sd_hellworld") 
		elseif ssd ==311834050 then 
			body:SetParameter(VARTYPE_ARCHETYPE,"earth") 
		elseif ssd ==2091568607 then 
			body:SetParameter(VARTYPE_ARCHETYPE,"hs_lowas") 
		elseif  Random(ssd):NextDouble() > 0.1 then 
			MsgN("asdfjas!")
			body:SetParameter(VARTYPE_ARCHETYPE,"gen_barren")
		end
		
		
		body:Spawn()
		body:SetUpdating(true)
		
		planets[i+1] = body 
		self:GenerateMoons(body,planetseed)
	end
	star.planets = planets
end
function generator:GenerateMoons(planet, seed) 
	local rnd = Random(seed)
	moons = {}
	if (rnd:NextDouble() > 0.8) then 
		local mooncount = rnd:NextInt(1,5) --LogNormalDistribution.Sample(2, 1, rnd) / 10
		for i = 0, mooncount do 
			local moonseed = rnd:NextInt()
			local moonrnd = Random(moonseed)
			
			local moon = ents.Create("planet")-- sCelestialBody() 
			moon.szdiff = 3
			moon:SetSeed(moonseed)
			moon.ismoon = true
			moon:SetName(  (planet:GetName() or "") .. " " .. "moon "..tostring(i+1))
			--moon.name = NameGenerator.GeneratePlanetName(moon.seed)
			
			local maxrad = planet.radius
			moon.mass = 0.33E20 * moonrnd:NextFloat( 0.1, 20)
			moon.radius = maxrad * moonrnd:NextFloat( 0.1, 0.7)*0.7
			moon:SetParameter( VARTYPE_RADIUS,moon.radius)
			--moon.orbit = SpaceOrbit()
			--moon.orbit.a = planet.radius + 46 * 1E5 * math.pow(2, i + moonrnd:NextFloat( -0.7, 0.7))
			--moon.orbit.e = moonrnd:NextFloat(  0, 0.2)
			--moon.orbit.inclination = moonrnd:NextFloat(  0, 0.2)
			--moon.orbit.periargument = moonrnd:NextFloat(  0, 0.2)
			--moon.orbit.ascendinglongitude = moonrnd:NextFloat(  0, 30)
			
			moon.orbit:SetOrbit(
				planet.radius*4 + 2*46 * 1E5 * math.pow(2, i + moonrnd:NextFloat( -0.7, 0.7)),
				moonrnd:NextFloat(  0, 0.2),
				moonrnd:NextFloat(  0, 0.2),
				moonrnd:NextFloat(  0, 0.2),
				moonrnd:NextFloat(  0, 30),
				0,
				0.1
			)
		 
			
			
			moon:SetParent(planet) 
			moon:SetSizepower(moon.radius*3)
			moon:SetParameter(NTYPE_TYPENAME,"moon")
			moon:Spawn()
			moon:SetUpdating(true)
			moons[i+1] = moon 
		end
	end
	planet.moons = moons
end

--[[
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

return GEN
]]
 