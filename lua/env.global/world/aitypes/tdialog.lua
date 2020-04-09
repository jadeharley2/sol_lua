
function ai:OnInit() 
    
    local e = self.ent
    
	e:AddTag(TAG_USEABLE)
    e:AddTag(TAG_NPC) 
    
	e.usetype = "ask"
	e:AddEventListener(EVENT_USE,"e",function(s,user)
        self:OpenMenu(user)
    end)  
    self.iknow = {}
end

function ai:OpenMenu(ply) 
    if self.dialog then
        self.dialog:Close()
        self.dialog = nil
        SHOWINV = false
    else
        if CLIENT and self.dialog == nil then
            local e = self.ent 
            if e then   
				e:SendEvent(EVENT_LERP_HEAD,ply)
                ply:SendEvent(EVENT_LERP_HEAD,e)
                 
                --self.dialog = panel.Create("window_formviewer") 
                local p = panel.Create("window_npc_dialog2")   
                
                p:SetPos(0,-600) 
                p:Start(self,e:GetName())


                local ddx = dialogue.New('test_parser')

                ddx:Set("player",'Anneke')
                ddx:Set("self",self.ent:GetName())
                ddx:Set("iknow",self.iknow) 
                ddx:Set("met",function(who)
                    return self.iknow[who]
                end)
                ddx:Set("setmet",function(who)
                    self.iknow[who] = true
                end)
                local cxz = {}
                cxz.opd = function (npc,ai,tb)
                    tb = tb or {}
                    local buff = ""
                    ddx.OnSay = function (actor,text)
                       if actor =='ARA' then
                            --MsgInfor(actor..": "..text)
                            --p:Open(text) 
                       end
                       buff = buff .. actor..": "..text.."\n" 
                    end
                    local rez = false
                    if tb.nooption then
                        rez = ddx:Run()
                    else
                        rez = ddx:Run(tb.t)
                    end
                    local main = {}
                    if rez =="CONT" then
                        main[#main+1] = {t = "next",f = cxz.opd, nooption=true}
                    else
                        for k,v in pairs(rez) do
                            main[#main+1] = {t = k,f = cxz.opd}
                        end
                    end
                    p:Open(buff,main) 
                    if #main==0 then 
                        SHOWINV = false
                    end
                    return #main>0
                end
                cxz.opd()

                self.dialog = p
 
                SHOWINV = true
            end
        end
    end
	
end
 
function ai:InDialog()
	return self.dialog~=nil
end