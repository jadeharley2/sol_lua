nodeloader = nodeloader or {}
nodeloader.ctypes = false
nodeloader.vtypes = false

nodeloader.unique = nodeloader.unique  or {} 

function nodeloader.Create(form,parent,uid,parentworld)  


    if not nodeloader.ctypes then
        --nodeloader.ctypes = {}
        --for k,v in pairs(debug.GetAPIInfo("CTYPE_")) do
        --    if string.starts(k,"CTYPE_") then
        --        local nk = string.lower(string.sub(k,7))
        --        nodeloader.ctypes[nk] = v
        --    end
        --end
        --nodeloader.vtypes = {}
        --for k,v in pairs(debug.GetAPIInfo("VARTYPE_")) do
        --    if string.starts(k,"VARTYPE_") then
        --        local nk = string.lower(string.sub(k,7))
        --        nodeloader.pairs[nk] = v
        --    end
        --end
    end

    if uid then
        local existing = nodeloader.unique[uid]
        if IsValidEnt(existing) then return existing else nodeloader.unique[uid] = nil end
    end

    local j = form
    if isstring(form) then
        j = forms.ReadForm(form)
    end

    if not j then error("FORM READ ERROR") end

    local ent = false
    if j.extends then
        local exprefab, subname = unpack(cstring.split(j.extends,':'))
        local exparent = nodeloader.Create(exprefab,parent,uid)
        if IsValidEnt(exparent) then
            local exsub = exparent:GetByName(subname)
            if IsValidEnt(exsub) then 
                if j.name then
                    exsub:SetName(j.name)
                end
                if j.seed then
                    exsub:SetSeed(j.seed)
                end

                if j.dynamic then
                    local wdata = json.Load(j.dynamic)
                    if wdata then
                        local b = procedural.Builder() 
                        b:BuildNode(wdata,exsub)
                    end
                    exsub:SetLoadMode(1) 
                    exsub:Enter()
                end

                if j.subs then
                    for k,v in ipairs(j.subs) do
                        local sub = nodeloader.Create(v,exsub)
                        if IsValidEnt(sub) then 
                            MsgN("val",sub)
                        end 
                    end
                end  
                ent = exparent 
            end 
        end
        if IsValidEnt(ent) then
        end
    elseif j.helper then
        ent = hook.Call("nl_helper."..j.helper,j,form,parent,uid,parentworld) 
    else
        local pos = Vector(0,0,0)
        local ang = Vector(0,0,0)
        local seed = 0
        if j.pos then
            pos = JVector(j.pos)
        elseif j.realpos and parent then
            pos = JVector(j.realpos) / parent:GetSizepower()
        end
        if j.ang then
            ang = JVector(j.ang)
        end
        if j.seed then
            seed = j.seed
        end

        if j.luatype then
            ent = ents.Create(j.luatype)
        elseif j.form then
            if seed == 0 then
                ent = forms.Spawn(j.form,parent,{pos = pos,ang = ang, seed = seed, data = j.modtable})
            else
                ent = forms.Create(j.form,parent,{pos = pos,ang = ang, seed = seed, data = j.modtable})
            end
        else  
            ent = ents.Create() 
        end  
        MsgN("ecrt",ent)

        if IsValidEnt(ent) then
            if j.components then
                for k,v in ipairs(j.components) do 
                    MsgN("com on",ent,v.type)
                    local com = ent:AddComponent(v.type)
                    if com then
                        CALL(com.SetupData,com,v)
                    end
                end 
            end
            if j.variables then
                for k,v in pairs(j.variables) do  
                    MsgN("setvar on",ent,k,v)
                    ent:SetParameter(k,v)  
                end 
            end
            if j.name then
                ent:SetName(j.name)
            end
            if not j.form then
                ent:SetSeed(seed) 
                if parent then ent:SetParent(parent) end
                ent:SetPos(pos)  
                ent:SetAng(ang)  
    
                CALL(ent.SetupData,ent,j)
            end 
            if j.sizepower then
                ent:SetSizepower(j.sizepower)
            end
    
            if not j.form then
                if seed==0 then
                    ent:Spawn()
                else
                    ent:Create()
                end
            end
            if j.subs then
                for k,v in ipairs(j.subs) do
                    local sub = nodeloader.Create(v,ent) 
                end
            end
            CALL(ent.PostSubInit,ent,j)
        end
    end

    if uid then
        ent.nl_uid = uid
        nodeloader.unique[uid] = ent

        if parentworld then
            parentworld = parentworld._parentworld or parentworld

            if IsValidEnt(parentworld) then
                local sublist = parentworld._subworlds or {}
                parentworld._subworlds = sublist
                sublist[#sublist+1] = ent
                ent._parentworld = parentworld
            end
        end
    end

    return ent
end
function nodeloader.Remove(uid)
    nodeloader.unique[uid] = nil
end
function nodeloader.DespawnSubWorlds(node)
    local sublist = node._subworlds or {}
    for k,v in pairs(sublist) do
        v:Despawn()
    end
    node._subworlds = nil
end
function nodeloader.Clear() 
    for k,v in pairs(nodeloader.unique) do
        if IsValidEnt(v) then
            v:Despawn()
        end
    end   
    nodeloader.unique = {}
end
--[[
    variants
    !name
    !g.name
]]
function nodeloader.GetByName(node,name)
    local parent = node:GetParent()
    if IsValidEnt(parent) then
        return parent:GetByName(name,false,true)
    end
end


hook.Add('formcreate.prefab','spawn',function(form,parent,arguments)
    return nodeloader.Create(form,parent,arguments.uid,arguments.parentworld)  
end) 

hook.Add("world.unload","nodeloader",function(node)
    nodeloader.DespawnSubWorlds(node)
end)


console.AddCmd("list_existing_worlds",function()
    local all = ents.GetWorlds()
    PrintTable(all)
end)


hook.Add("nl_helper.placement","nl",
function(j,form,ent) 
    --MsgN("nl_helper.placement")
    if j.subs then
        local segment = 360/j.sides
        local center = JVector(j.center,Vector(0,0,0))
        local axis = JVector(j.axis,Vector(0,1,0))
        local direction = JVector(j.direction,Vector(1,0,0))
        local ang_offset = JVector(j.ang_offset,Vector(0,0,0))  
        for k,v in ipairs(j.subs) do
            local sub = nodeloader.Create(v,ent) 
            if IsValidEnt(sub) then
                local angle = k*segment+ (j.offset or 0)
                local rmatrix = matrix.AxisRotation(axis,-angle)
                local pos = direction:TransformC(rmatrix)+center
                sub:SetPos(pos)
                sub:SetAng(matrix.Rotation(ang_offset) * rmatrix)
                --MsgN("placement",sub,angle,pos)
            end
        end
    end
end) 


_NL_CRT = nodeloader.Create