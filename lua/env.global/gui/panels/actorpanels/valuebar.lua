local testtexture = LoadTexture("gui/menu/bkg1.png")
local hurttexture = LoadTexture("gui/hurt.dds")

function PANEL:Init()
	--PrintTable(self) 
	 
	self:SetCanRaiseMouseEvents(false)
	self:SetAlpha(0.4)
	self:SetSize(300,10)
	self:SetColor(Vector(0.6,0.6,0.6)/3)
	
	local back = panel.Create() 
    back:SetTexture(testtexture) 
	back:SetPos(0,0)
	back:SetSize(299,8)
	back:SetColor(Vector(0.6,0.6,0.6)/3)
	
	local prevbar = panel.Create() 
	prevbar:SetPos(0,0)
	prevbar:SetColor(Vector(1,1,0))
	prevbar:Dock(DOCK_LEFT)
	prevbar:SetSize(0,100)
	
	local bar = panel.Create() 
	bar:SetPos(0,0)
	bar:SetColor(Vector(1,0,0))
	bar:Dock(DOCK_LEFT)
	bar:SetSize(100,100)
	
	
	self:Add(back)  
	back:Add(bar) 
	back:Add(prevbar) 
	
	self.fixedsize = true
	self.bar = bar
	self.prevbar = prevbar
	self.back = back
	self:UpdateLayout()
	 
	 
	
end
    

function PANEL:SetValue(val,maxval) 
	if val then   
		maxval = maxval or 100
		local insize = self:GetSize()
		self.bar:SetSize(val/maxval * insize.x,insize.y)
		self:UpdateLayout() 
		self:SetVisible(true)
		local lastval = self.lastval or 0 
		local lastdelta = val - lastval
		if lastdelta > 100 then lastdelta = 100 end
		if lastdelta < -100 then lastdelta = -100 end
		self.lastdelta = lastdelta
		self.lastval = val
		--MsgN(lastdelta)
		if lastdelta > 0 then
			self.prevbar:SetColor(Vector(0,1,0))
		else
			self.prevbar:SetColor(Vector(1,1,0))
		end 
	else
		self:SetVisible(false)
	end
end
function PANEL:GetValue()
	return self.lastval
end
function PANEL:Think()  
	local curthink = CurTime()
	local lastthink = self.lastthink or curthink
	self.lastthink = curthink
	local dt = curthink - lastthink
	
	local insize = self:GetSize()
	local lastdelta = self.lastdelta or 0  
	--local smval = self.smval or lastdelta
	lastdelta = (lastdelta *math.max(0,1-4*dt))
	local lvs = math.abs(lastdelta)
	self.prevbar:SetSize(lvs/100 * insize.x,insize.y)
	self.lastdelta = lastdelta
	 
end
 

