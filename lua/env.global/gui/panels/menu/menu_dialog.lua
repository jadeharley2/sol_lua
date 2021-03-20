
--local tBorder = LoadTexture("gui/menu/edge.png")
--local tBorder2 = LoadTexture("gui/menu/edge2.png")
--local tCorner = LoadTexture("gui/menu/corner.png")
local button_color = Vector(38,12,8)/255
local panel_color = button_color*1.2
	
function PANEL:Init(name,height,width) 
	height = height or 200 
	width = width or 500
	name = name or "none"
	 
	self:SetSize(width,height) 
	--self:SetVisible(false)
	self:SetColor(panel_color/2)
	
	--local bcol = Vector(83,164,255)/255
	local bcol = "#A3CB38"--"#009432" --Vector(83,164,255)/255
	local pcol = Vector(0,0,0)
	
	local sub = panel.Create()
	sub:SetSize(width-20,height-20)  
	sub:SetColor(pcol)
	sub:SetAlpha(0.7)
	
	gui.Border(self,{
		-- size = 32,
		color = "#009432"
	})  
	
	
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
	self.label = label
	
	
	function self:SetupStyle(p)
		p:SetTextColor(bcol)--Vector(1,1,1)/2)
		p:SetColors(Vector(1,1,1),button_color,button_color*2)
		
		--p:SetTextColorAuto(bcol)
		--v:SetTextOnly(true)
		p:SetTextAlignment(ALIGN_CENTER) 
	end
end 

