
 
local iconpool = 
{
	material = "textures/gui/panel_icons/material.png",
	shader = "textures/gui/panel_icons/shader.png",
	model = "textures/gui/panel_icons/model.png",
	texture = "textures/gui/panel_icons/image.png",
	sound = "textures/gui/panel_icons/sound.png",
	font = "textures/gui/panel_icons/font.png",
}

function PANEL:Init()  
	
	local refresh = function()
		self:Refresh() 
	end
	gui.FromTable({
		color = {0,0,0},
		size = {700,600},
		subs = {
			{
				name = "infopanel",
				color = {0,0,0},
				textcolor = {1,1,1},
				size = {600,40},
				dock = DOCK_BOTTOM,
				subs = {
					{ name = "header",
						color = {0.1,0.1,0.1},
						textcolor = {1,1,1},
						text = "Loaded resources",
						size = {600,32},
						dock = DOCK_TOP,
						subs = {
							{type = "checkbox", name = "cb_texture",
								size = {32,32},
								dock = DOCK_RIGHT,
								Value = true,
								OnValueChanged = refresh,
								texture = iconpool.texture,
							},
							{type = "checkbox", name = "cb_material",
								size = {32,32},
								dock = DOCK_RIGHT,
								Value = true,
								OnValueChanged = refresh,
								texture = iconpool.material,
							},
							{type = "checkbox", name = "cb_shader",
								size = {32,32},
								dock = DOCK_RIGHT,
								Value = true,
								OnValueChanged = refresh,
								texture = iconpool.shader,
							},
							{type = "checkbox", name = "cb_model",
								size = {32,32},
								dock = DOCK_RIGHT,
								Value = true,
								OnValueChanged = refresh,
								texture = iconpool.model,
							},
							{type = "checkbox", name = "cb_sound",
								size = {32,32},
								dock = DOCK_RIGHT,
								Value = true,
								OnValueChanged = refresh,
								texture = iconpool.sound,
							},
							{type = "checkbox", name = "cb_font",
								size = {32,32},
								dock = DOCK_RIGHT,
								Value = true,
								OnValueChanged = refresh,
								texture = iconpool.font,
							}
						}
					},
					{ name = "text",
						color = {0,0,0},
						textcolor = {0.8,0.8,0.8},
						size = {600,20},
						dock = DOCK_FILL, 
					}
				}
			},
			{ type = "listbox", name = 'grid', 
				dock = DOCK_FILL,
				RowHeight = 128,
				ItemsPerRow = 5,
			}
		}
	},self,{},self)
	
	--for k=1,99 do  
	--	grid:AddItem(makeitem(tostring(k),{0,1,0} ))
	--end 
	self:Refresh() 
end 
function PANEL:Refresh()  
	self:LoadItems(function(t,f) 
		local pb = self['cb_'..t]
		if pb then
			return pb:GetValue() 
		else
			return true
		end 
	end)
	self:UpdateLayout()
end
function PANEL:LoadItems(filter)
	local grid = self.grid
	grid:ClearItems()

	local t = {}
	for k,v in pairs(file.GetLoadedAssets()) do
		t[v[1]] = v[2]
	end
	
	for k,v in SortedPairs(t) do  
		if not filter or filter(v,k) then
			grid:AddItem(self:LoadItem(v,k,{0,1,0} ))
		end
	end 
end

function PANEL:LoadItem(text,f,color)
	local p = gui.FromTable({
		type = "button",
		size = {128,128},
		margin = {2,2,2,2},
		states = {
			idle = {color = {1,1,1}},
			hover = {color= {0.8,0.9,0.3}},
			pressed = {color = {1,1,1}},
		},
		state = 'idle', 
		subs = {
			{ 
				text = text,
				size={16,16},
				dock = DOCK_TOP,
				mouseenabled = false, 
				color = {0,0,0},
				textcolor = {1,1,1},
				alpha = 0.5,
			},
			{ 
				text = f,
				size={16,16},
				dock = DOCK_BOTTOM,
				mouseenabled = false,
				textcut = true,
				color = {0,0,0},
				textcolor = {1,1,1},
				alpha = 0.5,
			}
		}
	}) 
	
	if( string.match(text,"texture"))then
		p:SetTexture(f)
	else
		local t = iconpool[text]
		if t then
			p:SetTexture(t)
		end
	end
	
	return p
end

if SERVER then return nil end

loadedassetlist = loadedassetlist or {}

function loadedassetlist.Enable()
	local list_view = panel.Create("debug_loaded_assets")
	loadedassetlist._lv = list_view
	loadedassetlist._lvp = true
	
	local vsize = GetViewportSize()
	
	local nsi = 128*5.25
	 
	list_view:Dock(DOCK_RIGHT)
	list_view:SetSize(nsi-2,vsize.y-2-15)
	list_view:SetPos(-vsize.x+nsi,-15)
	list_view:Show() 
end
function loadedassetlist.Disable()
	if loadedassetlist._lv then loadedassetlist._lv:Close() end
	loadedassetlist._lvp = false
end
function loadedassetlist.Toggle()
	if loadedassetlist._lvp then
		loadedassetlist.Disable()
	else
		loadedassetlist.Enable()
	end
end
 
console.AddCmd("io_loadedassetlist", loadedassetlist.Toggle)
---test
  