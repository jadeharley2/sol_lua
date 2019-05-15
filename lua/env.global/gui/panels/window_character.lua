PANEL.basetype = "window"

GLOBAL_CEQPANEL = false 


function PANEL:Init()
	--PrintTable(self)
	self.fixedsize = true
	self.base.Init(self)
	self:SetSize(300,500)
	self:SetColor(Vector(0.6,0.6,0.6))
	 
	local tabs = panel.Create("tabmenu")
	
	self.tabs = tabs
	tabs:Dock(DOCK_FILL)
	self:Add(tabs)  
	self.stats = panel.Create("panel_stats")
	self.equip = panel.Create("panel_equipment")
	self.test = panel.Create("panel_itemmerger")
	tabs:AddTab("Stats",self.stats)
	tabs:AddTab("Equipment",self.equip)
	tabs:AddTab("test",self.test)
	self:UpdateLayout()  
	tabs:ShowTab(3)
	tabs:ShowTab(2)
	tabs:ShowTab(1)
end 
function PANEL:Open() 
	self:UpdateLayout() 
	self:Show()
end
function PANEL:Set(actor) 
	self.stats:Set(actor) 
	self.equip:Set(actor)
	GLOBAL_CEQPANEL = self.equip
end

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end