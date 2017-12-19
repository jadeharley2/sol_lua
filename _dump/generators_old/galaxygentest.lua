
luanet.load_assembly("System")
luanet.load_assembly("SolMain")
Random=luanet.import_type("System.Random") 
sCelestialBody=luanet.import_type("SolMain.sCelestialBody")
sStarSystem=luanet.import_type("SolMain.sStarSystem")
LogNormalDistribution=luanet.import_type("SolMain.LogNormalDistribution")
NameGenerator=luanet.import_type("SolMain.NameGenerator")
SpaceOrbit=luanet.import_type("SolMain.SpaceOrbit") 
VectorF=luanet.import_type("SharpDX.Vector3") 
StarsystemMap=luanet.import_type("SolMain.root.runtime.StarsystemMap") 
ObjectSystem=luanet.import_type("SolMain.ObjectSystem") 

include("masseffect/world.lua")

local function NextFloat(rnd,min,max)
	return rnd:NextDouble()*(max-min)+min
end

local function NextVector(rnd,min,max)
	return Vec(rnd:NextDouble()*(max-min)+min,rnd:NextDouble()*(max-min)+min,rnd:NextDouble()*(max-min)+min)
end

local GEN = {}
local pi2 = math.pi * 2
local piby180 = math.pi / 180
 


 
local function GenMassEffect(galaxy)
	local clusters = MassEffectData.world.clusters
	local links = MassEffectData.world.jumplinks
	 
	local seed = galaxy.seed 
	local rnd = Random(seed + 3218979)
	
	local ddivider = 100000
	
	local stars = {}
	for k,v in pairs(clusters) do
		local clusterpos = VCyl(v.d/200 ,(v.s-90)* piby180,NextFloat(rnd,-0.02,0.02))--NextVector(rnd,-0.8,0.8)*Vec(1,0.03,1)--0.01*i+0.01;
		 
		if v.systems then
			for k2,v2 in pairs(v.systems) do 
				local id2 = rnd:Next()
				local ss = 0
				if v2.global then
					ss = ObjectSystem.GET2(v2.global)
				else
					ss = sStarSystem()
					ss.color = Vec(1,1,1)
					ss.seed = id2;
					ss.sizepower = 9.46073E16 / 5 * 0.1
					ss:SetValue(VARTYPE_GENERATOR,"masseffectsystem")
					ss:SetValue("sysid",v2.id) 
					ss:SetParent(galaxy)
				end
				if v2.name then ss.name = v2.name end
				ss.position = clusterpos + Vec(v2.dx/ddivider,0/ddivider,v2.dy/ddivider)
				ss:Spawn()
				if(v2.main) then
					stars[v.id] = ss
				end
			end
		else
			local id = rnd:Next()
			local g = sStarSystem()
			g.name = v.name
			g.color = Vec(1,1,1)
			g.seed = id;
			g.position = clusterpos
			g.sizepower = 9.46073E16 / 5
			g:SetParent(galaxy)
			g:Spawn()
			stars[v.id] = g
		end
	end
	for k,v in pairs(links) do
		local s1 = stars[v[1]]
		local s2 = stars[v[2]]
		StarsystemMap.AddJump(s1.position,s2.position)
	end
	--local sol = ObjectSystem.GET2("star.sol")
	--sol.position = stars[1].position+Vec(0,-0.0001,0)
	
	PrintTable(stars)
end

function GEN:PostGenerate()

	GenMassEffect(self)
	--local galaxy = self
	--local seed = galaxy.seed 
	--local rnd = Random(seed + 3218979)
	
	
	--for i=1,100 do
	--	local id = rnd:Next()
	--	local g = sStarSystem()
	--	g.name = "umad? "..i
	--	g.color = Vec(1,1,1)
	--	g.seed = id;
	--	g.position = VCyl(NextFloat(rnd,0.1,0.6),NextFloat(rnd,0,pi2),NextFloat(rnd,-0.02,0.02))--NextVector(rnd,-0.8,0.8)*Vec(1,0.03,1)--0.01*i+0.01;
	--	g.sizepower = 9.46073E16 / 5
	--	g:SetParent(galaxy)
	--	g:Spawn()
	--	stars[i] = g
	--end
	--stars[#stars] = ObjectSystem.GET2("star.sol")
	--for _,v1 in pairs(stars) do 
	--	local dstars = {}
	--	for _,v2 in pairs(stars) do 
	--		local dist = VDistSq(v1.position,v2.position) 
	--		dstars[dist] = v2
	--	end   
	--	local cc = 0
	--	for k,v in SortedPairs(dstars) do
	--		if cc< 4 then
	--			if not StarsystemMap.Contains(v1.position,v.position) then
	--				StarsystemMap.AddJump(v1.position,v.position)
	--			end
	--			cc = cc+1
	--		end
	--	end
	--end
end


return GEN