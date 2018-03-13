
local cmauid = 1000000
function GetFreeUID()
	cmauid = cmauid + 1
	while(ents.GetById(cmauid)) do
		cmauid = cmauid + 1
	end
	return cmauid
end

