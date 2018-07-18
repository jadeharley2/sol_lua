 
function PANEL:Init()
	
	self:SetClipEnabled(true)
	self.inner = self
end

function PANEL:SetFloater(floater)
	self.floater = floater 
	self.inner:Add(floater)
	local bar = self.vbar
	local bar2 = self.hbar
	if bar then bar:SetScroll(-1) end
	if bar2 then bar2:SetScroll(-1) end
end
-- 0 = NONE, 1 = VERTICAL, 2 = HORISONTAL, 3 = BOTH
function PANEL:SetScrollbars(type)
		
	if type == 1 or type == 3 then
		local bar =  panel.Create("scrollbar")
		bar:SetType(1)
		bar:Dock(DOCK_RIGHT)
		self:Add(bar)
		self.vbar = bar
	end
	if type == 2 or type == 3 then
		local bar =  panel.Create("scrollbar")
		bar:SetType(2)
		bar:Dock(DOCK_BOTTOM)
		self:Add(bar)
		self.hbar = bar
	end
	self:SetClipEnabled(false)
	local inner = panel.Create()
	inner:SetClipEnabled(true)
	inner:Dock(DOCK_FILL)
	self:Add(inner)
	
	self.inner = inner
	
	self:UpdateLayout()
end
function PANEL:GetFloater()
	return self.floater
end
function PANEL:SetScroll(pos)
	local f = self.floater
	f:SetPos(pos)
end
function PANEL:SetColor(col)
	local f = self.inner
	if f and f~=self then f:SetColor(col) end 
	self.base.SetColor(self,col)
end
function PANEL:SetAlpha(a)
	local vbar = self.vbar
	local hbar = self.hbar
	local inn = self.inner
	if inn then inn:SetAlpha(a) end
	if vbar then vbar:SetAlpha(a) end
	if hbar then hbar:SetAlpha(a) end
	self.base.SetAlpha(self,a)
end
 
function PANEL:Scroll(delta)
	local bar = self.vbar
	if bar then bar:Scroll(delta) end 
end
function PANEL:HScroll(delta)
	local bar = self.hbar
	if bar then bar:Scroll(delta) end 
end


function PANEL:MouseEnter() 
	local bar = self.vbar
	local bar2 = self.hbar
	if bar or bar2 then 
		local sWVal = input.MouseWheel() 
		hook.Add("input.mousewheel", "float.scroll",function() 
			local mWVal = input.MouseWheel() 
			local delta = mWVal - sWVal
			sWVal = mWVal
			if input.KeyPressed(KEYS_SHIFTKEY) then
				if bar2 then bar2:Scroll(-delta) end
			else
				if bar then bar:Scroll(-delta) end
			end
		end)
	end
end
function PANEL:MouseLeave()
	local bar = self.vbar
	local bar2 = self.hbar
	if bar or bar2 then 
		hook.Remove("input.mousewheel", "float.scroll")
	end
end

function PANEL:Resize() 
	local floater = self.floater 
	local inner = self.inner
	if floater and inner then
		local vbar = self.vbar 
		local hbar = self.hbar 
		if vbar and not hbar then
			local ssize = self:GetSize()
			local bsize = vbar:GetSize()
			local fsize = floater:GetSize()
			floater:SetSize(ssize.x-bsize.x,fsize.y)
		end
	end
end