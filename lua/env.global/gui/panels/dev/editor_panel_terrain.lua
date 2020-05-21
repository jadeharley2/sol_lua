 
local layout = {
    color = {0,0,0},
    size = {200,200},
    subs = {
		--{ name = "header",class = "header_0",  
		--	text = "Terrain editor", 
		--},
		{  
			size = {100,40},
            dock = DOCK_TOP,
            color = {0,0,0},
            subs = {
                { class = "bmenutoggle", texture = "textures/gui/panel_icons/cancel.png", name = "bt_none",
                    contextinfo='Edit mode: None',
                    group = 'terrain'
                },
                { class = "bmenutoggle", texture = "textures/gui/panel_icons/raise.png",  name = "bt_raise",
                    OnClick = function()  end,
                    contextinfo='Edit mode: Raise',
                    group = 'terrain'
                },
                { class = "bmenutoggle", texture = "textures/gui/panel_icons/raise.png",  name = "bt_lower",
                    contextinfo='Edit mode: Lower',
                    rotation = 180,
                    group = 'terrain'
                },
                { class = "bmenutoggle", texture = "textures/gui/panel_icons/level.png",  name = "bt_level", 
                    contextinfo='Edit mode: Level', 
                    group = 'terrain'
                },
                { class = "bmenutoggle", texture = "textures/gui/panel_icons/paint.png",  name = "bt_paint", 
                    contextinfo='Edit mode: Paint', 
                    group = 'terrain'
                },
                { class = "bmenutoggle", texture = "textures/gui/panel_icons/texture.png",  name = "bt_texture", 
                    contextinfo='Edit mode: Texture', 
                    group = 'terrain'
                },
            }
		},
		{ 
			size = {100,15},
			dock = DOCK_TOP,
			textalignment = ALIGN_LEFT,
			text = "Brush radius (V+scroll):",
            textonly = true,
            textcolor = {1,1,1} 
		},
		{ name = "srad", type = "slider",
			size = {100,20},
			dock = DOCK_TOP,  
            color = {0.3,0.6,0.9}, 
            Maximum = 40,
            Value = 5,
		},
		{ 
			size = {100,15},
			dock = DOCK_TOP,
			textalignment = ALIGN_LEFT,
			text = "Brush power (B+scroll):",
            textonly = true,
            textcolor = {1,1,1} 
		},
		{ name = "spow", type = "slider",
			size = {100,20},
			dock = DOCK_TOP,  
            color = {0.3,0.6,0.9}, 
            Maximum = 100,
            Value = 10
		},
		{ class = "header_0",  
			text = "Brush color", 
		},
		{ type = 'colorpicker', name = "cpick",
			size = {200,200},
			dock = DOCK_TOP
		},
		{ class = "header_0", 
            text = "Surface type", 
		},
		{ type="list", name = "surfacetypelist", class = "back",
			dock = DOCK_FILL,  
		},
    }   
}

function PANEL:Init()  

    gui.FromTable(layout,self,global_editor_style,self) 
    self:PopulateSurfaceTypeList()
    self:UpdateLayout()
    self.mode = false
    self.bt_none.OnClick =  function(s) self:SetMode(false)  end
    self.bt_raise.OnClick =   function(s) self:SetMode('raise')  end
    self.bt_lower.OnClick =   function(s) self:SetMode('lower')  end
    self.bt_level.OnClick =   function(s) self:SetMode('level')  end
    self.bt_paint.OnClick =   function(s) self:SetMode('paint')  end
    self.bt_texture.OnClick = function(s) self:SetMode('tex')  end 
    self.srad.OnSlide = function(s,v) self.radius = v  end 
    self.spow.OnSlide = function(s,v) self.power = v  end  
    self.cpick.OnPick = function(s,color) 
        self.color = color
        --console.Call('terrain_color '..tostring(color.x)..' '..tostring(color.y)..' '..tostring(color.z))
    end 
end 
function PANEL:Update()
    local cam = GetCamera()
    local ent, terrain = cam:GetParentWithComponent(CTYPE_CHUNKTERRAIN)
    if terrain then
        
        if (not input.MouseIsHoveringAboveGui() or panel.GetTopElement().isviewport ) then
            local vp = panel.GetTopElement()
            local cmousep = nil
            if vp then
                local cs= vp:GetSize()
                cmousep = vp:GetLocalCursorPos()
                cmousep = Vector(cmousep.x/cs.x,cmousep.y/cs.y,0) 
            end
            local phtr = GetMousePhysTrace(cam,nil,cmousep)
            if phtr and phtr.Hit and phtr.Entity == ent then
                local r = self.radius or 5
                local mx = matrix.Scaling(r/phtr.Entity:GetSizepower()*1.2)
                    *matrix.Translation(phtr.Position)
                local mz = matrix.Scaling(r/phtr.Entity:GetSizepower()/5)
                    *matrix.Translation(phtr.Position)
                debug.ShapePrimCreate(31,phtr.Entity,'circle',mx)
                debug.ShapePrimCreate(32,phtr.Entity,'circle',
                    matrix.Rotation(Vector(90,0,0))*mx)
                debug.ShapePrimCreate(33,phtr.Entity,'circle',
                    matrix.Rotation(Vector(90,90,0))*mx)
                debug.ShapePrimCreate(34,phtr.Entity,'circle',mz)
                debug.ShapePrimCreate(35,phtr.Entity,'circle',
                    matrix.Rotation(Vector(90,0,0))*mz) 
                debug.ShapePrimCreate(36,phtr.Entity,'circle',
                    matrix.Rotation(Vector(90,90,0))*mz) 
                if input.leftMouseButton() then
                    local x = phtr.Position.x
                    local y = phtr.Position.z
                    local p = self.power or 10 
                    local color = self.color or Vector(1,1,1)
                    local type = self.type or 'void' 
                    if input.KeyPressed(KEYS_X) then p = -p end
                    if self.mode == 'raise' then   
                        terrain:Mod(x,y,r,p,1,color,type)
                    elseif self.mode == 'lower' then   
                        terrain:Mod(x,y,r,-p,1,color,type)
                    elseif self.mode == 'level' then   
                        terrain:Mod(x,y,r,p/100,2,color,type)
                    elseif self.mode == 'paint' then   
                        terrain:Mod(x,y,r,p/100,4,color,type)
                    elseif self.mode == 'tex' then   
                        terrain:Mod(x,y,r,p,5,color,type)
                    end
                end
            end
        end
    end
end
function PANEL:MouseWheel()
    local wheel = self.wheel or 0
    local nw = input.MouseWheel()
    local delta = nw-wheel
    self.wheel = nw 
    if input.KeyPressed(KEYS_V) then
		self.srad:SetValue(self.srad:GetValue()+delta/self.srad.maxvalue) 
    elseif input.KeyPressed(KEYS_B) then
		self.spow:SetValue(self.spow:GetValue()+delta/self.spow.maxvalue) 
    end
end
function PANEL:SetMode(mode)
    EDITOR_TERRAIN_MODE = mode
    self.mode = mode
    if mode then
        hook.Add(EVENT_GLOBAL_PREDRAW,"editor_terrain",function(s) self:Update() end)
        hook.Add("input.mousewheel","editor_terrain",function(s) self:MouseWheel() end)
    else
        hook.Remove(EVENT_GLOBAL_PREDRAW,"editor_terrain")
        hook.Remove("input.mousewheel","editor_terrain")
        --debug.ShapeDestroy(30)

        debug.ShapeDestroy(31)
        debug.ShapeDestroy(32)
        debug.ShapeDestroy(33)

        debug.ShapeDestroy(34)
        debug.ShapeDestroy(35)
        debug.ShapeDestroy(36)
    end
end
function PANEL:PopulateSurfaceTypeList()
    local sftl = self.surfacetypelist
    sftl:ClearItems()
    for k,v in SortedPairs(forms.GetList('surfacetype')) do 
        local data = forms.ReadForm('surfacetype.'..k)
        sftl:AddItem(gui.FromTable({
            size = {40,40},
            dock = DOCK_TOP,
            margin = {2,2,2,2},
            color = {0,0,0},
            subs = {
                {
                    dock = DOCK_LEFT,
                    size = {40,40},
                    texture = data.top.texture.diffuse
                },
                {
                    dock = DOCK_LEFT,
                    size = {40,40},
                    texture = data.slope.texture.diffuse
                },
                { type = "button",
                    dock = DOCK_TOP,
                    size = {20,20},  
                    text = data.name or k,
                    OnClick = function(s)
                        for k,v in pairs(sftl:GetItems()) do
                            v:SetColor(Vector(0,0,0))
                        end
                        s:GetParent():SetColor(Vector(0,1,0))
                        self:SelectSurfaceType(k)
                    end
                }
            }
        })) 
    end
end
function PANEL:SelectSurfaceType(type) 
    self.type = type
    --console.Call('terrain_surface '..type)
end