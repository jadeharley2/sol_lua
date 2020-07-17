

function ENT:Init()
    self:SetSpaceEnabled(false)
    self:SetSizepower(10)
    self:SetScale(1/10)
end

function ENT:Spawn() 
    local d = self.data
    MsgN("MAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADP",d)
    if d and d.field_strength then
        self:SetDimensions(d.field_size,d.field_strength)
    end
end
function ENT:SetDimensions(size, mul) 
    mul = math.max(0,mul or 1)
    size = size or 1

    self:SetSizepower(mul)
    self:SetScale(size/mul)
end