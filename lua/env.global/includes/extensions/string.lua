
function string.split(self, sep)
   if self==nil then return nil end
   local sep, fields = sep or " ", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end
--function string:split(sep)
--   local sep, fields = sep or " ", {}
--   local pattern = string.format("([^%s]+)", sep)
--   self:gsub(pattern, function(c) fields[#fields+1] = c end)
--   return fields
--end

function string.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end 

function string.Replace(s, oldValue, newValue)
   return string.gsub(s, oldValue, newValue) 
end 
string.replace = string.Replace

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function string.empty(s)
   return s == nil or s == ''
end

function string.join(separator,tab,skip)
   skip = skip or 0
	local r = tab[1+skip]
	for k,v in ipairs(tab) do
		if k > (1+skip) then 
			r = r .. separator .. v
		end
	end
	return r
end
