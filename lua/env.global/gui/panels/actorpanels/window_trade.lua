PANEL.basetype = "menu_dialog"

local layout = {
	color = {0,0,0},
	subs = {
        { name = "balance",
            dock = DOCK_BOTTOM,
            size = {20,20},
            text = "balance",
            textcolor = {1,1,1},
            color = {0,0,0},
            textalignment = ALIGN_RIGHT
        },
        {type = "tabmenu", 
            color = {0,0,0},
            dock = DOCK_FILL,
            tabs = {
                SELL = { type = "list", name = "list_sell",
                    color = {0,0,0},
                    dock = DOCK_FILL
                },
                BUY = { type = "list", name = "list",
                    color = {0,0,0},
                    dock = DOCK_FILL
                },
            }
        },
		
	}
}

function PANEL:Init()
	--PrintTable(self)
	self.fixedsize = true
	self.base.Init(self,"title",300,800)
    gui.FromTable(layout,self,{},self)  
end 

function PANEL:GetPrice(formid)
    local hash = debug.GetHash(formid)
    math.randomseed(hash)
    local price =currency.GetBasePrice(formid) + math.random(100,1000)
    return price
end

function PANEL:Open(npc,text,options,callback_buy,callback_sell) 
    self.label:SetText(text) 
	self.list:ClearItems()
	self.list_sell:ClearItems()
    
    local player = LocalPlayer()

    local plbalance = currency.GetBalance(player) or 0
    self.balance:SetText("balance: "..plbalance.." cr")

    local clc_buy = function(s)
        local price = s.price
        if price<=plbalance then
            if callback_buy(s.item,1,price) then
                currency.ModifyBalance(player,'cr',-price)
            end
            self:Open(npc,text,options,callback_buy,callback_sell)
        else
            MsgInfo("Not enough credits "..price.."/"..plbalance)
        end
    end
    local clc_sell = function(s)
        local price = s.price
        if callback_sell(s.item,1,price) then
            currency.ModifyBalance(player,'cr',price)
        end
        self:Open(npc,text,options,callback_buy,callback_sell)
    end
    local clc_sell_all = function(s)
        local price = s.price
        local count = player.storage:FormIdCount(s.item) 
        if callback_sell(s.item,count,price) then
            currency.ModifyBalance(player,'cr',price*count)
        end
        self:Open(npc,text,options,callback_buy,callback_sell)
    end
 
    local form_type = "apparel"
    local filter = nil --"vendor_small"
	local flist = forms.GetList(form_type,filter)  
	for k,v in SortedPairs(flist) do     
        local formid = 'apparel.'..k 
        self:AddItem(formid,v,plbalance,clc_buy) 
    end

    local form_type = "tool"
    local filter = nil --"vendor_small"
	local flist = forms.GetList(form_type,filter)  
	for k,v in SortedPairs(flist) do     
        local formid = 'tool.'..k 
        self:AddItem(formid,v,plbalance,clc_buy) 
    end


    for k,v in pairs(player.storage:GetItems()) do
        if v and v.formid then 
            local formid = v.formid
            local price = self:GetPrice(formid)/10
            local fcount = v.count or 1
            local count = ""
            if fcount>1 then count = tostring(fcount) end
            self.list_sell:AddItem(gui.FromTable({  type = "button",
                dock = DOCK_TOP,
                text_alignment = ALIGN_LEFT,
                size = {150,60},
                item = formid,
                price = price,
                subs = {
                    {
                        texture =  forms.GetIcon(formid) or "textures/gui/icons/unknown.png",
                        size = {60,60},
                        dock = DOCK_LEFT,
                        mouseenabled = false,
                        subs = {
                            {
                                mouseenabled = false,
                                text = count,
                                size = {24,24},
                                textonly = true,
                                dock = DOCK_TOP,
                                textalignment = ALIGN_RIGHT,
                                textcolor = {1,1,1}
                            }
                        }
                    },
                    {
                        text = forms.GetName(formid) or "unknown",
                        textonly = true,
                        size = {20,30},
                        dock = DOCK_TOP,
                        mouseenabled = false
                    },
                    { type = "button",
                        text = "sell all",
                        size = {100,20},
                        dock = DOCK_RIGHT,
                        OnClick = clc_sell_all,
                        price = price,
                        item = formid
                    },
                    {
                        text = "sell price: "..tostring(price).." cr  total: "..tostring(fcount*price).." cr",
                        textonly = true, 
                        size = {20,20},
                        textalignment = ALIGN_LEFT,
                        dock = DOCK_BOTTOM,
                        mouseenabled = false,
                    }, 
                },
                OnClick = clc_sell
            })) 
        end
    end
    self:Show()
end 

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end

function PANEL:AddItem(formid,v,plbalance,clc_buy)
    local price = self:GetPrice(formid)
    local tcolor = {0,0.6,0}
    if price>plbalance then
        tcolor = {0.6,0,0}
    end
    
    self.list:AddItem(gui.FromTable({  type = "button",
        dock = DOCK_TOP,
        text_alignment = ALIGN_LEFT,
        size = {150,60},
        item = formid,
        price = price,
        subs = {
            {
                texture =  forms.GetIcon(formid) or "textures/gui/icons/unknown.png",
                size = {60,60},
                dock = DOCK_LEFT,
                mouseenabled = false
            },
            {
                text = v,
                textonly = true,
                size = {20,30},
                dock = DOCK_TOP,
                mouseenabled = false
            },
            {
                text = "price: "..tostring(price).." cr",
                textonly = true,
                textcolor = tcolor,
                size = {20,20},
                textalignment = ALIGN_LEFT,
                dock = DOCK_BOTTOM,
                mouseenabled = false
            }, 
        },
        OnClick = clc_buy
    })) 
end