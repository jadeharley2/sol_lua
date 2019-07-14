
task.slot = "movement"

function task:Setup(seconds)
	self.amount = seconds 
	return true
end 
function task:OnBegin() 
	self.starttime = CurTime()
	return true
end 
function task:Step()  
	local ct = CurTime()
	if ct>self.starttime+self.amount then
		return true
	end
end
function task:OnEnd(result)
	
end 