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
	self.light = light
	
	self:AddEventListener(EVENT_USE,"use_event",function(user)
		MsgN(self," is used by aaa: ",user)
		local h, p = self:SearchTeleportLocation()
		if h then
			user:SetParent(p)
			user:SetPos(h)
			user.Recall = function(ent)
				ent:SetParent(self:GetParent())
				ent:SetPos(self:GetPos())
			end
		end
	end)
	self:AddFlag(FLAG_USEABLE)
	
	
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