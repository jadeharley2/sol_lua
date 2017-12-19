
local function cwmove()
	local bar = CURRENT_BAR_MOVE
	if bar then  
		local mousePos = input.getMousePosition() 
		local mouseDiff = mousePos - CURRENT_BAR_MOVE_POINTPOS   
		local mouseDiffF = Point(mouseDiff.x*2,mouseDiff.y*-2)
		local newPos = CURRENT_BAR_MOVE_POS + mouseDiffF
		if bar.lockx then
			bar:SetPos(CURRENT_BAR_MOVE_POS.x,newPos.y)
		else
			bar:SetPos(newPos.x,CURRENT_BAR_MOVE_POS.y)
		end
		bar.bar:SetScroll(bar.bar:GetScrollByPos( newPos))
		if not input.leftMouseButton() then
			CURRENT_BAR_MOVE = false
			UnlockMouse()
			hook.Remove("main.predraw", "gui.bar.move")
		end
	end
end



PANEL.width = 15

function PANEL:Init()
	local w = self.width
	self:SetSize(w,w)
end

--   1 = VERTICAL, 2 = HORISONTAL,  
function PANEL:SetType(type)
	local b1 = panel.Create("button")
	local b2 = panel.Create("button")
	local bdrag = panel.Create("button")
	
	local bcol = Vector(83,164,255)/255
	local w = self.width
	b1:SetSize(w,w)
	b2:SetSize(w,w)
	bdrag:SetSize(w,w)
	
	b1:SetColorAuto(bcol)
	b2:SetColorAuto(bcol)
	bdrag:SetColorAuto(bcol)
	
	
	self.stype = type
	if type == 1 then
		b1:Dock(DOCK_TOP)
		b2:Dock(DOCK_BOTTOM)
		b1:SetTexture(LoadTexture("gui/bar_up.png")) 
		b2:SetTexture(LoadTexture("gui/bar_down.png")) 
		self:SetTexture(LoadTexture("gui/bar_h.png")) 
		bdrag.lockx = true
	else
		b1:Dock(DOCK_RIGHT)
		b2:Dock(DOCK_LEFT)
		b1:SetTexture(LoadTexture("gui/bar_right.png")) 
		b2:SetTexture(LoadTexture("gui/bar_left.png")) 
		self:SetTexture(LoadTexture("gui/bar_v.png")) 
		bdrag.locky = true
	end
	
	self:Add(b1)
	self:Add(b2)
	self:Add(bdrag)
	self.b1 = b1
	self.b2 = b2
	self.bdrag = bdrag
	bdrag.bar = self
	
	b1.cooldown = 0.02
	b2.cooldown = 0.02
	
	b1.OnClick = function(s) self:Scroll(-20) end
	b2.OnClick = function(s) self:Scroll(20) end
	
	bdrag.OnClick = function(s) 
		if not CURRENT_BAR_MOVE then 
			CURRENT_BAR_MOVE_POS = bdrag:GetPos()
			CURRENT_BAR_MOVE_POINTPOS =  input.getMousePosition() 
			CURRENT_BAR_MOVE = bdrag
			hook.Add("main.predraw", "gui.bar.move", cwmove) 
		end
	end
end
function PANEL:GetScrollByPos(pos)
	local ss = self:GetSize()
	local w = self.width 
	local type = self.stype
	if type == 1 then
		return -pos.y  / (ss.y - w*2)
	else
		return -pos.x  / (ss.x - w*2)
	end 
end

function PANEL:SetScroll(value)-- [-1...0...1]
	local fcon = self:GetParent() 
	local floater = fcon.floater
	local container = fcon.inner
	local fpos = floater:GetPos()
	local type = self.stype
	
	value = math.max(math.min(value,1),-1)
	
	local target = (floater:GetSize() - container:GetSize())*value
	
	if type == 1 then
		floater:SetPos(fpos.x,target.y)
	else
		floater:SetPos(target.x,fpos.y) 
	end
	
	self:Refresh()
end
function PANEL:GetScroll()-- [-1...0...1]
	local type = self.stype
	local fcon = self:GetParent() 
	local floater = fcon.floater
	local container = fcon.inner
	local s = floater:GetPos() / (floater:GetSize() - container:GetSize())
	if type == 1 then
		return s.y
	else
		return s.x
	end
end
function PANEL:Scroll(delta)
	local fcon = self:GetParent() 
	local floater = fcon.floater
	local fpos = floater:GetPos()
	local type = self.stype
	
	local sval = self:GetScroll()
	if type == 1 then
		self:SetScroll(sval+delta / floater:GetSize().y)
	else
		self:SetScroll(sval+delta / floater:GetSize().x)
	end
	
	self:Refresh()
end

function PANEL:Refresh()
	local fcon = self:GetParent()
	local container = fcon.inner
	local floater = fcon.floater
	local ss = self:GetSize()
	local w = self.width
	local bdrag = self.bdrag
	local type = self.stype
	
	local scrollH = math.max(5, container:GetSize().y / floater:GetSize().y * (ss.y - w*2))
	local scrollS = floater:GetPos() / (floater:GetSize() - container:GetSize())
	if type == 1 then
		bdrag:SetSize(w,scrollH)
		bdrag:SetPos(0,-scrollS.y  * (ss.y - w*2))
	else
		bdrag:SetSize(scrollH,w)
		bdrag:SetPos(-scrollS.x * (ss.x - w*2),0)
	end
	--fcon:UpdateLayout()
end
