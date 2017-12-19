--AddCSLuaFile()

local BehaviorGraphMeta = BehaviorGraphMeta or {}

function CND_ONEND(s,e) return s.anim_end < CurTime()   end
function CND_ONREQ(s,e) return false end
 
function BehaviorGraphMeta:Run() 
	for k,v in pairs(self._cstate.transitions) do  
		if v[2] then
			if v[2](self,self._ent) then   
				return self:SetState(v[1]) 
			end
		else
			self.anim_end = 0
			return self:SetState(v[1])  
		end 
	end
end
function BehaviorGraphMeta:NewTwoWayTransition(s1name,s2name,funccond)
	self:NewTransition(s1name,s2name,funccond)
	self:NewTransition(s2name,s1name,funccond)
end
function BehaviorGraphMeta:NewTransition(s1name,s2name,funccond)
	local a1 = self.groups[s1name] 
	if a1 then
		for k,v in pairs(a1.states) do 
			self:NewTransition(v,s2name,funccond) 
		end
	else 
		local s1 = self.states[s1name] 
		if not s1 then MsgN("Warning state not found: "..s1name) end 
		s1.transitions[#s1.transitions+1] = {s2name,funccond}
	end
end
function BehaviorGraphMeta:NewState(name,onEnter,onExit)
	self.states[name] = {
		name = name,
		enter = onEnter,  
		exit = onExit,
		transitions = {}
	}
end
function BehaviorGraphMeta:NewGroup(name,aliasedStates)
	self.groups[name] = {
		name = name,
		states = aliasedStates
	}
end
function BehaviorGraphMeta:TrySetState(name)
	local from = self._cstate
	local to = self.states[name]
	
	if to == from then 
		--if self.debug then MsgN("TrySetState failed, state equals, to == from: ",from.name," => ",to.name) end 
		return false 
	end
	if self.debug then MsgN("TrySetState from, to: ",from.name," => ",to.name) end 
	if to and from then
		for k,v in pairs(from.transitions) do
			if v[1]==name and v[2] == CND_ONREQ then
				self:SetState(name)
				return true
			end
		end
	end
	if self.debug then MsgN("TrySetState failed, no ONREQ transition found, to, from: ",from.name," => ",to.name) end
	return false
end
 
function BehaviorGraphMeta:SetState(name,donotwritestate)  
	local ent = self._ent
	local from = self._cstate
	local to = self.states[name] 
	if to then
		if self._cstate then
			if self._cstate.exit then
				self._cstate.exit(self,ent,to) 
			end
		end
		if self._cstate then
			from = self._cstate 
			if self.debug then MsgN("changing state: ",from.name," => ",to.name) end
		else
			if self.debug then MsgN("starting graph with state: ",to.name) end
		end 
		self._cstate = to
		if self._cstate.enter then 
			self.anim_end = CurTime() + ( self._cstate.enter(self,ent,from) or 0.5 )
		else
			self.anim_end = CurTime()
		end
		if not donotwritestate then
			ent:SetParameter(VARTYPE_STATE,name)
		end
		if self.callback then
			self:callback(ent,name)
		end
	else
		ErrorNoHalt("Unknown state: "..name)
	end
end
function BehaviorGraphMeta:LoadState(fallbackstate)
	local ent = self._ent
		if ent then
		local state = ent:GetParameter(VARTYPE_STATE)
		if state and state~="" then
			self:SetState(state)   
		elseif fallbackstate then 
			self:SetState(fallbackstate)
		end
		MsgN(ent," loaded state ", state)
	end
end
function BehaviorGraphMeta:CurrentState()
	return self._cstate.name
end
	     
BehaviorGraphMeta.__index = BehaviorGraphMeta

function BehaviorGraph(ent)
	MsgN("New graph on: "..tostring(ent))
	local t = 
	{
		_ent = ent, 
		states = {}, 
		groups = {},
		anim_end = 0,
	}
	return setmetatable(t,BehaviorGraphMeta)
end 
  


    