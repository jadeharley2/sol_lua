
debug_panel = debug_panel or {} 
debug_panel.controls = debug_panel.controls or {}
debug_panel.exposure = 1

function PANEL:Init() 
	local vsize = GetViewportSize()
	self:SetColor(Vector(0,0,0))
	self:SetSize(vsize.x,15)
	self:SetPos(0,vsize.y-15)
	
	 
	debug_panel.panel = self
	
	self:Expand()
	
	hook.Add("window.resize","debugpanel_resize",function() 
		self:OnResize()  
	end) 
end 
abstract_filepanel = false
function PANEL:Expand() 
	self:Clear()
	
	self:AddControl("collapse","button","C",Vector(0.9,0.9,0.9),function() self:Collapse() end)
	self:AddSeparator()
	self:AddControl("editor","button","WE",Vector(0.8,0.8,0),function() console.Call("ed_world") end,true)
	self:AddControl("editor_lua","button","LE",Vector(0.2,0.8,0.2),function() console.Call("ed_lua") end,true)
	self:AddControl("editor_wire","button","WE",Vector(0.1,0.3,0.8),function() console.Call("ed_wire") end,true)
	self:AddControl("editor_flow","button","FE",Vector(0.4,0.3,0.8),function() console.Call("ed_flow") end,true)
	self:AddControl("editor_map","button","ME",Vector(0.4,0.8,0.8),function() console.Call("ed_map") end,true)
	self:AddControl("editor_form","button","FE",Vector(0.8,0.5,0.4),function() console.Call("ed_form") end,true)
	self:AddControl("editor_character","button","CE",Vector(0.4,0.8,0.6),function() console.Call("ed_char") end,true)
	self:AddSeparator()
	self:AddControl("file_browser","button","FB",Vector(0.4,0.5,0.8),function() 
		if abstract_filepanel then abstract_filepanel:Close() abstract_filepanel = false 
		else abstract_filepanel = panel.Create('files') abstract_filepanel:Show() end end)
	self:AddControl("asset_list","button","AL",Vector(0.4,0.8,0.4),function() console.Call("io_loadedassetlist") end)
	self:AddControl("reload_iosystem","button","IO",Vector(0.3,0.3,0.8),function() console.Call("iosystem_restart") end)
	self:AddControl("reload_ents","button","RE",Vector(0.8,0.3,0),function() console.Call("lua_reloadents") end)
	self:AddControl("reload_panels","button","RP",Vector(0.8,0.3,0.4),function() console.Call("lua_reloadpanels") end)
	self:AddControl("forms_update","button","FU",Vector(0.4,0.5,0.9),function() console.Call("forms_update") hook.Call("forms_updated") end) 
	self:AddSeparator()
	self:AddControl("reload_materials","button","RM",Vector(0.4,0.5,0.2),function() console.Call("reload_materials") end)
	self:AddControl("reload_textures","button","RT",Vector(0.4,0.7,0.4),function() console.Call("reload_textures") end)
	self:AddControl("reload_all","button","RA",Vector(0.4,0.5,0.8),function() console.Call("reload_assets") end)
	self:AddSeparator()
	self:AddControl("toggle_wireframe","button","WF",Vector(0.8,0.7,0.8),function() console.Call("debug_toggle wireframe") end,true)
	self:AddControl("toggle_nodeframe","button","NF",Vector(0.2,0.8,0.2),function() console.Call("debug_toggle nodeframe") end,true)
	self:AddControl("toggle_visframe","button","VF",Vector(0.8,0.2,0.3),function() console.Call("debug_toggle visframe") end,true)
	self:AddControl("toggle_surfframe","button","SF",Vector(0.8,0.8,0.3),function() console.Call("debug_toggle surfframe") end,true)
	self:AddControl("toggle_physframe","button","PF",Vector(0.8,0.2,0.2),function() console.Call("debug_toggle physframe") end,true)
	self:AddControl("toggle_phys","button","PH",Vector(0.5,0.1,0.1),function() console.Call("debug_toggle phys") end,true)
	self:AddControl("toggle_orbits","button","OR",Vector(0.5,0.7,0.3),function() console.Call("debug_toggle orbits") end,true)
	self:AddControl("toggle_navigation","button","NR",Vector(0.7,0.7,0.3),function() console.Call("debug_toggle navigation") end,true)
	self:AddControl("toggle_occlusion_cull","button","OC",Vector(0.7,0.4,0.8),function() console.Call("debug_toggle occlcull") end,true)
	self:AddControl("toggle_occlusion_cull_test","button","OT",Vector(0.7,0.4,1),function() console.Call("debug_toggle occlculltest") end,true)
	self:AddControl("toggle_frustum_cull","button","FC",Vector(0.7,0.7,0.4),function() console.Call("debug_toggle frustumcull") end,true)
	self:AddControl("toggle_frustum_cull_test","button","FT",Vector(0.7,0.7,0.4),function() console.Call("debug_toggle frustumculltest") end,true)
	self:AddControl("toggle_horizon_update","button","HZ",Vector(0.9,0.4,0.3),function() console.Call("debug_toggle horizon") end,true)
	self:AddSeparator()
	self:AddControl("toggle_channels","button","TC",Vector(0.7,0.3,0.4),function() console.Call("debug_toggle pp_channels") end,true)
	self:AddControl("toggle_light","button","TL",Vector(0.6,0.6,0.6),function() console.Call("debug_toggle light") end,true) 
	--local exposure = 1;
	self:AddControl("set_exposure_1","button","E1",Vector(0.7,0.4,0.8),function() 
		debug_panel.exposure = 1 console.Call("r_exposure "..debug_panel.exposure) end) 
	self:AddControl("add_exposure","button","E+",Vector(0.5,0.4,0.8),function() 
		debug_panel.exposure = debug_panel.exposure*2 console.Call("r_exposure "..debug_panel.exposure) end) 
	self:AddControl("sub_exposure","button","E-",Vector(0.3,0.4,0.8),function() 
		debug_panel.exposure = debug_panel.exposure/2 console.Call("r_exposure "..debug_panel.exposure) end) 
	self:AddControl("unfix_exposure","button","UE",Vector(0.7,0.4,0.8),function() console.Call("r_exposure -1") end) 
	self:AddSeparator()
	self:AddControl("toggle_clouds","button","CL",Vector(0.6,0.6,0.6),function() console.Call("debug_toggle clouds") end,true) 
	self:AddControl("toggle_atmosphere","button","AT",Vector(0.6,0.6,1),function() console.Call("debug_toggle atmosphere") end,true) 
	self:AddSeparator()
	self:AddControl("debug_profiler","button","DP",Vector(0.5,0.1,0.1),function() console.Call("debug_profiler") end,true)
	self:AddSeparator()
	self:AddControl("rerender_cubemap","button","CU",Vector(0.7,0.2,0.8),function() hook.Call("cubemap_render") end)
	self:AddControl("rerender_skybox","button","SK",Vector(0.7,0.7,0.9),function() if TSYSTEM then TSYSTEM:ReloadSkybox() end end)
	self:AddControl("reset_system","button","UR",Vector(0.4,0.7,0.8),function() if TSYSTEM then TSYSTEM:Regenerate() end end)
	self:AddControl("reset_surface","button","SR",Vector(0.4,0.8,0.6),function() console.Call("surf_reset")end)
	self:AddSeparator()
	self:AddControl("spaceinfo_toggle","button","SI",Vector(0.4,0.8,0.3),function() hook.Call("spaceinfo_toggle") end)
	self:AddControl("map_toggle","button","MA",Vector(0.4,0.9,0.8),function() ToggleMap() end)
	self:AddSeparator()
	self:AddControl("controller_freecam","button","FC",Vector(0.8,0.8,0.3),function() SetController("freecamera") end)
	self:AddControl("controller_actor","button","AC",Vector(0.3,0.8,0.3),function() SetController("actor") end)
	self:AddControl("controller_planetview","button","PV",Vector(0.4,0.8,0.8),function() SetController("planetview") end)
	self:AddControl("controller_systemview","button","SV",Vector(0.8,0.4,0.4),function() SetController("systemview") end) 
	self:AddSeparator()
	self:AddControl("camera_eject","button","CJ",Vector(0.8,0.9,0.4),function() GetCamera():Eject() end) 
	self:AddControl("to_camera","button","TC",Vector(0.5,0.9,0.4),function() 
		local c = GetCamera() local p = LocalPlayer() p:SetParent(c:GetParent()) p:SetPos(c:GetPos()) end) 
	self:AddControl("to_zero","button","TZ",Vector(0.9,0.9,0.4),function() GetCamera():SetPos(Vector(0,0,0)) end) 
	self:AddControl("respawn","button","RE",Vector(0.6,0.7,0.9),function() hook.Call("player.onspawn",LocalPlayer()) end) 
	self:AddSeparator()
	self:AddControl("time_dawn","button","TM",Vector(0.8,0.5,0.3),function() daycycle.SetLocalTime(6.5,1) end)
	self:AddControl("time_9h","button","TS",Vector(0.8,0.8,0.3),function() daycycle.SetLocalTime(9,1) end)
	self:AddControl("time_day","button","TD",Vector(0.6,0.8,0.9),function() daycycle.SetLocalTime(12,1) end)
	self:AddControl("time_15h","button","TF",Vector(0.8,0.8,0.3),function() daycycle.SetLocalTime(15,1) end)
	self:AddControl("time_dusk","button","TE",Vector(0.8,0.3,0.3),function() daycycle.SetLocalTime(17.5,1) end)
	self:AddControl("time_night","button","TN",Vector(0.3,0.3,0.8),function() daycycle.SetLocalTime(24,1) end)  
	self:AddSeparator()
	self:AddControl("menu_main","button","MM",Vector(0.5,0.7,0.8),function() hook.Call("menu","main") end)  
	self:AddControl("menu_hide","button","MH",Vector(0.8,0.7,0.5),function() hook.Call("menu") end)  
	self:UpdateLayout()
end 
function PANEL:Collapse()
	self:Clear()
	self:AddControl("expand","button","E",Vector(0.9,0.9,0.9),function() self:Expand() end)
	self:UpdateLayout()
end
function PANEL:OnResize()
	local vsize = GetViewportSize()
	self:SetColor(Vector(0,0,0))
	self:SetSize(vsize.x,15)
	self:SetPos(0,vsize.y-15)
end

function PANEL:AddControl(id,type,text,color,func,tggl) 
	local btnEditor = panel.Create(type)
	if(tggl) then btnEditor:SetToggleable(true) end
	btnEditor:SetSize(15,15)
	btnEditor:SetText(text)
	btnEditor:SetColorAuto(color)
	btnEditor.contextinfo = id
	if tggl then
		local sub = panel.Create()
		sub:SetColor(Vector(0,0,0))
		sub:SetSize(14,2)
		sub:SetPos(0,-14)
		sub:SetCanRaiseMouseEvents(false)
		btnEditor.s = sub
		btnEditor:Add(sub)
		btnEditor.OnClick =function(b,t) 
			if t then
				b.s:SetColor(Vector(0,1,0))
			else
				b.s:SetColor(Vector(0,0,0))
			end
			func(b,t) 
		end
	else
		btnEditor.OnClick = func
	end
	btnEditor:Dock(DOCK_LEFT)
	self:Add(btnEditor)
end
function PANEL:AddSeparator() 
	local sep = panel.Create()
	sep:SetColor(Vector(0,0,0))
	sep:SetSize(1,15)
	sep:Dock(DOCK_LEFT)
	self:Add(sep)
	local sep = panel.Create()
	sep:SetColor(Vector(1,1,1))
	sep:SetSize(1,15)
	sep:Dock(DOCK_LEFT)
	self:Add(sep)
	local sep = panel.Create()
	sep:SetColor(Vector(0,0,0))
	sep:SetSize(5,15)
	sep:Dock(DOCK_LEFT)
	self:Add(sep)
	local sep = panel.Create()
	sep:SetColor(Vector(1,1,1))
	sep:SetSize(1,15)
	sep:Dock(DOCK_LEFT)
	self:Add(sep)
	local sep = panel.Create()
	sep:SetColor(Vector(0,0,0))
	sep:SetSize(1,15)
	sep:Dock(DOCK_LEFT)
	self:Add(sep)
end 

hook.Add("input.keydown", "toggle_debug_panel" ,function(key)
	if not input.GetKeyboardBusy() then
		if key == KEYS_F4 and debug_panel.panel then
			debug_panel.vistoggle = not (debug_panel.vistoggle or false)
			debug_panel.panel:SetVisible(debug_panel.vistoggle)
		end
		if key == KEYS_OEMPLUS then
			debug_panel.exposure = debug_panel.exposure*2 
			console.Call("r_exposure "..debug_panel.exposure) 
		end
		if key == KEYS_OEMMINUS then
			debug_panel.exposure = debug_panel.exposure/2 
			console.Call("r_exposure "..debug_panel.exposure) 
		end
	end
end)

