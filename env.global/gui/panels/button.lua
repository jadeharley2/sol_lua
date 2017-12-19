
local LAST_BUTTON_PRESSED = false 
function PANEL:Init()
	self.downcolor = gui.style:GetColor("Button")-- Vector(1,0,0)
	self.upcolor = gui.style:GetColor("ButtonActive")--Vector(0.8,0.8,0.8)
	self.hovercolor = gui.style:GetColor("ButtonHovered")--Vector(0.8,0.4,0.4)
	self:SetColor( self.upcolor) 
end
function PANEL:SetColors(down,up,hover) 
	self.downcolor = down or  gui.style:GetColor("Button")-- Vector(1,0,0)
	self.upcolor = up or  gui.style:GetColor("ButtonActive")--Vector(0.8,0.8,0.8)
	self.hovercolor = hover or  gui.style:GetColor("ButtonHovered")--Vector(0.8,0.4,0.4)
	self:SetColor( self.upcolor) 
end
function PANEL:SetTextColors(down,up,hover) 
	self.flashtext = true
	self.textdowncolor = down  
	self.textupcolor = up  
	self.texthovercolor = hover  
	self:SetTextColor( self.textupcolor)
end

function PANEL:SetColorAuto(color,mul)
	mul = mul or 0.5
	self.downcolor = color*(1-mul)
	self.upcolor = color
	self.hovercolor = color*(1+mul)
	self:SetColor( self.upcolor) 
end

function PANEL:SetTextColorAuto(color,mul)
	mul = mul or 0.5
	self.flashtext = true
	self.textdowncolor = color*(1-mul)
	self.textupcolor = color
	self.texthovercolor = color*(1+mul)
	self:SetTextColor( self.textupcolor) 
end
function PANEL:SetPulse(period)
	self.cooldown = period
end

function PANEL:MouseDown(pulse) 

	if input.leftMouseButton() and 
		( 
			(not LAST_BUTTON_PRESSED and not MOUSE_LOCKED)
			or
			(LAST_BUTTON_PRESSED == self and self.cooldown)
		) then 
		if self.cooldown then
			local ct = CurTime()
			local nd = self.nextdown
			if not nd or nd < ct then
				self.nextdown = ct + self.cooldown
			else
				return nil
			end
			if pulse ~= true then
				hook.Add("main.predraw", "gui.button.pulse", function()
					self:MouseDown(true)
					if not input.leftMouseButton() then
						hook.Remove("main.predraw", "gui.button.pulse")
					end
				end)
			end
		end
		
		
		self:SetColor( self.downcolor) 
		if self.flashtext then self:SetTextColor( self.textdowncolor) end
		local OnClick = self.OnClick
		if OnClick then
			OnClick(self)
		end
		LAST_BUTTON_PRESSED = self
		if pulse ~= true then
			LockMouse()
			hook.Add("input.mouseup", "gui.button.down", function() UnlockMouse() LAST_BUTTON_PRESSED = false hook.Remove("input.mouseup", "gui.button.down") end)
		end
		
	end
end
function PANEL:MouseUp()
	self:SetColor( self.upcolor) 
	if self.flashtext then self:SetTextColor( self.textupcolor) end
	--if not input.leftMouseButton() then
	--	LAST_BUTTON_PRESSED = false 
	--end
end
function PANEL:MouseEnter() 
	self:SetColor( self.hovercolor) 
	if self.flashtext then self:SetTextColor( self.texthovercolor) end
end
function PANEL:MouseLeave() 
	self:SetColor( self.upcolor) 
	if self.flashtext then self:SetTextColor( self.textupcolor) end
end

function PANEL:Test() 
	-- при вызове через панель:Test()
		MsgN(self) -- >> панель
	-- при вызове через панель.Test()
		MsgN(self) -- >> ПУСТО
end

function PANEL.Test() 
	MsgN(self) -- >> ПУСТО
end

function PANEL.Test(self) 
	-- при вызове через панель:Test()
		MsgN(self) -- >> панель
	-- при вызове через панель.Test()
		MsgN(self) -- >> ПУСТО
end