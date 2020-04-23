
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
---add selfdestructing hook
function hook.AddOneshot(type,id,func)
	hook.Add(type,id,function(...)
		hook.Remove(type,id)
		func(...)
	end)
end
function hook.GetTable()
	return table.DeepCopy(lua_hooks)
end

local onerror = function(err)
	MsgN(err)  
	MsgN(debug.traceback())
end

---call all registered functions
---@param eventid string|number
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
-- >a, >b, >f, >{g,d} => {a,b,f,{g,d}}
function hook.Collect(eventid,...)
	--if eventid ~= "main.update" then MsgN("hook call: "..tostring(eventid)) MsgN(...) end
	local case = lua_hooks[eventid]
	local results = {}
	if case then
		for k,v in pairs(case.functions) do
			local success, result, value2 = xpcall(v,onerror,...)
			if success then
				if result then
					if value2 then
						results[result] = value2 
					else
						results[#results+1] = result 
					end
				end
			else
				MsgN("Error in hook: ",eventid,".",k," -> ",result)
			end
		end
	end
	return results
end
-- >{ a,b,c }, >{f,e}, >{g} => {a,b,c,f,e,g}
function hook.CollectElements(eventid,...) 
	local results = hook.Collect(eventid,...) 
	local nr = {}
	for _,v in ipairs(results) do
		if istable(v) then
			for k2,v2 in pairs(v) do
				if(isnumber(k2)) then
					nr[#nr+1] = v2;
				else
					nr[k2] = v2;
				end
			end
		end
	end
	return nr
end


---@param id string|number
---@param description string|nil
---@param arguments string|nil
function hook.RegisterHook(id,description,arguments)
	local argtab = nil
	if arguments then
		argtab = {}
		for i1,v1 in ipairs(arguments:split(',')) do
			local name, vtype = unpack(v1:split(':'))
			argtab[i1] = {_name = name,_valuetype = vtype}
		end
	end
	debug.AddAPIInfo("/hooks/"..id,{_type="hook",_description = description,_arguments = argtab})
end

_SetNativeCallFunc(hook.Call)



hook.RegisterHook("input.keydown",		"","key:number")
hook.RegisterHook("input.keyup",		"","key:number")
hook.RegisterHook("input.keypressed",	"")
hook.RegisterHook("input.mousedown",	"")
hook.RegisterHook("input.mouseup",		"")
hook.RegisterHook("input.mousewheel",	"")
hook.RegisterHook("input.doubleclick",	"")


console.AddCmd("listhooks",function (id)
	if id then
		local case = lua_hooks[id]
		if case then
			for k,v in SortedPairs(case.functions) do
				MsgN("  ",k)
			end
		end
	else
		for k,v in SortedPairs(lua_hooks,UniversalSort) do
			MsgN("  ",k)
		end
	end
end)


--json.Write("blah.json",debug.GetAPIInfo())