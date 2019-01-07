ability.icon = "hex"
ability.type = "target"  
ability.name = "PhysInteraction"  
ability.hidden = true

function ability:Begin(caster,trace) 
 
end

function ability:End(caster)  
end

function ability:Think(caster) 
	
	return true
end 
function ability:Pick(target)
	self.target = target
end  
function ability:Drop()
	local target = self.target
	if target then
		
	end
	self.target = nil
	
end  
   
