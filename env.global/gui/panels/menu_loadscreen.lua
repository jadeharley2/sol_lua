 
function PANEL:Init()  

	local self = panel.Create()
	self:SetSize(800,800) 
	self:SetColor(Vector(1,1,1)/1000)
	self:SetTexture(LoadTexture("gui/menu/sn_1024.dds")) 
	
	
	local loading_label = panel.Create()
	loading_label:SetText("Loading")
	loading_label:SetTextAlignment(ALIGN_CENTER)
	loading_label:SetColor(Vector(0,0,0))
	loading_label:SetTextColor( Vector(1,1,1))
	loading_label:SetSize(280,20)
	loading_label:SetPos(0,-520)
	
	self:Add(loading_label) 
end