
task.slot = "movement_upper"

function task:Setup(minimal_distance) 
	self.mindist = minimal_distance or 3 
	return true
end 
function task:OnBegin()  
	return true
end 
function task:Step()   
	local movetask = self.movetask
	local sttime = self.taskstart or 0
	if not movetask or sttime+30<CurTime() then 
		--MsgN("wan")
		local actor = self.ent
		local n,nav = actor:GetParentWithComponent(CTYPE_NAVIGATION)
		if nav then
			local parent = actor:GetParent()
			local sz = parent:GetSizepower()
			local pos_from = actor:GetPos()
			local ptp = nav:GetPointsInRadius(pos_from,10/sz)
			if ptp then 
				local target = table.Random(ptp)
				if target then
					local path = nav:GetPath(pos_from,target,0.001)
					if path then
						MsgN(target)
						self.taskstart = CurTime()
						self.movetask = Task("moveto",target,self.mindist,false)
						self.manager:Begin(self.movetask)
					end
				end
			end
		end
	end
end
function task:OnEnd(result)
	
end 