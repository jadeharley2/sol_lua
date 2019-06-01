
function ENT:Init() 
	self:SetSpaceEnabled(false)
	self:AddFlag(FLAG_USEABLE) 
end
 
function ENT:Spawn() 
	local scolor = self.color or self:GetParameter(VARTYPE_COLOR) or Vector(1,1,1)
	local brightness = self:GetParameter(VARTYPE_BRIGHTNESS) or 10
	self.color = scolor
 
	local light =self:GetComponent(CTYPE_LIGHT) or self:AddComponent(CTYPE_LIGHT)  
	light:SetColor(scolor) 
	light:SetBrightness(brightness) 
	light:SetDirectional(true)
	self.light = light
	 
	--self:SetUpdating(true)
end
function ENT:Load() 
end


function ENT:SetColor(c) 
	self:SetParameter(VARTYPE_COLOR,c)
	self.light:SetColor(c) 
	local brightness = self:GetParameter(VARTYPE_BRIGHTNESS) or 1 
end
function ENT:SetBrightness(c) 
	self:SetParameter(VARTYPE_BRIGHTNESS,c)
	self.light:SetBrightness(c) 
end 
function ENT:TurnOff()
	self.Fstate = false 
	self.light:Enable(false) 
end
function ENT:TurnOn()
	self.Fstate = true 
	self.light:Enable(true) 
end
function ENT:Toggle()
	local astate = self.Fstate  
	if astate then 
		astate = false
		self.Fstate = false 
	else 
		astate = true 
		self.Fstate = true
	end  
	self.light:Enable(astate)  
end
function ENT:Think()
	--local cam = GetCamera()

	--self:CopyAng(cam) 
end
 

ENT._typeevents = {
	[EVENT_USE] = {networked = true, f = function(self,user)  
		self:Toggle()
	end},
}