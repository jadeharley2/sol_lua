PANEL.basetype = "window"

function PANEL:Init()
	--PrintTable(self)
	self.base.Init(self)
	self:SetSize(300,500)
	self:SetColor(Vector(0.6,0.6,0.6))
	 
	local tabs = panel.Create("tabmenu")
	
	self.tabs = tabs
	tabs:Dock(DOCK_FILL)
	self:Add(tabs) 
	self.fixedsize = true
	self.stats = panel.Create("panel_stats")
	self.equip = panel.Create("tabmenu")
	tabs:AddTab("Stats",self.stats)
	tabs:AddTab("Equipment",self.equip)
	self:UpdateLayout()  
	tabs:ShowTab(2)
	tabs:ShowTab(1)
end 
function PANEL:Open() 
	self:UpdateLayout() 
	self:Show()
end
function PANEL:Set(actor) 
	self.stats:Set(actor) 
end

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end