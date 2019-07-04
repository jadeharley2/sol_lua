--AddCSLuaFile()
behaviour = behaviour or {} 
behaviour.predef_func = behaviour.predef_func or {}
behaviour.predef_cond = behaviour.predef_cond or {}
function behaviour.AddFunction(key,value)
	behaviour.predef_func[key] = value
end
function behaviour.AddCondition(key,value)
	behaviour.predef_cond[key] = value
end


local BehaviorGraphMeta =  DEFINE_METATABLE("BehaviorGraph")-- BehaviorGraphMeta or {} 

function BEH_CND_EQUIPPED(s,e,tag) local w = e:GetActiveWeapon() if w then return w.type == tag else return false end end
function BEH_CND_NOTEQUIPPED(s,e,tag) local w = e:GetActiveWeapon() if w then return w.type ~= tag else return true end end

function BEH_CND_DELAY(s,e,tag) return tag end
function BEH_CND_ALWAYS(s,e) return true end
function BEH_CND_NEVER(s,e) return false end
function BEH_CND_ONEND(s,e) return s.anim_end < CurTime()   end
function BEH_CND_ONREQ(s,e) return false end
function BEH_CND_ONCALL(s,e,value) return false end
function BEH_CND_ONRND(s,e,tag) if tag then return (math.random(0,1000000)/1000000)>tag end return false end
function BEH_CND_KEYDOWN(s,e,tag) if tag then return e:KeyDown(tag) end return false end

function BEH_CND_ONGROUND(s,e) local p = e.phys if p then return p:OnGround() else return true end end
function BEH_CND_NOTONGROUND(s,e) local p = e.phys if p then return not p:OnGround() else return false end end
		
behaviour.AddCondition("delay",				BEH_CND_DELAY)
behaviour.AddCondition("anim.end",			BEH_CND_ONEND)
behaviour.AddCondition("request",			BEH_CND_ONREQ)
behaviour.AddCondition("call",				BEH_CND_ONCALL)
behaviour.AddCondition("always",			BEH_CND_ALWAYS)
behaviour.AddCondition("never",				BEH_CND_NEVER)
behaviour.AddCondition("keydown",			BEH_CND_KEYDOWN) 
behaviour.AddCondition("onground",			BEH_CND_ONGROUND)
behaviour.AddCondition("notonground",		BEH_CND_NOTONGROUND)
behaviour.AddCondition("equipped",			BEH_CND_EQUIPPED)
behaviour.AddCondition("notequipped",		BEH_CND_NOTEQUIPPED)
 
behaviour.AddFunction("anim.set",function(state,ent,to,tag) 
	if tag then local m = ent.model 
		if m then 
			if istable(tag) then
				return m:SetAnimation(table.Random(tag)) 
			else
				return m:SetAnimation(tag) 
			end
		end 
	end 
end)
behaviour.AddFunction("anim.set.ns",function(state,ent,to,tag) 
	if tag then local m = ent.model 
		if m then 
			if istable(tag) then
				return m:SetAnimation(table.Random(tag),true) 
			else
				return m:SetAnimation(tag,true) 
			end
		end 
	end 
end)
behaviour.AddFunction("anim.reset",function(state,ent,to,tag) 
	if tag then local m = ent.model 
		if m then 
			if istable(tag) then
				return m:ResetAnimation(table.Random(tag)) 
			else
				return m:ResetAnimation(tag) 
			end
		end 
	end 
end)
behaviour.AddFunction("anim.reset.ns",function(state,ent,to,tag) 
	if tag then local m = ent.model 
		if m then 
			if istable(tag) then
				return m:ResetAnimation(table.Random(tag),true) 
			else
				return m:ResetAnimation(tag,true) 
			end
		end 
	end 
end)
behaviour.AddFunction("anim.layer.play",function(state,ent,to,tag) 
	if tag then 
		id = tag[1] or 1
		local seq = tag[2]
		local m = ent.model 
		if seq and m then 
			if istable(seq) then
				m:PlayLayeredSequence(id,table.Random(seq)) 
			else
				m:PlayLayeredSequence(id,seq) 
			end
		end 
	end 
	return 0 
end)
behaviour.AddFunction("anim.layer.stop",function(state,ent,to,tag) 
	if tag then   
		local m = ent.model 
		if m then 
			m:StopLayeredSequence(tag) 
		end 
	end 
	return 0 
end)
behaviour.AddFunction("sound.play",function(state,ent,to,tag) 
	if tag then   
		if istable(tag) then
			return ent:EmitSound(table.Random(tag),1,1) 
		else
			return ent:EmitSound(tag ,1,1) 
		end 
	end 
end)
behaviour.AddFunction("jump",function(state,ent,to,tag) 
	ent:Jump()
end)
behaviour.AddFunction("vehicle_exit",function(state,ent,to,tag) 
	ent:SetVehicle() 
end)
behaviour.AddFunction("ecall",function(state,ent,to,tag) 
	--MsgN("aaa",state,ent,to,unpack(tag))
	local f = ent[tag[1]] 
	if f then  
		local args = {}     
		for k,v in ipairs(tag) do
			args[k] = v  
		end
		args[1] = ent  
		pcall(f,unpack(args))
	end 
end) 
behaviour.AddFunction("call",function(state,ent,to,tag)  
	--MsgN("aaa",state,ent,to,unpack(tag))            
	local f = _G[tag[1]]                
	if f then  
		local args = {}     
		for k,v in ipairs(tag) do
			args[k-1] = v  
		end
		args[0] = nil 
		f(unpack(args))   
	end 
end) 
behaviour.AddFunction("setvar",function(state,ent,to,tag)  
	local key = tag[1]
	local value = tag[2]
	ent[key] = value  
end)  
	
function BehaviorGraphMeta:Run() 
	if self.disabled~=true then
		for k,v in pairs(self._cstate.transitions) do  
			if v[2] then
				if v[2](self,self._ent,v[3]) then   
					if istable(v[1]) then
						local rnd = (math.random(0,10000000)/10000000) 
						local cu = 0
						for kk,vv in pairs(v[1]) do
							cu = cu + vv
							--MsgN(cu,rnd)
							if(cu>rnd) then return self:SetState(kk) end
						end
					else
						return self:SetState(v[1]) 
					end
				end
			else
				self.anim_end = 0
				return self:SetState(v[1])  
			end 
		end
	end
end

function BehaviorGraphMeta:NewTwoWayTransition(s1name,s2name,funccond)
	self:NewTransition(s1name,s2name,funccond)
	self:NewTransition(s2name,s1name,funccond)
end
 
function BehaviorGraphMeta:NewTransition(s1name,s2name,funccond,tag)
	local a1 = self.groups[s1name] 
	if a1 then
		for k,v in pairs(a1.states) do 
			self:NewTransition(v,s2name,funccond,tag) 
		end
	else 
		local s1 = self.states[s1name] 
		if not s1 then MsgN("Warning state not found: "..s1name)
		else	
			s1.transitions[#s1.transitions+1] = {s2name,funccond,tag}
		end
	end
end 
function BehaviorGraphMeta:NewState(name,onEnter,onExit,tag)
	self.states[name] = {
		name = name,
		enter = onEnter,  
		exit = onExit,
		tag = tag,
		transitions = {}
	}
end
function BehaviorGraphMeta:NewGroup(name,aliasedStates)
	local g_states = {}
	for k,v in pairs(aliasedStates) do
		local g = self.groups[v]
		if g then
			for kk,vv in pairs(g.states) do
				g_states[#g_states+1] = vv
			end
		else
			g_states[#g_states+1] = v
		end
	end
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
	if to and from then
		--if self.debug then MsgN("TrySetState from, to: ",from.name," => ",to.name) end 
		for k,v in pairs(from.transitions) do
			if v[1]==name and v[2] == BEH_CND_ONREQ then
				self:SetState(name)
				return true
			end
		end
	end
	if self.debug then
		local mn = from if from then mn = from.name end
		local md = to if to then md = to.name end
		--MsgN("TrySetState failed, no ONREQ transition found, to, from: ",mn," => ",md,"(",name,")") 
	end
	return false
end
function BehaviorGraphMeta:Call(value)
	local from = self._cstate 
	 
	if from then
		for k,v in pairs(from.transitions) do
			if v[2] == BEH_CND_ONCALL and v[3]==value then
				self:SetState(v[1])
				return true
			end
		end
	end
	if self.debug then
		--MsgN("TrySetState failed, no ONREQ transition found, to, from: ",mn," => ",md,"(",name,")") 
	end
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
			self.anim_end = CurTime() + ( self._cstate.enter(self,ent,from,to.tag) or 0.5 )
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
		if self.debug then MsgN(ent," loaded state ", state) end
	end
end
function BehaviorGraphMeta:CurrentState()
	return self._cstate.name
end
	     
BehaviorGraphMeta.__index = BehaviorGraphMeta
local function FunctionGet(value,funcdict) --behaviour.predef_func
	if istable(value) then
		local functable = {}
		for kk,vv in pairs(value) do
			functable[kk] = funcdict[vv] 
		end
		return ConcatFunc(functable) 
	else
		return funcdict[value] 
	end
end

function BehaviorGraph(ent,tab)
	--MsgN("New graph on: "..tostring(ent))
	local t = 
	{
		_ent = ent, 
		states = {}, 
		groups = {},
		anim_end = 0,
	}
	t = setmetatable(t,BehaviorGraphMeta)
	if tab then
		for k,v in pairs(tab.states) do
			local pdf1 = FunctionGet(v[1], behaviour.predef_func)
			local pdf2 = FunctionGet(v[2], behaviour.predef_func) 
			t:NewState(k,pdf1,pdf2,v[3])
		end
		for k,v in pairs(tab.groups) do
			t:NewGroup(k,v)
		end
		for k,v in pairs(tab.links) do 
			local pdc = FunctionGet(v[3], behaviour.predef_cond)
			t:NewTransition(v[1],v[2],pdc,v[4]) 
		end
	end
	return t
end 
  


    