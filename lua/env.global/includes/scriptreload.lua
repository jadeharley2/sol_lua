
function xpcall_on_error(err)	
	MsgN("error:", err)
	MsgN(debug.traceback(nil,2))
end

function _ScriptReload(filename)
	if string.starts(filename,"lua/") then
		filename = string.sub(filename,5)
		if not hook.Call("script.reload",filename) then
			MsgN("script reload ", filename) 
			--xpcall(include,xpcall_on_error,filename)
			include(filename)
		end
	end
end 
function _FileReload(filename) 
	hook.Call("file.reload",filename)
end 