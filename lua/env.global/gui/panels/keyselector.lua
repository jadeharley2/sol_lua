
PANEL.basetype = "button"

function PANEL:Init()
    self.base.Init(self)
    self:SetText( "??")
end
function PANEL:OnClick()
    self:Disable()
    self:SetState("pressed")
    self:SetText( "[Press key to setup]")
	hook.Add("input.keydown", "gui.keyselector",function(k) self:SelectKey(k) end)
end
function PANEL:SelectKey(key)
    hook.Remove("input.keydown", "gui.keyselector")
    self:Enable()
    self:SetState("idle")

    self:SetText( input.KeyData(key))
    self.value = key
    local onkeyselect = self.OnKeySelected
    if isfunction(onkeyselect) then
        onkeyselect(self,key)
    end
end
function PANEL:GetValue()
    return self.value
end
function PANEL:SetValue(val)
    self.value = val
    self:SetText( input.KeyData(val))
end