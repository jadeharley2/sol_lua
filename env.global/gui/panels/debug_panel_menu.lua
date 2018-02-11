 

function PANEL:Init() 
	local vsize = GetViewportSize()
	self:SetColor(Vector(0,0,0))
	self:SetSize(vsize.x,15)
	self:SetPos(0,vsize.y-15)
	
	
	local btnEditor = panel.Create("button")
	btnEditor:SetSize(15,15)
	btnEditor:SetColorAuto(Vector(0.8,0.8,0))
	btnEditor.OnClick = function() editor.Toggle() end
	btnEditor:Dock(DOCK_LEFT)
	self:Add(btnEditor)
end 

