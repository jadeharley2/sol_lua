
function PANEL:Init() 
	self:SetColor(Vector(0,0,0)) 
	local tabButtonPanel = panel.Create() 
	local framePanel = panel.Create() 
	tabButtonPanel:SetSize(30,20)
	tabButtonPanel:Dock(DOCK_TOP)
	framePanel:SetSize(30,30)
	framePanel:Dock(DOCK_FILL)
	
	--local bordcol = gui.style:GetColor("Border")
	local backcol =Vector(0,0,0)-- gui.style:GetColor("WindowBack")
	framePanel:SetColor(backcol)
	tabButtonPanel:SetColor(gui.style:GetColor("Header"))
	
	self.plist = {}
	self.pnames = {}
	self.pbtns = {}
	self.tabButtonPanel = tabButtonPanel
	self.framePanel = framePanel
	
	self:Add(tabButtonPanel)  
	self:Add(framePanel)  
end

function PANEL:AddTab(name,sub,btnmodt)
MsgN("tTAb",name,sub)
	local b = panel.Create("button") 
	local plist = self.plist
	local pnames = self.pnames
	local pbtns = self.pbtns
	b:SetText(name or "Tab")
	local tabButtonPanel = self.tabButtonPanel
	b:SetSize(100,30)
	b:Dock(DOCK_LEFT)
	b.toggleable = true
	b.group = 'tabs'
	tabButtonPanel:Add(b)

	local lid = #plist+1
	plist[lid] = sub 
	pnames[lid] = name
	pbtns[lid] = b
	b.OnClick = function() self:ShowTab(lid) end
	
	local bordcol = gui.style:GetColor("Border")
	local separator = panel.Create()
	separator:SetSize(3,3) 
	separator:Dock(DOCK_LEFT)
	separator:SetColor(bordcol)
	tabButtonPanel:Add(separator)

	if btnmodt then
		gui.FromTable(btnmodt,b)
	end
	self:ShowTab(lid)
end
function PANEL:ShowTab(id)
	local plist = self.plist
	local framePanel = self.framePanel
	local pp = plist[id]
	MsgN("AA",id,pp)
	if pp then
		framePanel:Clear()
		framePanel:Add(pp)
		pp:SetPos(0,0)
		pp:Dock(DOCK_FILL)
		framePanel:UpdateLayout()
		self:UpdateLayout()
		if self.pbtns then
			for k,v in pairs(self.pbtns) do
				if k==id then v:SetState('pressed')
				else
					v:SetState('idle')
				end
			end
		end
		local OnTabChanged = self.OnTabChanged 
		if OnTabChanged then
			OnTabChanged(self,id,self.pnames[id])
		end
	end
end 

PANEL.tabs_info = {type = 'children_dict',add = PANEL.AddTab}