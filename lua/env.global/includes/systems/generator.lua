--if true then return 0 end
--[[
luanet.load_assembly("SolMain") 
sGenerator = luanet.import_type("SolMain.sGenerator") 

local generators = file.GetFiles("lua/env.global/generators","*.json", false)
for k,v in pairs(generators) do
	local jdata = json.Load(v)
	sGenerator.AddGenerator(jdata)
	MsgN("new generator added: "..v)
end




--local testE = entsCreate("")
--testE:SetVar("rotation",Angle(10,20,30))
 ]]
 
local ldir ="env.global/world/generators/"
hook.Add("script.reload","generator", function(filename)
	MsgN("check ","generator : ",filename,ldir,string.starts(filename,ldir))
	if string.starts(filename,ldir) then 
		local type = string.lower( file.GetFileNameWE(filename))
		local _tempvar = generator 
		generator = {} 
		include(filename) 
		_tempvar.Add(type,generator) 
		generator = _tempvar  
		return true
	end 
end)  

scriptgen.Reload() 