
function PANEL:Init()
	self:SetSize(16,128)  
	self:SetTexture("textures/gui/grad_hue.png") 
	self:UpdateLayout()
end
function PANEL:MouseDown()
	if not MouseLocked() then
		LockMouse() 
		hook.Add(EVENT_GLOBAL_PREDRAW,"slider",function(s)
			self:MouseClick()
		end)
		hook.Add("input.mouseup","slider",function(s) 
			hook.Remove(EVENT_GLOBAL_PREDRAW,"slider")
			hook.Remove("input.mouseup","slider")
			UnlockMouse()
		end)
	end
end 
function PANEL:MouseClick() 
	local cpos = self:GetLocalCursorPos() 
	local lpos = cpos/self:GetSize() 
	local h = (lpos.y)*360  
	local cv = HSVToColor(h,1,1)
	local OnPick = self.OnPick 
	if OnPick then
		OnPick(self,cv)
	end
end 
 