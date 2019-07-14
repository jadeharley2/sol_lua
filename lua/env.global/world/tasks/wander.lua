

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
function task:UpdateNeeds() 
	local actor = self.ent
	local n = actor.needs
	if n then 
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
function task:UpdateNeedsTask(n)
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
			--PrintTable(n)
			local need = n[topk]
			
			local tar = self:FindNearestRepl(topk)
			if tar then
				local replenish = need.replenishaction
				--actor:Say("sit")
				local rez = tar.needs.delta.fatigue
				self.taskstart = CurTime()
				self.movetask = Task("moveto",tar,replenish.range or 1.5,false)
				self.movetask:Next(Task(function(T) 
					need.value=0
					if replenish.use then USE(T.ent) end 
					return true 
				end))
				:Next(Task('wait',replenish.time))
				self.manager:Begin(self.movetask)
				return true
			else
				--actor:Say("*faints*")
				MsgN(actor,'is unable to find source for',topk)
				need.value=0
			end


			--[[
			if topk=='fatigue' then
				local tar = self:FindNearestRepl('fatigue')
				if tar then
					--actor:Say("sit")
					local rez = tar.needs.delta.fatigue
					self.taskstart = CurTime()
					self.movetask = Task("moveto",tar,1.5,false)
					self.movetask:Next(Task(function(T) n.fatigue = 0 USE(T.ent) return true end))
					self.manager:Begin(self.movetask)
					return true
				else
					--actor:Say("*faints*")
					n.fatigue=0
				end
			elseif topk=='sleep' then
				local tar, rez = self:FindNearestRepl('sleep')
				if tar then
					--actor:Say("sleep")
					local rez = tar.needs.delta.sleep
					self.taskstart = CurTime()
					self.movetask = Task("moveto",tar,1.5,false)
					self.movetask:Next(Task(function(T) n.sleep = 0 USE(T.ent) return true end))
					self.manager:Begin(self.movetask)
					return true
				else
					--actor:Say("i need a bed")
					n.sleep =0
				end
			elseif topk=='hunger' then
				local tar, rez = self:FindNearestRepl('hunger')
				if tar then
					--actor:Say("hunger")
					--local rez = tar.needs.delta.sleep
					self.taskstart = CurTime()
					self.movetask = Task("moveto",tar,1,false)
					self.movetask:Next(Task(function(T) n.hunger = 0 return true end))
					self.manager:Begin(self.movetask)
					return true
				else
					--actor:Say("i need to eat")
					n.hunger =0
				end
			elseif topk=='thirst' then
				local tar, rez = self:FindNearestRepl('thirst')
				if tar then
					--actor:Say("thirst")
					--local rez = tar.needs.delta.sleep
					self.taskstart = CurTime()
					self.movetask = Task("moveto",tar,1,false)
					self.movetask:Next(Task(function(T) n.thirst = 0 return true end))
					self.manager:Begin(self.movetask)
					return true
				else
					--actor:Say("i need water")
					n.thirst =0
				end
			elseif topk=='entertainment' then
				local tar, rez = self:FindNearestRepl('entertainment')
				if tar then
					--actor:Say("fun")
					--local rez = tar.needs.delta.sleep
					self.taskstart = CurTime()
					self.movetask = Task("moveto",tar,2,false)
					self.movetask:Next(Task(function(T) n.entertainment = 0 return true end))
					self.manager:Begin(self.movetask)
					return true
				else
					--actor:Say("i need entertainment")
					n.thirst =0
				end
			elseif topk=='social' then
				local tar, rez = self:FindNearestRepl('social')
				if tar then
					--actor:Say("social")
					--local rez = tar.needs.delta.sleep
					self.taskstart = CurTime()
					self.movetask = Task("moveto",tar,2,false)
					self.movetask:Next(Task(function(T) n.social = 0 return true end))
					self.manager:Begin(self.movetask)
					return true
				else
					--actor:Say("i need to talk")
					n.thirst =0
				end
			end
			]]
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
function task:Step()   
	local movetask = self.movetask
	local sttime = self.taskstart or 0
	local actor = self.ent

	self:UpdateNeeds()

	if not movetask or sttime+self.delaytime<CurTime() then 

		--MsgN("wan")
		local n,nav = actor:GetParentWithComponent(CTYPE_NAVIGATION)
		if nav then
			local parent = actor:GetParent()
			local sz = parent:GetSizepower()
			local pos = actor:GetPos()

			if(actor.IsInVehicle) then
				actor:SendEvent(EVENT_EXIT_VEHICLE) 
			end 
			if not self:UpdateNeedsTask(actor.needs) then
			--
				if math.random()>0.5 then
					self:VariantUseSomething(parent,nav,pos,sz)
				else
					self:VariantWalk(nav,pos,sz)
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
			self.movetask:Next(Task(function(T) 
				USE(T.ent) 
				if target:HasTag(TAG_SELECTION_MENU) and target.GetOptions then
					local opt = target:GetOptions()
					if opt then
						local randopt = table.Random(opt)
						if randopt then
							target:SendEvent(EVENT_SELECT_OPTION,T.ent,randopt)
						end
					end
					USE(T.ent)--close menu
				end
				
				return true 
			
			end))
			self.manager:Begin(self.movetask)
		end
	end 
end
function task:VariantWalk(nav,pos_from,sz)
	local ptp = nav:GetPointsInRadius(pos_from,10/sz)
	if ptp then 
		local target = table.Random(ptp)
		if target then
			local path = nav:GetPath(pos_from,target,0.001)
			if path then
				MsgN("VariantWalk",target)
				self.taskstart = CurTime()
				self.movetask = Task("moveto",target,self.mindist,false)
				self.manager:Begin(self.movetask)
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
function task:OnEnd(result)
	
end 