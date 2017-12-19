
luanet.load_assembly("System")
luanet.load_assembly("SolMain")
luanet.load_assembly("SharpDX")
Random=luanet.import_type("System.Random") 
sGalaxy=luanet.import_type("SolMain.sGalaxy") 
NameGenerator=luanet.import_type("SolMain.NameGenerator")
sStarSystem=luanet.import_type("SolMain.sStarSystem")
InstanceStar=luanet.import_type("SolMain.InstanceStar")
Color3=luanet.import_type("SharpDX.Color3")
Vector3=luanet.import_type("SharpDX.Vector3")
Vector4=luanet.import_type("SharpDX.Vector4")
Quaternion=luanet.import_type("SharpDX.Quaternion")


local GEN = {}

local twopi = math.pi * 2
local piovertwo = math.pi / 2

local function NextFloat(rnd,min,max)
	return rnd:NextDouble() * (max - min) + min
end
local function RandomVector(rnd,min,max)
	local x = rnd:NextDouble() * (max - min) + min
	local y = rnd:NextDouble() * (max - min) + min
	local z = rnd:NextDouble() * (max - min) + min
	return Vector3(x,y,z)
end
 -- get star density
 -- get cloud density
 -- get glow density
 -- create systems
 -- set system parameters
 -- return { systems[], starinstances[], glow[], cloud[]}
function GEN:Generate(chunk,sizepower)

	
	local stars = {}
	local starInstances = {}
	local glowInstances = {}
	local cloudInstances = {}
	
	local instanceSize = (9.46073E16) / 5 / sizepower
	local chunkRandom = Random(chunk.seed)  
	local globalDensity = 1 - chunk.position:Length() - (math.abs(chunk.position.Y * 10))
	local maxStarCount =  math.max(0, 25 * globalDensity)
	local starCount = 0
	if chunk.level > 3 then starCount = chunkRandom:Next(0, maxStarCount) end
	--if starCount ==0 then
	--	MsgN("o")
	--end
	local width = chunk.width;
	local starInstanceWidth = instanceSize * width * 300
	
	for i=0, starCount-1 do
		local id = chunkRandom:Next()
		local starPosition = chunk.position + RandomVector(chunkRandom,-1,1) * width
		local starClass =  NextFloat(chunkRandom,0, 3)
		local rotation =  NextFloat(chunkRandom,0,twopi)
		
		local starColor = Color3(math.sin(starClass - 0.3), math.sin(starClass), math.sin(starClass + 0.3))
		local realColor = Color3.AdjustSaturation(starColor, 0.5) * 0.3
		
		local starInstance = InstanceStar(starPosition, realColor, starInstanceWidth, Vector4(0, 0, 1.0 / 16, 1.0 / 16), rotation)
		starInstances[i] = starInstance
		 
		local star = sStarSystem()
		star.name = NameGenerator.GenerateStarName(id)--id.ToString("X4");
		star.color = realColor:ToVector3()
		star.seed = id
		star.position = starPosition
		star.sizepower = 9.46073E16 / 5
		star:SetParent(self)
		local test100 = Quaternion.RotationAxis(Vector3.UnitX, NextFloat(chunkRandom, 0, piovertwo))
		star.rotation = test100--star.rotation 
			--* 
			--Quaternion.Identity
			--* 
			--Quaternion.RotationAxis(Vector3.UnitX, NextFloat(chunkRandom, 0, piovertwo))
			--* Quaternion.RotationAxis(Vector3.UnitY, NextFloat(chunkRandom, 0, piovertwo))
			--* Quaternion.RotationAxis(Vector3.UnitZ, NextFloat(chunkRandom, 0, piovertwo))
		star:Spawn()
		stars[i] = star
	end
	 
	--MsgN("all ok")
	return stars, starInstances, glowInstances, cloudInstances
end

return GEN