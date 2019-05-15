--AddCSLuaFile()

--AbilitiesList =  {}--AbilitiesList or
local AB = {}
 
--props:
--type (self,target)
--dispelDelay 
--thinkDelay  
--cooldownDelay
--
--functions:
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
			ent.activeAbilities = ent.activeAbilities or {}
			--self.id = #ent.meffects
			ent.activeAbilities[self._name] = self 
			         
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
			if (  self.dispelDelay and self.dispelDelay>0) then
				--self.did = "dispel".. tostring(math.random( 1, 99999 ))
				
				self.task_dispel = debug.Delayed(self.dispelDelay*1000,function()
					self:Dispel()
					MsgN("disp del")
				end)
			end
			hook.Call("ability.cast",self,ent)
			return true
		end
	end
	return false
end  
function AB:Dispel()
	local ent = self.target
	--timer.Destroy(self.tid)
	--timer.Destroy(self.did)
	if self.task_dispel then self.task_dispel:Stop() end
	if self.task_think then self.task_think:Stop() end
	if self.End then self:End(ent) end
	ent.activeAbilities[self._name] = nil 
	--MsgN("dispelled") 
end
function AB:Ready()
	self.nextcast = self.nextcast or 0
	return ( self.Begin and self.nextcast<CurTime())
end
function AB:CastAnimation(ent) 
	ent.abilityanim = self.animation
	--ent.graph:SetState("ability") 
end
 
local ab_class = DefineClass("Ability","ability","lua/env.global/world/abilities/",AB)
    
function Ability(type) 
	local path = "forms/abilities/"..type..".json"
	if file.Exists(path) then
		local data = json.Read(path)
		if data and data.archetype then
			data.id = type
			local archetype = ab_class:Create(data.archetype)
			if archetype then
				for k,v in pairs(data) do
					archetype[k] = v
				end 
				if archetype.OnLoad then archetype:OnLoad() end
				return archetype
			end 
		end 
	end
	return ab_class:Create(type)
end 
      
function isability(obj)
	return ab_class:IsBelongs(obj)
end
            
debug.AddAPIInfo("/userclass/Ability",{
	Cast={_type="function",_arguments={{_name="caster",_valuetype="Entity"}},_returns={{_name="successful",_valuetype="boolean"}}},
	Dispel={_type="function"},
	Ready={_type="function"},
	CastAnimation={_type="function",_arguments={{_name="caster",_valuetype="Entity"}}},
})