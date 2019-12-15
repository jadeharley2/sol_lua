
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
local layout = {
    color = {0,0,0},
    size = {200,200},
    subs = {
		{ name = "header",
			size = {100,20},
			dock = DOCK_TOP,
			textalignment = ALIGN_CENTER,
			text = "Mesh editor",
			color = {0.3,0.6,0.9}, 
		},
		{  
			size = {100,40},
            dock = DOCK_TOP,
            color = {0,0,0},
            subs = {
                { class = "bmenutoggle", texture = "textures/gui/panel_icons/cancel.png", name = "bt_none",
                    contextinfo='None',
                    group = 'op', mode = false
                },
                { class = "bmenutoggle", texture = "textures/gui/panel_icons/extrude.png",  name = "bt_extrude", 
                    contextinfo='Extrude',
                    group = 'op', mode = 'extrude'
                }, 
                { class = "bmenutoggle", texture = "textures/gui/panel_icons/inset.png",  name = "bt_inset", 
                    contextinfo='Inset',
                    group = 'op', mode = 'inset'
                }, 
                { class = "bmenutoggle", texture = "textures/gui/panel_icons/tesselate.png",  name = "bt_tesselate", 
                    contextinfo='Tesselate',
                    group = 'op', mode = 'tesselate'
                }, 
            }
		}, 
		{ name = "header",
			size = {100,20},
			dock = DOCK_TOP,
			textalignment = ALIGN_CENTER,
			text = "Create",
			color = {0.3,0.6,0.9}, 
		},
		{  
			size = {100,40},
            dock = DOCK_TOP,
            color = {0,0,0},
            subs = { 
                { class = "bmenutoggle", texture = "textures/gui/panel_icons/ngon.png",  name = "bt_ngon", 
                    contextinfo='Create NGon',
                    group = 'op', mode = 'ngon'
                },
                { class = "bmenutoggle", texture = "textures/gui/panel_icons/staircase.png",  name = "bt_stairs", 
                    contextinfo='Create Stairs',
                    group = 'op', mode = 'stairs'
                },
            }
		}, 
		{ 
			size = {100,20},
			dock = DOCK_TOP,
			textalignment = ALIGN_CENTER,
			text = "Operation parameters",
			color = {0.3,0.6,0.9}, 
		},
		{ type="list", name = "paramlist",
			dock = DOCK_FILL, 
			color = {0.1,0.1,0.1}, 
		},
    }   
}

function PANEL:Init()  

    gui.FromTable(layout,self,sty,self)  
    self:UpdateLayout()
    self.mode = false 
    local set_mode = function(s)
        self:SetMode(s.mode)
    end 
    self.bt_none.OnClick = set_mode
    self.bt_extrude.OnClick = set_mode
    self.bt_inset.OnClick = set_mode
    self.bt_tesselate.OnClick = set_mode

    self.bt_ngon.OnClick = set_mode
    self.bt_stairs.OnClick = set_mode
    
    
    
    
end  

function PANEL:SetMode(mode)
    self.mode = mode
end