
task.slot = "movement"

function task:Setup(target) 
	self.target = target  
	return true
end 
function task:OnBegin() 
	MsgN("task: Ship centering")  
	return true
end 
function task:Step()   
	local ship = self.ent  
	if ship:RotateLookAtStep(self.target) then
		MsgN("Ship centering complete")
		return true
	end
end
function task:OnEnd(result)
	
end 