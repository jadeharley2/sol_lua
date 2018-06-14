PANEL.basetype = "window"

function PANEL:Init()
	--PrintTable(self)
	self.fixedsize = true
	self.base.Init(self)
	local inner = self.inner
	self:SetSize(600,500)
	self:SetColor(Vector(0.6,0.6,0.6))
	 
	local list = panel.Create("list")  
	list:Dock(DOCK_FILL)
	list:SetSize(300,300)
	
	list.hasback = true
	
	self.list = list
	inner:Add(list)
end 
function PANEL:RefreshList()
	local list = self.list
	local li = {}
	for k,v in pairs(player.GetAll()) do
		li[k] = v:GetName()
	end
	list.lines = li
	list:Refresh()
end
function PANEL:Open() 
	self:RefreshList()
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
local PAN = PANEL
PAN.SST = false 
hook.Add("input.keydown", "tabmenu",function()
	if input.KeyPressed(KEYS_TAB) then 
		PAN.SST = PAN.SST or panel.Create("window_serverstatus") 
		PAN.SST:SetCanRaiseMouseEvents(false)
		if PAN.SST.opened then
			PAN.SST.opened = false
			PAN.SST:Close()
		else
			PAN.SST.opened = true
			PAN.SST:Open()
		end
	end
end )