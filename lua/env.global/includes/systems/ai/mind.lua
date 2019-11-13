module.Require('classifier')
--[[
classifier action types:
	0 - call function with output as arguments
	1 - add return arguments to pool
]]
local cla = classifier.CLPipe()
local deconstructor = cla:AddStage('deconstructor','',2) 
local identity = cla:AddStage('identity','<>',1)
local dialogue = cla:AddStage('dialogue','=',0,function(...) MsgN(table.Random({...})) end) 
local action = cla:AddStage('action','!',0,function(action,...)
    if action=='jump' then  
        if LocalPlayer() then
            LocalPlayer():Jump() 
        end
	end    
end)  
local action = cla:AddStage('action','$',0,function(action,...)
	--MsgN("act:",action,...)
	if action then
		local env = {}
		env.msg = MsgN
		env.pt = PrintTable
		env.a = {...}
		local f = assert(load(action,"x","bt",env)) 
		f()    
	end   
end)   
cla:LearnFile('input/ta.txt')

hook.Add("lisen","cla",function(text)
	cla:Query(text)
end) 
console.AddCmd("lis",function(...)
	cla:Query(table.concat({...}," "))
end)           