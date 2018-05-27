
PANEL.basetype = "menu_dialog"

function PANEL:Init()  
	 
	self.base.Init(self,"Settings",300)
	
	
	local settings_buttonpanel = panel.Create()
	settings_buttonpanel:SetSize(70,20)
	
	local settings_save = panel.Create("button")
	settings_save:SetText("Save")
	settings_save:SetSize(70,20)
	settings_save:SetPos(-300,-200) 
	self:SetupStyle(settings_save)
	settings_save.OnClick = function()
		for k,v in pairs(self.savelist) do
			if v.type == "string" then
				local val = v:GetText()
				settings.SetString(k,val)
			elseif v.type == "number" then
				local val = tonumber(v:GetText())
				if v.evalfunction then
					local n = v.evalfunction(val)
					v:SetText(tostring(n))
					settings.SetNumber(k,n)
				else
					settings.SetNumber(k,val)
				end
				if v.applyfunction then
					v.applyfunction(val)
				end
			elseif v.type == "bool" then
				local val = v.value or false
				settings.SetBool(k,val)
				if v.applyfunction then
					v.applyfunction(val)
				end
			end
		end
		hook.Call("settings.changed")
		settings.Save()
		hook.Call("menu","main")
	end
	
	local settings_back = panel.Create("button")
	settings_back:SetText("Back")
	settings_back:SetSize(70,20)
	settings_back:SetPos(0,-200)
	self:SetupStyle(settings_back)
	settings_back.OnClick = function() hook.Call("menu","main") end
	
	local settings_addons = panel.Create("button")
	settings_addons:SetText("Addons")
	settings_addons:SetSize(70,20)
	settings_addons:SetPos(300,-200) 
	self:SetupStyle(settings_addons)
	settings_addons.OnClick = function() hook.Call("menu","addons") end
	
	 
	settings_buttonpanel:Add(settings_save) settings_save:Dock(DOCK_LEFT)
	settings_buttonpanel:Add(settings_back) settings_back:SetPos(0,0) 
	settings_buttonpanel:Add(settings_addons) settings_addons:Dock(DOCK_RIGHT)
	settings_buttonpanel:Dock(DOCK_BOTTOM) 
	settings_buttonpanel:SetColor(gui.style:GetColor("WindowBack"))
	
	local testtabmenu = panel.Create("tabmenu")
	local panelColor = Vector(50,150,50)/256
	local savelist = {}
	for k,v in pairs(SETTINGS_VALUES.Categories) do
		local tab = panel.Create() 
		tab:SetColor(panelColor)
		for k2,v2 in pairs(v.variables) do
			
			local sp = panel.Create()
			sp:SetSize(450,20)  
			sp:Dock(DOCK_TOP)
			sp:SetColor(panelColor)
			local label = panel.Create()
			label:SetText(v2.name)
			label:SetTextAlignment(ALIGN_CENTER) 
			label:Dock(DOCK_LEFT)
			label:SetColor(panelColor/2)
			label:SetTextColor( Vector(1,1,1))
			label:SetSize(170,20)
			sp:Add(label)
			
			local inp = false
			if v2.type == "bool" then
				inp = panel.Create("checkbox") 
				inp:SetValue(settings.GetBool(v2.var,v2.default))
			elseif v2.type == "number" then 
				inp = panel.Create("input_text")   
				inp:SetSize(280,20) 
				inp.rest_numbers = true
				inp:SetText(tostring(settings.GetNumber(v2.var,v2.default))) 
				inp.evalfunction = v2.proc 
			elseif v2.type == "string" then 
				inp = panel.Create("input_text")  
				inp:SetSize(280,20)
				inp:SetText(settings.GetString(v2.var,v2.default)) 
				inp.evalfunction = v2.proc 
			end
			inp.applyfunction = v2.apply
			
			inp:Dock(DOCK_LEFT)
			inp.type = v2.type
			savelist[v2.var] = inp
			sp:Add(inp)   
			  
			tab:Add(sp)
		end
		testtabmenu:AddTab(v.name,tab)
	end
	self.savelist = savelist
	
	--testtabmenu:AddTab("T01",panel.Create())
	--testtabmenu:AddTab("T02",panel.Create("button"))
	--testtabmenu:AddTab("o_O",panel.Create("window_chat"))
	testtabmenu:SetSize(100,100)
	testtabmenu:Dock(DOCK_FILL)
	testtabmenu:ShowTab(1)
	 
	self.sub:Add(settings_buttonpanel)
	self.sub:Add(testtabmenu)
	self:UpdateLayout() 
end