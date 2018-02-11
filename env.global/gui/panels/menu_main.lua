local button_color = Vector(38,12,8)/255
local panel_color = button_color*1.2

	
function PANEL:Init()  
	local vsize = GetViewportSize() 
	--self:SetColor(Vector(0,0,0))
	self:SetSize( vsize*2)
	self:SetTexture(LoadTexture("gui/menu/bkg1.png")) 
	--menu
	local menu = panel.Create()
	menu:SetSize(800,800)
	menu:SetColor(Vector(1,1,1)/1000)
	menu:SetTexture(LoadTexture("gui/menu/sn_1024.dds"))
	local sp = panel.Create("button")
	local mp = panel.Create("button")
	local opt = panel.Create("button")
	local exi = panel.Create("button")
	local mmn = panel.Create("button") mmn:SetVisible(false)
	
	 sp:SetPos(0,200)
	 mp:SetPos(0,100)
	opt:SetPos(0,-100)
	exi:SetPos(0,-200)
	mmn:SetPos(0,-200)
	
	local bcol = Vector(83,164,255)/255
	
	sp:SetText("Singleplayer")
	mp:SetText("Multiplayer")
	opt:SetText("Options")
	exi:SetText("Exit")
	mmn:SetText("Main menu")
	
	local function SetupStyle(p)
		p:SetTextColor(Vector(1,1,1)/2)
		p:SetColors(Vector(1,1,1),button_color,button_color*2)
	end
	
	local buttons = {sp,mp,opt,exi,mmn}
	for k,v in pairs(buttons) do 
		v:SetSize(250,20) 
		v:SetTextAlignment(ALIGN_CENTER)
		SetupStyle(v)
		menu:Add(v)
		--v:SetTextColor(bcol)
		v:SetTextColorAuto(bcol)
		v:SetTextOnly(true)
	end 
	 
	menu.sp = sp
	menu.mp = mp
	menu.opt = opt
	menu.exi = exi
	menu.mmn = mmn
	
	self:Add(menu) 
	sp .OnClick = function() 
		if self.worldIsLoaded then
			hook.Call("menu")
		else 
			hook.Call("menu","sp") 
		end
	end
	mp .OnClick = function() 
		if self.worldIsLoaded then
			hook.Call("menu","save")
		else 
			hook.Call("menu","mp") 
		end
	end
	opt.OnClick = function() hook.Call("menu","settings") end
	exi.OnClick = function() engine.Exit() end
	mmn.OnClick = function()
		UnloadWorld()
		self:SetWorldLoaded(false)
		healthbar:UpdateHealth()
	end
	self.menu = menu
	 
	
	self.panels = self.panels or {["main"] = menu}
	function self:AddPanel(id,class)
		local p = panel.Create(class)  
		self:Add(p)
		self.panels[id] = p
		p:SetVisible(false)
	end
	 
	self:AddPanel("loadscreen","menu_loadscreen") 
	self:AddPanel("sp","menu_singleplayer")  
	self:AddPanel("mp","menu_multiplayer") 
	self:AddPanel("settings","menu_settings") 
	self:AddPanel("addons","menu_addons") 
	self:AddPanel("save","menu_savegame") 
	self:AddPanel("load","menu_loadgame") 
	   
	--self:Add(chat)
	--self.chat = chat
	
	hook.Add("input.keydown","mainmenu",function(key)  
		if input.GetKeyboardBusy() then return nil end
		if key == KEYS_ESCAPE then 
			if self.worldIsLoaded then 
				self:MenuToggle() 
			end
		end
		if key == KEYS_OEMTILDE then 	 
			if not settings.GetBool("server.noconsole") then
				local console = self.console
				if not console then
					console = panel.Create("window_console")  
					console:SetTitle("Console")
					console:SetSize(800,800)
					console:UpdateLayout()
					local wsize = GetViewportSize()
					console:SetPos(vsize.x-800,vsize.y-800)
					self:Add(console)
					self.console = console
				end
				if not self:GetVisible() then
					if self.worldIsLoaded then hook.Call("menu","main") end 
					console:SetVisible(true)
					console.enabled = true
					console:Select()
				else
					if console.enabled then
						console:SetVisible(false)
						console.enabled = false
						if self.worldIsLoaded then hook.Call("menu") end
					else
						if self.worldIsLoaded then hook.Call("menu","main") end 
						console:SetVisible(true)
						console.enabled = true
						console:Select()
					end
				end
			end
		end
	end)
	hook.Add("settings.changed","consolecheck",function()
		local c = settings.GetBool("server.noconsole")
		local console = self.console
		if console and c then
			console:SetVisible(false)
			console.enabled = false  
		end
		self.console_enabled = not c
	end)
	
	
	hook.Add("menu","event",function(name)
		if name then
			local panel = self.panels[name]
			MsgN("menu call ",name," -> ",panel)
			if panel then
				self:SetVisible(true) 
				self:ReVis(panel)
			end
		else 
			MsgN("menu hide")
			self:SetVisible(false) 
		end
	end)
	
	MAIN_MENU = self
end

function PANEL:ReVis(n)
	for k,v in pairs(self.panels) do
		if(n==v) then
			if v.OnShow then v:OnShow() end
			v:SetVisible(true) 
		else
			v:SetVisible(false) 
		end
	end
end


function PANEL:MenuToggle()
	if self:GetVisible() then
		hook.Call("menu")
		
		local console = self.console
		if console and c then
			console.enabled = false
		end
	else
		hook.Call("menu","main")
	end
end
function PANEL:SetWorldLoaded(b)
	self.worldIsLoaded = b
	if b then
		self:SetAlpha(0)
		self.menu.mmn:SetVisible(true)
		self.menu.exi:SetVisible(false)
		self.menu.sp:SetText("Continue")
		self.menu.mp:SetText("Save")
	else
		self:SetAlpha(1)
		self.menu.mmn:SetVisible(false)
		self.menu.exi:SetVisible(true)
		self.menu.sp:SetText("Singleplayer")
		self.menu.mp:SetText("Multiplayer")
	end
end
