

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
