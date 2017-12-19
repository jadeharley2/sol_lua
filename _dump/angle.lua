--metatable
--local ent = FindMetaTable("Entity") 
--ent.__call = function(t, k, ...) return t[k](...) end
--metatable
local meta = FindMetaTable("Angle") 
local stsub = string.sub

function Angle(pitch,yaw,roll)
	return setmetatable({p=pitch,y=yaw,r=roll},meta)
end

meta.__index = function(a,key)
	return a[stsub(key,1,1)]
end
meta.__newindex = function(a,key,value)
	local keyindex = stsub(key,1,1)
	a[keyindex] = value
end

meta.__add = function(a,b)
	return Angle(
	( a.p+b.p + 180 ) % 360 - 180, 
	( a.y+b.y + 180 ) % 360 - 180, 
	( a.r+b.r + 180 ) % 360 - 180)
end
meta.__sub = function(a,b)
	return Angle(
	( a.p-b.p + 180 ) % 360 - 180, 
	( a.y-b.y + 180 ) % 360 - 180, 
	( a.r-b.r + 180 ) % 360 - 180)
end
meta.__eq =  function(a,b)
	return a.p == b.p and a.y == b.y and a.r == b.r
end
meta.__tostring = function(a)
	return "Angle["..tostring(a.p)..", "..tostring(a.y)..", "..tostring(a.r).."]"
end

local testangle = Angle(30,1,10)

local testangle2 = Angle(3,1,-200)
Msg(testangle2.p, testangle2.pitch)
testangle2.p = 10 
Msg(testangle2.p, testangle2.pitch)
local testrezult = testangle + testangle2

Msg(testangle,testangle2,tostring(testrezult))

 