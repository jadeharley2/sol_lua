--AddCSLuaFile()

DeclareVartype("STATUSEFFECTS",84321,"json","active effects data")


--AbilitiesList =  {}--AbilitiesList or
local EF = {}

--props:
--type (self,target)
--dispelDelay
--thinkDelay  
--cooldownDelay 
--
--funcs:
--self:Start(ent) - returns if effect can be applied
--self:Think(ent)
--self:End(ent)

function EF:OnLoad()
end 
function EF:Start(source,target,position) 
	if not self._type then 
		return false
	end
	self._source = source
	self._target = target
	if self:Begin(source,target,position) then 
		if(not self.singlecast)then 
			self._casttime = CurTime()
			target._active_effects = target._active_effects or {}
			target._active_effects[self._type] = self
			if self.Think then
				self.task_think = debug.DelayedTimer(0,(self.thinkDelay or 1)*1000,-1, function() 
					if not self:Think(target) then 
						self:Dispel()
					end
				end)
			end
			if (self.dispelDelay and self.dispelDelay>0) then 
				self.task_dispel = debug.Delayed(self.dispelDelay*1000,function()
					self:Dispel() 
				end)
			end
		end
		hook.Call("effect.cast",self,target)
	end
end 
function EF:Dispell()  
	local target = self._target
	if self.End then
		self:End(self._source,target)
	end
	target._active_effects = target._active_effects or {}
	target._active_effects[self._type] = nil
	hook.Call("effect.end",self,target)
end 

EF.Dispel = EF.Dispell
function EF:TimeLeft()
	if self._casttime and self.dispelDelay then
		return (self._casttime+self.dispelDelay)-CurTime()
	else
		return -1
	end
end

local ef_class = DefineClass("Effect","effect","lua/env.global/world/effects/",EF)
      
function Effect(ftype,modtable) 
	local path = "forms/effects/"..ftype..".json"
	if file.Exists(path) then
		local data = json.Read(path)
		if data and data.archetype then
			data.id = ftype
			local archetype = ef_class:Create(data.archetype)
			if archetype then
				for k,v in pairs(data) do
					archetype[k] = v
				end 
				if modtable then
					for k,v in pairs(modtable) do
						archetype[k] = v
					end
				end
				archetype._type = ftype
				if archetype.OnLoad then archetype:OnLoad() end
				return archetype
			end 
		end 
	end 
	return ef_class:Create(type)
end 

function ApplyEffect(source,target,ftype)
	local eff = Effect(ftype)
	if eff then
		ace = target._active_effects or {}
		target._active_effects = ace
		
		if ace[ftype] then
			ace[ftype]:Dispell()
			ace[ftype] = nil
		end	

		if eff:Start(source,target) then
			ace[ftype] = eff 
		end
	end
end

function GetEffect(node,type)
	if IsValidEnt(node) then
		ace = node._active_effects
		if ace then
			return ace[type]
		end
	end
end
function GetEffects(node,type)
	if IsValidEnt(node) then
		return node._active_effects or {}
	end
	return {}
end
	
	
 
DeclareEnumValue("event","EFFECT_BEGIN",				334201) 
DeclareEnumValue("event","EFFECT_END",					334201) 


local _metaevents = debug.getregistry().Entity._metaevents 

_metaevents[EVENT_EFFECT_BEGIN] = {networked = true, f = function(self,effect_name) 
	ApplyEffect(self,effect_name)
end}
_metaevents[EVENT_EFFECT_END] = {networked = true, f = function(self,effect_name) 

end}