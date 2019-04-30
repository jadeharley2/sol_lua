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
function math.Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
math.round = math.Round

function math.snap(num, to) 
  return math.floor(num / to + 0.5) * to
end

function math.fix(num,def)
	if math.finite(num) then
		return num
	else
		return def
	end 
end  

function math.mean(a,...) 
  local r = a
  if(type(a)~='table') then
    r = {a,...} 
  end
  local m = 0
  local c = 0
  for k,v in pairs(r) do
    m=m+v
    c=c+1
  end
  return m/c
end
 
function math.counts(r)  
  local rez = {}
  for k,v in pairs(r) do
    rez[v] = (rez[v] or 0) + 1
  end
  return rez
end
 