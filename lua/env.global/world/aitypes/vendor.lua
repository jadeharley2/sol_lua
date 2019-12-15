
function ai:OnInit() 
    
    local e = self.ent
    
	e:AddTag(TAG_USEABLE)
    e:AddTag(TAG_NPC) 
    
	e.usetype = "trade"
	e:AddEventListener(EVENT_USE,"e",function(s,user)
        self:OpenMenu(user)
	end)  
end

function ai:DoTrade(ply,item,count,price)
    ply:SendEvent(EVENT_GIVE_ITEM,item,count)
end
function ai:DoTradeBuy(ply,item,count,price)
    local slt = ply.storage:GetItemSlot(item)
    if slt then
        ply:SendEvent(EVENT_ITEM_TAKEN,slt,count)
    end
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
                local p = panel.Create("window_trade")   
                
                p:SetPos(0,-600) 
                p:Open(self,e:GetName(),{},function (item,count,price)
                    self:DoTrade(ply,item,count,price)
                    return true
                end,
                function (item,count,price)
                    self:DoTradeBuy(ply,item,count,price)
                    return true
                end)
                self.dialog = p

                --local givefunc = function(LP,itemname) 
                --    ply:SendEvent(EVENT_GIVE_ITEM,'apparel.'..itemname) 
                --end
                --self.dialog:Setup("apparel",givefunc)
                --self.dialog.OnClose = function()
                --    self.dialog=false
                --    SHOWINV = false
                --end
                --self.dialog:Show()
                --self.dialog:SetPos(Point(0,-500))
                SHOWINV = true
            end
        end
    end
	
end
 
function ai:InDialog()
	return self.dialog~=nil
end