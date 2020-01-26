
local LAST_BUTTON_PRESSED = false 
function PANEL:Init()
	--self.upcolor = gui.style:GetColor("ButtonActive")--Vector(0.8,0.8,0.8)
	--self.hovercolor = gui.style:GetColor("ButtonHovered")--Vector(0.8,0.4,0.4)
	--self.downcolor = gui.style:GetColor("Button")-- Vector(1,0,0)
	--self:SetColor( self.upcolor) 
	
	local bactive = gui.style:GetColor("ButtonActive"):ToTable()
	local bpressed = gui.style:GetColor("Button"):ToTable()
	self:AddState("idle",{ 
		color = bactive,
		color2 = bpressed,
		gradangle = -45
	})
	self:AddState("hover",{color = gui.style:GetColor("ButtonHovered"):ToTable()})
	self:AddState("pressed",{color = bpressed}) 
	self:SetState("idle")
	
end
function PANEL:ApplyStyle(style)
	if style.button then self:SetStates(style.button) end
end

function PANEL:SetColors(down,up,hover) 
	--self.upcolor = up or  gui.style:GetColor("ButtonActive")--Vector(0.8,0.8,0.8)
	--self.hovercolor = hover or  gui.style:GetColor("ButtonHovered")--Vector(0.8,0.4,0.4)
	--self.downcolor = down or  gui.style:GetColor("Button")-- Vector(1,0,0)
	--self:SetColor( self.upcolor) 
	
	self:AddState("idle",{
		color = (up or gui.style:GetColor("ButtonActive")):ToTable(),
		color2 = (up or gui.style:GetColor("Button")):ToTable(),
		gradangle = -45
	})
	self:AddState("hover",{color = (hover or gui.style:GetColor("ButtonHovered")):ToTable()})
	self:AddState("pressed",{color = (down or gui.style:GetColor("Button")):ToTable()})
	self:SetState("idle")
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
	--self.upcolor = color
	--self.hovercolor = color*(1+mul)
	--self.downcolor = color*(1-mul)
	--self:SetColor( self.upcolor) 
	
	self:AddState("idle",{
		color = (color):ToTable(),
		color2 = (color*(1-mul)):ToTable(),
		gradangle = -45
	})
	self:AddState("hover",{color = (color*(1+mul)):ToTable()})
	self:AddState("pressed",{color = (color*(1-mul)):ToTable()})
	self:SetState("idle")
end

function PANEL:SetTextColorAuto(color,mul)
	mul = mul or 0.5
	color = color or Vector(1,1,1)
	self.flashtext = true
	self.textdowncolor = color*(1-mul)
	self.textupcolor = color
	self.texthovercolor = color*(1+mul)
	self:SetTextColor( self.textupcolor) 
end
function PANEL:SetPulse(period)
	self.cooldown = period
end
function PANEL:SetToggleable(tgl) 
	self.toggleable = tgl
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
		
		local newstate = false
		
		if(self.toggleable) then
			if self:IsPressed() then 
				self:SetState("idle") 
				newstate = false
			else 
				self:SetState("pressed") 
				newstate = true 
			end
		else  
			self:SetState("pressed")
			newstate = true
		end

		local group = self.group
		if group then -- unpress others
			local parent = self:GetParent()
			for k,v in pairs(parent:GetChildren()) do
				if v~=self and v.group == group then 
					v:SetState("idle")  
				end
			end
		end


		if self.flashtext then self:SetTextColor( self.textdowncolor) end
		local OnClick = self.OnClick
		if OnClick then
			OnClick(self,newstate)
		end
		LAST_BUTTON_PRESSED = self
		if pulse ~= true then
			LockMouse()
			hook.Add("input.mouseup", "gui.button.down", function() UnlockMouse() LAST_BUTTON_PRESSED = false hook.Remove("input.mouseup", "gui.button.down") end)
		end
		
	end
end
function PANEL:MouseUp()
	---####---self:SetColor( self.upcolor) 
	if self.flashtext then self:SetTextColor( self.textupcolor) end
	--if not input.leftMouseButton() then
	--	LAST_BUTTON_PRESSED = false 
	--end
	if(not self.toggleable) then
		self:SetState("idle")
	end
end
function PANEL:MouseEnter() 
	---####---self:SetColor( self.hovercolor) 
	if self.flashtext then self:SetTextColor( self.texthovercolor) end
	
	if(not self.toggleable or not self:IsPressed()) then
		self:SetState("hover")
		sound.Start('interface/click.ogg',0.3) 
	end
	
	
	local OnEnter = self.OnEnter 
	if OnEnter then OnEnter(self) end
end
function PANEL:MouseLeave() 
	if self.toggleable then 
		if self:IsPressed() then
			self:SetState("pressed")
		else
			self:SetState("idle")
		end  
	else 
		---####---self:SetColor( self.upcolor) 
		self:SetState("idle")
	end
	if self.flashtext then self:SetTextColor( self.textupcolor) end
	
	local OnLeave = self.OnLeave 
	if OnLeave then OnLeave(self) end
end

function PANEL:IsPressed()
	return self:GetState() == "pressed"
end 
