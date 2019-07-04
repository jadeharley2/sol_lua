

function J(val)
	if isuserdata(val) then
		return json.FromJson(val)
	else
		return json.ToJson(val)
	end
end

function JVector(jvec,default)
	if jvec then
		return Vector(jvec[1],jvec[2],jvec[3])
	else
		return default
	end
end
function JPoint(jvec,default)
	if jvec then
		return Point(jvec[1],jvec[2])
	else
		return default
	end
end
function VectorJ(vec)
	if vec then
		return {vec.x,vec.y,vec.z}
	end
	return {0,0,0} 
end

function Multicall(tab_obj,func,...)
	for k,v in pairs(tab_obj) do
		local t = type(v)
		if t=='userdata' or t=='table' then
			v[func](v,...)
		end
	end
end 


if SERVER then

--function CCCAA(e,pos)
--	dostring(str)
--	network.BroadcastLua('Entity('..tostring(e)..'):SetPos('..)
--end
--
end