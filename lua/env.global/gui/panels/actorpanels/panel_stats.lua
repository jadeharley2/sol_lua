 

function PANEL:Init() 
	self:SetColor(Vector(0,0,0))
	
end 

function PANEL:Set(actor)
	self:Clear()
	local asp = actor.species
	if asp then
		self:AddGroup("General")
		self:AddRecord("Species:", asp.name or "unknown")
		self:AddRecord("Race:", asp.racename or "none")
	end
	self:AddGroup("Attributes")
	self:AddRecord("Strength:", 0) 
	self:AddRecord("Mass:", actor.phys:GetMass()) 
	self:AddRecord("Ground Speed:",tostring(actor.walkspeed).."-"..tostring(actor.runspeed)) 
	self:AddRecord("Flight Speed:", actor.flyspeed) 
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

function PANEL:AddRecord(text,value)
	if not isstring(value) then
		value = tostring(value)
	end
	
	local r = panel.Create()
	r:SetSize(10,20)
	r:Dock(DOCK_TOP)
	r:SetColor(Vector(20,20,20)/100)
	self:Add(r)
	
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
	self:Add(rd) 
end