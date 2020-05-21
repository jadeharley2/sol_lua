
local textsize = 16 
local sty = {
    bmenu = {type = "button", 
        size = {40,40},
        dock = DOCK_LEFT,
        states = {
            pressed    = {color = {255/255*2, 164/255*2, 83/255*2}},
            hover   = {color = {100/255,200/255, 255/255}},
            idle = {color = {53/255, 204/255, 205/255}},
        }, 
        state = 'idle'
    },
    bmenutoggle = {type = "button", 
        size = {40,40},
        dock = DOCK_LEFT,
        states = {
            pressed    = {color = {255/255*2, 164/255*2, 83/255*2}},
            hover   = {color = {100/255,200/255, 255/255}},
            idle = {color = {53/255, 204/255, 205/255}},
        }, 
        state = 'idle',
        toggleable = true,
    },
    menu_separator = {type = "panel", 
        size = {2,2},
        dock = DOCK_LEFT,
        color = {83/255, 164/255, 255/255}
	},
    bmenu_op = {type = "button", 
        size = {40,40},
        dock = DOCK_LEFT,
        states = {
            pressed    = {color = {255/255*2, 164/255*2, 83/255*2}},
            hover   = {color = {100/255,200/255, 255/255}},
            idle = {color = {53/255, 104/255, 205/255}},
        }, 
        state = 'idle',
        margin = {2,2,2,2},
    },
	header_0 = {
		size = {100,20},
		dock = DOCK_TOP,
		textalignment = ALIGN_CENTER, 
		--textcolor = {2,2,2},
		gradient = {
			{0.3,0.6,0.9}, {0.1,0.2,0.4}, -45
		},
	},
	header_1 = {
		size = {100,16},
		dock = DOCK_TOP,
		textalignment = ALIGN_CENTER, 
		--textcolor = {2,2,2},
		gradient = {
			{0.3,0.9,0.7}, {0.1,0.4,0.2}, -45
		},
	},
	back = { 
		gradient = {
			{0,0,0}, {0.1,0.1,0.1}, 0
		},
	},
	btitle = { type = "button",
		dock=DOCK_RIGHT,
		size = {20,textsize},
		margin = {1,1,1,1},
		textcolor = {1,0.3,0.3},
		ColorAuto = Vector(0,0,0),
		textalignment = ALIGN_CENTER,
	},
	bgroup = { type="group",  
		dock=DOCK_TOP,
		_sub_header = {
			color = {0,0,0},
			size = {20,textsize},
			textcolor = {0.3,0.9,0.7}
		} 
	},
	cgroup = { type="group",  
		dock=DOCK_TOP,
		_sub_header = {
			color = {0.2,0.1,0},
			textcolor = {0.9,0.6,0.3},
			size = {20,textsize},
			textalignment = ALIGN_LEFT
		} 
	}
}
global_editor_style = sty
local lastpath = "forms/nodes/"
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
							MsgInfo("Editor nodes removed!")
						end,
						contextinfo='Clear nodes'
					},
					{ class = "bmenu",  name = "bsavenode", texture = "textures/gui/panel_icons/save.png", 
						OnClick = function()
							local cparent = GetCamera():GetParent()
							local cseed = cparent:GetSeed()
							if cseed ~= 0 then
								engine.SaveNode(cparent, tostring(cseed), TAG_EDITORNODE)
								MsgInfo("Nodes saved!")
							else
								MsgInfo("Unable to save nodes! Current node seed is 0!")
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
								s.OnAccept = function(s,name) 
									engine.SaveNode(cparent, "manual/"..name, TAG_EDITORNODE) 
									MsgInfo("Nodes saved!")
								end
								s:Show() 
							end
						end,
						contextinfo = 'Save nodes as'
					}, 
					--{ class = "bmenu", name = "bsavechunks", texture = "textures/gui/panel_icons/save.png", 
					--	OnClick = function()
					--		local cparent = GetCamera():GetParent()
					--		if cparent then
					--			local terrain = cparent:GetComponent(CTYPE_CHUNKTERRAIN)
					--			if terrain then
					--				terrain:SaveChunks()
					--				MsgInfo("Chunks saved!")
					--				return true
					--			end
					--		end
					--		MsgInfo("Unable to save nonexistant terrain!")
					--	end,
					--	contextinfo = 'Save chunks'
					--}, 
					{ class = "bmenu",  name = "bload", texture = "textures/gui/panel_icons/load.png",  
						OnClick = function()
							local cparent = GetCamera():GetParent() 
							if cparent then
								
								OpenFileDialog(lastpath,".n",function(path)
									lastpath = file.GetDirectory(path) 
									local cp = string.sub(path,13)
									--curfilepath = path
									engine.LoadNode(cparent, cp) 
									MsgInfo("Nodefile "..cp.." loaded!")
								end) 
								--local s = panel.Create("window_save")
								--s:SetTitle("Load node") 
								--s:SetButtons("Load","Back") 
								--s.OnAccept = function(s,name) 
								--	engine.LoadNode(cparent, "manual/"..name) 
								--	MsgInfo("Nodes loaded!")
								--end
								--s:Show() 
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
						OnClick = function() worldeditor:SetGridMode("local") end,
						Pressed = worldeditor:GetGridMode()=="local"},
					{ class = "bmenu", texture = "textures/gui/panel_icons/parentspace.png", contextinfo='Parent grid',
						OnClick = function() worldeditor:SetGridMode("parent") end,
						Pressed = worldeditor:GetGridMode()=="parent"},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/possnap.png", contextinfo='Position snap',
						OnClick = function(s,val) worldeditor:SetPosSnap(val) end,
						Pressed = worldeditor:GetPosSnap()},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/anglesnap.png", contextinfo='Angle snap'},
					{class="menu_separator"},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/localorigin.png", contextinfo='Local origin'},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/medorigin.png", contextinfo='Median origin'},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/otherorigin.png", contextinfo='Point origin'},
					{class="menu_separator"},
					{ class = "bmenu",  name = "bsetchunk", texture = "textures/gui/panel_icons/load.png",  
						OnClick = function()
							for node,v in pairs(worldeditor.selected) do
								if IsValidEnt(node) then
									terrain_NodeSetChunk(node,true)
								end
							end
						end,
						contextinfo = 'Set as chunk nodes'
					}, 
					{ class = "bmenu",  name = "bunsetchunk", texture = "textures/gui/panel_icons/load.png",  
						OnClick = function()
							for node,v in pairs(worldeditor.selected) do
								if IsValidEnt(node) then
									terrain_NodeSetChunk(node,false)
								end
							end
						end,
						contextinfo = 'Remove from chunk nodes'
					}, 
					{class="menu_separator"},
					{ class = "bmenutoggle",  name = "bplacementauto", texture = "textures/gui/panel_icons/star.png",  
						OnClick = function(s)  
							worldeditor.bplacementauto = s:IsPressed()
						end,
						Pressed = worldeditor.bplacementauto,
						contextinfo = 'Place object on click'
					}, 
					{ class = "bmenutoggle",  name = "bplacementrandyaw", texture = "textures/gui/panel_icons/rotate.png",  
						OnClick = function(s)  
							worldeditor.bplacementrandyaw = s:IsPressed()
						end,
						Pressed = worldeditor.bplacementrandyaw,
						contextinfo = 'Use random Yaw rotation'
					}, 
					{ class = "bmenutoggle",  name = "bautochunknode", texture = "textures/gui/panel_icons/image.png",  
						OnClick = function(s)  
							worldeditor.autochunknode = s:IsPressed()
						end,
						Pressed = worldeditor.autochunknode,
						contextinfo = 'Make chunknode on spawn'
					}, 
				}
			}, 
			{ type = "dockslot", class = "back",   
				color = {0,0,0},
				size = {200,300},
				dock = DOCK_FILL, 
				subs ={ 
					{ type = "testdragable",   
						size = {300,300},
						dock = DOCK_LEFT,
						tabs = { 
							mesh = {type = "editor_panel_edmesh" },
							terrain = {type = "editor_panel_terrain" },
							nodes = {type = "editor_panel_node" },
						}
					},
					{ type = "testdragable",   
						size = {300,300},
						dock = DOCK_RIGHT,
						tabs = { 
							properties = {type = "node_properties" },
							materials = {type = "node_materials" } 
						}
					},
					{ type = "testdragable",   
						size = {300,300},
						dock = DOCK_BOTTOM,
						tabs = { 
							console = {type = "panel_console", enabled = true }, 
							assets = {type = "panel_assets" }, 
						}
					},
					
					{ type = "testdragable",   
						size = {300,300},
						dock = DOCK_FILL,
						tabs = { 
							viewport = {type = "viewport", id = "1", texture = "@main_final",
								OnClick = function ()
									if input.leftMouseButton() and self.bplacementauto:IsPressed() then
										WE_SpawnOnMouse(self.bplacementrandyaw:IsPressed())
									end
								end
							}, 
							flow = {type = "graph_editor" }, 
						}
					},
				}
			},
			--[[
			{ 
				visible = false, 
				dock = DOCK_FILL,
				subs = {
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
					
					--{ type = "panel_assets", class = "back",   
					--	color = {0,0,0},
					--	size = {200,300},
					--	dock = DOCK_BOTTOM, 
					--},
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
									MsgInfo("Editor nodes removed!")
								end,
								contextinfo='Clear nodes'
							},
							{ class = "bmenu",  name = "bsavenode", texture = "textures/gui/panel_icons/save.png", 
								OnClick = function()
									local cparent = GetCamera():GetParent()
									local cseed = cparent:GetSeed()
									if cseed ~= 0 then
										engine.SaveNode(cparent, tostring(cseed), TAG_EDITORNODE)
										MsgInfo("Nodes saved!")
									else
										MsgInfo("Unable to save nodes! Current node seed is 0!")
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
										s.OnAccept = function(s,name) 
											engine.SaveNode(cparent, "manual/"..name, TAG_EDITORNODE) 
											MsgInfo("Nodes saved!")
										end
										s:Show() 
									end
								end,
								contextinfo = 'Save nodes as'
							}, 
							--{ class = "bmenu", name = "bsavechunks", texture = "textures/gui/panel_icons/save.png", 
							--	OnClick = function()
							--		local cparent = GetCamera():GetParent()
							--		if cparent then
							--			local terrain = cparent:GetComponent(CTYPE_CHUNKTERRAIN)
							--			if terrain then
							--				terrain:SaveChunks()
							--				MsgInfo("Chunks saved!")
							--				return true
							--			end
							--		end
							--		MsgInfo("Unable to save nonexistant terrain!")
							--	end,
							--	contextinfo = 'Save chunks'
							--}, 
							{ class = "bmenu",  name = "bload", texture = "textures/gui/panel_icons/load.png",  
								OnClick = function()
									local cparent = GetCamera():GetParent() 
									if cparent then
										local s = panel.Create("window_save")
										s:SetTitle("Load node") 
										s:SetButtons("Load","Back") 
										s.OnAccept = function(s,name) 
											engine.LoadNode(cparent, "manual/"..name) 
											MsgInfo("Nodes loaded!")
										end
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
								OnClick = function() worldeditor:SetGridMode("local") end,
								Pressed = worldeditor:GetGridMode()=="local"},
							{ class = "bmenu", texture = "textures/gui/panel_icons/parentspace.png", contextinfo='Parent grid',
								OnClick = function() worldeditor:SetGridMode("parent") end,
								Pressed = worldeditor:GetGridMode()=="parent"},
							{ class = "bmenutoggle", texture = "textures/gui/panel_icons/possnap.png", contextinfo='Position snap',
								OnClick = function(s,val) worldeditor:SetPosSnap(val) end,
								Pressed = worldeditor:GetPosSnap()},
							{ class = "bmenutoggle", texture = "textures/gui/panel_icons/anglesnap.png", contextinfo='Angle snap'},
							{class="menu_separator"},
							{ class = "bmenutoggle", texture = "textures/gui/panel_icons/localorigin.png", contextinfo='Local origin'},
							{ class = "bmenutoggle", texture = "textures/gui/panel_icons/medorigin.png", contextinfo='Median origin'},
							{ class = "bmenutoggle", texture = "textures/gui/panel_icons/otherorigin.png", contextinfo='Point origin'},
							{class="menu_separator"},
							{ class = "bmenu",  name = "bsetchunk", texture = "textures/gui/panel_icons/load.png",  
								OnClick = function()
									for node,v in pairs(worldeditor.selected) do
										if IsValidEnt(node) then
											terrain_NodeSetChunk(node,true)
										end
									end
								end,
								contextinfo = 'Set as chunk nodes'
							}, 
							{ class = "bmenu",  name = "bunsetchunk", texture = "textures/gui/panel_icons/load.png",  
								OnClick = function()
									for node,v in pairs(worldeditor.selected) do
										if IsValidEnt(node) then
											terrain_NodeSetChunk(node,false)
										end
									end
								end,
								contextinfo = 'Remove from chunk nodes'
							}, 
							{class="menu_separator"},
							{ class = "bmenutoggle",  name = "bplacementauto", texture = "textures/gui/panel_icons/star.png",  
								OnClick = function(s)  
									worldeditor.bplacementauto = s:IsPressed()
								end,
								Pressed = worldeditor.bplacementauto,
								contextinfo = 'Place object on click'
							}, 
							{ class = "bmenutoggle",  name = "bplacementrandyaw", texture = "textures/gui/panel_icons/rotate.png",  
								OnClick = function(s)  
									worldeditor.bplacementrandyaw = s:IsPressed()
								end,
								Pressed = worldeditor.bplacementrandyaw,
								contextinfo = 'Use random Yaw rotation'
							}, 
							{ class = "bmenutoggle",  name = "bautochunknode", texture = "textures/gui/panel_icons/image.png",  
								OnClick = function(s)  
									worldeditor.autochunknode = s:IsPressed()
								end,
								Pressed = worldeditor.autochunknode,
								contextinfo = 'Make chunknode on spawn'
							}, 
						}
					}, 
					{type='viewport',name="vp",dock=DOCK_FILL, OnClick = function ()
						if input.leftMouseButton() and self.bplacementauto:IsPressed() then
							WE_SpawnOnMouse(self.bplacementrandyaw:IsPressed())
						end
					end}
				}
			}]]
			
		} 
    },self,sty,self)
    
    
	--self.vp:InitializeFromTexture(1,"@main_final") 
end 


function ViewportGetMousePos()
	local top = panel.GetTopElement()
	if top and top.isviewport then
		local vsz = top:GetSize()
		local vmp = top:GetLocalCursorPos()
		local vsr = (vmp/vsz) 
		return Vector(vsr.x,vsr.y,0)
	else
		return input.getInterfaceMousePos()
	end
end