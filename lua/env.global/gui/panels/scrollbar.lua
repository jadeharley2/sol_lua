CURRENT_BAR_MOVE = false
local function cwmove()
	local bar = CURRENT_BAR_MOVE
	if bar then  
	print("XX",bar)
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



PANEL.width = 12

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
	bdrag:SetColorAuto(bcol/2)
	
	
	self.stype = type
	if type == 1 then
		b1:Dock(DOCK_TOP)
		b2:Dock(DOCK_BOTTOM)
		b1:SetTexture("textures/gui/bar_up.png") 
		b2:SetTexture("textures/gui/bar_down.png")
		self:SetTexture("textures/gui/bar_h.png")
		bdrag.lockx = true
	else
		b1:Dock(DOCK_RIGHT)
		b2:Dock(DOCK_LEFT)
		b1:SetTexture("textures/gui/bar_right.png")
		b2:SetTexture("textures/gui/bar_left.png")
		self:SetTexture("textures/gui/bar_v.png")
		bdrag.locky = true
	end
	local drawerrorfix = panel.Create()
	drawerrorfix:SetSize(0,0)
	self:Add(bdrag)
	self:Add(b1)
	self:Add(b2)
	self:Add(drawerrorfix)
	self.b1 = b1
	self.b2 = b2
	self.bdrag = bdrag
	bdrag.bar = self
	
	local subbdr = panel.Create()
	subbdr:Dock(DOCK_FILL)
	subbdr:SetSize(2,2)
	subbdr:SetMargin(2,2,2,2)
	subbdr:SetColor(Vector(0,0,0))
	subbdr:SetCanRaiseMouseEvents(false)
	bdrag:Add(subbdr)
	
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

function PANEL:SetScroll(value)-- [0...1]
	local fcon = self:GetParent() 
	local floater = fcon.floater
	local container = fcon.inner
	local fpos = floater:GetPos()
	local type = self.stype
	
	value = math.max(math.min(value,1),0)
	
	local fsize = floater:GetSize()
	local csize = container:GetSize()
	--if type == 1 then
	--	if(fsize.x<=csize.x) then value = -1 end
	--else
	--	if(fsize.y<=csize.y) then value = -1 end
	--end
	--MsgN(fsize,csize)
	local target = (csize - fsize)*value; -- (fsize - csize)*(-value)---1)/2
	--MsgN("SET",value,">>",target,fsize,csize)
	if type == 1 then
		if fsize.y < csize.y then
			--MsgN("floater less")
			floater:SetPos(fpos.x,0)
		else
			--MsgN("floater ok")
			floater:SetPos(fpos.x,math.round(target.y))
		end
	else
		if fsize.x < csize.x then
			floater:SetPos(0,fpos.y) 
		else
			floater:SetPos(math.round(target.x),fpos.y) 
		end
	end
	
	self:Refresh()
end
function PANEL:GetScroll()-- [0...1]
	local type = self.stype
	local fcon = self:GetParent() 
	local floater = fcon.floater
	local container = fcon.inner
	
	local fpos = floater:GetPos()
	local fsize = floater:GetSize()
	local csize = container:GetSize()
	
	--local diff = fsize-csize 
	--local s = (diff-floater:GetPos())/diff
	--MsgN("pos",fpos)
	local s = fpos/(csize - fsize) ; 
	
	--local s = -floater:GetPos() / ( container:GetSize())
	--MsgN('GET',s.y or 0,csize,fsize)
	if type == 1 then
		if fsize.y < csize.y then
			return 0
		else
			return s.y or 0
		end
	else
		if fsize.x < csize.x then
			return 0
		else
			return s.x or 0
		end
	end
end
function PANEL:Scroll(delta)
	local fcon = self:GetParent() 
	local floater = fcon.floater
	--local fpos = floater:GetPos()
	local type = self.stype
	
	local sval = self:GetScroll()
	if sval~=sval then sval =0 end -- anti nan value
	
	-- scroll pos range: -outer .. 0
	
	local fsize = floater:GetSize()
	if type == 1 then
	--MsgN("SCRO",sval,"+",delta," -> ",delta / fsize.y," ->>> ",sval)
		self:SetScroll(sval+delta / fsize.y)
	else
		self:SetScroll(sval+delta / fsize.x)
	end
	
	self:Refresh()
end

function PANEL:Refresh()
	local fcon = self:GetParent()
	if fcon then
		local container = fcon.inner
		local floater = fcon.floater
		if container and floater then
			local ss = self:GetSize()
			local w = self.width
			local bdrag = self.bdrag
			local type = self.stype
			
			local scrollH =math.min(ss.y - w*2, math.max(5, container:GetSize().y / floater:GetSize().y * (ss.y - w*2)))
			local scrollS = floater:GetPos() / (floater:GetSize() - container:GetSize())
			if type == 1 then
				bdrag:SetSize(w,scrollH)
				bdrag:SetPos(0,-scrollS.y  * (ss.y - w*2 - scrollH )+w)--
			else
				bdrag:SetSize(scrollH,w)
				bdrag:SetPos(-scrollS.x * (ss.x - w*2 - scrollH)+w,0)
			end 
		end
	--fcon:UpdateLayout()
	end
end
function PANEL:Resize()
	self:Refresh()
end