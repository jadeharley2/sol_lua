
function PANEL:Init() 
	self:SetColor(Vector(0,0,0)) 
	local tabButtonPanel = panel.Create() 
	local framePanel = panel.Create() 
	tabButtonPanel:Dock(DOCK_TOP)
	tabButtonPanel:SetSize(30,20)
	framePanel:SetSize(30,30)
	framePanel:Dock(DOCK_FILL)
	
	--local bordcol = gui.style:GetColor("Border")
	local backcol = gui.style:GetColor("WindowBack")
	framePanel:SetColor(backcol)
	tabButtonPanel:SetColor(gui.style:GetColor("Header"))
	
	self.plist = {}
	self.tabButtonPanel = tabButtonPanel
	self.framePanel = framePanel
	
	self:Add(tabButtonPanel)  
	self:Add(framePanel)  
end

function PANEL:AddTab(name,sub)
	local b = panel.Create("button") 
	local plist = self.plist
	b:SetText(name or "Tab")
	local tabButtonPanel = self.tabButtonPanel
	b:SetSize(100,30)
	b:Dock(DOCK_LEFT)
	tabButtonPanel:Add(b)
	local lid = #plist+1
	plist[lid] = sub 
	b.OnClick = function() self:ShowTab(lid) end
	
	local bordcol = gui.style:GetColor("Border")
	local separator = panel.Create()
	separator:SetSize(3,3) 
	separator:Dock(DOCK_LEFT)
	separator:SetColor(bordcol)
	tabButtonPanel:Add(separator)
	
end
function PANEL:ShowTab(id)
	local plist = self.plist
	local framePanel = self.framePanel
	local pp = plist[id]
	framePanel:Clear()
	framePanel:Add(pp)
	pp:SetPos(0,0)
	pp:Dock(DOCK_FILL)
	framePanel:UpdateLayout()
	self:UpdateLayout()
end
