
function math.NormalizeAngle( a )
	return ( a + 180 ) % 360 - 180
end

function math.AngleDifference( a, b )
	local d = math.NormalizeAngle( a - b )
	if d < 180 then
		return d
	end
	return d - 360
end

function math.AngleDelta( a, b ) -- -180...180 angle
	local d = a - b
	if d > 181 then
		return d - 360
	end
	if d < -181 then
		return d + 360
	end
	return d
end

--[[

a = -180
b = 90
d = a - b = -180 - 90 = -270
ret = d + 360 = -270 + 360 = 90

a = 90
b = -180
d = a - b = 90 - -180 = 270
ret = d + 360 = 270 - 360 = -90


]]