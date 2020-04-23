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

hook.Add("prop.variable.load","light",function (self,j,tags)  
    if j.light then 
		local color = self[VARTYPE_COLOR] or JVector(j.light.color,Vector(1,1,1))
		local brightness = self[VARTYPE_BRIGHTNESS] or j.light.brightness or 1
		local light = self:RequireComponent(CTYPE_LIGHT)  
		light:SetColor(color)
		light:SetBrightness(brightness) 
		if j.light.pos then
			light:SetOffset(JVector(j.light.pos)) 
		end
		light:SetDirectional(j.light.isdirectional or false)
		self.light = light
		
		if tags.lamp then
			local wio = self:RequireComponent(CTYPE_WIREIO)-- Component("wireio",self)
			wio:AddInput("toggle",LampInputs)
			wio:AddInput("on",LampInputs)
			wio:AddInput("off",LampInputs)
			wio:AddInput("enabled",LampInputs)
		end
		if j.light.hasbutton then 
			self:AddInteraction("togglelight",{text="toggle light",action=ToggleLight})
		end
	end 
end)


hook.Add('item_features','propv.light',function(formid,data,addfeature) 
	if data.light then
		local c = data.light.color or {1,1,1}
        addfeature("light: #"..rgbToHex(c,255),c,'textures/gui/features/light.png')  
    end 
end) 