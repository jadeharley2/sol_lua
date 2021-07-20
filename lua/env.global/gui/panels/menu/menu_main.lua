local button_color = Vector(38,12,8)/255
local panel_color = button_color*1.2
local style = { 
	menu = {
		size = {250,20},
		textonly = true, 
		textcolor = {0.5,0.5,0.5}, 
		textalignment = ALIGN_CENTER,
		states = {
			idle    = {textColor = {83/255, 164/255, 255/255}},
			hover   = {textColor = {100/255,200/255, 255/255}},
			pressed = {textColor = {53/255, 104/255, 205/255}},
		}, 
		state = "idle", 
	},
	submenu = {
		visible = false,
		
	},
}
local layout = {
	name = "self",
	--origin = ALIGN_CENTER,
	texture="textures/gui/menu/bkg1.png",
	--size = {400,400},
	pvsize = {1,1},
	--align = {ALIGN_CENTER,0,0},
	pos = {0,0},
	subs = { 
		{name = "main"    ,type="panel",   class = "submenu",
			origin = ALIGN_CENTER,
			visible = true,
			texture="textures/gui/menu/sn_1024.dds", 
			size = {800,800},
			--pos = {500,900},
			pvpos = 'center',
			color = {0.001,0.001,0.001},
			subs = {
				{name = "bsingle"   ,type="button",
					text = "Singleplayer", 
					class = "menu",  
					pvpos = {0.5,0.5,-125,-10-100},
					OnClick = fwrap(hook.Call,{"menu","sp"}),
				},
				{name = "bmulti"    ,type="button", class = "menu",
					text = "Multiplayer",   
					pvpos = {0.5,0.5,-125,-10-50},
					OnClick = fwrap(hook.Call,{"menu","mp"}),
				},
				{name = "boptions"  ,type="button", class = "menu",
					text = "Options",  
					pvpos = {0.5,0.5,-125,-10+50},
					OnClick = fwrap(hook.Call,{"menu","settings"}),
				},
				{name = "bexit"     ,type="button", class = "menu",
					text = "Exit",  
					pvpos = {0.5,0.5,-125,-10+100},
					OnClick = engine.Exit,
				},
				
				{name = "bcontinue"   ,type="button", class = "menu",
					text = "Continue",  
					pvpos = {0.5,0.5,-125,-10-100},
					OnClick = fwrap(hook.Call,{"menu"}),
					visible = false
				},
				{name = "bsave"       ,type="button", class = "menu",
					text = "Save",  
					pvpos = {0.5,0.5,-125,-10-50},
					OnClick = fwrap(hook.Call,{"menu","save"}),
					visible = false
				},
				{name = "bmainmenu"    ,type="button", class = "menu",
					text = "Main menu",   
					pvpos = {0.5,0.5,-125,-10+100},
					OnClick = function(s)
						world.UnloadWorld()
						s.menu.self:SetWorldLoaded(false)  
					end,
					visible = false
				}, 
			},
		}, 
		{name = "loadscreen"    ,type="menu_loadscreen",  pvpos = 'center', class = "submenu"},
		{name = "sp"            ,type="menu_singleplayer",pvpos = 'center', class = "submenu"},
		{name = "mp"            ,type="menu_multiplayer", pvpos = 'center', class = "submenu"},
		{name = "settings"      ,type="menu_settings",    pvpos = 'center', class = "submenu"},
		{name = "addons"        ,type="menu_addons",      pvpos = 'center', class = "submenu"},
		{name = "save"          ,type="menu_savegame",    pvpos = 'center', class = "submenu"},
		{name = "load"          ,type="menu_loadgame",    pvpos = 'center', class = "submenu"},
		{name = "editor"        ,type="menu_editors",     pvpos = 'center', class = "submenu"},

		{name = "discord"        ,type="menu_discord"},
	}
}
	 
function PANEL:Init()   
	
	local nt = {}
	gui.FromTable(layout,self,style,nt,"menu")
	--MsgN("menu loaded")
	--PrintTable(nt)
	self.nodes = nt
	
	hook.Add("input.keydown","mainmenu",function(key)  
		if input.GetKeyboardBusy() then return nil end
		if key == KEYS_ESCAPE then 
			if self.worldIsLoaded then 
				self:MenuToggle() 
			end
		end 
	end) 
	
	
	hook.Add("menu","event",function(name)
		if name then
			local panel = self.nodes[name]
			MsgN("menu call ",name," -> ",panel)
			if panel then 
				if panel.OnShow then panel:OnShow() end
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
function PANEL:Update()  
end

function PANEL:ReVis(n)
	for k,v in pairs(self.nodes) do
		if v.class == "submenu" then
			if(n==v) then
				if v.OnShow then v:OnShow() end
				v:SetVisible(true) 
			else
				if v.OnHide then v:OnHide() end
				v:SetVisible(false) 
			end
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
		self.nodes.bsingle:SetVisible(false)
		self.nodes.bmulti:SetVisible(false) 
		self.nodes.bexit:SetVisible(false) 
		
		self.nodes.bcontinue:SetVisible(true)
		self.nodes.bsave:SetVisible(true)
		self.nodes.bmainmenu:SetVisible(true) 
	else
		self:SetAlpha(1)
		self.nodes.bcontinue:SetVisible(false)
		self.nodes.bsave:SetVisible(false)
		self.nodes.bmainmenu:SetVisible(false)
		
		self.nodes.bsingle:SetVisible(true)
		self.nodes.bmulti:SetVisible(true) 
		self.nodes.bexit:SetVisible(true)  
	end
end

console.AddCmd("mainmenu.reload",function ()
	local self = MAIN_MENU
	self:Clear()
	local nt = {}
	gui.FromTable(layout,self,style,nt,"menu") 
	self.nodes = nt
	self:Update()
end)