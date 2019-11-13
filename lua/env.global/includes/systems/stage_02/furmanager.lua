if SERVER then return end

furmanager = furmanager or {} 
furmanager.renderer = furmanager.renderer or false 
furmanager.RenderFur = function(task,callback) 
	local rte = furmanager.renderer
	if not IsValidEnt(rte) then 
		rte = ents.Create("util_textureRenderer")
		rte.size = 128
		rte:Spawn()
		furmanager.renderer = rte
	end 
	rte:Draw(nil,task,callback,{
		backcolor = Vector(1,1,1),
		backalpha = 1, 
		blend = BLEND_SUBTRACT
	}) 
end    
 
furmanager.PrepareModel = function(vm,nmat) 
    for matid,matname in pairs(vm:GetMaterials()) do
        local matval = nmat[matname] 
        if not matval then 
            matval = vm:GetMaterial(matid-1)
            local furLen = GetMaterialProperty(matval,'furLen')
            if furLen and furLen>0 then
                matval = CopyMaterial(matval)
                nmat[matname] = matval
                vm:SetMaterial(matval,matid-1)
                MsgN("new fur mat found:",matname)
            else
                --notfur
            end
        else
            vm:SetMaterial(matval)
        end  
    end
end
furmanager.PrepareMaterials = function(node) 
    local nmat = {}
    furmanager.PrepareModel(node.model,nmat)
    for k,v in pairs(node:GetChildren(true)) do
        if v:GetClass()=='body_part' and not v.iscloth then
           furmanager.PrepareModel(v.model,nmat)
        end
    end
    return nmat
end 
furmanager.UpdateMaterials = function(node,ent)  
    for matname,material in pairs(node.mat) do 
        local renderdata = {}
        for slot,masktable in pairs(node.masks) do
            local texvalue = masktable[matname] 
            if texvalue then
                renderdata[#renderdata+1] = { size = {128,128}, texture = texvalue}
            end 
        end
        if #renderdata==0 then
            SetMaterialProperty(material,'g_MeshTexture_g','textures/debug/white.png')
            hook.Call("fur_update",ent,matname,'textures/debug/white.png')
            --MsgN("renderdata==0",matname)
        else
            --PrintTable(renderdata)
            furmanager.RenderFur(gui.FromTable({subs = renderdata}),function(tex)
                SetMaterialProperty(material,'g_MeshTexture_g',tex)
                hook.Call("fur_update",ent,matname,tex)
            end)
        end
    end  
end
 

hook.Add("actor.setcharacter","furm",function(node,char)
    if node.hasfur then
        local mats = furmanager.PrepareMaterials(node)
        if mats then 
            local matv = {}
            for k,v in pairs(mats) do 
                matv[file.GetFileNameWE(k)] = v
                --SetMaterialProperty(v,"furLen",3)
            end
            local nfrm =  node._furmasks
            if nfrm then
                nfrm.mat = matv 
                debug.Delayed(100,function()
                    furmanager.UpdateMaterials(nfrm,node)
                end)
            else
                node._furmasks = {masks={},mat = matv}
            end 
        end
    end
end)
hook.Add("equipment.equip","furm",function(node,slot,data)
    if data.furmasks then
        local n = node._furmasks
        if n then 
            --MsgN("##EQUIP",slot)
            n.masks[slot] = data.furmasks 
            debug.Delayed(100,function()
                furmanager.UpdateMaterials(n,node) 
            end)
        end
    end
end)
hook.Add("equipment.unequip","furm",function(node,slot) 
    local n = node._furmasks
    if n then
        --MsgN("##UNEQUIP",slot)
        n.masks[slot] = nil
        debug.Delayed(100,function()
            furmanager.UpdateMaterials(n,node) 
        end)
    end
end)


console.AddCmd("fur_update",function()
    local node = LocalPlayer()
    if node then
        local n = node._furmasks
        if n then 
            furmanager.UpdateMaterials(n,node) 
        end
    end
end)