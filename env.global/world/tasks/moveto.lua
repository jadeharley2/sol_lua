
task.slot = "movement"

function task:Setup(target,minimal_distance,run)
	self.target = target
	self.mindist = minimal_distance or 3 
	self.run = run or false
	return true
end 
function task:OnBegin()
	local actor = self.ent
	local target = self.target
	local e,nav = actor:GetParentWithComponent(CTYPE_NAVIGATION)
	if e and nav then
		local path = nav:GetPath(actor:GetPos(),target:GetPos(),0.001)
		if path then
			self.path = path
			self.pid = 1
			return true
		else
			return false, "nopath"
		end
	end
	return false
end 
function task:Step() 
	local actor = self.ent
	local path = self.path
	local pid = self.pid
	local mindist = self.mindist
	local run = self.run
	
	local phys = actor.phys
	local parent = actor:GetParent()
	local sz = parent:GetSizepower()
	local LW = actor:GetLocalSpace(parent)
	local positionCurrent = actor:GetPos()
	local positionTarget = path[pid]
	local conNorm = phys:GetContactEvasionNormal()
	if positionTarget then
		local dir =  ((positionTarget-positionCurrent)*sz+conNorm*-1):TransformN(LW)--self:GetLocalCoordinates(tp)
		local dist = dir:Length()
		--MsgN(conNorm)
		if mindist>dist then 
			if pid<#path then 
				pid = pid+1
				positionTarget = path[pid] 
				self.pid = pid
				
				return nil
			else 
				actor:Stop() 
				return true
			end
		end
		if dist>0 then
			local dnorm = dir/dist
			local Up = actor:Up():Normalized()
			local rad, polar,elev = actor:GetHeadingElevation(-dnorm)
			local lastdist = self.lastdist
			local times = self.times22 or 0
			self.times22 = times
			self.lastdist = dist
			local drf = polar/ 3.1415926 * 180 
			local rdist = math.Clamp(math.fix(dist,1),0.5,10)+1 
			actor:TRotateAroundAxis(Up, (-drf)/200)--/rdist) 
			if dist>mindist then   
				actor:Move(Vector(0,0,1),run)
				local Forward = actor:Right():Normalized()
				phys:SetViewDirection(Forward) 
				actor.model:SetPoseParameter("move_yaw",  0) 
			else
				if lastdist and lastdist<=dist then
					times = times + 1
					if times > 20 then
						actor:SendEvent(EVENT_ACTOR_JUMP)
						times = 0
						USE(actor)
					end
				end
			end
		end
	else
		--MsgN("ERROR:TARGET NOT SET")
	end
end
function task:OnEnd(result)
	
end