local layout = {
    size = {64,64},
    texture = "textures/gui/icons/com/folder.png", 
}
PANEL.basetype = "button"
function PANEL:Init() 
	self.fixedsize = true
    self.base.Init(self)  
	gui.FromTable(layout,self,{},self)
end  
function PANEL:SetItems(tab)
    self:SetAutoSize(true)
    for key, value in pairs(tab) do
        self:Add(gui.FromTable(value))
    end
end
function PANEL:OnClick()
    
end