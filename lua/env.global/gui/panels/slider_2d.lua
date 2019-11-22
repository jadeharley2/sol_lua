
function PANEL:Init() 
	self.pointer = panel.Create("panel",{
		texture = "textures/gui/pointer.png",
		size = {8,8},
		color = {1,1,1}
	},self) 
	self.pointer:SetCanRaiseMouseEvents(false) 
end
function PANEL:MouseClick()
	local cpos = self:GetLocalCursorPos()
	self.pointer:SetPos(cpos)
	local lpos = cpos/self:GetSize()
	local vpx = lpos.x*0.5+0.5
	local vpy = lpos.y*0.5+0.5  
	local OnSlide = self.OnSlide
	if OnSlide then
		OnSlide(self,vpx,vpy)
	end 
end
function PANEL:SetSlider(x,y)
	local sz = self:GetSize()
	self.pointer:SetPos((x*2-1)*sz.x,(y*2-1)*sz.y)
end
 