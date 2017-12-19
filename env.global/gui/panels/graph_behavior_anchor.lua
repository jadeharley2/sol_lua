
local CURRENT_SELECTED_ANCHOR = false
 

PANEL.basetype = "button"
local t_manchor = LoadTexture("gui/manchor.png")
function PANEL:Init() 
	self.base.Init(self) 
	self:SetSize(8,8)
	self:SetTexture(t_manchor)
	self.base.SetColorAuto(self, Vector(0.7,0.7,0.7),0.2)
end
function PANEL:Attach(node)
	self.editor = node.editor
	self.node = node
	 
	self:SetPos(50,50)
	
	node:Add(self)
end
function PANEL:OnClick() 
	if CURRENT_SELECTED_ANCHOR and CURRENT_SELECTED_ANCHOR ~= self then
		
		
		self:CreateLink(self,CURRENT_SELECTED_ANCHOR) 
		CURRENT_SELECTED_ANCHOR = false
	else
		self.base.SetColorAuto(self,Vector(0.7,0.5,0.2),0.2)
		CURRENT_SELECTED_ANCHOR = self
	end
end
function PANEL:GetValue()
	MsgN("GET ",self.name," : ",self.value)
	return self.value
end
function PANEL:SetValue(val)
	MsgN("SET ",self.node.name.."."..self.name," : ",val)
	self.value = val
end
function PANEL:CreateLink(a,b)
	
	local from = a 
	local to = b 
	  
	 
	
	to.base.SetColorAuto(to,Vector(0.2,0.7,0.2),0.2)
	from.base.SetColorAuto(from,Vector(0.2,0.7,0.2),0.2)

	local curve = panel.Create("curve")
	curve:SetSize(2,2)
	
	
	curve.from = from
	curve.to = to 
	curve.bend = 0
	from.editor.curvelayer:Add(curve)
	curve:SetColor(Vector(83,164,255)/255) 
	
	cuup[#cuup+1] = curve
	GUI_CURVE_UPDATE()
end

 