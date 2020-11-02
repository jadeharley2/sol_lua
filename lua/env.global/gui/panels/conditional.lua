




function PANEL:Init()  
    self.variants = {}
end

function PANEL:AddVariant(key,value)
    self.variants[key] = value
end
function PANEL:SetHook(name)
    local key, id = unpack(string.split(name,"@")) 
    MsgN("f",name,key,id)
    hook.Add(key, id, function (mode)
        if self:GetTop() then
            local r = self.variants[mode]
            if r then
                self:Clear()
                r:Dock(DOCK_FILL)
                self:Add(r)
                self:UpdateLayout()
            end
        else
            hook.Remove(key, id)
        end
    end)
end

PANEL.variants_info = {type = 'children_dict',add = PANEL.AddVariant}