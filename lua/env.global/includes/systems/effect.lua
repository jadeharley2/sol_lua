--AddCSLuaFile()

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
	self._source = source
	self._target = target
	if self:Begin(source,target,position) then 
		target._active_effects = target._active_effects or {}
		target._active_effects[self._type] = self
		if self.Think then
			self.task_think = debug.DelayedTimer(0,(self.thinkDelay or 1)*1000,-1, function() 
				if not self:Think(ent) then 
					self:Dispel()
				end
			end)
		end
		if (self.dispelDelay and self.dispelDelay>0) then 
			self.task_dispel = debug.Delayed(self.dispelDelay*1000,function()
				self:Dispel() 
			end)
		end
		hook.Call("effect.cast",self,ent)
	end
end 
function EF:Dispell()  
	local target = self._target
	self:End(self._source,target)
	target._active_effects = target._active_effects or {}
	target._active_effects[self._type] = nil
end 
EF.Dispel = EF.Dispell


local ef_class = DefineClass("Effect","effect","lua/env.global/world/effects/",EF)
    
function Effect(type) 
	local path = "forms/effects/"..type..".json"
	if file.Exists(path) then
		local data = json.Read(path)
		if data and data.archetype then
			data.id = type
			local archetype = ef_class:Create(data.archetype)
			if archetype then
				for k,v in pairs(data) do
					archetype[k] = v
				end 
				archetype._type = type
				if archetype.OnLoad then archetype:OnLoad() end
				return archetype
			end 
		end 
	end 
	return ef_class:Create(type)
end 

function ApplyEffect(source,target,type)
	local eff = Effect(type)
	if eff then
		ace = target._active_effects or {}
		target._active_effects = ace
		
		if ace[type] then
			ace[type]:Dispell()
			ace[type] = nil
		end	

		if eff:Start(source,target) then
			ace[type] = eff
		end
	end
end

function GetEffect(node,type)
	ace = node._active_effects
	if ace then
		return ace[type]
	end
end
	
 
DeclareEnumValue("event","EFFECT_BEGIN",				334201) 
DeclareEnumValue("event","EFFECT_END",					334201) 


local _metaevents = debug.getregistry().Entity._metaevents 

_metaevents[EVENT_EFFECT_BEGIN] = {networked = true, f = function(self,effect_name) 
	ApplyEffect(self,effect_name)
end}
_metaevents[EVENT_EFFECT_END] = {networked = true, f = function(self,effect_name) 

end}