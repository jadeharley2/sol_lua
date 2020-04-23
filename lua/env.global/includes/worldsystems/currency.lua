currency = currency or {}
currency.data = currency.data or {}
currency.types = currency.types or {}

local data = currency.data
local types = currency.types
function currency.RegisterCurrencty(type,name,icon)
    types[type] = {name = name,icon = icon}
end
function currency.GetType(type)
    return types[type]
end

---@param entity Entity
---@param type string
function currency.GetBalance(entity,type)
    type = type or 'cr'

    if IsValidEnt(entity) then
        local seed = entity:GetSeed()
        local record = data[seed]
        if record then
            local balance = record[type]
            return balance or 0
        end
    end
    return 0
end 

function currency.ModifyBalance(entity, type, value) 
    if IsValidEnt(entity) then
        local seed = entity:GetSeed()
        local record = data[seed] or {}
        data[seed] = record

        record[type] = (record[type] or 0) + value
    end 
end

function currency.GetAvailable(entity)
    if IsValidEnt(entity) then
        local seed = entity:GetSeed()
        local record = data[seed]
        if record then
            local nt = {}
            for k,v in pairs(record) do
                nt[k] = v
            end
            return nt
        end
    end
    return {}
end 
 
currency.defaultprices = json.Read("forms/pricelists/default.json")
function currency.GetBasePrice(formid) 
    local defprice = currency.defaultprices[formid]
    if defprice then return defprice end

    local data = forms.ReadForm(formid)
    local totals = 0
    if data then
        local c = data.composition
        totals = totals + (data.price or 0)
        if c and istable(c) then
            for k,v in pairs(c) do
                local pr = currency.defaultprices[k]
                if pr then
                    totals = totals + pr * v
                else
                    totals = totals + 100 * v
                end
            end
        end
    end
    return totals*2.5
end

currency.RegisterCurrencty('cr','universal credit','textures/gui/icons/currency/cr.png')


if CLIENT then
    console.AddCmd("addcr", function (amount)
        currency.ModifyBalance(LocalPlayer(),'cr',amount)
    end)
end