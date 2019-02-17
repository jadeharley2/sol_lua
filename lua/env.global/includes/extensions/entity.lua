--auto reload

local registry = debug.getregistry()
local ENTITY = registry.Entity

-- do for all items in table or for one
function tableq(t)
	if istable(t) then return pairs(t) 
	else
		return function(t,c)  
			if c==0 then
				return 1, t
			else
				return nil
			end
		end, t, 0
	end
end
 
hook.Add("script.reload","entity", function(filename)
	if string.starts(filename,"env.global/world/entities/") then 
		ents.LoadType(filename)
		return true
	end
end)
Entity = ents.GetById


function ENTITY:Delayed(name,delay,action)
	--MsgN("DDDelayed",self,name)
	local ddtasks = self._ddtasks or {}
	
	local oldtask = ddtasks[name]
	if oldtask then
		oldtask:Stop()
	end
	
	local task = debug.Delayed(delay,action)
	ddtasks[name] = task
	self._ddtasks = ddtasks
	return task
end

function ENTITY:Timer(name,delay,interval,count,action)
	--MsgN("DDTimer",self,name)
	local ddtasks = self._ddtasks or {}
	
	local oldtask = ddtasks[name]
	if oldtask then
		oldtask:Stop()
	end
	
	local task = debug.DelayedTimer(delay,interval,count,action)
	ddtasks[name] = task
	self._ddtasks = ddtasks
	return task
end

function ENTITY:Hook(hookname,name,action)
	--MsgN("DDHook",self,hookname,name)
	local ddhooks = self._ddhooks or {}
	
	local seed = tostring(self:GetSeed())
	local keyname = name..".ent"..seed 
	 
	local oldhook = ddhooks[hookname]
	if oldhook then
		hook.Remove(hookname,oldhook)
	end
	
	ddhooks[hookname] = keyname 
	hook.Add(hookname,keyname,action) 
	self._ddhooks = ddhooks
end
function ENTITY:UnHook(hookname,name)
	--MsgN("DDUnHook",self,hookname,name)
	local ddhooks = self._ddhooks or {}
	
	local seed = tostring(self:GetSeed())
	local keyname = name..".ent"..seed 
	
	local oldhook = ddhooks[hookname]
	if oldhook then
		hook.Remove(hookname,oldhook)
	end
	self._ddhooks = ddhooks
end

function ENTITY:DDFreeAll()
	--MsgN("DDFreeAll",self)
	--MsgN("  tasks")
	for k,v in pairs(self._ddtasks or {}) do
		--MsgN("    ",k," - ",v)
		v:Stop()
	end
	--MsgN("  hooks")
	for k,v in pairs(self._ddhooks or {}) do
		--MsgN("    ",k," - ",v)
		hook.Remove(k,v)
	end
	self._ddtasks = nil
	self._ddhooks = nil
end
