
PANEL.STATIC = PANEL.STATIC or {}
local static = PANEL.STATIC  
 

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
	mv:SetTextColor(Vector(2,2,2))--gui.style:GetColor("Text"))	
	mv:SetColors(
		gui.style:GetColor("Header"),
		gui.style:GetColor("HeaderActive"),
		gui.style:GetColor("HeaderHovered"))
	
	local sResize = function(s)
		panel.start_resize(self,1,s.dir)
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
	local rmenter = function(s)  
		panel.cursor_resize(s.dir)
	end
	local rleave = function(s)  
		if not panel.current_resize then
			panel.SetCursor(0)
		end
	end
	
	
	rs_b.dir = Point(0,1)
	rs_t.dir = Point(0,-1)
	rs_l.dir = Point(-1,0)
	rs_r.dir = Point(1,0)
	rs_tl.dir = Point(-1,-1)
	rs_tr.dir = Point(1,-1)
	rs_bl.dir = Point(-1,1)
	rs_br.dir = Point(1,1)
	self.rs_b  = rs_b
	self.rs_t  = rs_t
	self.rs_l  = rs_l
	self.rs_r  = rs_r
	self.rs_tl = rs_tl
	self.rs_tr = rs_tr
	self.rs_bl = rs_bl
	self.rs_br = rs_br 
	self.borders = {rs_b,rs_t,rs_l,rs_r,rs_tl,rs_tr,rs_bl,rs_br}
	

	for k,v in pairs(self.borders) do
		v.OnClick = sResize
		v.OnEnter = rmenter
		v.OnLeave = rleave
	end 
	
	
	mv.OnClick = function(s)  
		if not self.fixedpos then
			self:Show()
			panel.start_drag(self,1) 
		end 
	end
	--dockbtn.OnClick = sDock 
	bc.OnClick = function() 
		self:Close() 
		local OnClose = self.OnClose
		if OnClose then
			OnClose(self)
		end
	end
	
	local fixedsize = self.fixedsize
	
	
	local sizeframe_width = 8--5
	local movepanel_height = 20
	
	local bordcol = gui.style:GetColor("Border")
	local backcol = gui.style:GetColor("WindowBack")
	local bordcola = 0--gui.style:GetAlpha("Border")
	local backcola = gui.style:GetAlpha("WindowBack")
	self:SetColor(backcol)
	self:SetAlpha(backcola)
	self:SetTextOnly(true)
	inner:SetColor(backcol)
	inner:SetAlpha(backcola)
	inner:SetSize(10,10)
	
	
	
	if not fixedsize then 
		for k,v in pairs(self.borders) do
			v:SetSize(sizeframe_width,sizeframe_width)
			v:SetColorAuto(bordcol)
			v:SetAlpha(bordcola)
		end
		self:Add(rs_b) rs_b:Dock(DOCK_BOTTOM)
		self:Add(rs_t) rs_t:Dock(DOCK_TOP)
		self:Add(rs_l) rs_l:Dock(DOCK_LEFT)
		self:Add(rs_r) rs_r:Dock(DOCK_RIGHT)
		
		rs_t:Add(rs_tl) rs_tl:Dock(DOCK_LEFT)
		rs_t:Add(rs_tr) rs_tr:Dock(DOCK_RIGHT)
		rs_b:Add(rs_bl) rs_bl:Dock(DOCK_LEFT)
		rs_b:Add(rs_br) rs_br:Dock(DOCK_RIGHT)
	
	end
	--[[
	local texture_corner = "textures/gui/menu/corner.png"
	local texture_hedge = "textures/gui/menu/edge.png"
	local texture_vedge = "textures/gui/menu/edge2.png"
	
	gui.FromTable({ 
		textonly = true,
		subs={
			{class="border",dock = DOCK_TOP, textonly = true,subs ={
					{class="border corner",dock=DOCK_LEFT,dir = Point(-1,-1)},
					{class="border corner",dock=DOCK_RIGHT,dir = Point(1,-1), rotation = -90},
					{class="border vedge",dock=DOCK_FILL,dir = Point(0,-1)}
			}},
			{class="border",dock = DOCK_BOTTOM, textonly = true,subs ={
					{class="border corner",dock=DOCK_LEFT,dir = Point(-1,1), rotation = 90},
					{class="border corner",dock=DOCK_RIGHT,dir = Point(1,1), rotation = 180},
					{class="border vedge",dock=DOCK_FILL,dir = Point(0,1)}
			}},
			{class="border hedge",dock=DOCK_LEFT,dir = Point(-1,0)},
			{class="border hedge",dock=DOCK_RIGHT,dir = Point(1,0)},
		},
	},
	self,
	{
		border = { 
			type='button',
			size = {16,16},
			color = "#009432",
			--mouseenabled = false, 
			OnClick = sResize,
			OnEnter = rmenter,
			OnLeave = rleave
		},
		corner = {texture = texture_corner},
		hedge = {texture = texture_hedge}, 
		vedge = {texture = texture_vedge}
	}) 
	]]

	self.mv    = mv
	self.header = mv
	self.bc    = bc
	self.inner = inner
		--self.dockbtn  = dockbtn
	 
	mv:SetSize(movepanel_height,movepanel_height)
	----rs_tl:SetSize(sizeframe_width,sizeframe_width)
	----rs_tr:SetSize(sizeframe_width,sizeframe_width)
	----rs_bl:SetSize(sizeframe_width,sizeframe_width)
	----rs_br:SetSize(sizeframe_width,sizeframe_width)
	--dockbtn:SetSize(movepanel_height,movepanel_height)
	
	bc:SetSize(movepanel_height,movepanel_height)
	
	self:Add(mv) mv:Dock(DOCK_TOP)
	self:Add(inner) inner:Dock(DOCK_FILL)
	
	mv:Add(bc) bc:Dock(DOCK_RIGHT)
	--self:Add(dockbtn)
	 
	
	function self:SetTitle(text)
		mv:SetText(text)
	end
	
	self:SetMinSize(40,40)
	self:SetSize(400,400) --Resize(Point(400,400))
	gui.ApplyStyle(self,green_style,'window')
end
function PANEL:SetContents(panel)
	self.inner:Add(panel)
end
PANEL.contents_info = {type = 'children_array',add = PANEL.SetContents}

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
 
function PANEL:SetTitle(str)
	self.mv:SetText(str)
end