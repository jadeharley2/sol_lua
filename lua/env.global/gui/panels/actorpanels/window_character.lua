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
	self.test = panel.Create("panel_craft")
	self.combine = panel.Create("panel_combine")
	self.deconstruct = panel.Create("panel_deconstruct")
	local sz = 32
	tabs.tabButtonPanel:SetSize(sz,sz)
	tabs:AddTab("Stats",self.stats,{texture = "textures/gui/panel_icons/stats.png",size = {sz,sz},text="",contextinfo = "status"})
	tabs:AddTab("Equipment",self.equip,{texture = "textures/gui/panel_icons/equipment.png",size = {sz,sz},text="",contextinfo = "equipment"})
	tabs:AddTab("Craft",self.test,{texture = "textures/gui/panel_icons/craft.png",size = {sz,sz},text="",contextinfo = "craft"})
	tabs:AddTab("Combine",self.combine,{texture = "textures/gui/panel_icons/combine.png",size = {sz,sz},text="",contextinfo="combine"})
	tabs:AddTab("Deconstruct",self.deconstruct,{texture = "textures/gui/panel_icons/deconstruct.png",size = {sz,sz},text="",contextinfo="deconstruct"})
	self:UpdateLayout()  
	tabs:ShowTab(3)
	tabs:ShowTab(2)
	tabs:ShowTab(1)
end 
function PANEL:Open() 
	self.test:Refresh()
	self:UpdateLayout() 
	self:Show() 
end
function PANEL:Set(actor) 
	local islocal = actor ==LocalPlayer()
	self.stats:Set(actor) 
	self.equip:Set(actor)
	if actor:HasTag(TAG_ACTOR) then
		self.tabs:SetTabVisible("Stats",true)
	else
		self.tabs:SetTabVisible("Stats",false)
	end
	if actor:GetComponent(CTYPE_EQUIPMENT) then
		self.tabs:SetTabVisible("Equipment",true)
	else
		self.tabs:SetTabVisible("Equipment",false)
	end
	if islocal then
		self.tabs:SetTabVisible("Deconstruct",true)
		self.tabs:SetTabVisible("Combine",true)
		self.tabs:SetTabVisible("Craft",true)
	else
		self.tabs:SetTabVisible("Deconstruct",false)
		self.tabs:SetTabVisible("Combine",false)
		self.tabs:SetTabVisible("Craft",false)
	end
	self:SetTitle(actor:GetName())
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