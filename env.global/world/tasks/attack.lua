
task.slot = "movement_upper"

function task:Setup(target,minimal_distance) 
	self.target = target
	self.mindist = minimal_distance or 10 
	return true
end 
function task:OnBegin()  
	return true
end 
function task:Step()   

	if self.times%10 == 0 then 
		local actor = self.ent
		local target = self.target
		local run = false
		local dist = actor:GetDistance(target)
		if dist > 100 or not IsVisibleAround(actor,target) then
			run = dist > 20 or target:IsRunning()
			self.manager:Begin(Task("moveto",target,5,run))
		else
			actor:Stop()
			self.manager:Begin(Task("rotateto",target))
			local dir = target:GetPos()-actor:GetPos()
			actor:WeaponFire(dir)
		end
	end
end
function task:OnEnd(result)
	 
end 