local instance = false
function ColorPicker(color,callback,custompos)
	if instance then
		instance:Close()
	end
	b = panel.Create("colorpicker")
	local mpos = (custompos or input.getInterfaceMousePos()*GetViewportSize())+b:GetSize()*Point(1,-1) 
	b:SetValue(color) 
	b:SetPos(mpos) 
	b:AddButtons(callback)
	b:Show()
	instance = b
end

function PANEL:Init()
	self:SetSize(128+32,128) 
	self.sub = panel.Create("panel",{size={20,0},dock=DOCK_BOTTOM,color={0,0,0}},self)
	self.dis = panel.Create("panel",{size={16,16},dock=DOCK_LEFT},self)
	self.hue = panel.Create("colorhue",{dock=DOCK_RIGHT},self)
	self.box = panel.Create("colorbox",{dock=DOCK_FILL},self) 
	self.hue.OnPick = function(s,c)
		self.box:SetColor(c)
		local rc = self.box:CalcColor()
		self:UpdateColor(rc) 
	end
	self.box.OnPick = function(s,c) 
		self:UpdateColor(c) 
	end 
end
function PANEL:AddButtons(onpick,onend) 
	self:SetSize(128+32,128+20)
	self.sub:SetSize(20,20)
	self.sok = panel.Create("button",{text = "Ok",size={64+16,20},dock=DOCK_LEFT},self.sub)
	self.scn = panel.Create("button",{text = "Cancel",size={64+16,20},dock=DOCK_RIGHT},self.sub)

	self.sok:SetMargin(2,2,2,2)
	self.scn:SetMargin(2,2,2,2)
	self:UpdateLayout()
	self.sok.OnClick = function()
		self:Pick(self.color)
		if onend then onend(self) 
		else
			if not self:GetParent() then
				self:Close()
			end
		end
	end
	self.scn.OnClick = function()
		if onend then onend(self) 
		else
			if not self:GetParent() then
				self:Close()
			end
		end
	end
	self.Pick = onpick
	self:UpdateLayout()
end
function PANEL:SetValue(c)
	local hue,s,v = ColorToHSV(c) 
	self.box:SetColor(HSVToColor(hue,1,1))
	self.box:SetSlider(1-s,v)
	self:UpdateColor(c,true)
end
function PANEL:UpdateColor(c,nr)
	self.color = c
	self.dis:SetColor(c)
	if not nr then
		local OnPick = self.OnPick
		if OnPick then
			OnPick(self,c)
		end
	end
end
function PANEL:Pick(c)
end

 