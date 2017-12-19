--AddCSLuaFile()

--AbilitiesList =  {}--AbilitiesList or
local EF = {}

--props:
--type (self,target)
--dispellDelay
--thinkDelay  
--cooldownDelay
--
--funcs:
--self:Start(ent) - returns if effect can be applied
--self:Think(ent)
--self:End(ent)

function EF:Start(ent)  
end 
function EF:End() 
end 

local ef_class = DefineClass("Effect","effect","lua/env.global/world/effects/",EF)
    
function Effect(type) 
	return ef_class:Create(type)
end 
    
  