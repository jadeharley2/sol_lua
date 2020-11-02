if not CLIENT then return end
console.AddCmd("modworldmat",function(path)
    local cam = GetCamera()
    local u = cam:GetTop()
    if not path  then
        u:RemoveComponents(CTYPE_MATERIALMOD) 
    else
        local mm = u:RequireComponent(CTYPE_MATERIALMOD) 
        mm:SetMaterial(LoadMaterial(path))
    end
end) 