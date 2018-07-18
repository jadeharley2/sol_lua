
function string:split(sep)
   local sep, fields = sep or " ", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

function string.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function string.Replace(s, oldValue, newValue)
   return string.gsub(s, oldValue, newValue) 
end 
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function string.empty(s)
   return s == nil or s == ''
end

function string.join(separator,tab)
	local r = tab[1]
	for k,v in pairs(tab) do
		if k > 1 then 
			r = r .. separator .. v
		end
	end
	return r
end