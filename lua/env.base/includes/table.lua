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

table.Copy = deepcopy

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
table.Keys = function(t)
	local nt = {}
	for k,v in pairs(t) do
		nt[#nt+1] = k
	end
	return nt
end
table.Values = function(t)
	local nt = {}
	for k,v in pairs(t) do
		nt[#nt+1] = v
	end
	return nt
end
table.Select = function(t,func,...)
	local t2 ={}
	
	for k,v in pairs(t) do
		if func(k,v,...) then t2[#t2+1] = v end
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
end

--take @count@ elements from start
table.Take = function(tab,count) 
	local ntab = {} 
	for k,v in pairs(tab) do 
		if k>count then break end
		ntab[k] = v 
	end 
	return ntab
end
--skip @count@ elements from start
table.Skip = function(tab,count) 
	local ntab = {} 
	for k,v in pairs(tab) do  
		if k>count then ntab[k-count] = v end
	end 
	return ntab
end
