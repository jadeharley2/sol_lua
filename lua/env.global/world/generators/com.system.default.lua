 
 

generator.target = "starSystem"

generator[EVENT_GENERATOR_SETUP] = function(self, node) -- system(self)
	local seed = node:GetSeed()
	
	local rnd = Random(seed + 3452)
	--MsgN("seed",seed)
	if seed~=1062413718 then
		self:GenerateSystemEntry(node,seed) 
	else
		---[[
		if(rnd:NextFloat(0,1)>0.9) then --0.9
			self:GenerateBinarySystem(node,seed) 
			--self:GenerateHierarchicalSystem(node,node,seed) 
			--MsgInfo("binary!")  
		else 
			self:GenerateUnarySystem(node,seed) 
			--MsgInfo("unary!")
		end 
		--]]
	end
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
		star:SetParameter(VARTYPE_TYPE,NTYPE_BLACKHOLE)
	else
		star:SetParameter(VARTYPE_TYPE,NTYPE_STAR)
	end
	star:SetParent(system)
	star:Spawn() 
	
	stars[1] = star
	
	self:GeneratePlanets(star,seed,6.9551E8*60,6.9551E8*60)
	system.stars = stars
end

 
function generator:GeneratePlanets(star,  seed, spacing, mindist, maxdist)

	mindist = mindist or spacing
	maxdist = maxdist or 9E12

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
		local dist = mindist + spacing * math.pow(2, i + rnd:NextFloat(-0.1, 0.1))
		body.orbit:SetOrbit(
			dist,
			rnd:NextFloat( 0, 0.2),
			rnd:NextFloat( 0, 0.2),
			rnd:NextFloat( 0, 0.2),
			rnd:NextFloat( 0, 30),
			0,
			0.1/(i*i+1)
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
		--MsgN("?????!")
		if ssd ==2008649333 then
		elseif ssd ==100310535 then 
			--2008649333
			body:SetParameter(VARTYPE_ARCHETYPE,"sd_hellworld") 
		elseif ssd ==311834050 then 
			body:SetParameter(VARTYPE_ARCHETYPE,"earth") 
		elseif ssd ==2091568607 then 
			body:SetParameter(VARTYPE_ARCHETYPE,"hs_lowas") 
		elseif  Random(ssd):NextDouble() > 0.1 then 
			--MsgN("asdfjas!")
			body:SetParameter(VARTYPE_ARCHETYPE,"gen_barren")
		end
		
		
		body:Spawn()
		
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
				1/(i*i+1)
			)
		 
			
			
			moon:SetParent(planet) 
			moon:SetSizepower(moon.radius*3)
			moon:SetParameter(NTYPE_TYPENAME,"moon")
			moon:Spawn()
			moon:SetUpdating(true,1000)
			moons[i+1] = moon 
		end
	end
	planet.moons = moons
end

function generator:GenerateBinarySystem(system, seed) 
 
	--local rnd = Random(seed)
	
	--local center = sCelestialBody()--ents.Create("star")
	--center.name = (system.name or "") .. "_"
	--center.radius = 0
	--center.mass = 0
	--center.sizepower = 6.9551E8 * 20000
	--center:SetParent(system)
	--center:Spawn() 
	
	local center = ents.Create("star") 
	center.szdiff = 20000
	center:SetSeed(seed + 3218888)
	center:SetName(  system:GetName().."_")
	local r = 0
	local c = system:GetParameter(VARTYPE_COLOR)
	center:SetParameter(VARTYPE_RADIUS,r)
	center:SetParameter(VARTYPE_COLOR,c)
	center.radius = r
	center.mass = 0  
	center:SetSizepower(6.9551E8 * 100000) 
	center:SetParent(system)
	center:RemoveTag(TAG_STAR)
	center:Spawn() 
	
	
	local rnd = Random(seed + 3218979)
	
	local starmass = 1.9891E30*rnd:NextFloat( 0.8, 2.3)
	local orbit_a = 1E11*rnd:NextFloat( 0.8, 2.3)
	local orbit_e = rnd:NextFloat(0, 0.3)
	
	--local starA = sCelestialBody()--ents.Create("star")
	--starA.name = (system.name or "") .. " A"
	--starA.radius = 6.9551E8
	--starA.mass = starmass
	--starA.color = system.color
	--starA.sizepower = starA.radius * 100
	--starA:SetValue("typename","star")
	--starA:SetParent(center)
	--starA:Spawn() 
	
	local starA = ents.Create("star") 
	starA.szdiff = 20000
	starA:SetSeed(seed + 3218255)
	starA:SetName(  system:GetName() .. " A" )
	local r = 6.9551E8
	local c = system:GetParameter(VARTYPE_COLOR)
	starA:SetParameter(VARTYPE_RADIUS,r)
	starA:SetParameter(VARTYPE_COLOR,c)
	starA.radius = r
	starA.mass = 0  
	starA:SetSizepower(r * 100) 
	starA:SetParent(center)
	starA:Spawn() 
	
	
	--local starB = sCelestialBody()--ents.Create("star")
	--starB.name = system.name .. " B"
	--starB.radius = 6.9551E8
	--starB.mass = starmass
	--starB.color = system.color
	--starB.sizepower = starB.radius * 100
	--starB:SetValue("typename","star")
	--starB:SetParent(center)
	--starB:Spawn()  
	
	local starB = ents.Create("star") 
	starB.szdiff = 20000
	starB:SetSeed(seed + 3218324)
	starB:SetName(  system:GetName() .. " B" )
	local r = 6.9551E8
	local c = system:GetParameter(VARTYPE_COLOR)
	starB:SetParameter(VARTYPE_RADIUS,r)
	starB:SetParameter(VARTYPE_COLOR,c)
	starB.radius = r
	starB.mass = 0  
	starB:SetSizepower(r * 100) 
	starB:SetParent(center)
	starB:Spawn() 
	
	
	local orbit = starA:AddComponent(CTYPE_ORBIT)  
	starA.orbit = orbit 
	starA.orbit:SetOrbit(
		orbit_a,
		orbit_e,
		0,
		0,
		3.1415926,
		0,
		1
	)
	--starA.orbit = SpaceOrbit()
	--starA.orbit.a = orbit_a 
	--starA.orbit.e = orbit_e
	--starA.orbit.inclination = 0
	--starA.orbit.periargument = 0
	--starA.orbit.ascendinglongitude = 0
	starA:SetUpdating(true,10)
	
	local orbit = starB:AddComponent(CTYPE_ORBIT)  
	starB.orbit = orbit
	starB.orbit:SetOrbit(
		orbit_a,
		orbit_e,
		0,
		0,
		0,
		0,
		1
	)
	--starB.orbit = SpaceOrbit()
	--starB.orbit.a = orbit_a
	--starB.orbit.e = orbit_e
	--starB.orbit.inclination = 0
	--starB.orbit.periargument = 0
	--starB.orbit.ascendinglongitude = 3.1415926
	starB:SetUpdating(true,10)
	--
	--GEN.GeneratePlanets(center, orbit_a* 3, seed+23979)
	--
	--GEN.GeneratePlanets(starA, 6.9551E8* 10, seed+32789)
	--GEN.GeneratePlanets(starB, 6.9551E8* 10, seed-2390719)
	
	self:GeneratePlanets(center,seed,6.9551E8*500,6.9551E8*100,6.9551E8 * 20000)
end
--[[
return GEN
]]
 
local au = 149597870700 --m
local sol_mass = 1.9891E30 --kg
local sol_r = 695700000 -- m
local sol_lum = 2.23e22  -- m
local earth_r = 6371000 --m
local earth_m = 5.97237*10e24 --kg 
local jupiter_r = 69911000 --m
local jupiter_m = 1.8982*10e27 --kg

local spd =1-- 1e8--10000/(orbit_a/au)
--[[
	56±2 % single, 
	33±2% binary, 
	8±1% triple, 
	3±1% +.

]]
function generator:GenerateSystemEntry(system, seed, mass) 
	local rnd = Random(seed)

	mass = mass or sol_mass * rnd:NextFloat( 0.1, 10) --total system mass
	radius = radius or 100 * au -- max subnode distance

	local stars = {}
	local planets = {}
	system.stars = stars
	system.planets = planets

	self:GenerateHierarchicalSystem(system, system, seed, mass, radius) 
  
end
function generator:GenerateHierarchicalSystem(system, parent, seed, mass, radius) 
  
	local rnd = Random(seed)

	mass = mass or sol_mass * rnd:NextFloat( 0.1, 10) --total system mass
	radius = radius or 100 * au -- max subnode distance
	
	local anchor_mass = mass * rnd:NextFloat( 0.6, 0.9)

	if mass > 0.1*sol_mass and rnd:NextFloat(0,1)>0.66 then --binary object probability
		
		local center = ents.Create("mass_center")  
		center:SetSeed(seed + 3218888)  
		center:SetSizepower(radius) 
		center:SetParent(parent) 
		center:SetParameter(VARTYPE_MASS,anchor_mass)
		center:Spawn() 


	
		local starmass = anchor_mass * 0.45
		local orbit_a = radius*rnd:NextFloat( 0.1, 0.4)
		local orbit_e = rnd:NextFloat(0, 0.3) 
 

		local starA = self:GenerateHierarchicalSystem(system, center, seed + 3218255, starmass, radius/10) 
		local starB = self:GenerateHierarchicalSystem(system, center, seed + 3218324, starmass, radius/10) 
 
		
		local orbit = starA:AddComponent(CTYPE_ORBIT)  
		starA.orbit = orbit 
		starA.orbit:SetOrbit(
			orbit_a,orbit_e,
			0,
			0,
			3.1415926,
			0,
			spd
		)  
		orbit:SetParameter("ms",spd*orbit:GetOrbitalSpeed(anchor_mass,starmass))
		starA:SetSizepower(orbit:GetHillSphereRadius(anchor_mass,starmass))

		local orbit = starB:AddComponent(CTYPE_ORBIT)  
		starB.orbit = orbit
		starB.orbit:SetOrbit(
			orbit_a,orbit_e,
			0,
			0,
			0,
			0,
			spd
		)  
		orbit:SetParameter("ms",spd*orbit:GetOrbitalSpeed(anchor_mass,starmass))
		starB:SetSizepower(orbit:GetHillSphereRadius(anchor_mass,starmass))

		starA:SetAng(Vector(rnd:NextFloat(-90, 90),rnd:NextFloat(-180, 180),rnd:NextFloat(-90, 90)))
		starB:SetAng(Vector(rnd:NextFloat(-90, 90),rnd:NextFloat(-180, 180),rnd:NextFloat(-90, 90)))
		starA:SetUpdating(true,10)
		starB:SetUpdating(true,10) 
		-- if orbit is less than star.radius*number -> can spawn subs inside [minr...maxr] bounds
		--if orbit_a < r
		local sza = starA:GetSizepower()
		for k,v in pairs(starA:GetChildren()) do
			if v.orbit and v.orbit:GetParameter('a')>sza then
				v:Despawn()
			end
		end
		local szb = starB:GetSizepower()
		for k,v in pairs(starB:GetChildren()) do
			if v.orbit and v.orbit:GetParameter('a')>szb then
				v:Despawn()
			end
		end

		local minimum_r = orbit_a*2
		local maximum_r = radius/3

		self:GenerateLinearSystem(system,center,seed + 345235, anchor_mass * 0.1,radius,minimum_r,maximum_r)
		 

		return center
	else

		local starmass = anchor_mass

		local starA = ents.Create("star") 
		starA.szdiff = 20000
		starA:SetSeed(seed + 3218255)
		starA:SetName(  system:GetName() .. " A" )
		local r = 6.9551E8*(starmass/sol_mass)
		local c = system:GetParameter(VARTYPE_COLOR)
		starA:SetParameter(VARTYPE_RADIUS,r)
		starA:SetParameter(VARTYPE_COLOR,c)
		starA:SetParameter(VARTYPE_MASS,starmass)
		starA:SetParameter(VARTYPE_BRIGHTNESS,sol_lum*(starmass/sol_mass)/100) 
		starA.radius = r 
		starA:SetSizepower(radius) 
		starA:SetParent(parent)
		starA:Spawn() 
		
		local minimum_r = r*2.5
		local maximum_r = radius*2
		self:GenerateLinearSystem(system,starA,seed + 355335,anchor_mass,radius,minimum_r,maximum_r)

		local id = #system.stars+1 
		system.stars[id] = starA

		starA:SetName(system:GetName().." star "..id)

		return starA
	end
	
	 
	--self:GeneratePlanets(center,seed,6.9551E8*500,6.9551E8*100,6.9551E8 * 20000)
end
 

function generator:GenerateLinearSystem(system, parent, seed, mass, radius,minr,maxr) 

	local rnd = Random(seed)

	local starmass = parent:GetParameter(VARTYPE_MASS) 

	--local a_min_a = (parent:GetParameter(VARTYPE_RADIUS) or 6.9551E8)*2--starA.orbit:GetRocheLimitRigid(anchor_mass,starmass)
	--local a_max_a = parent:GetSizepower()--parent.orbit:GetHillSphereRadius(mass,starmass)
	minr = minr + minr*rnd:NextFloat(0,10)
	local sbradius = radius/10
	if maxr>minr then
		local ncount =rnd:NextFloat(0, 10) --math.min( rnd:NextFloat(0, 6),(maxr-minr)/(sbradius/10))
		local ptd = minr--(maxr-minr)/ncount*2 
		local medmass = mass/ncount
		for k=1,ncount do
			



			local m = earth_m*rnd:NextFloat(0.1, 5) 
			local r = earth_r*(m/earth_m)
			



			local body = ents.Create("planet")
			local planetseed = seed+23*k--planetrnd:NextInt()
			body:SetSeed(planetseed)
			--body:SetName(  (star:GetName() or "") .. " " .. "planet "..tostring(i+1))--NameGenerator.GetChar(i))
			body.mass = m
			body.radius = r 
			body:SetParameter( VARTYPE_RADIUS,r)
			body:SetParameter( VARTYPE_MASS,m)
			

			local sub = body



			local orbit_a = minr + ptd*(k-1)*(k-1)
			local orbit_e = rnd:NextFloat(0, 0.3) 
			local orbit_i = rnd:NextFloat(0, 0.1) 
			local orbit_al = rnd:NextFloat(0, 10) 
			local orbit = sub:GetComponent(CTYPE_ORBIT) or sub:AddComponent(CTYPE_ORBIT)  
			sub.orbit = orbit
			sub.orbit:SetOrbit(
				orbit_a,orbit_e,
				orbit_i,
				0,
				orbit_al,
				0,
				spd
			)  
			orbit:SetParameter("ms",spd*orbit:GetOrbitalSpeed(starmass,m))
			sub:SetUpdating(true,10)
			local psz = orbit:GetHillSphereRadius(starmass,m)
			sub:SetSizepower(psz)

			body.szdiff = psz/r


			body.orbitIsSet = true 
			
			body:SetParameter(NTYPE_TYPENAME,"planet")
			body:SetParent(parent)
			--body:SetSizepower(body.radius*100)
			
			local ssd = planetseed--body:GetSeed()
			--MsgN("?????!")
			if ssd ==2008649333 then
			elseif ssd ==100310535 then 
				--2008649333
				body:SetParameter(VARTYPE_ARCHETYPE,"sd_hellworld") 
			elseif ssd ==311834050 then 
				body:SetParameter(VARTYPE_ARCHETYPE,"earth") 
			elseif ssd ==2091568607 then 
				body:SetParameter(VARTYPE_ARCHETYPE,"hs_lowas") 
			elseif  Random(ssd):NextDouble() > 0.1 then 
				--MsgN("asdfjas!")
				body:SetParameter(VARTYPE_ARCHETYPE,"gen_barren")
			end
			
			
			body:Spawn()
			

			local id = #system.planets+1 
			system.planets[id] = body

			body:SetName(system:GetName().." planet "..id)




		end
	end
end
