PANEL.basetype = "window"

function PANEL:Init()
	--PrintTable(self)
	self.base.Init(self)
	self:SetSize(500,200)
	self:SetColor(Vector(0.6,0.6,0.6))
	 
	local tabs = panel.Create("tabmenu")
	
	self.tabs = tabs
	tabs:Dock(DOCK_FILL)
	self:Add(tabs) 
	
	local grid = panel.Create("icongrid") 
	local inv = Inventory(30)
	
	local ab_grid = panel.Create("icongrid") 
	local ab_inv = Inventory(30)
	
	grid:SetSize(40,40)
	ab_grid:SetSize(40,40)
	
	self.inv = inv
	self.ab_inv = ab_inv
	
	--lua_run for k,v in list(chat.list.inv.list) do MsgN(v) end
	grid:Dock(DOCK_FILL)
	
	tabs:AddTab("INV",grid)
	tabs:AddTab("ABL",ab_grid)
	
	local ff_grid_floater = panel.Create("graph_grid")  
	ff_grid_floater:SetSize(4000,4000)
	ff_grid_floater:SetTextureScale(Point(4000/256,4000/256)) 
	
	local ff_grid = panel.Create("floatcontainer") 
	ff_grid:SetSize(200,200)  
	ff_grid:SetScrollbars(3)
	ff_grid:SetFloater(ff_grid_floater)
	tabs:AddTab("TEST",ff_grid)
	
	self.grid = grid
	self.ab_grid = ab_grid
	self.fixedsize = true
	
	--grid:Refresh()
	--ab_grid:Refresh()
	self:UpdateLayout() 
	tabs:ShowTab(2)
	tabs:ShowTab(1)
end
function PANEL:SetInventory(inv)
	self.inv = inv
	self.grid:LoadInventory(inv)
	self:UpdateLayout()
	self.grid:Refresh()
	self:UpdateLayout()
end
function PANEL:SetInventory2(inv)
	self.ab_inv = inv
	self.ab_grid:LoadInventory(inv)
	self:UpdateLayout()
	self.ab_grid:Refresh()
	self:UpdateLayout()
end
function PANEL:Open() 
	self:UpdateLayout()
	self.grid:LoadInventory(self.inv)
	self.grid:Refresh()
	self.ab_grid:LoadInventory(self.ab_inv)
	self.ab_grid:Refresh()
	self:UpdateLayout()
	self:Show()
end

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end