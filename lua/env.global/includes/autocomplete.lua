
FunctionIsSafeToGet = function(text)
	if string.starts(text,'Entity(') then
		return true
	end	 
	if string.starts(text,'Vector(') then
		return true
	end	 
	if string.starts(text,'LocalPlayer(') then
		return true
	end	 
	if string.starts(text,'Get') then
		return true
	end	 
end

LuaGetAPIInfo = function(parent,key)
	local element = false
    if parent then 
        local metatype = MetaType(parent)
        if metatype then
            local info = debug.GetAPIInfo(metatype) or debug.GetAPIInfo('/globals/'..metatype)
            if info then
                return info[key] 
            end
        end
	else
		return debug.GetAPIInfo('/globals/'..key)
	end
end

LuaFunctionAutocomplete = function(parent,key)
	local r = {}  
	if parent then
		
		if type(parent)=='userdata' then
			parent = getmetatable(parent)
		end
		
		if type(parent)=='table' then
			local logged = {}
			for k,v in pairs(parent) do
                if string.starts(k,key) then 
                    r[#r+1] = k
					logged[k] = true
				end
			end
			local meta = getmetatable(parent)
			if meta then
				for k,v in pairs(meta) do
                    if string.starts(k,key) and not logged[k] then
                        r[#r+1] = k
					end
				end
			end
		end
	end
	return r

end
LuaAutocompleteIsFunction = function(parent,key)
	if type(parent)=='userdata' then
		parent = getmetatable(parent)
	end  
	if type(parent)=='table' then
		local v = parent[key] 
		return v and isfunction(v)
	end 
	return false
end
LuaAutocompleteRetValue = function(parent, key)
	local element = LuaGetAPIInfo(parent,key)

    if element and element._type=='function' then
        local ret = element._returns
        if istable(ret) then --first value only
            return ret[1]._valuetype 
        else
            return ret
        end
	end
end

LuaApiGetSub = function(parent,key)

end

debug.AddAPIInfo("/globals/LocalPlayer",{
	_type = "function", 
	_description = 'gets local player actor', 
	_returns = {{_name='value',_valuetype='Entity'}}
})
debug.AddAPIInfo("/globals/Entity",{
	_type = "function", 
	_description = 'get entity by id',  
	_returns = {{_name='value',_valuetype='Entity'}}
})  