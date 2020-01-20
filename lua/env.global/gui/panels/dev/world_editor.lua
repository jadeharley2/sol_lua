local sty = {
    bmenu = {type = "button", 
        size = {40,40},
        dock = DOCK_LEFT,
        states = {
            pressed    = {color = {255/255*2, 164/255*2, 83/255*2}},
            hover   = {color = {100/255,200/255, 255/255}},
            idle = {color = {53/255, 104/255, 205/255}},
        }, 
        state = 'idle'
    },
    bmenutoggle = {type = "button", 
        size = {40,40},
        dock = DOCK_LEFT,
        states = {
            pressed    = {color = {255/255*2, 164/255*2, 83/255*2}},
            hover   = {color = {100/255,200/255, 255/255}},
            idle = {color = {53/255, 104/255, 205/255}},
        }, 
        state = 'idle',
        toggleable = true,
    },
    menu_separator = {type = "panel", 
        size = {2,2},
        dock = DOCK_LEFT,
        color = {83/255, 164/255, 255/255}
    }
}

function PANEL:Init()  
	
	gui.FromTable({ 
		color = {0,0,0},
		subs = {
			{ name = "menus",
				size = {40,40},
				color = {0,0,0},
				dock = DOCK_TOP,
				subs = {
					{ class = "bmenu", texture = "textures/gui/panel_icons/new.png",
						OnClick = function()
							local cparent = GetCamera():GetParent()
							for k,v in pairs(cparent:GetChildren()) do
								if v:HasTag(TAG_EDITORNODE) then
									v:Despawn()
								end
							end
						end,
						contextinfo='Clear nodes'
					},
					{ class = "bmenu",  name = "bsavenode", texture = "textures/gui/panel_icons/save.png", 
						OnClick = function()
							local cparent = GetCamera():GetParent()
							local cseed = cparent:GetSeed()
							if cseed ~= 0 then
								engine.SaveNode(cparent, tostring(cseed), TAG_EDITORNODE)
							end
						end,
						contextinfo = 'Load nodes by current seed'
					},
					{ class = "bmenu", name = "bsave", texture = "textures/gui/panel_icons/save.png", 
						OnClick = function()
							local cparent = GetCamera():GetParent()
							if cparent then
								local s = panel.Create("window_save")
								s:SetTitle("Save node") 
								s:SetButtons("Save","Back") 
								s.OnAccept = function(s,name) engine.SaveNode(cparent, "manual/"..name, TAG_EDITORNODE) end
								s:Show() 
							end
						end,
						contextinfo = 'Save nodes as'
					}, 
					{ class = "bmenu",  name = "bload", texture = "textures/gui/panel_icons/load.png",  
						OnClick = function()
							local cparent = GetCamera():GetParent() 
							if cparent then
								local s = panel.Create("window_save")
								s:SetTitle("Load node") 
								s:SetButtons("Load","Back") 
								s.OnAccept = function(s,name) engine.LoadNode(cparent, "manual/"..name) end
								s:Show() 
							end 
						end,
						contextinfo = 'Load nodes'
					}, 
					{class="menu_separator"},
					{ class = "bmenu", texture = "textures/gui/panel_icons/left.png", contextinfo='Undo'},
					{ class = "bmenu", texture = "textures/gui/panel_icons/left.png", contextinfo='Redo', rotation = 180},
					{class="menu_separator"},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/move.png", contextinfo='Move mode'},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/rotate.png", contextinfo='Rotation mode'},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/scale.png", contextinfo='Scailing mode'},
					{class="menu_separator"},
					{ class = "bmenu", texture = "textures/gui/panel_icons/localspace.png", contextinfo='Local grid',
						OnClick = function() worldeditor:SetGridMode("local") end},
					{ class = "bmenu", texture = "textures/gui/panel_icons/parentspace.png", contextinfo='Parent grid',
						OnClick = function() worldeditor:SetGridMode("parent") end},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/possnap.png", contextinfo='Position snap',
						OnClick = function(s,val) worldeditor:SetPosSnap(val) end},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/anglesnap.png", contextinfo='Angle snap'},
					{class="menu_separator"},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/localorigin.png", contextinfo='Local origin'},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/medorigin.png", contextinfo='Median origin'},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/otherorigin.png", contextinfo='Point origin'},
					{class="menu_separator"},
				}
			}, 
			{ name = "rightpanel", type = 'tabmenu',
				size = {300,100},
				dock = DOCK_RIGHT, 
				tabs = {
					PROPERTIES = { type = "node_properties",name = "node_props",
						size = {300,100}, 
					}, 
					MATERIALS = { type = "node_materials",name = "node_mats",
						size = {300,100}, 
					}, 
				}, 
			},
			{ name = "xpanel", type = 'tabmenu',
				size = {300,100},
				dock = DOCK_LEFT,
				tabs = {
					NODE = { type = "editor_panel_node",name = "pnode",
						size = {300,100}, 
					}, 
					TERRAIN = { type = "editor_panel_terrain",name = "pterr",
						size = {300,100}, 
					},
					MESH = { type = "editor_panel_edmesh",name = "pmesh",
						size = {300,100}, 
					}
				},
				OnTabChanged = function(s,id,name)
					worldeditor:SetMode(name)
				end
			},
			
			{ type = "panel_assets",  
				color = {0,0,0},
				size = {200,300},
				dock = DOCK_BOTTOM, 
			},
			{type='viewport',name="vp",dock=DOCK_FILL}
		} 
    },self,sty,self)
    
    
	self.vp:InitializeFromTexture(1,"@main_final") 
end 
