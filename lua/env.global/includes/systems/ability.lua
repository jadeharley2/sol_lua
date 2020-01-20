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

			local cooldown = self.cooldown or self.cooldownDelay 
			if cooldown then
				self.nextcast = CurTime()+cooldown
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
	ent.graph:SetState("ability") 
end
function AB:ApplyEffects(caster,target,pos)

	local result = false
	for k,v in pairs(self.effects) do
		local eff = Effect(v.effect or k,v)
		if eff then
			if eff.targeton=='caster' then
				result = eff:Start(caster,caster,pos) 
			else
				result = eff:Start(caster,target,pos) 
			end
		end 
		--if not result then return false end
	end
	return true 
end
function AB:ApplyVisuals(caster,target,pos)
	if self.viseffects then
		local cparent = caster:GetParent()
		local parent = target:GetParent()
		for k,v in pairs(self.viseffects) do
			if v.effect=='particle' then
				if v.target == 'caster' then
					SpawnParticles(cparent,v.type,caster:GetPos(),v.time,v.size,v.speed)
				else --if v.target == 'target' then 
					SpawnParticles(parent,v.type,pos,v.time,v.size,v.speed)
				end 
			elseif v.effect=='sound' then
				if v.target == 'caster' then
					caster:EmitSound(v.path, v.volume or 1, v.pitch or 1)
				else --if v.target == 'target' then 
					target:EmitSound(v.path, v.volume or 1, v.pitch or 1)
				end 
			end
		end
	end
end
 
local ab_class = DefineClass("Ability","ability","lua/env.global/world/abilities/",AB)
    
function Ability(type) 
	local abform = forms.GetForm("ability."..type)

	--local path = "forms/abilities/"..type..".json"
	if abform then --file.Exists(path) then
		local data = forms.ReadForm('ability.'..type)-- json.Read(path)
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