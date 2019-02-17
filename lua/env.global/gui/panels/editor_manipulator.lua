
-- lua_run S_MNP()
local manips = {}
local CURRENT_MANIP = false
local function cwtrack() 
	for k,m in pairs(manips) do  
		local t = m.target
		local ss = GetViewportSize()
		local camp = GetCamera():GetParent()
		local sz = camp:GetSizepower()
		local lpos = camp:GetLocalCoordinates(t)
		local lp = panel.GetLocalPos(lpos)
		
		if lp.z<1 then
			m:SetPos(lp.x*ss.x,lp.y*ss.y)
			if CURRENT_MANIP == m then
			
				local lpx = (panel.GetLocalPos(lpos+Vector(1,0,0)/sz) - lp)*ss
				local lpy = (panel.GetLocalPos(lpos+Vector(0,1,0)/sz) - lp)*ss
				local lpz = (panel.GetLocalPos(lpos+Vector(0,0,1)/sz) - lp)*ss
				local lmx = (panel.GetLocalPos(lpos+Vector(-1,0,0)/sz) - lp)*ss
				local lmy = (panel.GetLocalPos(lpos+Vector(0,-1,0)/sz) - lp)*ss
				local lmz = (panel.GetLocalPos(lpos+Vector(0,0,-1)/sz) - lp)*ss
				
				m.sx.len = lpx:Length()
				m.sy.len = lpy:Length()
				m.sz.len = lpz:Length()
				m.px.len = lmx:Length()
				m.py.len = lmy:Length()
				m.pz.len = lmz:Length()
				
				m.sx:SetPos(lpx.x,lpx.y)
				m.sy:SetPos(lpy.x,lpy.y)
				m.sz:SetPos(lpz.x,lpz.y)
				m.px:SetPos(lmx.x,lmx.y)
				m.py:SetPos(lmy.x,lmy.y)
				m.pz:SetPos(lmz.x,lmz.y) 
			end
		else 
			m:SetPos(-10000,0)
		end
	end
end
local function cwmove()
	local t = CURRENT_MOVE
	if t then  
		local mousePos = input.getMousePosition() 
		local mouseDiff = mousePos - CURRENT_MOVE_POINTPOS   
		local mouseDLen = mouseDiff:Length() 
		local oneDLen =  CURRENT_MOVE_B.len
		local diff = mouseDLen/oneDLen 
		local oldPos = CURRENT_MOVE_POS
		local camp = GetCamera():GetParent()
		local sz = camp:GetSizepower()
		local newPos = oldPos + CURRENT_MOVE_B.dir/sz*diff 
		t:SetPos(newPos)
		if not input.leftMouseButton() then
			CURRENT_MOVE = false
			hook.Remove("main.predraw", "gui.window.move")
		end
	end
end

local function SETCURRENTMANIP(m)
	local cm = CURRENT_MANIP
	if cm then
		cm:SetSize(20,20)
		for k,v in pairs(cm.btn) do 
			v:SetVisible(false)
		end
		cm.sc:SetVisible(true)
		CURRENT_MANIP = false
	end
	
	if cm ~= m then 
		CURRENT_MANIP = m
		m:SetSize(3000,3000)
		for k,v in pairs(m.btn) do 
			v:SetVisible(true)
		end
	end
end

function PANEL:Init() 
	self:SetAlpha(0)
	self:SetSize(20,20)
	local sc = panel.Create("button")
	local sx = panel.Create("button") sx.dir = Vector(1,0,0)
	local sy = panel.Create("button") sy.dir = Vector(0,1,0)
	local sz = panel.Create("button") sz.dir = Vector(0,0,1)
	
	local px = panel.Create("button") px.dir = Vector(-1,0,0)
	local py = panel.Create("button") py.dir = Vector(0,-1,0)
	local pz = panel.Create("button") pz.dir = Vector(0,0,-1)
	
	local btn = {sc,sx,sy,sz,px,py,pz}
	self.sc = sc
	self.sx = sx
	self.sy = sy
	self.sz = sz 
	self.px = px
	self.py = py
	self.pz = pz
	self.btn = btn
	
	for k,v in pairs(btn) do 
		v:SetSize(10,10)
		v:SetVisible(false)
		self:Add(v)
	end
	
	sc:SetVisible(true)
	sc:SetSize(20,20)
	
	local sToggle = function(s) 
		SETCURRENTMANIP(self)
	end
	local sMove = function(s)  
		CURRENT_MOVE = self.target
		CURRENT_MOVE_B = s
		CURRENT_MOVE_POS = self.target:GetPos()
		CURRENT_MOVE_POINTPOS = input.getMousePosition() 
		hook.Add("main.predraw", "gui.editor.move", cwmove)
	end
	sc.OnClick = sToggle
	
	sx.OnClick = sMove
	sy.OnClick = sMove
	sz.OnClick = sMove
	px.OnClick = sMove
	py.OnClick = sMove
	pz.OnClick = sMove
		
	
	manips[#manips+1] = self
	
	hook.Add("main.predraw", "gui.edm.track", cwtrack)
end

function PANEL:SetTarget(targetnode)
	self.target = targetnode
end

function PANEL:MouseDown()
	
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end

local ctmns = {}
function S_MNP()
	local cam = GetCamera()
	local trgs = cam:GetParent():GetChildren()
	local i = 1
	for k,v in pairs(trgs) do
		if v~=cam then 
			ctmn = ctmns[i] or panel.Create("editor_manipulator") 
			ctmn:SetTarget(v)
			ctmn:Show()
			ctmns[i] = ctmn
			i = i + 1
		end
	end 
	
end