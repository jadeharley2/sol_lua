

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

function Multicall(tab_obj,func,...)
	for k,v in pairs(tab_obj) do
		v[func](v,...)
	end
end