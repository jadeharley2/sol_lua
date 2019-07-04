
function Lerp(a,b,d)
	return a + (b-a)*d
end
 
function Smoothstep(edge0, edge1, x) 
	local val =math.Clamp( x*x*(3 - 2*x),0,1)
	local r = edge0 + val*(edge1 - edge0)
	if not math.finite(r) then r = 0 end
    return math.Clamp(r,edge0, edge1)
end
 
function math.isnan(x)
	return  x ~= x
end
function math.finite(x)
	return x > -math.huge and x < math.huge
end
function math.bad(x)
	return x ~= x or (x > -math.huge and x < math.huge)
end
function math.mod(a,b)
	return a - math.floor(a/b)*b
end
function math.sum(t)
	local o = 0
	for k,v in pairs(t) do o = o + v end
	return o
end
function math.avg(t)
	local o = 0
	local c = 0
	for k,v in pairs(t) do o = o + v   c = c + 1 end
	return o/c
end