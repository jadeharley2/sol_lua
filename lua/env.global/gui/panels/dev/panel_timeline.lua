module.Require('video')

E_REC = E_REC or false
function PANEL:Init() 
    gui.FromTable({
        color = {0,0,0},
        size = {1000,100},
        subs = {
            { name = 'bpanel',
                textonly = true,
                size = {30,30},
                dock = DOCK_TOP,
                subs = {
                    { class = 'button',name = 'bnew',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        texture = 'textures/gui/panel_icons/new.png',
                        contextinfo = 'Clear path',
                        OnClick = function(s)
                            E_REC = cameramover.NewRecord(E_FS or GetCamera())
                            E_REC:BeginPath()
                        end 
                    },
                    { class = 'button',name = 'bapply',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        texture = 'textures/gui/panel_icons/left.png',
                        rotation = 90,
                        contextinfo = 'Apply path',
                        OnClick = function(s)
                            E_REC:EndPath(false)
                        end 
                    },
                    { class = 'tgbutton',name = 'bstop',
                        group = 'time',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        contextinfo = 'Stop',
                        texture = 'textures/gui/panel_icons/stop.png',
                        OnClick = function(s)
                            E_REC:Stop()
                            U.time:SetDeltaTime(0)
                        end,
                        toggleable = false
                    },

                    { class = 'tgbutton',name = 'breverse',
                        group = 'time',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        texture = 'textures/gui/panel_icons/play.png',
                        rotation = 180,
                        contextinfo = 'Play backwards',
                        OnClick = function(s)
                            local spd = tonumber(self.tspeed:GetText());
                            local tmul = tonumber(self.tmul:GetText());
                            (E_FS or GetCamera()):SetUpdating(true)
                            E_REC:Play(-spd,true)
                            U.time:SetDeltaTime(-spd*tmul)
                        end 
                    },
                    { class = 'tgbutton',name = 'bpause',
                        group = 'time',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        contextinfo = 'Pause',
                        texture = 'textures/gui/panel_icons/pause.png',
                        OnClick = function(s)
                            E_REC:Pause()
                            U.time:SetDeltaTime(0)
                        end 
                    },
                    { class = 'tgbutton',name = 'bplay',
                        group = 'time',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        contextinfo = 'Play',
                        texture = 'textures/gui/panel_icons/play.png',
                        OnClick = function(s)
                            local spd = tonumber(self.tspeed:GetText());
                            local tmul = tonumber(self.tmul:GetText());
                            (E_FS or GetCamera()):SetUpdating(true)
                            E_REC:Play(spd,true)
                            U.time:SetDeltaTime(spd*tmul)
                        end,
                    },
                    { class = 'button', name = 'bframe',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        contextinfo = 'Add path key',
                        texture = 'textures/gui/panel_icons/keyframe.png',
                        OnClick = function(s)
                            E_REC:AddNode()
                        end 
                    },
                    { type = 'input_text', name = 'tspeed',
                        dock = DOCK_LEFT,
                        size = {100,30}, 
                        text = '0.01',
                        contextinfo = 'Frame step',
                        rest_numbers = true,
                    },
                    { type = 'input_text', name = 'tmul',
                        dock = DOCK_LEFT,
                        size = {100,30}, 
                        text = '1',
                        contextinfo = 'Time multiplier',
                        rest_numbers = true,
                    },

                    { class = 'button',name = 'bsave',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        contextinfo = 'Save path',
                        texture = 'textures/gui/panel_icons/save.png',
                        OnClick = function(s)
                            E_REC:Save(self.tfile:GetText())
                        end 
                    },
                    { class = 'button',name = 'bload',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        contextinfo = 'Load path',
                        texture = 'textures/gui/panel_icons/load.png',
                        OnClick = function(s)
                            E_REC:Load(self.tfile:GetText())
                        end 
                    },
                    { type = 'input_text', name = 'tfile',
                        dock = DOCK_LEFT,
                        size = {200,30}, 
                        text = 'test0', 
                        contextinfo = 'Path filename',
                    },
                    { class = 'recbutton',name = 'brec',
                        dock = DOCK_LEFT,
                        size = {30,30},
                        contextinfo = 'Start recording',
                        texture = 'textures/gui/panel_icons/record.png',
                        OnClick = function(s,state)
                            if state then
                                MsgN("RECORDING STARTED")
                                s.contextinfo = 'Stop recording'
                                framecapture.StartCapture(self.trecfile:GetText(),1)
                            else
                                MsgN("RECORDING STOPPED")
                                s.contextinfo = 'Start recording'
                                framecapture.StopCapture()
                            end
                        end 
                    },
                    { type = 'input_text', name = 'trecfile',
                        dock = DOCK_LEFT,
                        size = {200,30}, 
                        text = 'output0', 
                        contextinfo = 'Record output path',
                    },
                }
            },
            { name = 'timepanel',
                color = {0.1,0.1,0.1},
                dock = DOCK_FILL,
                margin = {4,4,4,4}
            }
        }
    },self,{
        button = {
            type = 'button',
            states = {
                idle = {color={0.5,0.4,0.3}},
                hover = {color={0.7,0.6,0.4}},
                pressed = {color={1,1,0.5}},
            },
            state = 'idle'
        },
        tgbutton = {
            type = 'button',
            states = {
                idle = {color={0.5,0.5,0.5}},
                hover = {color={0.7,0.7,0.7}},
                pressed = {color={0.5,1,0.5}},
            },
            state = 'idle',
            toggleable = true
        },
        recbutton = {
            type = 'button',
            states = {
                idle = {color={0.5,0.2,0.2}},
                hover = {color={0.7,0.7,0.7}},
                pressed = {color={1,0.5,0.5}},
            },
            state = 'idle',
            toggleable = true
        }
    },self) 
end

function PANEL:SetState(state)
    
    if state == 'p' then

    end
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