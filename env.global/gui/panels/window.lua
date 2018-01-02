GUI_PANEL_GLOBALS = GUI_PANEL_GLOBALS or {}
local CURRENT_WINDOW_RESIZE = false
local CURRENT_WINDOW_RESIZE_POINTPOS = false
local CURRENT_WINDOW_RESIZE_SIZE = false
local CURRENT_WINDOW_RESIZE_POS = false
local CURRENT_WINDOW_RESIZE_DIR = false
local function cwresize()
	local window = CURRENT_WINDOW_RESIZE
	if window then 
		local dir = CURRENT_WINDOW_RESIZE_DIR
		local posdir = Point(dir.x,-dir.y)
		local mousePos = input.getMousePosition() 
		local mouseDiff = mousePos - CURRENT_WINDOW_RESIZE_POINTPOS 
		local newSize = CURRENT_WINDOW_RESIZE_SIZE + mouseDiff * dir
		window:SetSize(newSize)
		
		local rrs = window:GetSize() - CURRENT_WINDOW_RESIZE_SIZE
		local newPos = CURRENT_WINDOW_RESIZE_POS + rrs * posdir
		window:SetPos(newPos)
		if not input.leftMouseButton() then
			CURRENT_WINDOW_RESIZE = false
			UnlockMouse()
			hook.Remove("main.predraw", "gui.window.resize")
		end
	end
end
local function cwmove()
	local window = CURRENT_WINDOW_MOVE
	if window then  
		local mousePos = input.getMousePosition() 
		local mouseDiff = mousePos - CURRENT_WINDOW_MOVE_POINTPOS   
		local mouseDiffF = Point(mouseDiff.x*2,mouseDiff.y*-2)
		local newPos = CURRENT_WINDOW_MOVE_POS + mouseDiffF
		window:SetPos(newPos)
		if not input.leftMouseButton() then
			CURRENT_WINDOW_MOVE = false
			UnlockMouse()
			hook.Remove("main.predraw", "gui.window.move")
		end
	end
end
GUI_PANEL_GLOBALS.cwmove = cwmove
GUI_PANEL_GLOBALS.cwresize = cwresize

function PANEL:Init() 
	
	local rs_b = panel.Create("button")
	local rs_t = panel.Create("button")
	local rs_l = panel.Create("button")
	local rs_r = panel.Create("button")
	local rs_tl = panel.Create("button")
	local rs_tr = panel.Create("button")
	local rs_bl = panel.Create("button")
	local rs_br = panel.Create("button")
	local mv = panel.Create("button")
	local inner = panel.Create()
	
	local bc = panel.Create("button")
	
	--local dockbtn = panel.Create("button")
	
	mv.upcolor = Vector(0.6,0.8,0.9) 
	--mv:SetColor(mv.upcolor)
	mv:SetTextColor(gui.style:GetColor("Text"))	
	mv:SetColors(
		gui.style:GetColor("Header"),
		gui.style:GetColor("HeaderActive"),
		gui.style:GetColor("HeaderHovered"))
	
	local sResize = function(s)
		if not CURRENT_WINDOW_RESIZE then
			if not self.fixedsize then
				CURRENT_WINDOW_RESIZE_SIZE = self:GetSize()
				CURRENT_WINDOW_RESIZE_POS = self:GetPos()
				CURRENT_WINDOW_RESIZE_POINTPOS =  input.getMousePosition()
				CURRENT_WINDOW_RESIZE_DIR = s.dir
				CURRENT_WINDOW_RESIZE = self
				hook.Add("main.predraw", "gui.window.resize", cwresize)
			end
		end
	end
	local sMove = function(s) 
		if not CURRENT_WINDOW_MOVE then
			if not self.fixedpos then
				CURRENT_WINDOW_MOVE_POS = self:GetPos()
				CURRENT_WINDOW_MOVE_POINTPOS =  input.getMousePosition() 
				CURRENT_WINDOW_MOVE = self
				hook.Add("main.predraw", "gui.window.move", cwmove)
			end
		end
	end
	--[[local sDock = function(s)  
		local dock_l = panel.Create("button")
		local dock_r = panel.Create("button")
		local dock_u = panel.Create("button")
		local dock_d = panel.Create("button")
		local dockbtns = {dock_l,dock_r,dock_u,dock_d}
		dockbtn.btns = dockbtns
		local db = dockbtn:GetSize()
		dock_l:SetPos(-db.x/2,0)
		dock_r:SetPos(db.x/2,0)
		dock_d:SetPos(0,-db.y/2)
		dock_u:SetPos(0,db.y/2)
		for k,v in pairs(dockbtns) do
			v:SetSize(db.x/2,db.y/2)
			dockbtn:Add(v)
		end
		dock_l.OnClick = function()
			local par = self:GetParent()
			local ps = par:GetSize()
			local ss = self:GetSize()
			self:SetPos(-ps.x+ss.x)
			self:Resize(ss.x,ps.y)
		end
	end]]
	rs_b.dir = Point(0,1)
	rs_t.dir = Point(0,-1)
	rs_l.dir = Point(-1,0)
	rs_r.dir = Point(1,0)
	rs_tl.dir = Point(-1,-1)
	rs_tr.dir = Point(1,-1)
	rs_bl.dir = Point(-1,1)
	rs_br.dir = Point(1,1)
	rs_b.OnClick = sResize
	rs_t.OnClick = sResize
	rs_l.OnClick = sResize
	rs_r.OnClick = sResize 
	rs_tl.OnClick = sResize
	rs_tr.OnClick = sResize
	rs_bl.OnClick = sResize
	rs_br.OnClick = sResize 
	 
	
	mv.OnClick = sMove 
	--dockbtn.OnClick = sDock 
	bc.OnClick = function() 
		self:Close() 
		local OnClose = self.OnClose
		if OnClose then
			OnClose(self)
		end
	end
	
	self.rs_b  = rs_b
	self.rs_t  = rs_t
	self.rs_l  = rs_l
	self.rs_r  = rs_r
	self.rs_tl = rs_tl
	self.rs_tr = rs_tr
	self.rs_bl = rs_bl
	self.rs_br = rs_br
	self.mv    = mv
	self.bc    = bc
	self.inner = inner
	self.borders = {rs_b,rs_t,rs_l,rs_r,rs_tl,rs_tr,rs_bl,rs_br}
	--self.dockbtn  = dockbtn
	 
	local sizeframe_width = 5
	local movepanel_height = 20
	
	local bordcol = gui.style:GetColor("Border")
	local backcol = gui.style:GetColor("WindowBack")
	local bordcola = gui.style:GetAlpha("Border")
	local backcola = gui.style:GetAlpha("WindowBack")
	self:SetColor(backcol)
	self:SetAlpha(backcola)
	inner:SetColor(backcol)
	inner:SetAlpha(backcola)
	inner:SetSize(10,10)
	for k,v in pairs({rs_b,rs_t,rs_l,rs_r,rs_tl,rs_tr,rs_bl,rs_br}) do
		v:SetSize(sizeframe_width,sizeframe_width)
		v:SetColorAuto(bordcol)
		v:SetAlpha(bordcola)
	end
	mv:SetSize(movepanel_height,movepanel_height)
	----rs_tl:SetSize(sizeframe_width,sizeframe_width)
	----rs_tr:SetSize(sizeframe_width,sizeframe_width)
	----rs_bl:SetSize(sizeframe_width,sizeframe_width)
	----rs_br:SetSize(sizeframe_width,sizeframe_width)
	--dockbtn:SetSize(movepanel_height,movepanel_height)
	
	bc:SetSize(movepanel_height,movepanel_height)
	
	self:Add(rs_b) rs_b:Dock(DOCK_BOTTOM)
	self:Add(rs_t) rs_t:Dock(DOCK_TOP)
	self:Add(rs_l) rs_l:Dock(DOCK_LEFT)
	self:Add(rs_r) rs_r:Dock(DOCK_RIGHT)
	
	rs_t:Add(rs_tl) rs_tl:Dock(DOCK_LEFT)
	rs_t:Add(rs_tr) rs_tr:Dock(DOCK_RIGHT)
	rs_b:Add(rs_bl) rs_bl:Dock(DOCK_LEFT)
	rs_b:Add(rs_br) rs_br:Dock(DOCK_RIGHT)
	
	self:Add(mv) mv:Dock(DOCK_TOP)
	self:Add(inner) inner:Dock(DOCK_FILL)
	
	mv:Add(bc) bc:Dock(DOCK_RIGHT)
	--self:Add(dockbtn)
	
	--function self:Resize(newSize) 
	--	local sx =math.max( newSize.x ,40)
	--	local sy =math.max( newSize.y ,40)
	--	
	--	self:SetSize(sx,sy) 
	--	------rs_b:SetSize(sx-sizeframe_width*2,sizeframe_width)
	--	------rs_t:SetSize(sx-sizeframe_width*2,sizeframe_width)
	--	------rs_l:SetSize(sizeframe_width,sy-sizeframe_width*2)
	--	------rs_r:SetSize(sizeframe_width,sy-sizeframe_width*2)
	--	------mv:SetSize(sx-sizeframe_width*2,movepanel_height)
	--	------local t = sy-sizeframe_width
	--	------local b = -sy+sizeframe_width
	--	------local l = -sx+sizeframe_width
	--	------local r = sx-sizeframe_width 
	--	------rs_b:SetPos(0,b)
	--	------rs_t:SetPos(0,t)
	--	------rs_l:SetPos(l,0)
	--	------rs_r:SetPos(r,0) 
	--	------rs_tl:SetPos(l,t)
	--	------rs_tr:SetPos(r,t)
	--	------rs_bl:SetPos(l,b)
	--	------rs_br:SetPos(r,b)
	--	------mv:SetPos(0,sy-sizeframe_width*2 - movepanel_height)
	--	------bc:AlignTo(mv,ALIGN_LEFT,ALIGN_LEFT)
	--	--dockbtn:SetPos(sx-sizeframe_width*2-movepanel_height,sy-sizeframe_width*2 - movepanel_height)
	--	local sor = self.OnResize
	--	if sor then
	--		sor(self)
	--	end
	--end
	
	function self:SetTitle(text)
		mv:SetText(text)
	end
	
	self:SetMinSize(40,40)
	self:SetSize(400,400) --Resize(Point(400,400))
end

function PANEL:Resize() 
end

function PANEL:MouseDown()
	
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end
 