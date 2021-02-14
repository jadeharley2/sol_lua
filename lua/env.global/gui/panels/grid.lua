 
function PANEL:Init()
	--PrintTable(self) 
	self.columns = 10
	self.rows = 4
	self.rowheight = 48
	self.rows = {} 
	self:SetColor(Vector(0,0,0)) 
	self.rowcounter = 0
	self:SetAutoSize(false,true)
end
function PANEL:NewRow() 
	local newrow = panel.Create("panel",{color = {0,0,0},size={100,self.rowheight}})
	newrow:Dock(DOCK_TOP)
	self.rows[#self.rows+1] = newrow
	self:Add(newrow)
	return newrow
end
function PANEL:AddPanel(p)
	local c = self.rowcounter
	local row = self.currentrow
	if(not self.currentrow or c>self.columns-1) then
		c=0
		row = self:NewRow()
		self.currentrow = row
	end
	p:Dock(DOCK_LEFT)
	p:SetMargin(1,1,1,1)
	row:Add(p)
	self.rowcounter = c + 1
end
