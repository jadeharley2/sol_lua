local meta = {}

local templates = {}

function LevelGen(nodeself,templatename,dbg)
	local t = templates[templatename]
	local lgen = { nod = nodeself,template = t, debug = dbg }
	setmetatable(lgen,meta)
	return lgen
end


function meta:SelectSection(seed,type)
	local t = self.template
	local rnd = Random(seed)
	local filtered = table.Where(t.sections,function(k,v) return v[section_type] end)
	if self.debug then MsgN("filtered: ",#sections," -> ",#filtered) end
	local ctype = table.Random(filtered,rnd) 
	if ctype then
		local csection = table.Random(ctype,rnd)
		return csection
	else
		if self.debug then MsgN("filter - no ctype") end
		return nil
	end
end
function meta:SelectAttachment(seed,section)
	local filteredatt = table.Where(csection.points,function(k,v,a) return v.t==a end,section_type)
	if self.debug then MsgN("filteredattachments: ",#csection.points," -> ",#filteredatt) end
	local cattachpointa =  table.Random(filteredatt,rnd) 
	if cattachpointa then
		local otherattachpoints = table.Where(csection.points,function(k,v) return v~=cattachpointa end)
		return cattachpointa, otherattachpoints
	else
		if self.debug then MsgN("no attach point") end 
		return nil
	end
end
--function meta:SpawnSection(seed,
function meta:GenerateGrid(seed)
	
end





function TEMP_SurfaceEntSpawn(type,node,pos,ang,scale)

end