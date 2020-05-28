

DeclareEnumValue("tag","REPL_FATIGUE",					10101) 
DeclareEnumValue("tag","REPL_SLEEP",					10102) 

task.slot = "movement_upper"
task.delaytime = 10
task.bannedents = {}

function task:Setup(minimal_distance) 
	self.mindist = minimal_distance or 3 
	return true
end 
function task:OnBegin()  
	local actor = self.ent
	local needs = actor.needs or {}
	actor.needs = needs
	self.needs = needs

	--needs.sleep = needs.sleep or 0
	--needs.fatigue = needs.fatigue or 0
	--needs.thirst = needs.thirst or 0
	--needs.hunger = needs.hunger or 0
	--needs.entertainment = needs.entertainment or 0
	--needs.social = needs.social or 0


	return true
end 
local needsMul = 5 --40
function task:NeedsTick() 
	local actor = self.ent
	local n = actor.needs
	if n and n.list then 
		for k,v in pairs(n.list) do
			v.value = v.value + v.rate * needsMul
		end
		--n.sleep = n.sleep + 0.001   *needsMul
		--n.fatigue = n.fatigue + 0.01*needsMul
		--n.hunger = 	n.hunger + 0.01*needsMul
		--n.thirst = 	n.thirst + 0.02*needsMul
		--n.entertainment = n.entertainment + 0.01*needsMul
		--n.social = n.social + 0.01*needsMul

	end
end
console.AddCmd("listneeds",function ()
	local actor = LocalPlayer().viewEntity
	if IsValidEnt(actor) then
		if actor.needs and actor.needs.list then 
			PrintTable(actor.needs.list)
		else
			MsgN("{}")
		end
	end
end)
function task:HasNeed()
	local actor = self.ent
	if actor.needs and actor.needs.list then 
		local n = actor.needs.list
		local topk=false;
		local topv = -10;
		for k,v in pairs(n) do
			if(v.value>topv)then
				topk = k
				topv = v.value or 0
			end
		end
		if topv>100 then
			return topk
		end
	end
end
function task:UpdateNeedTask(topk)
	local actor = self.ent 
	local need = n[topk]
	if need then 
		
		local tar = self:FindNearestRepl(topk)
		if tar then
			local replenish = need.replenishaction
			--actor:Say("sit")
			local rez = tar.needs.delta.fatigue
			self.taskstart = CurTime()
			local T = Task("moveto",tar,replenish.range or 1.5,false)
			T:Next(Task(function(T) 
				need.value=0
				if replenish.use then USE(T.ent) end 
				return true 
			end))
			T:Next(Task('wait',replenish.time))

			return T
		else
			--actor:Say("*faints*")
			MsgN(actor,'is unable to find source for',topk)
			need.value=0
		end 
	end
end
function task:FindNearestRepl(type) 
	local actor = self.ent
	local parent = actor:GetParent()
	local useableents = T(parent:GetChildren()):Where(function(k,n) 
		return --n:HasTag(TAG_USEABLE) 
		n ~= actor
		and n.needs
		and n.needs.delta
		and n.needs.delta[type]
	end)
	local mindist = 99999
	local mint = false
	--MsgN('useableents')
	--PrintTable(useableents)
	local apos = actor:GetPos()
	for k,v in pairs(useableents) do
		local d = v:GetPos():DistanceSquared(apos)
		if d <mindist then
			mindist = d
			mint = v
		end 
	end 
	return mint 
end
function task:GetNav(actor)
	 
	if actor.phys then
		local ground = actor.phys:GetGround()
		
		if ground and ground[1] then
			e = ground[1]
			self.navent = e
			local nav = e:GetComponent(CTYPE_NAVIGATION)
			if nav then
				self.lastnav = nav
				return nav
			end
		end
	end
	local n,nav = actor:GetParentWithComponent(CTYPE_NAVIGATION)
	if nav then
		self.lastnav = nav
	end
	return nav or self.lastnav
end
function task:Step()   
	local movetask = self.movetask
	local sttime = self.taskstart or 0
	local actor = self.ent
	self:NeedsTick()
 
	local current_task = self.current_task

	local ct = CurTime()
	if (self.nextsense or 0)  < ct then
		self.nextsense =ct + 1 
		local sensed = self:UpdateSenses(actor)
		if sensed then
			if actor:IsReallyMoving() then

			else
				if current_task then self.manager:End(current_task) end
				MsgN(actor, "sensed",sensed)
				local duration = math.random(1,20)

				current_task = Task("lookat",sensed,duration) 
				if self.manager:Begin(current_task) then
					self.current_task = current_task
				end
			end
		end 
	end

	if not current_task or current_task:IsFinished() then
		current_task = self:SelectActivity(actor)
		if current_task then
			if self.manager:Begin(current_task) then
				self.current_task = current_task
			end
			MsgN(actor,"selected",current_task)
		else
			MsgN(actor,"is unable to select activity")
		end
	end
	 

	if false and (not movetask or sttime+self.delaytime<CurTime()) then 

		--MsgN("wan")
		local nav = self:GetNav(actor)
		if true then
			local parent = actor:GetParent()
			local sz = parent:GetSizepower()
			local pos = actor:GetPos()

			if true then -- not self:UpdateNeedsTask(actor.needs) then
			--
			
				if nav then
					if false and math.random()>0.5 then
						self:VariantUseSomething(parent,nav,pos,sz)
					elseif math.random()>0.99 then
						self:VariantWalk(nav,pos,sz)
					end
				end
				--MsgN("tick")
				if math.random()>0.999 then
					self:VariantPose(table.Random({"pstand","pstand2"}),math.random(5,20))
				elseif math.random()>0.95 then 
					local nodes = GetNodesInRadius(parent,pos,20/sz)
					if nodes then
						local actors = {}
						local hasactors = false
						for k,v in pairs(nodes) do
							if v:GetClass()=='base_actor' and v~=actor then
								actors[#actors+1] = v
								hasactors = true
							end
						end
						if hasactors and math.random()>0.3 then
							actor:SendEvent(EVENT_LERP_HEAD,table.Random(actors))
						else
							actor:SendEvent(EVENT_LERP_HEAD,table.Random(nodes))
						end
					end
				elseif self.cansit and math.random()>0.999 then
					self:VariantSit(10)
				end
				--if self:VariantUnequipItem('uniform_1') then return nil end
				--if self:VariantUnequipItem('legw')then return nil end
				--if self:VariantUnequipItem('armw')then return nil end
				--if self:VariantUnequipItem('collar')then return nil end
				--if actor:GetCharacter()~='vikna' then
				--	if self:VariantBuyItems(nav,pos_from,sz,'apparel.disg_vikna')then return nil end
				--end
				--if self:VariantBuyItems(nav,pos_from,sz,'apparel.uniform_0')then return nil end
				--if self:VariantBuyItems(nav,pos_from,sz,'apparel.cape_0')then return nil end
				--if self:VariantBuyItems(nav,pos_from,sz,'apparel.scarf_0')then return nil end

				--self:VariantUseSomething(parent,nav,pos,sz)
			end
		end
	end
end
function task:UpdateSenses(actor)
	--MsgN(actor,"senses update")
	self.nodememory = self.nodememory or {}
	local nm = self.nodememory

	local parent = actor:GetParent()
	local sz = parent:GetSizepower()
	local pos = actor:GetPos()
	local nodes = GetNodesInRadius(parent,pos,10/sz)
	local apos = actor:GetAbsPos()
	local tb = {}
	for k,v in pairs(nodes) do
		if v~=actor and v.model then 
			local m = nm[v]
			local npos = v:GetAbsPos()
			if m then
				local diffpos = npos-m.pos
				m.pos = npos
				if diffpos:Length()>2 then
					tb[#tb+1] = v
				end
			else
				nm[v] = {pos = v:GetAbsPos()}
				tb[#tb+1] = v
			end 
			if npos:Distance(apos)<1 then
				return v
			end
		end
	end
	return table.Random(tb)
end
function task:SelectActivity(actor)
	local TASK = false 
	local need = self:HasNeed()
	if need then
		TASK = self:UpdateNeedTask(need) 
	end

	if not TASK and math.random()>0.999 then
		TASK = self:VariantPose(table.Random({"pstand","pstand2"}),math.random(5,20))
	end 

	local parent = actor:GetParent()
	local sz = parent:GetSizepower()
	local pos = actor:GetPos()

	if not TASK and math.random()>0.3 then 
		TASK = self:VariantLookAtRandom(parent,pos,sz)
	end

	if not TASK and self.cansit and math.random()>0.999 then
		TASK = self:VariantSit(math.random(10,120))
	end

	if not TASK then
		local nav = self:GetNav(actor)
		if nav then

			if false and math.random()>0.5 then
				--self:VariantUseSomething(parent,nav,pos,sz)
			elseif math.random()>0.5 then
				TASK = self:VariantWalk(nav,pos,sz)
			end
		end
	end

	if not TASK and self.cansit and math.random()>0.999 then
		TASK = self:VariantSit(math.random(10,120))
	end

	if not TASK and math.random()>0.5 then
		local rne = self:GetRandomEntity(actor,'base_actor')
		if rne then
			TASK = Task('follow',rne)
			TASK.Duration = math.random(24,120)
		end
	end

	if not TASK then
		TASK = Task('wait',math.random(2,10))
	end
	return TASK
end
function task:GetRandomEntity(actor,class)
	local parent = actor:GetParent()
	local sz = parent:GetSizepower()
	local pos = actor:GetPos()
	local nodes = GetNodesInRadius(parent,pos,20/sz)
	local tb = {}
	for k,v in pairs(nodes) do
		if (class==nil or v:GetClass()==class) and v~=actor then 
			tb[#tb+1] = v
		end
	end
	return table.Random(tb)
end
function task:VariantLookAtRandom(parent,pos,sz) 
	local nodes = GetNodesInRadius(parent,pos,20/sz)
	if nodes then
		local actors = {}
		local hasactors = false
		for k,v in pairs(nodes) do
			if v:GetClass()=='base_actor' and v~=actor then
				actors[#actors+1] = v
				hasactors = true
			end
		end
		local finaltarget = false
		if hasactors and math.random()>0.3 then
			finaltarget = table.Random(actors) 
		else
			finaltarget = table.Random(nodes)
		end
		if finaltarget then
			local duration = math.random(1,20)
			return Task("lookat",finaltarget,duration) 
		end
	end
end

function task:VariantUseSomething(parent,nav,pos_from,sz) 
	local actor = self.ent
	local ct = CurTime()
	local useableents = T(parent:GetChildren()):Where(function(k,n) 
		return n:HasTag(TAG_USEABLE) 
		and n ~= actor
		and actor:GetDistance(n) < 10 
		and (self.bannedents[n] or 0) < ct
	end)
	if #useableents>0 then
		local target = table.Random(useableents)

		local path = nav:GetPath(pos_from,target:GetPos(),0.001)
		if path then
			MsgN("VariantUseSomething",target)
			self.bannedents[target] = ct+60
			self.taskstart = ct
			self.movetask = Task("moveto",target,1.5,false)
			self.movetask:Next(Task(function(TASK) 
				USE(TASK.ent) 
				if target:HasTag(TAG_SELECTION_MENU) and target.GetOptions then
					local opt = target:GetOptions()
					if opt then
						local randopt = table.Random(opt)
						if randopt then
							target:SendEvent(EVENT_SELECT_OPTION,TASK.ent,randopt)
						end
					end
					USE(TASK.ent)--close menu
				end
				
				return true 
			
			end))
			self.manager:Begin(self.movetask)
		end
	end 
end
function task:VariantWalk(nav,pos_from,sz)
	local nnode = nav:GetNode()
	local lpos = nnode:GetLocalCoordinates(self.ent)
	local ptp = nav:GetPointsInRadius(lpos,1000) 
	
	--MsgN("VariantWalk",ptp)
	if ptp then  
		local target = table.Random(ptp)
		if target then
			local tpos = self.ent:GetParent():GetLocalCoordinates(nnode,target)
			local path = nav:GetPath(lpos,tpos,0.001)
			if path then
				MsgN("VariantWalk",tpos)
				self.taskstart = CurTime()
				return Task("moveto",tpos,self.mindist,false) 
			end
		end
	end
end
function task:VariantBuyItems(nav,pos_from,sz,itemname)
	local actor = self.ent
	if actor.storage then
		if actor:HasItem(itemname) then
			return true
		end
	end
	local parent = actor:GetParent()
	local ct = CurTime()
	local useableents = T(parent:GetChildren()):Where(function(k,n)  return n:HasTag(TAG_USEABLE) and n.usetype == "apparel spawner"end)
	if #useableents>0 then
		MsgN("Vendor",useableents[1]) 
		self.taskstart = ct
		self.movetask = Task("moveto",useableents[1]:GetPos(),1.5,false)
		self.movetask:Next(Task(function(T)  USE(T.ent)  return true   end))
			:Next(Task('wait',4))
			:Next(Task(function(T)  T.ent:Give(itemname) return true   end))
			:Next(Task('wait',1))
			:Next(Task(function(T)  USE(T.ent)  return true   end))
		self.manager:Begin(self.movetask)
	end
end
function task:VariantUnequipItem(itemname)
	local actor = self.ent
	if actor.equipment then
		local p = forms.GetForm("apparel",itemname) or forms.GetForm(itemname)
		local item = actor.equipment:HasItem(p)
		if item then
			local slot = item:Read("/parameters/slot") or false 
			if slot then
				actor:SendEvent(EVENT_UNEQUIPSLOT,slot)
				return true
			end
		end 
	end
end
function task:VariantPose(name,duration)
	local actor = self.ent
	local T = Task({
		slot = 'misc_task',
		Duration = duration,
		OnBegin = function ()
			return actor.is_posing and actor:GestureToggle(44, name)
		end,
		OnEnd = function()
			actor:GestureToggle(44, name)
			actor.is_posing = false
			return true
		end
	})
	return T
	--if not actor.is_posing and actor:GestureToggle(44, name) then
	--	actor.is_posing = true
	--	debug.Delayed(1000*duration,function ()
	--		actor:GestureToggle(44, name)
	--		actor.is_posing = false
	--	end)
	--end
end
function task:VariantSit(duration)
	local actor = self.ent
	if actor.IsInVehicle then return end
	local topk = 'fatigue'
	local tar = self:FindNearestRepl(topk)
	if tar then
		local T = Task("moveto",tar, 1.5,false)
		T:Next(Task(function(T) 
			Interact(actor,tar,'sit') 
			return true 
		end))
		T:Next(Task('wait',duration or 10))
		T:Next(Task(function(T) 
			actor:SendEvent(EVENT_EXIT_VEHICLE)
			return true 
		end))
		return T
	else
		--actor:Say("*faints*")
		MsgN(actor,'is unable to find chair') 
	end
end
function task:OnEnd(result)
	
end 