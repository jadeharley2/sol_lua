if SERVER then return end
 
env = env or {}
env.Planet = function()
	return GetCamera():GetParentWithFlag(FLAG_CELESTIAL_BODY)
end
env.Star = function()
	return GetCamera():GetParentWithFlag(FLAG_STAR)
end
env.Starsystem = function()
	return GetCamera():GetParentWithFlag(FLAG_STARSYSTEM)
end
env.Galaxy = function()
	return GetCamera():GetParentWithFlag(FLAG_GALAXY)
end

env.Temperature = function()
	return 0
end 
env.Humidity = function()
	return 0
end 
env.AtmPressure = function()
	return 0
end
env.Gravity = function()
	return Vector(0,0,-1)
end
env.EMField = function()
	return Vector(0,0,0)
end
env.MagField = function() --E,W,A,F
	return Vector(0,0,0),Vector(0,0,0),Vector(0,0,0),Vector(0,0,0)
end


tempCreateMap = function(pos,mul) 
	pos = pos or Vector(0,0,1) 
	mul = mul or 1
	local pl = env.Planet().surface.surface
	
	local r = {}
	local l2 = ""
	for x=1,180 do
		local u = {}
		local l = ""
		for y=1,360 do
			local v = pl:GetHeight(pos:Rotate(Vector(x-90,y-180,0)*mul))--+90
			u[y] = v
			if y ~= 360 then
				l = l .. tostring(v)..", "
			else 
				l = l .. tostring(v)
			end
		end
		 
		r[x] = u
		if x ~= 180 then
			l2 = l2 .. l.."\r\n"
		else 
			l2 = l2 .. l
		end
	end
	
	file.Write("output/planetscan.csv",l2)
	return l2
end

tempLocalMap = function(mul)
	local cam = GetCamera() 
	local surf = env.Planet().surface
	return tempCreateMap(surf:GetLocalCoordinates(cam),mul)
end