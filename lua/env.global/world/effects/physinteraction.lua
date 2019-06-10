ability.icon = "hex" 
ability.name = "PhysInteraction"   

function ability:Begin(source,target) 
 
end

function ability:End(source,target)  
end

function ability:Think() 
	
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
   
