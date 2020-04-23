 

function PANEL:Init() 
	self:SetColor(Vector(0,0,0))
	
end 

function PANEL:Set(actor)
	self.actor = actor
	self:Clear()
	local asp = actor.species
	if asp then
		self:AddGroup("General")
		self:AddRecord("Name:", actor:GetName() or "unknown")
		self:AddRecord("Species:", asp.name or "unknown")
		self:AddRecord("Race:", asp.racename or "none")
	end
	self:AddGroup("Attributes")
	self:AddRecord("Strength:", 0) 
	self:AddRecord("Mass:", actor.phys:GetMass()*10 .. " kg") 
	self:AddRecord("Ground Speed:",tostring(actor.walkspeed).."-"..tostring(actor.runspeed)) 
	self:AddRecord("Flight Speed:", actor.flyspeed) 

	
	self:AddGroup("Active effects")
		
	local er = panel.Create()
	er:SetSize(10,20)
	er:Dock(DOCK_TOP)
	er:SetAutoSize(false,true)
	er:SetColor(Vector(0,0,0))
	self:Add(er)
	self.er = er
	hook.Add(EVENT_GLOBAL_UPDATE,"statuspanel",function ()
		self:UpdateEffects()
	end)
		
	self:UpdateLayout()

	--hook.Add("effect.cast","statuspanel",function (eff,actor)
	--	if(actor==LocalPlayer())then
	--		self:Set(actor)
	--	end
	--end)
	--hook.Add("effect.end","statuspanel",function (eff,actor)
	--	if(actor==LocalPlayer())then
	--		self:Set(actor)
	--	end
	--end)
end
function PANEL:UpdateEffects()
	local effects = GetEffects(self.actor)
	self.er:Clear()
	for key, value in pairs(effects) do
		self:AddRecord(value._type, value:TimeLeft(),self.er) 
	end
	self:UpdateLayout() 
end
 
function PANEL:AddGroup(text)
	local r = panel.Create()
	r:SetSize(10,20)
	r:Dock(DOCK_TOP)
	r:SetColor(Vector(20,50,20)/100)
	r:SetText(text)
	r:SetTextAlignment(ALIGN_CENTER)
	self:Add(r)
end

function PANEL:AddRecord(text,value,up)
	up = up or self
	if not isstring(value) then
		value = tostring(value)
	end
	
	local r = panel.Create()
	r:SetSize(10,20)
	r:Dock(DOCK_TOP)
	r:SetColor(Vector(20,20,20)/100)
	up:Add(r)
	
	local rt = panel.Create()
	rt:SetSize(150,20)
	rt:Dock(DOCK_LEFT)
	rt:SetText(text)
	rt:SetColor(Vector(20,20,50)/100)
	r:Add(rt)
	
	local rv = panel.Create()
	rv:SetSize(150,20)
	rv:Dock(DOCK_FILL)
	rv:SetText(value)
	rv:SetColor(Vector(20,20,20)/100)
	r:Add(rv)
	
	local rd = panel.Create()
	rd:SetSize(10,1)
	rd:Dock(DOCK_TOP)
	rd:SetColor(Vector(0,0,1))
	up:Add(rd) 
end