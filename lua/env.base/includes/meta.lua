function DEFINE_METATABLE(key)
	local reg_tbl = debug.getregistry()
	local metaroot = reg_tbl[key] or {}
	debug.getregistry()[key] = metaroot
	metaroot.__index = nil
	return metaroot
end 