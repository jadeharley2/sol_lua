
debug_panel = debug_panel or {} 
debug_panel.controls = debug_panel.controls or {}

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
function PANEL:Expand() 
	self:Clear()
	
	self:AddControl("collapse","button","C",Vector(0.9,0.9,0.9),function() self:Collapse() end)
	self:AddSeparator()
	self:AddControl("editor","button","E",Vector(0.8,0.8,0),function() editor.Toggle() end)
	self:AddSeparator()
	self:AddControl("reload_ents","button","RE",Vector(0.8,0.3,0),function() console.Call("lua_reloadents") end)
	self:AddControl("reload_panels","button","RP",Vector(0.8,0.3,0.4),function() console.Call("lua_reloadpanels") end)
	self:AddControl("reload_iosystem","button","IO",Vector(0.3,0.3,0.8),function() console.Call("iosystem_restart") end)
	self:AddSeparator()
	self:AddControl("reload_materials","button","RM",Vector(0.4,0.5,0.2),function() console.Call("reload_materials") end)
	self:AddControl("reload_textures","button","RT",Vector(0.4,0.7,0.4),function() console.Call("reload_textures") end)
	self:AddControl("reload_all","button","RA",Vector(0.4,0.5,0.8),function() console.Call("reload_assets") end)
	self:AddSeparator()
	self:AddControl("toggle_wireframe","button","WF",Vector(0.8,0.7,0.8),function() console.Call("debug_toggle wireframe") end)
	self:AddControl("toggle_nodeframe","button","NF",Vector(0.2,0.8,0.2),function() console.Call("debug_toggle nodeframe") end)
	self:AddControl("toggle_visframe","button","VF",Vector(0.8,0.2,0.3),function() console.Call("debug_toggle visframe") end)
	self:AddControl("toggle_physframe","button","PF",Vector(0.8,0.2,0.2),function() console.Call("debug_toggle physframe") end)
	self:AddSeparator()
	self:AddControl("debug_profiler","button","DP",Vector(0.5,0.1,0.1),function() console.Call("debug_profiler") end)
	self:AddSeparator()
	self:AddControl("rerender_cubemap","button","CU",Vector(0.7,0.2,0.8),function() hook.Call("cubemap_render") end)
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

function PANEL:AddControl(id,type,text,color,func) 
	local btnEditor = panel.Create(type)
	btnEditor:SetSize(15,15)
	btnEditor:SetText(text)
	btnEditor:SetColorAuto(color)
	btnEditor.OnClick = func
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

