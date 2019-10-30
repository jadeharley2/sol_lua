E_REC = E_REC or false
function PANEL:Init()
    gui.FromTable({
        color = {0,0,0},
        size = {1000,100},
        subs = {
            {
                textonly = true,
                size = {30,30},
                dock = DOCK_TOP,
                subs = {
                    { type = 'button',name = 'bnew',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        texture = 'textures/gui/panel_icons/new.png',
                        OnClick = function(s)
                            E_REC = cameramover.NewRecord(E_FS or GetCamera())
                            E_REC:BeginPath()
                        end 
                    },
                    { type = 'button',name = 'bapply',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        texture = 'textures/gui/panel_icons/save.png',
                        OnClick = function(s)
                            E_REC:EndPath(false)
                        end 
                    },
                    { type = 'button',name = 'bstop',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        texture = 'textures/gui/panel_icons/stop.png',
                        OnClick = function(s)
                            E_REC:Stop()
                        end 
                    },

                    { type = 'button',name = 'breverse',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        texture = 'textures/gui/panel_icons/play.png',
                        rotation = 180,
                        OnClick = function(s)
                            local spd = tonumber(self.tspeed:GetText());
                            (E_FS or GetCamera()):SetUpdating(true)
                            E_REC:Play(-spd,true)
                        end 
                    },
                    { type = 'button',name = 'bpause',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        texture = 'textures/gui/panel_icons/pause.png',
                        OnClick = function(s)
                            E_REC:Pause()
                        end 
                    },
                    { type = 'button',name = 'bplay',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        texture = 'textures/gui/panel_icons/play.png',
                        OnClick = function(s)
                            local spd = tonumber(self.tspeed:GetText());
                            (E_FS or GetCamera()):SetUpdating(true)
                            E_REC:Play(spd,true)
                        end 
                    },
                    { type = 'button', name = 'bframe',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        texture = 'textures/gui/panel_icons/keyframe.png',
                        OnClick = function(s)
                            E_REC:AddNode()
                        end 
                    },
                    { type = 'input_text', name = 'tspeed',
                        dock = DOCK_LEFT,
                        size = {100,30}, 
                        text = '0.01',
                        rest_numbers = true,
                    },

                    { type = 'button',name = 'bsave',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        texture = 'textures/gui/panel_icons/save.png',
                        OnClick = function(s)
                            E_REC:Save(self.tfile:GetText())
                        end 
                    },
                    { type = 'button',name = 'bload',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        texture = 'textures/gui/panel_icons/load.png',
                        OnClick = function(s)
                            E_REC:Load(self.tfile:GetText())
                        end 
                    },
                    { type = 'input_text', name = 'tfile',
                        dock = DOCK_LEFT,
                        size = {200,30}, 
                        text = 'test0', 
                    },
                }
            }
        }
    },self,{},self) 
end

PANEL.gtimeline = PANEL.gtimeline or false


console.AddCmd("timeline",function()
    if PANEL.gtimeline then
        PANEL.gtimeline:Close()
        PANEL.gtimeline = false
    else
        local debugp = panel.Create("panel_timeline") 
		local wsize = GetViewportSize()   
		debugp:SetPos(0,-wsize.y+100)
        PANEL.gtimeline = debugp
        debugp:Show()      
         MsgN(debugp.tspeed)
    end
end)