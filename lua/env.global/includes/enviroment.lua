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
	--return 0
	local cam = GetCamera() 
	local planet = cam:GetParentWithFlag(FLAG_PLANET)
	if planet then 
	
		if planet.surface then
		
			local sc = planet.surface.surface
			
			if sc and sc:HasAtmosphere() then
				local dptp = planet:GetDistance(cam) 
				local radius = planet:GetParameter(VARTYPE_RADIUS)
				local surfdist = dptp-radius
				--MsgN(surfdist)
				if surfdist<=0 then
					return -1
				else
					local atmwidth = 100000--temp linear 100km = 1
					return math.max(0, 1-surfdist/atmwidth)
				end
			end
		end
	end
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


ENV_EVENT_NONE = 0
ENV_EVENT_VISUAL = 1
ENV_EVENT_AUDIAL = 2
ENV_EVENT_QUAKE = 3

env.EnvEvent = function(node,pos,eid,data)
	for k,v in pairs(node:GetChildren()) do
		if v and IsValidEnt(v) then
			local een = v._eenv
			if een then
				local et = een[eid]
				if et then
					for k2,v2 in pairs(et) do
						v2(v,node,pos,data)
					end
				end
			end
		end
	end 
	if eid == ENV_EVENT_AUDIAL then
	end
end
env.EnvSubscribe = function(node,eid,name,f)
	local een = node._eenv or {}
	node._eenv = een

	een[eid] = een[eid] or {}
	een[eid][name] = f
end
env.Microphone = function(node,func)
	env.EnvSubscribe(node,ENV_EVENT_AUDIAL,'sound',func)
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