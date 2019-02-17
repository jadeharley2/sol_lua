  
local t_mpanel = LoadTexture("gui/tab_70x30.png") 
local activeTabColor = Vector(0.2,0.2,0.2)
local activeTabTextColor = Vector(0.7,0.7,0.7)
 
function PANEL:Init()
	--PrintTable(self) 
	self.tdid = true
	self:SetSize(100,100)
	self:SetColor(Vector(0.6,0.6,0.6)/7) 
	   
	local left = panel.Create("button")  
	left:Dock(DOCK_LEFT) 
	--left:SetCanRaiseMouseEvents(false) 
	self:Add(left) 
	local right = panel.Create("button") 
	right:Dock(DOCK_RIGHT) 
	--right:SetCanRaiseMouseEvents(false) 
	self:Add(right) 
	local top = panel.Create("button")   
	top:Dock(DOCK_TOP) 
	--top:SetCanRaiseMouseEvents(false) 
	self:Add(top) 
	local bottom = panel.Create("button")   
	bottom:Dock(DOCK_BOTTOM) 
	--bottom:SetCanRaiseMouseEvents(false)  
	self:Add(bottom)
	self:SetMargin(5,5,5,5)
	
	local handle = panel.Create("button")   
	handle:SetColorAuto(Vector(0.2,0.2,0.5),0)
	handle:SetSize(10,20)
	handle:Dock(DOCK_TOP)
	handle.OnClick = function(s)
		self:StartDrag()
	end  
	self:Add(handle)
	
	
	local handle_safezone = panel.Create("button")   
	handle_safezone:SetColorAuto(Vector(0.2,0.2,0.5),0)
	handle_safezone:SetSize(25,10)
	handle_safezone:Dock(DOCK_LEFT)
	handle_safezone.OnClick = function(s) self:StartDrag() end  
	handle:Add(handle_safezone)
	
	local handle_addtab = panel.Create("button")   
	handle_addtab:SetColorAuto(activeTabColor*0.5)
	handle_addtab:SetTextColorAuto(activeTabTextColor*0.5)
	handle_addtab:SetSize(25,25)
	handle_addtab:SetText("+")
	handle_addtab:SetTextAlignment(ALIGN_CENTER)
	handle_addtab:SetTexture(t_mpanel) 
	handle_addtab:Dock(DOCK_LEFT)
	--handle_addtab:SetTextOnly(true)
	handle_addtab.OnClick = function(s)  
		local context = {
			{text = "blank",action = function() local p = panel.Create() p:SetColor(Vector(0,0,0)) self:AddTab("blank",p) end},  
			{text = "lua",action = function() local p = panel.Create("editor_panel_classtree") self:AddTab("lua",p) end},  
		} 
		
		ContextMenu(self,context)
	end  
	handle:Add(handle_addtab)
	self.handle_addtab = handle_addtab
	
	local framePanel = panel.Create() 
	framePanel:SetSize(30,30)
	framePanel:Dock(DOCK_FILL)
	framePanel:SetColor(activeTabColor) 
	framePanel:SetPadding(5,5,5,5)
	self:Add(framePanel)
	

	
	self.plist = {}
	self.slist = {}
	self.tabButtonPanel = handle
	self.framePanel = framePanel
	
	
	local drop_visualizer = panel.Create()  
	drop_visualizer:SetCanRaiseMouseEvents(false) 
	drop_visualizer:SetColor(Vector(0,1,0))
	drop_visualizer:SetAlpha(0.2)
	drop_visualizer:SetSize(0,0) 
	drop_visualizer:SetVisible(false)
	self:Add(drop_visualizer)
	self.drop_visualizer = drop_visualizer
	
	--local tabs = panel.Create("tabmenu")   
	----tabs:SetColorAuto(Vector(0.2,0.2,0.5))
	--tabs:SetSize(10,10)
	--tabs:Dock(DOCK_FILL) 
	--self:Add(tabs)
	--self.tabs = tabs
	
	
	self.sides = {left,right,top,bottom}
	self.left = left
	self.right = right
	self.top = top
	self.bottom = bottom
	
	bottom.dir = Point(0,1)
	top.dir = Point(0,-1)
	left.dir = Point(-1,0)
	right.dir = Point(1,0)
	
	 
	local sResize = function(s)
		panel.start_resize(self,1,s.dir)
	end 
	local rmenter = function(s)  
		panel.cursor_resize(s.dir)
	end
	local rleave = function(s)  
		if not panel.current_resize then
			panel.SetCursor(0)
		end
	end 
	
	for k,v in pairs(self.sides) do
		v:SetColorAuto(Vector(0,0,0))
		v:SetSize(3,3)
		v.OnClick = sResize
		v.OnEnter = rmenter
		v.OnLeave = rleave
	end 
	
	
	self:UpdateLayout()
end  

function PANEL:StartDrag() 
	--panel.start_drag(self,1)
	if not panel.current_drag then
		self:SetCanRaiseMouseEvents(false) 
		self:SetColor(Vector(0.9,0.9,0.9)/3)
		self:SetAlpha(0.3)
		self:Dock(DOCK_NONE)
		--self:SetSize(100,100)
		--
		
		local p = self:GetParent()
		p:Remove(self)
		if p.DragDrop then
			self:SetPos(self:GetPos()+p:GetPos())
			p:GetParent():Add(self)
		else
			p:Add(self)
		end 
		if not panel.start_drag(self,1,true) then
			self:OnDropped()
		end
	end
end
	
function PANEL:AddTab(name,sub) 
	local b = panel.Create("button") 
	local plist = self.plist
	local slist = self.slist
	local tabButtonPanel = self.tabButtonPanel
	b:SetText(name or "Tab")
	b:SetSize(70,30)
	b:Dock(DOCK_LEFT)
	tabButtonPanel:Add(b) 
	plist[name] = sub 
	sub.listid = name
	b:SetTexture(t_mpanel)
	b:SetColorAuto(activeTabColor*0.5)
	b:SetTextColorAuto(activeTabTextColor*0.5)
	b.OnClick = function() 
		self:ShowTab(name) 
		if self:TabCount()>1 then
			panel.start_drag_on_shift(self,1,function(n) 
				local newn = panel.Create("testdragable")  
				newn:SetPos(n:GetPos()) 
				newn:SetSize(n:GetSize())
				self:RemoveTab(name)
				newn:AddTab(name,sub)
				n:GetParent():Add(newn)
				newn:ShowTab() 
				newn:UpdateLayout()
				newn:StartDrag()
				return false
			end) 
		else
			panel.start_drag_on_shift(self,1,function(n) 
				self:StartDrag()
				return false
			end)
		end
	end
	 
	
	slist[name] = {b,separator}
	
	local ha = self.handle_addtab 
	if ha then
		tabButtonPanel:Remove(ha)
		tabButtonPanel:Add(ha) 
	end
	self:UpdateLayout()
end
function PANEL:RemoveTab(name) 
	local plist = self.plist
	local slist = self.slist
	local tabButtonPanel = self.tabButtonPanel
	local t = plist[name]
	if t then
		for k,v in pairs(slist[name]) do
			tabButtonPanel:Remove(v)
		end
		plist[name] = nil
		slist[name] = nil
		t.listid = nil
		self:ShowTab() 
	end
	
	local ha = self.handle_addtab 
	if ha then
		tabButtonPanel:Remove(ha)
		tabButtonPanel:Add(ha) 
	end
end
function PANEL:ShowTab(id)
	local plist = self.plist
	local slist = self.slist
	local framePanel = self.framePanel
	local pp = false
	if id then
		pp = plist[id] 
	else
		for k,v in pairs(plist) do
			if v then
				pp = v
				break
			end
		end
	end
	framePanel:Clear()
	if pp then
		framePanel:Add(pp)
		pp:SetPos(0,0)
		pp:Dock(DOCK_FILL)
		
		for k,v in pairs(slist) do
			v[1]:SetColorAuto(activeTabColor*0.5)
			v[1]:SetTextColorAuto(activeTabTextColor*0.5)
		end
		if pp.listid then
			local btns = slist[pp.listid]
			if btns then
				btns[1]:SetColorAuto(activeTabColor)
				btns[1]:SetTextColorAuto(activeTabTextColor)
			end
		end
	end
	framePanel:UpdateLayout()
	self:UpdateLayout()
end 
function PANEL:TabCount()
	local plist = self.plist
	local tc=0
	for k,v in pairs(plist) do
		tc = tc + 1
	end
	return tc
end

function PANEL:SetContents(name,node) 
	self.tabs:AddTab(name,node)
end

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end



function PANEL:MouseDown(id)
	if id == 1 then
			
	elseif id == 2 then  
	elseif id == 3 then 
	end
end
function PANEL:OnDropped(onto)
	self:SetCanRaiseMouseEvents(true)
	self:SetColor(Vector(0.6,0.6,0.6)/7) 
	self:SetAlpha(1)
	MsgN("drop on ",onto)
	
	local side = self:GetDock()
	for k,v in pairs(self.sides) do v:SetVisible(false) end
	if side == DOCK_LEFT then
		self.right:SetVisible(true)
	elseif side == DOCK_RIGHT then
		self.left:SetVisible(true)
	elseif side == DOCK_TOP then
		self.bottom:SetVisible(true)
	elseif side == DOCK_BOTTOM then
		self.top:SetVisible(true)
	elseif side == DOCK_NONE then 
		for k,v in pairs(self.sides) do v:SetVisible(true) end
	end
end

function PANEL:DragEnter(node) 
	if self == node or not node.tdid then return end
	MsgN("enter",node)
	
	local dv = self.drop_visualizer 
	dv:Dock(DOCK_FILL) 
	dv:SetVisible(true)
	
	self:UpdateLayout()
end

function PANEL:DragExit(node) 
	MsgN("exit",node)
	
	local dv = self.drop_visualizer
	dv:SetPos(99999,0)
	dv:Dock(DOCK_NONE) 
	dv:SetVisible(false)
	
	self:UpdateLayout()
end
function PANEL:DragHover(node)  
end
--[[
function PANEL:DragHover(node)  
	if self == node then return end
	local dv = self.drop_visualizer
	local ss = self:GetSize()
	--dv:SetSize(node:GetSize())
	local pos = self:GetLocalCursorPos()/ss
	local lastdock = dv:GetDock()
	
	local newdock = lastdock
	if pos.x< -0.5 then 
		newdock = DOCK_LEFT
	elseif pos.x >0.5 then
		newdock =DOCK_RIGHT  
	else
		if pos.y< -0.5 then
			newdock =DOCK_BOTTOM  
		elseif pos.y >0.5 then
			newdock =DOCK_TOP  
		else
			newdock =DOCK_FILL  
		end 
	end
	
	if newdock ~= lastdock then
		MsgN("new",newdock,lastdock)
		dv:SetSize(ss.x/4,ss.y/3)
		--self:Remove(dv)
		dv:Dock(newdock)
		--self:Add(dv)
		dv:SetVisible(true)
		self:UpdateLayout()
	end
end]]
function PANEL:DragDrop(node) 
	if self == node or not node.tdid then return end
	MsgN("DROP!",node) 
	for k,v in pairs(node.plist) do
		self:AddTab(k,v)
	end
	node:GetParent():Remove(node) 
end
 