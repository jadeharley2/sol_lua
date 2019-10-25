--if true then return false end

local COM = {}
 
 
    

components = DefineClass("Component","component","lua/env.global/world/components/",COM)
   
if true then return false end
 
function Component(type,node,...) 
	local lua_components = node.lua_components
	if not lua_components then
		lua_components = {}
		node.lua_components = lua_components
	end
	
	local com = lua_components[type]
	if not com then 
		com = components:Create(type)
		if com.OnInit then com:OnInit(...) end
		com.node = node
		lua_components[type] = com
		com:OnAttach(node)
	end 
	return com
end 


function TryGetComponent(type,node) 
	if node then
		local lua_components = node.lua_components
		if lua_components then
			return lua_components[type]
		end
	end
	return nil
end 
 