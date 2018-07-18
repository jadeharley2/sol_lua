

local set_meta = DEFINE_METATABLE("Set")

 
function set_meta:Add(key)
    self[key] = true
end

function set_meta:Remove(key)
	for k,v in pairs(self) do
		if k==key then
			self[k] = nil 
		end
	end
    self[key] = nil
end

function set_meta:Contains(key)
    return self[key] ~= nil
end 

function set_meta:Clear() 
	for k,v in pairs(self) do
		self[k] = nil
	end
end

function set_meta:First() 
	for k,v in pairs(self) do
		return k
	end 
end

function set_meta:ToTable() 
	local t = {}
	for k,v in pairs(self) do
		t[#t+1] = k
	end 
	return t
end

function set_meta:Count() 
	local c = 0;
	for k,v in pairs(self) do
		c = c + 1
	end 
	return c
end

set_meta.__index = set_meta
--set_meta.__newindex = set_meta

function Set(...)
	local s = {} 
	for k,v in pairs({...}) do
		s[v] = true
	end
	setmetatable(s,set_meta)
	return s
end
