
task.slot = "movement_upper"

function task:Setup(target,minimal_distance) 
	self.target = target
	self.mindist = minimal_distance or 3 
	return true
end 
function task:OnBegin()  
	return true
end 
function task:Step()   
	--MsgN("huh??",self.times)

	if self.times%10 == 0 then 
		local actor = self.ent
		local target = self.target
		local run = false
		local dist = actor:GetDistance(target)
		run = dist > 10 or target:IsRunning()
		self.manager:Begin(Task("moveto",target,self.mindist,run))
		--MsgN("huh??")
	end
end
function task:OnEnd(result)
	
end 