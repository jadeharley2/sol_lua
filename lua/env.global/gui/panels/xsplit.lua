 
function PANEL:Init() 
end
function PANEL:Resize()
    local sz = self:GetSize()
    --local pad = {self:GetPadding()}
    --local center = Point(0,0)
    local chl = self:GetChildren()
    local cc = #chl
    for k,v in pairs(chl) do
        local w = sz.x/cc
        v:SetSize(math.floor(sz.x/cc),sz.y)
        v:SetPos(math.floor((k-1)*w),0)-- -(cc-1)*w+center.x,center.y)
    end
end  