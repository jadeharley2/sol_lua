  
local EDITOR = {}   

--props: 
--
--funcs: 

function EDITOR:Open()
end
function EDITOR:Close() 
end

local editor_class = DefineClass("Editor","editor","lua/env.global/editor/",EDITOR)

function Editor(type) 
	return editor_class:Create(type)
end 

