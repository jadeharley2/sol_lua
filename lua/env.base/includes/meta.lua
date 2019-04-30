function DEFINE_METATABLE(key)
	local reg_tbl = debug.getregistry()
	local metaroot = reg_tbl[key] or {}
	debug.getregistry()[key] = metaroot
	metaroot.__index = nil
	return metaroot
end 


function Collect(times,func,...) 
	local r = {}
	for k=1,times do
		r[k] = func(...)
	end
	return r
end