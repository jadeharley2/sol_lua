
function PANEL:Init()
	self:SetSize(16,128)  
	self:SetTexture("textures/gui/grad_hue.png") 
	self:UpdateLayout()
end
function PANEL:MouseClick() 
	local cpos = self:GetLocalCursorPos() 
	local lpos = cpos/self:GetSize() 
	local h = (lpos.y*0.5+0.5)*360  
	local cv = HSVToColor(h,1,1)
	local OnPick = self.OnPick 
	if OnPick then
		OnPick(self,cv)
	end
end 
 