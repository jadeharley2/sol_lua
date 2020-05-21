 

function PANEL:Init()
	--PrintTable(self) 
	   
	self:SetSize(100,100)
	self:SetColor(Vector(0.6,0.6,0.6)/7) 
	 
	--local drop_visualizer_panel = panel.Create()  
	--drop_visualizer_panel:SetCanRaiseMouseEvents(false) 
	--drop_visualizer_panel:SetColor(Vector(0,0,0))
	--drop_visualizer_panel:SetAlpha(0.2)
	--drop_visualizer_panel:SetSize(0,0) 
	--drop_visualizer_panel:SetVisible(false)
	--self:Add(drop_visualizer_panel)
	--self.drop_visualizer_panel = drop_visualizer_panel
	
	local drop_visualizer = panel.Create()  
	drop_visualizer:SetCanRaiseMouseEvents(false) 
	drop_visualizer:SetColor(Vector(0,1,0))
	drop_visualizer:SetAlpha(0.2)
	drop_visualizer:SetSize(0,0) 
	drop_visualizer:SetVisible(false)
	self:Add(drop_visualizer)
	self.drop_visualizer = drop_visualizer
	
	local leftoverspace = panel.Create()  
	leftoverspace:SetCanRaiseMouseEvents(false) 
	leftoverspace:SetColor(Vector(1,0,0))
	leftoverspace:SetAlpha(0.2)
	leftoverspace:SetSize(0,0) 
	leftoverspace:SetVisible(false)
	self:Add(leftoverspace)
	self.leftoverspace = leftoverspace
	
	--local handle = panel.Create("button")   
	--handle:SetColorAuto(Vector(0.2,0.2,0.5))
	--handle:SetSize(20,20)
	--handle:Dock(DOCK_TOP)
	--handle.OnClick = function(s)
	--	----panel.start_drag(self,1)
	--	--if not panel.current_drag then
	--	--	self:SetCanRaiseMouseEvents(false) 
	--	--	self:SetColor(Vector(0.9,0.9,0.9)/3)
	--	--	self:SetAlpha(0.3)
	--	--	self:Dock(DOCK_NONE)
	--	--	--self:SetSize(100,100)
	--	--	--
	--	--	
	--	--	local p = self:GetParent()
	--	--	p:Remove(self)
	--	--	if p.DragDrop then
	--	--		self:SetPos(self:GetPos()+p:GetPos())
	--	--		p:GetParent():Add(self)
	--	--	else
	--	--		p:Add(self)
	--	--	end 
	--	--	if not panel.start_drag(self,1) then
	--	--		self:OnDropped()
	--	--	end
	--	--end
	--end  
	--self:Add(handle)
	
	
end  

function PANEL:OnDropped(onto)
	self:SetCanRaiseMouseEvents(true)
	self:SetColor(Vector(0.6,0.6,0.6)/3)
	self:SetAlpha(1) 
	 
end



function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end


function PANEL:DragEnter(node) 
	MsgN("enter",node)
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
function PANEL:GetDockSlot(node)

	local lo = self.leftoverspace
	local dv = self.drop_visualizer
	self:Remove(dv)
	self:Remove(lo)
	lo:SetVisible(true)
	lo:Dock(DOCK_FILL)
	self:Add(lo) 
	self:UpdateLayout()
	local ssLO = lo:GetSize()  
	local posLO = lo:GetLocalCursorPos()/ssLO
	self:Remove(lo) 
	self:Add(dv)
	local ss = ssLO --self:GetSize()
	local sx, sy = ss.x/4, ss.y/3
	if node.fixedheight then
		sy = node:GetSize().y
	end
	if node.fixedwidth then
		sx = node:GetSize().x
	end
	--local pos = self:GetLocalCursorPos()/ss 
	
	if node.fixedwidth then
		if posLO.x< 0 then 
			return DOCK_LEFT, sx, sy
		elseif posLO.x >0.5 then
			return DOCK_RIGHT, sx, sy
		end 
	elseif node.fixedheight then
		if posLO.y< 0 then
			return DOCK_BOTTOM, sx, sy
		else 
			return DOCK_TOP, sx, sy 
		end
	else
		if posLO.x< -0.5 then 
			return DOCK_LEFT, sx, sy
		elseif posLO.x >0.5 then
			return DOCK_RIGHT, sx, sy
		else 
			if posLO.y< -0.5 then
				return DOCK_BOTTOM, sx, sy
			elseif posLO.y >0.5 then
				return DOCK_TOP, sx, sy
			else
				return DOCK_FILL, sx, sy 
			end 
		end 
	end
end
function PANEL:DragHover(node)  
	local dvp = self.drop_visualizer_panel
	local dv = self.drop_visualizer
	local ss = self:GetSize()
	--dv:SetSize(node:GetSize())
	local pos = self:GetLocalCursorPos()/ss
	local lastdock = dv:GetDock()
	
	local newdock, nx,ny = self:GetDockSlot(node)
	--if pos.x< -0.5 then 
	--	newdock = DOCK_LEFT
	--elseif pos.x >0.5 then
	--	newdock =DOCK_RIGHT  
	--else
	--	if pos.y< -0.5 then
	--		newdock =DOCK_BOTTOM  
	--	elseif pos.y >0.5 then
	--		newdock =DOCK_TOP  
	--	else
	--		newdock =DOCK_FILL  
	--	end 
	--end
	newdock = newdock or lastdock
	
	if newdock ~= lastdock then
		MsgN("new",newdock,lastdock)
		--local sp = self:GetPos()
		--dvp:SetSize(ss.x,ss.y)
		--dvp:SetPos(sp.x,sp.y)
		--self:Remove(dvp)
		--self:GetParent():Add(dvp)
		--dvp:SetVisible(true)
		
		dv:SetSize(nx or ss.x/4,ny or ss.y/3)
		dv:SetMargin(node:GetMargin())
		self:Remove(dv)
		dv:Dock(newdock)
		self:Add(dv)
		dv:SetVisible(true)
		self:UpdateLayout()
	end
end
function PANEL:DragDrop(node) 
	
	--local dvp = self.drop_visualizer_panel
	--dvp:GetParent():Remove(dvp)
	--self:Add(dvp)
	--dvp:SetPos(99999,0) 
	--dvp:SetVisible(false)
	--node:Close()
	node:GetParent():Remove(node)

	local dv = self.drop_visualizer
	dv:SetPos(99999,0)
	dv:Dock(DOCK_NONE) 
	dv:SetVisible(false)
	
	local ss = self:GetSize()
	--local pos = self:GetLocalCursorPos()/ss
	
	local newdock, nx,ny =self:GetDockSlot(node)  

	node:SetSize(nx or ss.x/4,ny or ss.y/3)
	node:Dock(newdock)
	self:Add(node)
	MsgN("DROP!",node,newdock)
	--if pos.x< -0.5 then
	--	node:Dock(DOCK_LEFT)
	--	self:Add(node)
	--elseif pos.x >0.5 then
	--	node:Dock(DOCK_RIGHT)
	--	self:Add(node)
	--else
	--	if pos.y< -0.5 then
	--		node:Dock(DOCK_BOTTOM)
	--		self:Add(node)
	--	elseif pos.y >0.5 then
	--		node:Dock(DOCK_TOP)
	--		self:Add(node)
	--	else
	--		node:Dock(DOCK_FILL)
	--		self:Add(node)
	--	end 
	--end
	self:UpdateLayout()
end