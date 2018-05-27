--lua_run TEST_CGM(GetCamera():GetParent())
function CreateTeleporter(parent,pos)

	local m =  ents.Create("spaceship_teleporter")
	m:SetParent( parent)
	m:SetSizepower(0.76) 
	m:SetSpaceEnabled(false) 
	m:SetPos(pos) 
	m:Spawn()
	--GetCamera():SetParent(m.system)
	return m
end

function ENT:Init()  
end
function ENT:Spawn()
 
	
	
	 
	local light = self:AddComponent(CTYPE_LIGHT)  
	light:SetColor(Vector(0.1,0.2,0.9))
	light:SetBrightness(10) 
	light:Enable(false) 
	self.light = light
	 
	self:AddFlag(FLAG_USEABLE)
	self.enabled = true
	
	
	self:InitWire() 
end
function ENT:Load()
	self:InitWire()
end
function ENT:InitWire()
	local wio = Component("wireio",self)
	wio:AddInput("toggle",self.WInputs)
	wio:AddInput("on",self.WInputs)
	wio:AddInput("off",self.WInputs)
	
	wio:AddOutput("teleport_in")
	wio:AddOutput("teleport_out")
	wio:AddOutput("teleport_prepare")
	wio:AddOutput("teleport_stop")
end
 

function ENT:WInputs(f,k,v) 
	if k == "toggle" then self:Toggle()
	elseif k == "on" then self:TurnOn()
	elseif k == "off"then self:TurnOff() end 
end

function ENT:SearchTeleportLocation()
	local spaceship = self:GetParent()
	local pdt = spaceship:GetParent()
	--local planet = self:GetParentWithFlag(FLAG_PLANET) 
	local pdts = pdt:GetComponent(CTYPE_PHYSSPACE)
	if pdts then
		local sz = pdt:GetSizepower()
		local pos = spaceship:GetPos()
		local dir = -spaceship:Up()
		local hit, location, normal, distance = pdts:RayCast(pos,dir)
		MsgN("RCR: ",hit," l: ",location," n: ",normal," d: ",distance)
		return location + normal / sz * 5, pdt
	else
		MsgN("NO RCR!")
	end
end

function ENT:Toggle()
	local astate = self.enabled
	if astate then 
		astate = false
		self.enabled = false 
	else 
		astate = true 
		self.enabled = true
	end   
end
function ENT:TurnOff()
	self.enabled = false 
end
function ENT:TurnOn()
	self.enabled = true  
end
--prepare:2100ms 
--teleport:300ms
--cooldown:2000ms
function ENT:TeleportStartup(user,target_parent,target_pos,fast) 
	if not self.active or fast then
		self.active = true
		self.wireio:SetOutput("teleport_prepare") 
		if not fast and CLIENT then
			user:EmitSound("energy/or_engine.ogg",1)
		end
		local delay = 8100
		if fast then delay = 0 end
		debug.Delayed(delay,function() 
			self.light:Enable(true)  
			if CLIENT then
				user:EmitSound("events/teleport.ogg",1)
			end
			local delay2 = 100
			if fast then delay2 = 0 end
			debug.Delayed(delay2,function() 
				if target_parent then
					self:TeleportOut(user,target_parent,target_pos)
				else
					self:TeleportIn(user)
				end
				debug.Delayed(300,function() 
					self.light:Enable(false) 
					self.wireio:SetOutput("teleport_stop")
					self.active = false
				end)
			end)
		end)
	end
end

function ENT:TeleportOut(ent,parent,pos)
	ent:SetParent(parent)
	ent:SetPos(pos)
	self.wireio:SetOutput("teleport_out")
end
function ENT:TeleportIn(ent)
	ent:SetParent(self:GetParent())
	ent:SetPos(self:GetPos())
	self.wireio:SetOutput("teleport_in")
end


ENT._typeevents = {
	[EVENT_USE] = {networked = true, f = function(self,user) 
		if self.enabled then
			MsgN(self," is used by aaasa: ",user)
			local h, p = self:SearchTeleportLocation()
			if h then 
				user.Recall = function(ent) 
					if ent:GetParent() ~= self:GetParent() then
						self:TeleportStartup(ent) 
					end
				end
				
				self:TeleportStartup(user,p,h) 
			end
		end
	end},
} 
