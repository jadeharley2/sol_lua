

local set_meta = {}


function set_meta:Add(key)
    self[key] = true
end

function set_meta:Remove(key)
    self[key] = nil
end

function set_meta:Contains(key)
    return self[key] ~= nil
end

set_meta.__index = set_meta
set_meta.__newindex = set_meta

function Set(...)
	local s = {} 
	for k,v in pairs({...}) do
		s[v] = true
	end
	setmetatable(s,set_meta)
	return s
end
