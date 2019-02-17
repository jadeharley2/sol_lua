
stellarclass = stellarclass or {}

stellarclass.spectraltypes = { 
	O={color = {146, 181, 255},temp = {30000,60000}},
	B={color = {162, 192, 255},temp = {10000,30000}},
	A={color = {213, 224, 255},temp = {7500,10000}},
	F={color = {249, 245, 255},temp = {6000,7500}},
	G={color = {255, 237, 227},temp = {5200,6000}},
	K={color = {255, 218, 181},temp = {3700,5200}},
	M={color = {255, 181, 108},temp = {2400,3700}},
	--brown dwarfs
	L={color = {255, 127, 108}},
	T={color = {140, 40,  25}},
	--sub brown dwarf
	Y={color = {60,  6,   36}},
	--carbon stars
	C={color = {255, 127, 108}},
	S={color = {255, 181, 108}},
	--degenerate
	D={color = {127, 127, 127}},
	
}
for k,v in pairs(stellarclass.spectraltypes) do
	v.class = k
end
stellarclass.lumclass = {
	['0'] = {name="hypergiant"},
	Ia    = {name="supergiant"},
	Ib    = {name="supergiant"},
	II    = {name="brightgiant"},
	III   = {name="giant"},
	IV    = {name="subgiant"},
	V     = {name="main sequence star"},
	VI    = {name="subdwarf"},
	VII   = {name="dwarf"},
}
for k,v in pairs(stellarclass.lumclass) do
	v.type = k
end

function stellarclass.FromString(s)
	s = s:trim()
	local sptype = string.sub(s,1,1):trim()
	local lmclass = string.sub(s,2):trim()
	
	local s = stellarclass.spectraltypes[sptype]
	local l = stellarclass.lumclass[lmclass]
	local r = {}
	table.Merge(s,r) 
	table.Merge(l,r)
	return r--{spectraltype = s, lumclass = l}
end




