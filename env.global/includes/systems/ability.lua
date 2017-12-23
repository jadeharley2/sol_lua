--AddCSLuaFile()

--AbilitiesList =  {}--AbilitiesList or
local AB = {}
 
--props:
--type (self,target)
--dispellDelay 
--thinkDelay  
--cooldownDelay
--
--funcs:
--self:Begin(ent, trace) - returns if effect is can be applied
--self:Think(ent)
--self:End(ent)
 
function AB:Cast(ent) 
	self.nextcast = self.nextcast or 0
	if self.Begin and self.nextcast<CurTime() then
		--local trace = ent:GetEyeTrace()--= 0
		--if self.type == "target" or  self.type == "projectile" then 
		--trace = 
		  
		--end   
               
		if self:Begin(ent,trace) then
			MsgN("cast")
			MsgN(self.Think)
			ent.meffects = ent.meffects or {}
			self.id = #ent.meffects
			ent.meffects[self.id ] = self 
			         
			self.target = ent
			if self.cooldownDelay then
				self.nextcast = CurTime()+self.cooldownDelay
			end   
			if self.Think then
				self.task_think = debug.DelayedTimer(0,(self.thinkDelay or 1)*1000,-1, function()
					--MsgN("think") 
					if not self:Think(ent) then
						self.task:Stop()
					end
				end)
			end
			if (  self.dispellDelay and self.dispellDelay>0) then
				--self.did = "dispell".. tostring(math.random( 1, 99999 ))
				
				self.task_dispell = debug.Delayed(self.dispellDelay*1000,function()
					self:Dispell()
					MsgN("disp del")
				end)
			end
			hook.Call("ability.cast",self,ent)
			return true
		end
	end
	return false
end  
function AB:Dispell()
	local ent = self.target
	--timer.Destroy(self.tid)
	--timer.Destroy(self.did)
	if self.task_dispell then self.task_dispell:Stop() end
	if self.task_think then self.task_think:Stop() end
	if self.End then self:End(ent) end
	ent.meffects[self.id] = nil
	--MsgN("dispelled") 
end
function AB:Ready()
	self.nextcast = self.nextcast or 0
	return ( self.Begin and self.nextcast<CurTime())
end
function AB:CastAnimation(ent) 
	ent.abilityanim = self.animation
	ent.graph:SetState("ability") 
end
 
local ab_class = DefineClass("Ability","ability","lua/env.global/world/abilities/",AB)
    
function Ability(type) 
	return ab_class:Create(type)
end 

function isability(obj)
	return ab_class:IsBelongs(obj)
end
  