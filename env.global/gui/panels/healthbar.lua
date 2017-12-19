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
	
	hook.Add( "window.resize","gui.health.repos",function()
		local vsize = GetViewportSize()
		local csize = self:GetSize() 
		self:SetPos(0,-vsize.y+csize.y+110)
	end)
	
	hook.Add( "main.update","gui.health.update",function() self:Think() end)
	
	local vsize = GetViewportSize()
	local csize = self:GetSize() 
	self:SetPos(0,-vsize.y+csize.y+20)
end
 
function PANEL:UpdateHealth(val) 
	if val then  
		local insize = self:GetSize()
		self.bar:SetSize(val/100 * insize.x,insize.y)
		self:UpdateLayout() 
		self:SetVisible(true)
		local lastval = self.lastval or 0 
		local lastdelta = val - lastval
		self.lastdelta = lastdelta
		self.lastval = val
		MsgN(lastdelta)
		if lastdelta > 0 then
			self.prevbar:SetColor(Vector(0,1,0))
		else
			self.prevbar:SetColor(Vector(1,1,0))
		end
		if math.abs(lastdelta) > 1  then 
			local heff = self.hurteffect
			if not heff then 
				heff = panel.Create() 
				heff:SetPos(0,0)
				heff:SetColor(Vector(1,0,0))
				heff:SetTexture(hurttexture)  
				heff:SetCanRaiseMouseEvents(false)
				
				self.hurteffect = heff
			end
			local vsize = GetViewportSize()
			heff:SetSize(vsize) 
			heff:SetAlpha(lastdelta/-10) 
			if lastdelta > 0 then
				heff:SetColor(Vector(0.1,1,0.3))
			else
				heff:SetColor(Vector(1,0.3,0.1))
			end
			heff:Show()
		end
	else
		self:SetVisible(false)
	end
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
	
	local heff = self.hurteffect
	if heff then
		heff:SetAlpha(lvs/(10))
		if lvs < 1 then
			heff:Close() 
		end
	end
end

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end