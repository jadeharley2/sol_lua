

function J(val)
	if isuserdata(val) then
		return json.FromJson(val)
	else
		return json.ToJson(val)
	end
end

function JVector(jvec,default)
	if jvec then
		local j3 = jvec[3]
		if j3 then
			return Vector(jvec[1],jvec[2],j3)
		else
			return Vector(jvec[0],jvec[1],jvec[2])
		end
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
function JMatrix(tab)
	local r = matrix.Identity()
	if tab.sca then
		if istable(tab.sca) then
			r = matrix.Scaling(Vector(tab.sca[1],tab.sca[2],tab.sca[3]))
		else
			r = matrix.Scaling(tab.sca)
		end
	end
	if tab.ang then
		r = r * matrix.Rotation(Vector(tab.ang[1],tab.ang[2],tab.ang[3]))
	end
	if tab.pos then
		r = r * matrix.Translation(Vector(tab.pos[1],tab.pos[2],tab.pos[3]))
	end
	return r
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