 
local COM = {}
 

 
components = DefineClass("Component","component","lua/env.global/world/components/",COM)
    
function Component(type) 
	return ef_class:Create(type)
end 
     
   