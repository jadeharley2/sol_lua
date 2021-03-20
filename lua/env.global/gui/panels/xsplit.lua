 
function PANEL:Init() 
end
function PANEL:Resize()
    local sz = self:GetSize()
    --local pad = {self:GetPadding()}
    local center = Point(0,0)
    local chl = self:GetChildren()
    local cc = #chl
    for k,v in pairs(chl) do
        local w = sz.x/cc
        v:SetSize(sz.x/cc,sz.y)
        v:SetPos((k-1)*w*2-(cc-1)*w+center.x,center.y)
    end
end  