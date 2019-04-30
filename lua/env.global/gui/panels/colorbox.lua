
PANEL.basetype = "slider"

function PANEL:Init()
	self:SetSize(128,128)  
	self:SetColor(Vector(1,0,0))

	self.gray = panel.Create("panel",{
		texture = "textures/gui/grad_r.png" ,
		color = {1,1,1}
	},self) 
	self.black = panel.Create("panel",{
		texture = "textures/gui/grad_d.png",
		color = {0,0,0}
	},self) 
	
	self.gray:Dock(DOCK_FILL)
	self.black:Dock(DOCK_FILL)
	self.gray:SetCanRaiseMouseEvents(false)
	self.black:SetCanRaiseMouseEvents(false) 

	self.base.Init(self)
	self:UpdateLayout()
end
function PANEL:OnSlide(x,y)
	--local lpos = self:GetLocalCursorPos()/self:GetSize()
	self.saturation = 1-x--0.5-lpos.x*0.5
	self.value = y--lpos.y*0.5+0.5

	local rezColor = self:CalcColor()

	MsgN(saturation,value)

	local OnPick = self.OnPick
	if OnPick then
		OnPick(self,rezColor)
	end 
end
function PANEL:CalcColor()
	local baseColor = self:GetColor()
	local h,s,v = ColorToHSV(baseColor)
	local rezColor = HSVToColor(h,self.saturation,self.value) 
	self.color = rezColor
	return rezColor
end


 