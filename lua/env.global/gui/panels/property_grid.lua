
function PANEL:Init()
    self:SetAutoSize(false,true)
    self:SetSize(200,200)
    self:SetColor(Vector(0,0,0))
    self:SetTextOnly(true)
end

function PANEL:SetObject(obj,info)
    info = info or {}
    self.object = obj
    self.info = info
    self.valtable = {}
    self:Clear()
    local textsize = 20
    if istable(obj) then
        for k,value in pairs(obj) do
            if not string.starts(k,'_') then
                local info = info[k] 
                local proptype = 'display'
                if info then
                    proptype = info.type
                else
                    proptype = type(value)
                    if proptype=='userdata' then
                        if IsOfType(value,'Vector') then
                            proptype = 'vector'
                        end
                    elseif proptype == 'table' then
                        if #value ==3 then 
                            proptype = 'vector'
                        else 
                            proptype = 'array'
                        end
                    end
                end

                local pva = panel.Create("button") 
                pva:SetColorAuto(Vector(0.6,0.6,0.6)/2,0)
                pva:SetTextColor(Vector(0,0,0))
                pva:SetSize(20,textsize)
                pva:Dock(DOCK_TOP)
                pva:SetMargin(5,2,0,0)
                pva:SetTextAlignment(ALIGN_LEFT)
                pva:SetText(k..":")
                --pva:SetTextOnly(true)
                pva:SetMargin(2,2,2,2)
                --pva.OnClick = function() end
                self:Add(pva)


                local inp = false
                if proptype == 'boolean' or proptype == 'bool' then 
                    inp = panel.Create("checkbox")  
                    inp:SetSize(20,20)
                    inp:Dock(DOCK_RIGHT)
                    pva:Add(inp)
                    self.valtable[k] = function(v)
                        inp:SetValue(v or false)
                    end
                    inp.OnValueChanged = function(s,newv) 
                        obj[k] = newv
                        self:OnUpdate(k,newv)
                    end
                elseif proptype == "number" then 
					inp = panel.Create("input_text")   
					inp:SetSize(220,textsize) 
					inp:Dock(DOCK_RIGHT)
					inp.rest_numbers = true 
					inp.OnTextChanged = function(n,key) 
                        --if key== KEYS_ENTER then
                            local newv = tonumber(n:GetText())
                            obj[k] = newv
                            self:OnUpdate(k,newv)
						--end
                    end 
                    self.valtable[k] = function(v)
                        inp:SetText(tostring(v or "")) 
                    end
					pva:Add(inp) 
				elseif proptype == "string" then 
					inp = panel.Create("input_text")  
					inp:SetSize(220,textsize)
					inp:Dock(DOCK_RIGHT) 
					--inp.evalfunction = v2.proc 
					inp.OnTextChanged = function(n,key) 
						--if key== KEYS_ENTER then 
                            local newv = n:GetText()
                            obj[k] = newv
                            self:OnUpdate(k,newv)
						--end
					end
                    self.valtable[k] = function(v)
                        inp:SetText(tostring(v or "")) 
                    end
					pva:Add(inp)
                elseif proptype == "vector" then  
                    local changed = function (s)
                        
                    end
                    
                    gui.FromTable({
                        size = {20,textsize*3},
                        text = "",
                        subs = {
                            {
                                textonly = true,
                                size = {220,220},
                                dock = DOCK_RIGHT,
                                subs = {
                                    { type = 'input_text', name = "vx",
                                        size = {20,textsize-2},
                                        dock = DOCK_TOP,
                                        margin = {2,2,2,2},
                                        OnTextChanged = changed
                                    },
                                    { type = 'input_text', name = "vy",
                                        size = {20,textsize-2},
                                        dock = DOCK_TOP,
                                        margin = {2,2,2,2},
                                        OnTextChanged = changed
                                    },
                                    { type = 'input_text', name = "vz",
                                        size = {20,textsize-2},
                                        dock = DOCK_TOP,
                                        margin = {2,2,2,2},
                                        OnTextChanged = changed
                                    }
                                }
                            },
                            {
                                textonly = true,
                                size = {20,textsize},
                                dock = DOCK_TOP,
                                text = k..":",
                                textaligment = ALIGN_LEFT
                            }
                        }
                    },pva,{},pva)
                    inpx = panel.Create("input_text")  
                    
                    
                    self.valtable[k] = function(v)
                        pva.vx:SetText(tostring(v.x or v[1]))
                        pva.vy:SetText(tostring(v.y or v[2]))
                        pva.vz:SetText(tostring(v.z or v[3]))
                       -- inp:SetText(tostring(v or "")) 
                    end
                    pva:Add(inpx) 
                elseif proptype == "array" then  
                        local changed = function (s)
                            local newv = tonumber(s:GetText())
                            obj[k][s.index] = newv
                            self:OnUpdate(k,obj[k]) 
                        end
                        local fieldnum = #value
                        gui.FromTable({
                            size = {20,textsize*fieldnum},
                            text = "",
                            subs = {
                                { name = "fields",
                                    textonly = true,
                                    size = {220,220},
                                    dock = DOCK_RIGHT,
                                },
                                {
                                    textonly = true,
                                    size = {20,textsize},
                                    dock = DOCK_TOP,
                                    text = k..":",
                                    textaligment = ALIGN_LEFT
                                }
                            }
                        },pva,{},pva)
                        inpx = panel.Create("input_text")  
                        local fieldray = {}
                        for k=1,fieldnum do
                            local field = gui.FromTable({ type = 'input_text',
                                size = {20,textsize-2},
                                dock = DOCK_TOP,
                                margin = {2,2,2,2},
                                index = k,
                                OnTextChanged = changed
                            })
                            fieldray[k] = field
                            pva.fields:Add(field)
                        end 
                        
                        self.valtable[k] = function(v) 
                            for kk,vv in pairs(v) do
                                fieldray[kk] = tostring(vv)
                            end  
                        end
                        pva:Add(inpx)
                end

                if inp then


                end
            end
        end
    end

    self:UpdateValues()
    self:UpdateLayout()
end

function PANEL:UpdateValues()
    local obj = self.object
    if obj then
        for k,f in pairs(self.valtable) do
            f(obj[k])
        end
    end
end

function PANEL:OnUpdate(key, value)
    
end