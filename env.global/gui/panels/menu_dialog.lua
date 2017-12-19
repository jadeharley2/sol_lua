
local tBorder = LoadTexture("gui/menu/edge.png")
local tBorder2 = LoadTexture("gui/menu/edge2.png")
local tCorner = LoadTexture("gui/menu/corner.png")
local button_color = Vector(38,12,8)/255
local panel_color = button_color*1.2
	
function PANEL:Init(name,height,width)  
	height = height or 200
	width = width or 500
	 
	self:SetSize(width,height) 
	--self:SetVisible(false)
	self:SetColor(panel_color/2)
	
	local bcol = Vector(83,164,255)/255
	local pcol = Vector(0,0,0)
	
	local sub = panel.Create()
	sub:SetSize(width-20,height-20)  
	sub:SetColor(pcol)
	sub:SetAlpha(0.7)
	
	local border_t = panel.Create() border_t:Dock(DOCK_TOP)    self:Add(border_t) border_t:SetTextOnly(true)
	local border_d = panel.Create() border_d:Dock(DOCK_BOTTOM) self:Add(border_d) border_d:SetTextOnly(true)
	local border_l = panel.Create() border_l:Dock(DOCK_LEFT)   self:Add(border_l)
	local border_r = panel.Create() border_r:Dock(DOCK_RIGHT)  self:Add(border_r)
	
	local border_dl = panel.Create() border_dl:Dock(DOCK_LEFT)   border_d:Add(border_dl) border_dl:SetRotation(90)
	local border_dr = panel.Create() border_dr:Dock(DOCK_RIGHT)  border_d:Add(border_dr) border_dr:SetRotation(180)
	local border_dd = panel.Create() border_dd:Dock(DOCK_FILL)   border_d:Add(border_dd)
	
	local border_tl = panel.Create() border_tl:Dock(DOCK_LEFT)   border_t:Add(border_tl)
	local border_tr = panel.Create() border_tr:Dock(DOCK_RIGHT)  border_t:Add(border_tr) border_tr:SetRotation(-90)
	local border_tt = panel.Create() border_tt:Dock(DOCK_FILL)   border_t:Add(border_tt) 
	
	border_l:SetTexture(tBorder)
	border_r:SetTexture(tBorder)
	border_dl:SetTexture(tCorner)
	border_dr:SetTexture(tCorner)
	border_dd:SetTexture(tBorder2)
	border_tl:SetTexture(tCorner)
	border_tr:SetTexture(tCorner)
	border_tt:SetTexture(tBorder2)
	
	self:SetTextOnly(true)
	local borders = {border_t,border_d,border_l,border_r,border_dl,border_dr,border_tl,border_tr,border_dd,border_tt}
	for k,v in pairs(borders) do
		v:SetSize(16,16)
		v:SetColor(bcol)
		v:SetCanRaiseMouseEvents(false)
	end
	
	
	local label = panel.Create()
	label:SetText(name)
	label:SetTextAlignment(ALIGN_CENTER)
	label:SetSize(280,20)
	label:SetPos(0,height+15) 
	label:SetTextColor(bcol)
	label:SetColor(pcol)
	--label:SetAlpha(0.7)
	label:SetTextOnly(true)
	
	self:Add(sub)
	self:Add(label)
	
	self.sub = sub
	
	
	local bcol = Vector(83,164,255)/255
	function self:SetupStyle(p)
		p:SetTextColor(Vector(1,1,1)/2)
		p:SetColors(Vector(1,1,1),button_color,button_color*2)
		
		p:SetTextColorAuto(bcol)
		--v:SetTextOnly(true)
		p:SetTextAlignment(ALIGN_CENTER) 
	end
end

