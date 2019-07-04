 
function PANEL:Init()   

	--local self = panel.Create()
	self:SetSize(150,150) 
	self:SetColor(Vector(100,100,100)/100)
	self:SetTexture(LoadTexture("gui/menu/sn_1024.dds")) 
	
end

function PANEL:OnShow()
	self:Think()
	hook.Add("main.predraw","loadscreen.think",function() self:Think() end)
end
function PANEL:OnHide()
	hook.Remove("main.predraw","loadscreen.think")
end
function PANEL:Think()
	self:SetRotation(self:GetRotation()-1)
	local sw = GetViewportSize()
	self:SetPos(sw.x-200,-sw.y+200)
end
