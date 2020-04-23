table = table or {}

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

table.DeepCopy = deepcopy
table.Copy = function (orig)
	local newt = {}
	for k,v in pairs(orig) do
		newt[k] = v
	end
	return newt
end


table.Random = function(t,rnd)
	if #t == 0 then return nil end
	if rnd then
		local id = rnd:NextInt(1,#t+1)
		return t[id]
	else
		local id = math.random(1,#t)
		return t[id]
	end
end
table.RandomKey = function(t,rnd)
	local nt = {}
	for k,v in pairs(t) do
		nt[#nt+1] = k
	end
	return table.Random(nt,rnd)
end


function T(t)
	return setmetatable(t or {},table)
end

--x = 2
--f(x,y){x} 

table.Keys = function(t)
	local nt = T()
	for k,v in pairs(t) do
		nt[#nt+1] = k
	end
	return nt
end
table.Values = function(t)
	local nt = T()
	for k,v in pairs(t) do
		nt[#nt+1] = v
	end
	return nt
end
table.KVSwitch = function(t)
	local nt = T()
	for k,v in pairs(t) do
		nt[v] = k
	end
	return nt
end
table.Select = function(t,func,...)
	local t2 = T()
	if isstring(func) then  
		for k,v in pairs(t) do
			local f = v[func]
			if f and isfunction(f) then
				t2[k] = f(v,...) 
			end
		end
	else
		for k,v in pairs(t) do
			t2[k] = func(v,...) 
		end
	end
	return t2
end
table.SelectKV = function(t,func,...)
	local t2 = T()
	if isstring(func) then  
		for k,v in pairs(t) do
			local f = v[func]
			if f and isfunction(f) then
				t2[k] = f(k,v,...) 
			end
		end
	else
		for k,v in pairs(t) do
			t2[k] = func(k,v,...) 
		end
	end
	return t2
end
table.Where = function(t,func,...)
	local t2 = T() 
	for k,v in pairs(t) do
		if func(k,v,...) then t2[#t2+1] = v end
	end 
	return t2
end
table.Map = function(t,func,...)
	local t2 = T() 
	for k,v in pairs(t) do
		local nk,nv = func(k,v,...)
		if nk~=nil and nv~=nil then t2[nk] = nv end
	end 
	return t2
end
table.Merge = function(from,to,deep) 
	for k,v in pairs(from) do
		local rv = to[k]
		if rv==nil or not istable(rv) then 
			if deep then
				to[k] = deepcopy(v)
			else
				to[k] = v
			end
		else 
			if deep then
				if istable(v) then
					table.Merge(deepcopy(v), to[k], true)
				end
			end
		end
	end 
	return to
end

--take @count@ elements from start
table.Take = function(tab,count) 
	local ntab = T()
	for k,v in pairs(tab) do 
		if k>count then break end
		ntab[k] = v 
	end 
	return ntab
end
--skip @count@ elements from start
table.Skip = function(tab,count) 
	local ntab = T()
	for k,v in pairs(tab) do  
		if k>count then ntab[k-count] = v end
	end 
	return ntab
end
--skip startcount till end
table.SubTrim = function(tab,startc,endc) 
	local ntab = T()
	local c = 0
	for k,v in pairs(tab) do  
		if k>startc then 
			ntab[k-startc] = v 
			c = c +1 
		end 
	end  
	for k = 1, endc do 
		ntab[c-k+1] = nil
	end
	return ntab
end

table.__index = table



--[short function declaration example]
--local bla = _(v){v*v*v}
--PrintTable(T({a=1,b=2,c=3}):Select(bla))  
--PrintTable(T({a=1,b=2,c=3}):Select(_(v){v*v*v}))  