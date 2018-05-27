function math.sign(x)
   if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end

function math.Clamp(val,min,max)
	if val<min then return min
	elseif val>max then return max
	else return val end
end
function math.lerp(a, b, f) 
    return a + f * (b - a)
end
function math.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function math.fix(num,def)
	if math.finite(num) then
		return num
	else
		return def
	end
end