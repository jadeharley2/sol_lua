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