
DeclareEnumValue("event","DAMAGE",					321001) 
DeclareEnumValue("event","HEALTH_CHANGED",			321002) 
DeclareEnumValue("event","MAXHEALTH_CHANGED",		321003) 
DeclareEnumValue("event","DEATH",					321004) 
DeclareEnumValue("event","RESPAWN",					321005) 


component.uid = DeclareEnumValue("CTYPE","HEALTH", 3414)

function component:GetHealth()
	return self:GetNode():GetParameter(VARTYPE_HEALTH)
end
function component:SetHealth(val) 
	self:GetNode():SendEvent(EVENT_HEALTH_CHANGED,val)
end

function component:GetMaxHealth()
	return self:GetNode():GetParameter(VARTYPE_MAXHEALTH)
end
function component:SetMaxHealth(val) 
	self:GetNode():SendEvent(EVENT_MAXHEALTH_CHANGED,val)
end

function component:GetHealthPercentage()
	local n = self:GetNode()
	return n:GetParameter(VARTYPE_HEALTH) / n:GetParameter(VARTYPE_MAXHEALTH)
end

function component:SetHealthPercentage(pc) 
	local n = self:GetNode()
	n:SendEvent(EVENT_HEALTH_CHANGED, pc*n:GetParameter(VARTYPE_MAXHEALTH))
end

function component:Hurt(amount) 
	n:SendEvent(EVENT_DAMAGE,amount)
end

function component:Kill()  
	self:GetNode():SendEvent(EVENT_DEATH)
end
function component:Respawn()  
	self:GetNode():SendEvent(EVENT_SPAWN)
end

function component:IsAlive()
	return not self:GetNode()._dead
end

function component:IsDead()
	return self:GetNode()._dead == true
end


function component:OnAttach(node)
	node:RegisterComponent(self)   
end
function component:OnDetach(node)
	node:UnregisterComponent(self)   
end

component.editor = {
	name = "Health",
	properties = {
		amount = {text = "amount",type="parameter",valtype="number",key=VARTYPE_HEALTH},
		max_amount = {text = "maximum amount",type="parameter",valtype="number",key=VARTYPE_MAXHEALTH},  
	},
	
}
component._typeevents = { 
	[EVENT_DAMAGE] = {networked = true, f = function(self,amount) 
		local node = self:GetNode()
		if SERVER or not network.IsConnected() then 
			local hp = node:GetParameter(VARTYPE_HEALTH) 
			hp = hp - amount 
			node:SetParameter(VARTYPE_HEALTH,hp)
			node:SetHealth(hp)  
			if hp <= 0 then node:SendEvent(EVENT_DEATH) end  
		end 
	end},
	[EVENT_HEALTH_CHANGED] = {networked = true, f = function(self,val) 
		self:GetNode():SetParameter(VARTYPE_HEALTH,val)   
	end},
	[EVENT_MAXHEALTH_CHANGED] = {networked = true, f = function(self,val) 
		self:GetNode():SetParameter(VARTYPE_MAXHEALTH,val) 
	end},
	[EVENT_DEATH] = {networked = true, f = function(self) 
		local node = self:GetNode()
		node:SetParameter(VARTYPE_HEALTH,0)  
		node._dead = true  
		MsgN(node,"died")
	end},
	[EVENT_SPAWN] = {networked = true, f = function(self) 
		local node = self:GetNode()
		local hp = node:GetParameter(VARTYPE_MAXHEALTH)
		node:SetParameter(VARTYPE_HEALTH,hp)  
		node._dead = nil 
		MsgN(node,"revived with",hp,"hp")
	end},
}
COMRegFunctions(component,{
	IsAlive = function(node) return not node._dead end,
	IsDead = function(node) return node._dead end,
	Kill = function(node) 
		node:SendEvent(EVENT_DEATH) 
	end,
	Respawn = function(node) 
		node:SendEvent(EVENT_SPAWN) 
	end,
	Hurt = function(node,amount) 
		node:SendEvent(EVENT_DAMAGE,amount) 
	end,
	GetHealth = function(node) 
		return node:GetParameter(VARTYPE_HEALTH)  
	end,
	SetHealth = function(node,val) 
		node:SendEvent(EVENT_HEALTH_CHANGED,val) 
	end,
	GetMaxHealth = function(node) 
		return node:GetParameter(VARTYPE_MAXHEALTH) 
	end,
	SetMaxHealth = function(node,val) 
		node:SendEvent(EVENT_MAXHEALTH_CHANGED,val) 
	end, 
	GetHealthPercentage = function(node) 
		return node:GetParameter(VARTYPE_HEALTH) / node:GetParameter(VARTYPE_MAXHEALTH)
	end, 
	SetHealthPercentage = function(node,pc)  
		node:SendEvent(EVENT_HEALTH_CHANGED, pc*node:GetParameter(VARTYPE_MAXHEALTH))
	end,
})
 
 

