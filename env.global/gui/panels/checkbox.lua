
function PANEL:Init()
	
	self.value = false
	
	self:SetSize(22,22) 
	self:SetColor(Vector(0,0,0)) 
	
	local inp = panel.Create("button")
	inp:SetColors(Vector(50,150,50)/256,Vector(150,50,50)/256,Vector(100,100,100)/256) 
	inp:SetSize(18,18) 
	inp:SetToggleable(true)
	inp.OnClick = function(b)
		self.value = not self.value 
		--self:UpdateColor()
		if self.OnValueChanged then
			self.OnValueChanged(self,self.value)
		end
	end
	self.inp = inp
	self:Add(inp) 
	--self:UpdateColor()
end

function PANEL:SetValue(val)
	self.value = val
	if val then
		self.inp:SetState("pressed")
	else
		self.inp:SetState("idle")
	end
	--self:UpdateColor()
end
function PANEL:GetValue()
	return self.value
end

--function PANEL:UpdateColor()
--	local color = Vector(50,150,50)/256
--	if not self.value then
--		color = Vector(150,50,50)/256
--	end
--	self.inp.downcolor = color / 2
--	self.inp.upcolor = color 
--	self.inp.hovercolor = color * 1.1
--	self.inp:SetColor(self.inp.hovercolor)
--end