

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
function Interact(USER,TARGET,intent,...)
    if IsValidEnt(TARGET) and IsValidEnt(USER) then  
        local dist = TARGET:GetDistance(USER)
        if dist<(USER.userange or 2) then
        TARGET:SendEvent(EVENT_INTERACT,USER,intent,...)  
        --MsgN("[interact] ",intent,USER,TARGET)
        end
    end 
end
function GetInteractOptions(USER,ENT)
    local t = {}
    local et = ENT._interact
    if et and istable(et) then
        for k,v in pairs(et) do
            if not isfunction(v.isvalid) or CALL(v.isvalid,ENT,USER,v) == true then 
                if v.text and isfunction(v.text) then
                    local vnew = table.Copy(v)
                    vnew.text = CALL(v.text,ENT,USER)  
                    if isstring(vnew.text) then
                        t[k] = vnew
                    end
                else
                    t[k] = v
                end
            end
        end
    end
    hook.Call('interact.options',USER,ENT,t)
    return t
end
local registry = debug.getregistry()
local ENTITY = registry.Entity

ENTITY._metaevents[EVENT_INTERACT] = {
    networked = true,
    f = function (self,user,intent,...)
        local i = self._interact
        if i then
            local interacttype = i[intent]
            if interacttype and interacttype.action then
                interacttype.action(self,user,...)
                return true
            end
        end
        hook.Call("interact",user,self,intent,...)
    end
}
function ENTITY:AddInteraction(itype,table) 
    self._interact = self._interact or {}
    self._interact[itype] = table
end
--- player->vendor Interact()
--- vendor->player Interact('options',...)
--- player->vendor Interact('talk')
--- vendor->player Interact('talk_options',...)
--- player->vendor Interact('trade')
--- vendor->player Interact('trade_options',...)
--- player->vendor Interact('buy_item',...)
--- vendor->player Interact('result','ok')
