
hook = hook or {}

hook.lua_hooks = hook.lua_hooks or {}
local lua_hooks = hook.lua_hooks

function hook.Add(type, id, func)
	local case = lua_hooks[type] or {}
	case.functions = case.functions or {}
	if not case.functions[id] then
		case.count = (case.count or 0) + 1
	end
	case.functions[id] = func 
	lua_hooks[type] = case
end
function hook.Remove(type, id)
	local case = lua_hooks[type]
	if case then
		if case.functions[id] then
			case.functions[id] = nil
			case.count = case.count - 1
		end
		if(case._count == 0) then
			lua_hooks[type] = nil
		end
	end
end
function hook.GetTable()
	return table.Copy(lua_hooks)
end

local onerror = function()  
	MsgN(debug.traceback())
end

function hook.Call(eventid,...)
	--if eventid ~= "main.update" then MsgN("hook call: "..tostring(eventid)) MsgN(...) end
	local case = lua_hooks[eventid]
	if case then
		for k,v in pairs(case.functions) do
			local success, result = xpcall(v,onerror,...)
			if success then
				if result then
					return result
				end
			else
				MsgN("Error in hook: ",eventid,".",k," -> ",result)
			end
		end
	end
end

_SetNativeCallFunc(hook.Call)