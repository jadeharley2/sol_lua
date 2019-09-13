

--interaction options table
--[[
    {
        actionname = {
            type = "string"
            text = "string",
            icon = "string",
            result = "string"
        }
    }

    action types:  



    examples
    1. button
    self:Interact(User) => {
        press = { 
            result="light:on",
            text = "Press button",
        },
        open = {
            text = "Open cover",
            icon = "open.png"
        }
    }
    self:Interact(User,"press")=> true 
    1. npc
    self:Interact(User) => {
        talk = {  
            type = "start_dialog",
            text = "Start dialog",
            icon = "talk.png"
        },
        trade = {
            type = "start_trade",
            text = "Trade items",
            icon = "trade.png"
        }
    }
    self:Interact(User,"trade") => {
        waterbarrel = { type="item", text="barrel of water",amount=3, price={3223,"credits"}}
    }
    self:Interact(User,"talk") => {
        wander = { type="item", text="You can go"}
    }

    -- buy a barrel of water: 
        GetInteractOptions(...,vendor) => returns available interact options
        GetInteractOptions(...,vendor,'start_trade') => returns available items
        Interact(...,vendor,'buy',{item='waterbarrel',amount=1}) 
]]


--function GetInteractOptions(USER,ENT,intent)
--    if ENT and USER then 
--        local f = ENT.GetInteractOptions 
--        if f then 
--            return f(ENT,USER,intent)  
--        end
--    end
--    return nil
--end
EVENT_INTERACT = DeclareEnumValue("event","INTERACT",				101032) 
function Interact(USER,ENT,intent,...)
    if ENT and USER then 
        ENT:SendEvent(EVENT_INTERACT,USER,intent,...)  
    end 
end
function GetInteractOptions(USER,ENT)
    local t = {}
    local et = ENT._interact
    if et and istable(et) then
        for k,v in pairs(et) do
            t[k] = v
        end
    end
    hook.Call('interact.options',USER,ENT,t)
    return t
end
--- player->vendor Interact()
--- vendor->player Interact('options',...)
--- player->vendor Interact('talk')
--- vendor->player Interact('talk_options',...)
--- player->vendor Interact('trade')
--- vendor->player Interact('trade_options',...)
--- player->vendor Interact('buy_item',...)
--- vendor->player Interact('result','ok')
hook.Add('interact.options','pickup',function(u,e,t)
    if e:HasTag(TAG_STOREABLE) then
        t.pickup = {text = "pick up"}
    end
end) 