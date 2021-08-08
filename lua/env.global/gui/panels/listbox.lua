 
 

function PANEL:Init() 
	self.rheight = 32
	self.iperrow = 6
	  
	self.rows = {}
	self.rowstyle = {color = {0.1,0.1,0.1}}
	
	local floater = panel.Create() 
	floater:SetColor(Vector(0,0.1,0))
	floater:SetTextOnly(true)
	self.floater = floater
	
	
	
	local ff_grid = panel.Create("floatcontainer") 
	ff_grid:Dock(DOCK_FILL)
	ff_grid:SetScrollbars(1) 
	ff_grid:SetFloater(floater) 
	ff_grid:SetColor(Vector(0,0,0))
	--ff_grid:SetTextOnly(true)
	ff_grid.inner:SetTextOnly(true)
	self.ff_grid = ff_grid
	self:Add(ff_grid)
	
end 

function PANEL:SetRowStyle(v) self.rowstyle = v end
function PANEL:GetRowStyle(v) return self.rowstyle end
function PANEL:SetRowHeight(v) self.rheight = v end
function PANEL:GetRowHeight(v) return self.rheight end
function PANEL:SetItemsPerRow(v) self.iperrow = v end
function PANEL:GetItemsPerRow(v) return self.iperrow end

function PANEL:AddItem(p)  
	local c = self.crow
	if not c then
		c = self:AddRow()
	else
		local cc = #c:GetChildren()
		local mc = self.iperrow
		if mc<=cc then
			c = self:AddRow()
		end
	end
	p:Dock(DOCK_LEFT)
	c:Add(p)
end
function PANEL:AddRow()  
	local r = panel.Create("panel",self.rowstyle)
	local rh = self.rheight
	r:SetColor(Vector(0,0,0))
	r:SetSize(rh,rh)
	r:Dock(DOCK_TOP)
	self.crow = r
	self.rows[#self.rows+1] = r  
	self.floater:Add(r)
	self.floater:SetSize(self:GetSize()[1] or 10, #self.rows*rh)
	return r
end
function PANEL:ClearItems()
	self.floater:Clear()
	self.crow = nil
	self.rows = {}
end


function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end