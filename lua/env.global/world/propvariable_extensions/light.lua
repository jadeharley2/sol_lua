local function LampInputs(self,f,k,v)
	local light = self.light;
	if light then
		if k == "toggle" then light:Enable(not light:IsEnabled())
		elseif k == "on" then light:Enable(true)
		elseif k == "off"then light:Enable(false) 
        elseif k == "enabled" then 
            if v~=0 then 
                light:Enable(true) 
            else
                light:Enable(false)
            end
        end
	end
end
local function ToggleLight(self,user)
	local light = self.light;
	if light then
		light:Enable(not light:IsEnabled()) 
	end
end
local function DaylightTimer(self)
	if IsValidEnt(self) then
		local light = self:GetComponent(CTYPE_LIGHT) 
		if light then
			local time = daycycle.GetLocalTimeTable(self)
			local turnon = 18
			local turnoff = 9  
			if light:IsEnabled() then
				if time.hours > turnoff and time.hours < turnon then
					light:Enable(false) 
					MsgN("DExcE")
				end
			else
				if time.hours < turnoff or time.hours > turnon then
					light:Enable(true) 
					MsgN("DE")
				end
			end
			return true
		end 
	end
	return false
end

hook.Add("prop.variable.load","light",function (self,j,tags)  
	local L = j.light
    if L then 
		local color = self[VARTYPE_COLOR] or JVector(L.color,Vector(1,1,1))
		local brightness = self[VARTYPE_BRIGHTNESS] or L.brightness or 1
		local light = self:RequireComponent(CTYPE_LIGHT)  
		light:SetColor(color)
		light:SetBrightness(brightness) 
		if L.pos then
			light:SetOffset(JVector(L.pos)) 
		end
		light:SetDirectional(L.isdirectional or false)
		self.light = light
		
		if tags.lamp then
			local wio = self:RequireComponent(CTYPE_WIREIO)-- Component("wireio",self)
			wio:AddInput("toggle",LampInputs)
			wio:AddInput("on",LampInputs)
			wio:AddInput("off",LampInputs)
			wio:AddInput("enabled",LampInputs)
		end
		if L.hasbutton then 
			self.info = "lamp"
			self:AddInteraction("togglelight",{text="toggle light",action=ToggleLight})
		end
		if L.daylight then 
			self:Timer("daylight",100,1100,-1,function (x)
				DaylightTimer(self)
			end )
		end
		if L.shader then
			light:SetShader(L.shader)
		end
	end 
end)


hook.Add('item_features','propv.light',function(formid,data,addfeature) 
	if data.light then
		local c = data.light.color or {1,1,1}
        addfeature("light: #"..rgbToHex(c,255),c,'textures/gui/features/light.png')  
    end 
end) 