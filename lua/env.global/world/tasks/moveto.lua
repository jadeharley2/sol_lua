
task.slot = "movement"

function task:Setup(target,minimal_distance,run)
	self.target = target
	self.mindist = minimal_distance or 3 
	self.run = run or false
	return true
end 
function task:OnBegin() 
	self.ttt = 10
	local actor = self.ent
	local target = self.target
	local e,nav = actor:GetParentWithComponent(CTYPE_NAVIGATION)
	if e and nav then
		local pos_from = actor:GetPos()
		local pos_to = self.target
		if pos_to.GetPos then pos_to = pos_to:GetPos() end
		self._storedcon = actor.controller
		--actor.controller = self
		local path = nav:GetPath(pos_from,pos_to,0.001)
		if path then
			self.path = path
			self.pid = 1
			return true
		else
			return false, "nopath"
		end
	else
		local pos_from = actor:GetPos()
		local pos_to = self.target
		self.path = {pos_from,pos_to}
		self.pid = 1 
		return true
	end
	return false
end 
function task:Step() 


	self.ttt = self.ttt -1
	if self.ttt<0 then
		local actor = self.ent
		local target = self.target
		local e,nav = actor:GetParentWithComponent(CTYPE_NAVIGATION)
		if e and nav then
			local pos_from = actor:GetPos()
			local pos_to = self.target
			if pos_to.GetPos then pos_to = pos_to:GetPos() end
			self._storedcon = actor.controller
			--actor.controller = self
			local path = nav:GetPath(pos_from,pos_to,0.001)
			if path then
				self.path = path
				self.pid = 1 
			end

		end
		
		self.ttt = 10
	end



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
				if self.wasmoving then
					actor:Stop() 
				end
				return true
			end
		end
		if dist>0 then



			local dnorm = dir/dist
			local Up = actor:Up():Normalized()
			local lastdist = self.lastdist
			local times = self.times22 or 0
			self.times22 = times
			self.lastdist = dist

			actor:Hook(EVENT_GLOBAL_PREDRAW,'frotate',function()
				local rad, polar,elev = actor:GetHeadingElevation(-dnorm)
				local drf = polar/ 3.1415926 * 180 
				actor:TRotateAroundAxis(Up, (-drf)/1000)--/rdist) 
			end)
			local rdist = math.Clamp(math.fix(dist,1),0.5,10)+1 
			if dist>mindist then  
				if false then
					local lworld = (actor:GetWorld() * matrix.Rotation(0,-90,0))--:Inversed()
					local lpd = dir:TransformN(lworld)
					local localDir = Vector(lpd.x,0,lpd.z):Normalized()
					
					local sz1 = actor:GetSizepower()
					local sz2 = parent:GetSizepower()
					
					debug.ShapeBoxCreate(3333,actor,
					matrix.Translation(Vector(1,1,1)/-2)
					* matrix.Scaling(0.2/sz1) 
					* matrix.Translation(Vector(1,0,0)/sz1))

					debug.ShapeBoxCreate(3334,parent,
					matrix.Translation(Vector(1,1,1)/-2)
					* matrix.Scaling(0.02/sz2) 
					* matrix.Translation(actor:GetPos()+localDir/sz2))

					actor:Move(Vector(localDir.z,0,localDir.x),run)
				else
					actor:Move(Vector(0,0,1),run)
				end
				local Forward = actor:Right():Normalized()
				phys:SetViewDirection(Forward) 
				actor.model:SetPoseParameter("move_yaw",  0) 
				actor:SetEyeAngles(0,0,true)
				self.wasmoving = true
			else
				if lastdist and lastdist<=dist then
					times = times + 1
					if times > 10 then
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
	self.ent:UnHook(EVENT_GLOBAL_PREDRAW,'frotate')
	--self.ent.controller = self._storedcon
end