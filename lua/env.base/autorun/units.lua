
CONST_Parsec = 30856776000000000
CONST_LightYear = 9460730472580800
CONST_AstronomicalUnit = 149597870700 
CONST_SunRadius = 695700000
CONST_JupiterRadius = 71492000
CONST_EarthRadius = 6371000
CONST_KiloMetre = 1000

CONST_SunMass = 1.98855E30
CONST_JupiterMass = 1.898E27 
CONST_EarthMass = 5.9722E24
 
CONST_Minute = 60
CONST_Hour = 3600
CONST_EarthDay = 24*CONST_Hour
CONST_EarthMonth = 30*CONST_EarthDay
CONST_EarthYear = 31557600
local prefixesCI = { "", "kilo", "Mega", "Giga", "Tera", "Peta", "Exa", "Zetta", "Yotta" }
local prefixesCIs = { "", "k", "M", "G", "T", "P", "E", "Z", "Y" }
local unitCI = { "metres", "parsecs", "light-years", "astronomical unit" }
local unitCIs = { "m", "pc", "ly", "au" }

function ToStandardUnits(cvalue)
	if istable(cvalue) then
		local v = cvalue[1]
		local vt = cvalue[2]
		
		-- distances to metres
		if(vt=="pc") then return v*CONST_Parsec end
		if(vt=="ly") then return v*CONST_LightYear end 
		if(vt=="au") then return v*CONST_AstronomicalUnit end
		if(vt=="sr") then return v*CONST_SunRadius end
		if(vt=="jr") then return v*CONST_JupiterRadius end
		if(vt=="er") then return v*CONST_EarthRadius end
		if(vt=="km") then return v*CONST_KiloMetre end
		
		-- masses to kilogramms
		if(vt=="sm") then return v*CONST_SunMass end
		if(vt=="jm") then return v*CONST_JupiterMass end
		if(vt=="em") then return v*CONST_EarthMass end
		
		
		-- time to seconds
		if(vt=="eyr") then return v*CONST_EarthYear end
		if(vt=="emn") then return v*CONST_EarthMonth end
		if(vt=="ed") then return v*CONST_EarthDay end
		if(vt=="h") then return v*CONST_Hour end
		if(vt=="m") then return v*CONST_Minute end
		
		-- luminosity
		
		-- temp
		if(vt=="gc") then return v end
		
		return 0
	else
		return cvalue
	end
end
function DistanceNormalize(distance, shortprefix, useParsecs)
	shortprefix = shortprefix or true
	useParsecs = useParsecs or false
	
	local unitid = 0;
	local prefixpow = 0;
	local lypc = false;
	if (useParsecs and distance > CONST_Parsec) then distance = distance / CONST_Parsec unitid = 1 lypc = true end
	if (not useParsecs and distance > CONST_LightYear) then distance = distance / CONST_LightYear unitid = 2 lypc = true end
	if (not lypc and distance > CONST_AstronomicalUnit) then distance = distance / CONST_AstronomicalUnit unitid = 3 lypc = true end 

	while (distance > 1000 and prefixpow < #prefixesCI-1) do  distance = distance / 1000 prefixpow = prefixpow + 1 end

	local result = ""
	if (shortprefix) then   
		units = prefixesCIs[prefixpow+1] .. unitCIs[unitid+1] 
	else 
		units = prefixesCI[prefixpow+1] .. unitCI[unitid+1] 
	end
	return distance, units
end