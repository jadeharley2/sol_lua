function DEFINE_METATABLE(key)
	local reg_tbl = debug.getregistry()
	local metaroot = reg_tbl[key] or {}
	debug.getregistry()[key] = metaroot
	metaroot.__index = nil
	metaroot.__metaname = key
	return metaroot
end 

function MetaType(x)
	if type(x) == 'userdata' then
		x = getmetatable(x)
	end
	if type(x) == 'table' then
		return x.__metaname
	end
end

function Collect(times,func,...) 
	local r = {}
	for k=1,times do
		r[k] = func(...)
	end
	return r
end