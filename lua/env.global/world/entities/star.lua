 

--commit test 3


function ENT:Init()  
	--local orbit = self:AddComponent(CTYPE_ORBIT)  
	--self.orbit = orbit
	self:AddTag(TAG_STAR)
	self:SetSpaceEnabled(true,1)
end

function ENT:SetupData(data) 
	if data.color then
		self.color = JVector(data.color)
	end  
	if data.brightness then
		self.brightness = data.brightness
	end  
	if data.radius then
		self.radius = data.radius
	end  
	if data.isstar then
		self:AddTag(TAG_STAR)
	end
end
function ENT:Spawn()
	if self:HasTag(TAG_STAR) then
		local r = self.radius or self:GetParameter(VARTYPE_RADIUS)
		local surface = ents.Create("star_surface") 
		surface:SetParent(self) 
		surface:SetSizepower(r*2)
		
		local scolor =  self.color or self:GetParameter(VARTYPE_COLOR) or  Vector(0.2,0.6,1.2)
		local starlum = self.brightness or self:GetParameter(VARTYPE_BRIGHTNESS) or  2.23e22 
		
		MsgN("<<docl",scolor)
		local scolorlen = scolor:Length()
		
		local light = self:AddComponent(CTYPE_LIGHT)  
		light:SetColor(scolor*(2/3)+Vector(1,1,1)*scolorlen*(1/3))
		light:SetBrightness(starlum)
		light:SetShadow(true)
		--149597870700*149597870700 (sun lum)
		
		--dist = localdist(a,b)
		--V = brightness/(dist*dist)
		self.light = light
		
		surface:Spawn()  
	end
end
function ENT:SetBrightness(b)
	if self.light then
		self.light:SetBrightness(b) 
	end
end
function ENT:SetMass(m)
	self.mass = m
	self[VARTYPE_MASS] = m
end
function ENT:SetColor(color)  
	self:SetParameter(VARTYPE_COLOR,color)
	self.light:SetColor(color+Vector(0.1,0.1,0.1)) 
end
function ENT:GetColor()   
	return self:GetParameter(VARTYPE_COLOR) or self.color or Vector(0.2,0.6,1.2)
end
----
--function ENT:Leave()   
--end
function ENT:Explode()
	SpawnParticlesStarsystem(self,"explosion_void",Vector(0,0,0),100,4000000000,0.01)
	local t = 0
	local lum = self:GetParameter(VARTYPE_BRIGHTNESS) or 2.23e22 
	debug.DelayedTimer(0,10,1000,
		function()
			t = t + 0.0002
			local brd = 1
			if t<0.2 then
			elseif t<0.4 then
				brd = 50*50*((t-0.2)/0.2)+1
			elseif t<1 then
				brd = 50*50*(1-(t-0.4)/0.6)+1
			end
			self.light:SetBrightness(lum*brd)
			MsgN(t)
		end)
end