crafting = crafting or {}
crafting.recipes =  {}

function crafting.LoadRecipes()
    local lst = forms.GetList('recipe')
    for id,v in pairs(lst) do
        local data = forms.ReadForm('recipe.'..id) 
        --MsgN("c",id,v,data)      
        if data then
            local outform = data.output.item 
            if outform then
                local rectable = crafting.recipes[outform] or {}
                crafting.recipes[outform] = rectable
                rectable[id] = data
            end
        end
    end  
end   
crafting.LoadRecipes()
hook.Add("forms_updated","recipes",crafting.LoadRecipes)

function crafting.GetRecipesFor(formid)

 
end 
function crafting.GetIngredientsFor(formid)
    local rlist = crafting.recipes[formid] 
    if rlist then
        local ilist = {}
        for k,v in pairs(rlist) do
            local items = {}
            for kk,vv in pairs(v.input) do
                items[vv.item] = vv.count or 1
            end
            ilist[#ilist+1] = items
        end
        return ilist
    end
end
function crafting.GetIngredientCount(recipe,ingrid) 
    for k,v in pairs(recipe.input) do
        if v.item == ingrid then
            return v.count or 1
        end
    end
    return 0
end
function crafting.GetCraftableItems(filter) 
    local t = {}
    for k,v in pairs(crafting.recipes) do
        t[#t+1] = k
    end
    return t
end
function crafting.CheckHasResourcesForRecipe(recipe,storage)
    local eitems = storage:FormIdCounts()
    local eicounts = table.Select(eitems,math.sum)
    
    -- check requirements
    local takelist = {}

    for k,v in pairs(recipe.input) do 
        local sat_count = v.count or 1
        --if (eicounts[v.item] or 0)>=(v.count or 1) then
           -- takelist[eitems[itempath][1]] = (v.count or 1)
        --else
            local itempath = v.item -- forms.GetForm(v.item)
            if itempath then
                if (eicounts[itempath] or 0)>=(v.count or 1) then 
                    local itable = eitems[itempath]
                    for kk,vv in pairs(itable) do
                        local takecount = math.min(sat_count,vv)
                        takelist[kk] = takecount
                        sat_count = sat_count - takecount
                        if sat_count==0 then break end
                    end
                else 
                    return false, v.item
                end
            else 
                return false, v.item
            end
        --end
    end
    return takelist
end
function crafting.CheckHasResources(formid,storage)
    local recipegroup = crafting.recipes[formid] 
    if recipegroup then
        for k,v in pairs(recipegroup) do
            if crafting.CheckHasResourcesForRecipe(v,storage) then
                return recipe
            end
        end 
    end
    return false
end
function crafting.CanCraft(formid,storage)
    if storage:HasFreeSlot(1) then
        if crafting.CheckHasResources(formid,storage) then
            return true
        end
    end
    return false
end
function crafting.GetRecipe(formid,recipeid)
    local recipegroup = crafting.recipes[formid]
    if recipegroup then 
        if recipeid==nil then
            return recipegroup[next(recipegroup)]
        else
            return recipegroup[recipeid]
        end
    end
    return nil
end
function crafting.Craft(formid,recipeid,storage) 
    MsgN(formid,recipeid,storage)
    local recipe = crafting.GetRecipe(formid,recipeid)
    if recipe then 
        if not storage:HasFreeSlot(#recipe.output) then
            return false, 'no free slots'
        end
        local takelist, err_item = crafting.CheckHasResourcesForRecipe(recipe,storage)
        if not takelist then
            local eitems = storage:FormIdCounts()
            local eicounts = table.Select(eitems,math.sum)

            local need = crafting.GetIngredientCount(recipe,err_item)
            local have = eicounts[err_item] or 0
            local erritem_name = (forms.GetName(err_item) or err_item)
            PrintTable(eicounts)
            MsgInfo("insufficient resources: "..tostring(erritem_name)..' '..have..'/'..need)
            return false, 'insufficient resources', err_item
        end
        MsgN("takelist")
        PrintTable(takelist)
        for k,v in pairs(takelist) do 
            storage:TakeItemAsData(k,v)
            MsgN("taken",k)
        end 
        -- all ok
        --for k,v in pairs(recipe.output) do
            MsgN("cr",recipe.output.item,recipe.output.count)
            local critem = forms.GetItem(recipe.output.item,0)
            local freeslot =nil-- storage:GetFreeSlot()
            storage:PutItemAsData(freeslot,critem,recipe.output.count or 1)
            MsgInfo("craft complete: "..(forms.GetName(recipe.output.item) or recipe.output.item) )
        --end
        return true
    end
end

function crafting.GetCombineOptions(item_data_a,item_data_b)
    if item_data_a and item_data_b then
        local formid_a = item_data_a:Read("/parameters/form")
        local formid_b = item_data_b:Read("/parameters/form")
        
        if(forms.HasTag(formid_a,'dyeable') and forms.HasTag(formid_b,'dye')) then
            return {dye="dye"}
        end

        --hook.Call("itemcombine")
    end
    return {}
end
function crafting.Combine(item_data_a,item_data_b,type,storage)
    if item_data_a and item_data_b then
        MsgN("combine:",type)
        if type =='dye' then
            local formid_a = item_data_a:Read("/parameters/form")
            local formid_b = item_data_b:Read("/parameters/form")
            local data_a = forms.ReadForm(formid_a)
            local data_b = forms.ReadForm(formid_b)
            MsgN("combine:",formid_a,formid_b,data_a,data_b)

            local slotA = storage:GetItemSlot(formid_a)
            local slotB = storage:GetItemSlot(formid_b)
            if slotA and slotB then 
                local d = data_a.dye
                if d then 
                    data_a.dye = nil
                    
                    if d.type == 'modmaterial' then
                        data_a.modmaterial = data_a.modmaterial or {{hold=true},{hold=true},{hold=true},{hold=true}}
                        if d.vartype =='vec3' then
                            data_a.modmaterial[d.matid][d.variable] = data_b.tint
                        elseif d.vartype =='vec4' then
                            data_a.modmaterial[d.matid][d.variable] = {data_b.tint[1],data_b.tint[2],data_b.tint[3],1}
                        end
                    end
                    PrintTable(data_a.modmaterial)
                    data_a.name = (data_a.name or formid_a)  .. " | " .. (data_b.suffix or data_b.name)

                    --storage:PutItemAsData(nil,json.ToJson(data_a), 1)

                    local idparts = string.split(formid_a,'.')

                    local newid = idparts[2].."_"..(data_b.suffix or string.split(formid_b,'.')[2])
                    if forms.Create(idparts[1],newid) then
                        forms.SetData(idparts[1],newid,json.ToJson(data_a))

                        local critem = forms.GetItem(idparts[1]..'.'..newid,0)
                       -- MsgN("ni",newid,critem)
                        if critem then
                            storage:PutItemAsData(nil,critem,1)
                            storage:TakeItemAsData(slotA,1)
                            storage:TakeItemAsData(slotB,1)
                            return true
                        end
                    end

                end
                --PrintTable(data_a,56)
            end
        end
    end
end
