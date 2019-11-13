
hook.Add('craft.can_combine','dye',function(formid_a,formid_b)
    if(forms.HasTag(formid_a,'dyeable') and forms.HasTag(formid_b,'dye')) then
        return 'dye' 
    end
end)
hook.Add('craft.can_combine','clean',function(formid_a,formid_b)
    if(forms.HasTag(formid_a,'dyed') and formid_b=='resource.water') then
        return 'clean' 
    end
end)
hook.Add('craft.can_combine','blend',function(formid_a,formid_b)
    if(forms.HasTag(formid_a,'dye') and forms.HasTag(formid_b,'dye')) then
        return 'blend' 
    end
end)

crafting.AddCombination('dye',function(formid_a,data_a,formid_b,data_b) 
    local d = data_a.dye
    if d then 
        data_a.source_id = formid_a
        data_a.dye = nil 
        if d.type == 'modmaterial' then
            data_a.modmaterial = data_a.modmaterial or {{hold=true},{hold=true},{hold=true},{hold=true}}
            if d.vartype =='vec3' then
                local mat = data_a.modmaterial[d.matid]
                mat[d.variable] = data_b.tint
                if data_b.metalness then
                    mat.base_specular_tint = data_b.metalness
                end
                if data_b.smooth then
                    mat.base_specular_intencity = data_b.smooth
                end 
                if data_b.glow then
                    mat.emissionTint = {data_b.tint[1]*data_b.glow,data_b.tint[2]*data_b.glow,data_b.tint[3]*data_b.glow} 
                    mat.g_MeshTexture_e = 'textures/debug/white.png'
                    mat.rimfadeEmission = {0.1,1}
                end
            elseif d.vartype =='vec4' then
                data_a.modmaterial[d.matid][d.variable] = {data_b.tint[1],data_b.tint[2],data_b.tint[3],1}
            end
        end
        -- PrintTable(data_a.modmaterial)
        -- data_a.name = (data_a.name or formid_a)  .. " | " .. (data_b.suffix or data_b.name)
        data_a.tags[#data_a.tags+1] = 'dyed'
        data_a.features = data_a.features or {}
        if data_b.features then
            for k,v in pairs(data_b.features) do
                data_a.features[k] = v
            end 
        end
        --data_a.features.color = {(data_b.suffix or data_b.name),data_b.tint} 

        local idparts = string.split(formid_a,'.')

        local newid = string.join('.',idparts,1).."_"..(data_b.suffix or string.join('.',string.split(formid_b,'.'),1)) 
        return newid, data_a
    end
    --PrintTable(data_a,56)
end)


crafting.AddCombination('clean',function(formid_a,data_a,formid_b,data_b)   
    if data_a.source_id then  
        return data_a.source_id
    end 
end)


crafting.AddCombination('blend',function(formid_a,data_a,formid_b,data_b) 
    local t1 = data_a.tint
    local t2 = data_b.tint 
    if t1 and t2 then 
        local mix = {(t1[1]+t2[1])/2, (t1[2]+t2[2])/2, (t1[3]+t2[3])/2}
        local hex = '#'..rgbToHex(mix,255)
        local id = hex
        data_a.tint = mix
        local f = {}
        if data_a.glow or data_b.glow then  
            local g = ((data_a.glow or 0) + (data_b.glow or 0))/2 
            data_a.glow = g
            f.glow = {tostring(data_a.glow),{g,g,g}} 
            id = id ..'l'..rgbToHex({data_a.glow},255)
        end
        if data_a.metalness or data_b.metalness then  
            local m = ((data_a.metalness or 0) + (data_b.metalness or 0))/2 
            data_a.metalness = m
            f.metalness = {tostring(data_a.metalness),{m,m,m}} 
            id = id ..'m'..rgbToHex({data_a.metalness},255)
        end
        if data_a.smooth or data_b.smooth then  
            local s = ((data_a.smooth or 0) + (data_b.smooth or 0))/2 
            data_a.smooth = s
            id = id ..'s'..rgbToHex({data_a.smooth},255)
        end
        data_a.features = f
        f.color = {hex, mix} 
        
        if data_a.metalness and data_a.metalness>0.5 then
            data_a.suffix = 'metallic_'..hex
            data_a.name = 'Metallic dye'
            data_a.icon = "res/liquid_metallic"
        elseif data_a.glow and data_a.glow>0.2 then
            data_a.suffix = 'luminous_'..hex
            data_a.name = 'Luminous dye'
            data_a.icon = "res/liquid_luminous" 
        else
            data_a.suffix = hex
            data_a.name = 'Generic dye'
            data_a.icon = "res/liquid" 
        end
        local newid = 'resource.dye_'..id 
        return newid, data_a, 2
    end
    --PrintTable(data_a,56)
end)