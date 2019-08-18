
task.slot = "movement_upper"

function task:Setup(target,minimal_distance,tpdistance) 
	self.target = target
	self.mindist = minimal_distance or 3  
	self.tpdistance = tpdistance or 40 --m
	
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
		local tpd = self.tpdistance or 20 
		local dist = actor:GetDistance(target)
		run = dist > 10 or target:IsRunning()

		--MsgN(dist,tpd) 
		if false and (dist>tpd or dist==0) then
			local ppos = target:GetPos() - target:Right()/actor:GetParent():GetSizepower()
			actor:SetPos(ppos)
		else
			self.manager:Begin(Task("moveto",target,self.mindist,run))
		end

		--MsgN("huh??")
	end
end
function task:OnEnd(result)
	
end 