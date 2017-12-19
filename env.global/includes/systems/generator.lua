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