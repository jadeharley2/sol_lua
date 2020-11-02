
task.slot = "think"

function task:Setup(target,minimal_distance,run)
	self.target = target
	self.mindist = minimal_distance or 3 
	self.run = run or false
	self.mode = "search" 
	return true
end 
function task:OnBegin() 
	self.ttt = 0

	return true
end 
function task:Step() 

	local actor = self.ent
	local parent = actor:GetParent() 
MsgN("ASD",self.mode)
	if not self.ctask or self.ctask:IsFinished() then
		if self.mode == "search" then
			local fctask = self:SelectMarkerAndGo()
			if fctask then
				self.mode = "move"
				self.ctask = fctask
			end
		elseif self.mode == "move" then
			--...
		elseif self.mode == "work" then
			self.ctask = Task("wait",5) 
		end 
	end 
end
function task:OnEnd(result) 
	self.ent:Stop()
end
function task:SelectMarkerAndGo()
	local actor = self.ent 
	local parent = actor:GetParent()  
    
	local marker = false
	local mindist = 99999
	for k,v in pairs(parent:GetChildren()) do
		if v.marker_type=="res" then
			local dist = v:GetDistanceSq(actor)
			if mindist>dist then
				marker = v
				mindist = dist
			end 
			MsgN("TSK",v)
		end
	end
	if IsValidEnt(marker) then
		return self:GoTo(marker)  
	end
end
function task:GoTo(target) 
	if target then
		local actor = self.ent 
		local parent = actor:GetParent()
		local e,nav = actor:GetParentWithComponent(CTYPE_NAVIGATION)

		local lpos = parent:GetLocalCoordinates(actor)
		local tpos = parent:GetLocalCoordinates(target)
		local path = nav:GetPath(lpos,tpos,0.001)
		if path then 
			self.taskstart = CurTime()
			return Task("moveto",tpos,self.mindist,false) 
		end
	end 
end


function task:FindPath(target)
	local actor = self.ent 
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
	
end