PANEL.basetype = "menu_dialog"

function PANEL:Init()  
	
	self.base.Init(self,"Multiplayer",200)
	
	
	local network_label = panel.Create()
	network_label:SetText("Enter Address")
	network_label:SetTextAlignment(ALIGN_CENTER)
	network_label:SetSize(280,20)
	network_label:SetPos(0,50)
	network_label:SetTextColor( Vector(1,1,1))
	network_label:SetColor(Vector(50,150,50)/256/3)
	
	local network_address = panel.Create("input_text")
	network_address.downcolor = Vector(50,50,50)/256
	network_address.upcolor = Vector(0,0,0)/256
	network_address.hovercolor = Vector(80,80,80)/256
	network_address:SetColor(network_address.upcolor)
	network_address:SetTextColor( Vector(1,1,1))
	network_address:SetSize(280,20)
	network_address:SetText2(settings.GetString("network.lastip",""))
	
	local network_connect = panel.Create("button")
	network_connect:SetText("Connect")
	network_connect:SetSize(70,20)
	network_connect:SetPos(-100,-50)
	self:SetupStyle(network_connect)
	
	local network_back = panel.Create("button")
	network_back:SetText("Back")
	network_back:SetSize(70,20)
	network_back:SetPos(100,-50)
	self:SetupStyle(network_back)
	
	network_connect.OnClick = function() 
		hook.Call("menu","loadscreen")
		_GLT = network_address:GetText()
		settings.SetString("network.lastip",_GLT)
		settings.Save()
		hook.Add("engine.worldstate.loaded","mp_load",function() 
			hook.Remove("engine.worldstate.loaded","mp_load")
			
			debug.Delayed(1,function()  
				engine.ResumePhysics()
				MAIN_MENU:SetWorldLoaded(true) 
				hook.Call("menu") 
			end)
		end)
		debug.Delayed(1,function()  
			engine.PausePhysics() 
			if network.IsConnected() then
				UnloadWorld()
			end
			   
			if ConnectTo(_GLT) then
			else 
				debug.Delayed(1,function()  
					engine.ResumePhysics()
					hook.Call("menu","mp") 
				end)
			end
		end)
		if chat then chat:Show() end
	end
	network_back.OnClick = function() hook.Call("menu","main") end
	
	self:Add(network_label)
	self:Add(network_address)
	self:Add(network_connect) 
	self:Add(network_back)  
	 
end