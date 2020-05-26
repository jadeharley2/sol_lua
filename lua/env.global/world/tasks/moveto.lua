
task.slot = "movement"

function task:Setup(target,minimal_distance,run)
	self.target = target
	self.mindist = minimal_distance or 3 
	self.run = run or false
	return true
end 
function task:OnBegin() 
	self.ttt = 0
	local actor = self.ent
	if(actor.IsInVehicle) then
		actor:SendEvent(EVENT_EXIT_VEHICLE) 
	end 
	--local target = self.target
	--local e,nav = actor:GetParentWithComponent(CTYPE_NAVIGATION)
	--if e and nav then
	--	self.navent = e
--
	--	local pos_from = actor:GetPos()
	--	local pos_to = self.target
	--	if pos_to.GetPos then pos_to = pos_to:GetPos() end
	--	self._storedcon = actor.controller
	--	--actor.controller = self
	--	local path = nav:GetPath(pos_from,pos_to,0.001)
	--	if path then
	--		self.path = path
	--		self.pid = 1
	--		return true
	--	else
	--		return false, "nopath"
	--	end
	--else
	--	local pos_from = actor:GetPos()
	--	local pos_to = self.target 
	--	if pos_to.GetPos then pos_to = pos_to:GetPos() end
	--	self.path = {pos_from,pos_to}
	--	self.navent = actor:GetParent()
	--	self.pid = 1 
	--	MsgN("true?")
	--	return true
	--end
	--MsgN("False?")
	local rez = self:FindPath()
	--MsgN("path:",rez)
	return rez
end 
function task:FindPath()
	local actor = self.ent
	local target = self.target
	local parent = actor:GetParent()
	local e,nav = actor:GetParentWithComponent(CTYPE_NAVIGATION)
	if e and nav then
		self.navent = e
		actor.lastknownnav = nav
		actor.lastknownnavent = e

		local pos_from = actor:GetPos()
		local pos_to = target
		if pos_to.GetPos then pos_to = pos_to:GetPos() end
		self._storedcon = actor.controller
		--actor.controller = self
		local path = nav:GetPath(pos_from,pos_to,0.001)
		if path then
			self.path = path
			self.pid = 1 
			return true
		end 
	else 
		local ground = actor.phys:GetGround()
		if ground and ground[1] then
			e = ground[1]
			self.navent = e
			local nav = e:GetComponent(CTYPE_NAVIGATION)
			if nav then
				local pos_from = actor:GetPos()
				local pos_to = Vector(0,0,0)
				if MetaType(target) then
					pos_to = parent:GetLocalCoordinates(target)
				else
					pos_to = parent:GetLocalCoordinates(actor:GetParent(),target)
				end
				local local_posfrom = e:GetLocalCoordinates(parent,pos_from)
				local local_posto= e:GetLocalCoordinates(parent,pos_to)
				self._storedcon = actor.controller
				--actor.controller = self
				local path = nav:GetPath(local_posfrom,local_posto,0.001)
				if path then
					self.path = path
					self.pid = 1 
					return true
				end 
			end
		end 
	end

	local pos_from = actor:GetPos()
	local pos_to = self.target 
	if pos_to.GetPos then pos_to = pos_to:GetPos() end
	self.path = {pos_from,pos_to}
	self.navent = actor:GetParent()
	self.pid = 1  
	
	return true

	--return false
	
end
function task:Step() 

	local actor = self.ent
	local parent = actor:GetParent()
	self.ttt = self.ttt -1 
	if self.ttt<0 then 
		self:FindPath()
		self.ttt = 100
	end
	


	local path = self.path
	local pid = self.pid
	local mindist = self.mindist
	local run = self.run

	
	local phys = actor.phys
	local sz = parent:GetSizepower()
	local LW = actor:GetLocalSpace(parent)
	local positionCurrent =actor:GetPos()
	local positionTarget = parent:GetLocalCoordinates(self.navent, path[pid])
	local conNorm = phys:GetContactEvasionNormal()


	--MsgN(self.navent,positionCurrent,positionTarget)
	
	if positionTarget and MetaType(positionTarget)==nil then
		--Msg(">>",positionTarget)
		local dir =  ((positionTarget-positionCurrent)*sz+conNorm*-1):TransformN(LW)--self:GetLocalCoordinates(tp)
		local dist = dir:Length()
		--MsgN(conNorm)
		if mindist>dist then 
			if pid<#path then 
				pid = pid+1
				positionTarget = parent:GetLocalCoordinates(self.navent, path[pid])
				self.pid = pid
				
				return nil
			else 
				if self.wasmoving then
					actor:Stop() 
				end
				return true
			end
		end
		--MsgN(dist)
		if dist>0 then 
			local dnorm = dir/dist
			local Up = actor:Up():Normalized()
			local lastdist = self.lastdist
			local times = self.times22 or 0
			self.times22 = times
			self.lastdist = dist
			local xnorm = Vector(-dnorm.x,0,-dnorm.z):Normalized()
			local speedmul =math.Clamp(dnorm:Dot(Vector(1,0,0)),0,1)
			--MsgN(xnorm)
			--actor:LookAt(xnorm)
			actor:Hook(EVENT_GLOBAL_PREDRAW,'frotate',function()
				local rad, polar,elev = actor:GetHeadingElevation(-dnorm)
				local drf = polar/ 3.1415926 * 180 
				local rotspeed = math.Clamp((1-speedmul)*2,1,2)
				actor:TRotateAroundAxis(Up, (-drf)/1000*rotspeed)--/rdist)  
			end)
			local rdist = math.Clamp(math.fix(dist,1),0.5,10)+1 
			if dist>mindist then  
				local Forward = actor:Right():Normalized()

				--MsgN(speedmul)
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
					actor:Move(Vector(0,0,1),run,true,speedmul)
				end
				phys:SetViewDirection(Forward) 
				actor.model:SetPoseParameter("move_yaw",  0) 
				actor:SetEyeAngles(0,0,true)
				self.wasmoving = true
				if lastdist and lastdist<=dist then
					local jumptimes = self.jumptimes or 0
					local aborttimes = self.aborttimes or 0
					
					if jumptimes > 15 then
						Msg("JUMP",jumptimes)
						actor:SendEvent(EVENT_ACTOR_JUMP)
						jumptimes = 0
						--USE(actor)
					else
						jumptimes = jumptimes + 1
					end
					if aborttimes>100 then
						Msg("ABORT")
						actor:Stop() 
						return false 
					else
						aborttimes = aborttimes + 1
					end
					self.jumptimes = jumptimes
					self.aborttimes = aborttimes
				end
			else
				self.ent:UnHook(EVENT_GLOBAL_PREDRAW,'frotate')
			end
		end
	else
		--MsgN("ERROR:TARGET NOT SET")
	end
end
function task:OnEnd(result)
	self.ent:UnHook(EVENT_GLOBAL_PREDRAW,'frotate')
	--self.ent.controller = self._storedcon
	self.ent:Stop()
end