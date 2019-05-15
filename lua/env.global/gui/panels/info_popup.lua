
PANEL.msglist =PANEL.msglist or {}
local _P = PANEL.msglist

function MsgInfo(text,color)
	text = tostring(text)
	local m = panel.Create("info_popup") 
	if m and not isfunction(m) and m.ShowMsg then
		local vsize = GetViewportSize()
		local pc = #_P
		for k=1,pc do
			local v = _P[pc-k+1]
			if v then
			v.id = v.id+1
			_P[v.id] = v
			v.target = Point(-vsize.x+600,-vsize.y+50+(v.id)*50)
			end
		end
		_P[1] = m
		m.id = 1
		m:ShowMsg(text,Point(-vsize.x+600,-vsize.y+50),color)
	end
end

function PANEL:Init()  
	self:SetPos(-5000,0)
	self:SetColor(Vector(0,0,0)) 
	self:SetSize(500,15)
	self:SetAlpha(0.5)
	self:SetCanRaiseMouseEvents(false)
	
	local indicator = panel.Create()
	indicator:Dock(DOCK_LEFT)
	indicator:SetSize(5,15)
	indicator:SetColor(Vector(1,0,0))  
	indicator:SetAlpha(0.5)
	self:Add(indicator)
	self.indicator = indicator
end
function PANEL:ShowMsg(msg,pos,color)  
	local text = panel.Create()
	text:Dock(DOCK_FILL)
	text:SetSize(10,10)
	text:SetText(msg)
	text:SetColor(Vector(0,0,0))  
	text:SetTextColor(Vector(1,1,1))  
	text:SetTextOnly(true)  
	self:Add(text)
	--self:SetPos(0,0)
	self:Show()
	self.target = pos
	self.target2 = pos + Point(-5000,0)
	local showtime = 4
	
	if color then self.indicator:SetColor(color) end
	self:SetPos(pos+Point(0,-1000))
	
	debug.DelayedTimer(0,20,(showtime*1000+1000)/20, function() 
		local pos = self:GetPos()
		local target = self.target
		self:SetPos(pos+(target-pos)/10) 
	end)
	debug.DelayedTimer(showtime*1000,20,50, function() 
		local pos = self:GetPos()
		local target = self.target2
		self:SetPos(pos+(target-pos)/10) 
	end)
	debug.Delayed(showtime*1000+1000, function() 
		self:Close() 
		_P[self.id] = nil
		end)
end 
--debug.Delayed(100,function()
--MsgInfo("leld")
--end)