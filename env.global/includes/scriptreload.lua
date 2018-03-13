
function _ScriptReload(filename)
	if string.starts(filename,"data/lua/") then
		filename = string.sub(filename,10)
		if not hook.Call("script.reload",filename) then
			MsgN("script reload ", filename)
			include(filename)
		end
	end
end 

   