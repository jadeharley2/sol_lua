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
			ent.meffects = ent.meffects or {}
			self.id = #ent.meffects
			ent.meffects[self.id ] = self 
			self.tid = "think".. tostring(math.random( 1, 99999 ))
			self.target = ent
			if self.cooldownDelay then
				self.nextcast = CurTime()+self.cooldownDelay
			end
			if self.Think then
				timer.Create(self.tid,self.thinkDelay or 1,0, function()
					--MsgN("think")
					if not self:Think(ent) then
						timer.Destroy(self.tid)
					end
				end)
			end
			if (  self.dispellDelay and self.dispellDelay>0) then
				--self.did = "dispell".. tostring(math.random( 1, 99999 ))
				MsgN("disp del")
				debug.Delayed(self.dispellDelay*1000,function()
					self:Dispell()
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
  