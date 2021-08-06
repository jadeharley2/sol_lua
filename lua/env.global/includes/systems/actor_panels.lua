if SERVER then return end

actor_panels = actor_panels or {}
actor_panels.panels = actor_panels.panels or {}
actor_panels.persistent = actor_panels.persistent or {}
function actor_panels.SetSide(panel,side)
    local vsize = GetViewportSize()
    local psize = panel:GetSize()
    if side==ALIGN_LEFT then 
        panel:SetPos(0,vsize.y/2-psize.y/2)
    elseif side==ALIGN_RIGHT then
        panel:SetPos(vsize.x-psize.x,vsize.y/2-psize.y/2) 
    elseif side==ALIGN_TOP then
        panel:SetPos(vsize.x/2-psize.x/2,0) 
    elseif side==ALIGN_BOTTOM then
        panel:SetPos(vsize.x/2-psize.x/2,vsize.y-psize.y-50) 
    end
end
function actor_panels.OpenPanel(ptype,node,side,data) 
    local vsize = GetViewportSize()

    local v = actor_panels.persistent['local_'..ptype] 
      
    if not v then
        data = data or {}
        data.type = ptype
        v = gui.FromTable(data) 
        v:UpdateLayout()  
    end 
    v:Show()

    actor_panels.SetSide(v,side)
    actor_panels.AddPanel(v)
    if node == LocalPlayer() then
        actor_panels.SetPersistent('local_'..ptype,v)
    end
    return inv
end
function actor_panels.OpenInventory(node,side, inv) 
    local vsize = GetViewportSize()

    if node == LocalPlayer() then 
        inv = inv or actor_panels.persistent['local_inv'] 
    end
    if not inv then
        inv = panel.Create("window_inventory")
        inv:UpdateLayout()
        inv:SetTitle("Inventory") 
        inv:UpdateLayout() 
    end
    inv.node = node
    inv:RefreshINV() 

    actor_panels.SetSide(inv,side)
    actor_panels.AddPanel(inv)
    if node == LocalPlayer() then
        actor_panels.SetPersistent('local_inv',inv)
    end
    return inv
end
function actor_panels.OpenCharacterInfo(node,side, char)

    MsgN(node,node==LocalPlayer())
    if node == LocalPlayer() then 
        char = char or actor_panels.persistent['local_cinfo']  
    end
    if not char then
        char = panel.Create("window_character") 
        char:SetTitle("Character") 
    end
    char:Set(node)
    
    actor_panels.SetSide(char,side) 
    actor_panels.AddPanel(char)
    if node == LocalPlayer() then
        actor_panels.SetPersistent('local_cinfo',char)
    end
    return char
end
function actor_panels.OpenDialog(node,side, dialog)  
    
    if node == LocalPlayer() then 
        dialog = dialog or actor_panels.persistent['local_dialog']  
    end
    if not dialog then
        dialog = panel.Create("window_npc_dialog")  
    end 
    actor_panels.SetSide(dialog,side) 
    actor_panels.AddPanel(dialog)
    if node == LocalPlayer() then
        actor_panels.SetPersistent('local_dialog',dialog)
    end
    return dialog
end

function actor_panels.AddPanel(p,donotopen)
    actor_panels.panels[#actor_panels.panels+1] = p
    SHOWINV = true
    if not donotopen and p and p.Open then p:Open() end
end
function actor_panels.SetPersistent(name,panel)
    actor_panels.persistent[name] = panel 
end
function actor_panels.CloseAll()
    for k,v in pairs(actor_panels.panels) do
        if v and v.Close then v:Close() end
    end
    actor_panels.panels = {}
    SHOWINV = false
    hook.Call("actor_panels.closed")
end
function actor_panels.HasPanels()
    return #actor_panels.panels > 0
end
function actor_panels.FreePersistent() 
    actor_panels.persistent = {}
end


actor_panels.__index = nil
console.AddCmd("actor_panels.free",actor_panels.FreePersistent)
