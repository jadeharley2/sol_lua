crafting = crafting or {}
crafting.recipes =  {}

function crafting.LoadRecipes()
    local lst = forms.GetList('recipe')
    for id,v in pairs(lst) do 
        local data = forms.ReadForm('recipe.'..id) 
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
        if (eicounts[v.item] or 0)>=(v.count or 1) then
           -- takelist[eitems[itempath][1]] = (v.count or 1)
        else
            local itempath = forms.GetForm(v.item)
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
                    return false
                end
            else 
                return false
            end
        end
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
        local takelist = crafting.CheckHasResourcesForRecipe(recipe,storage)
        if not takelist then
            return false, 'insufficient resources'
        end
        for k,v in pairs(takelist) do 
            storage:TakeItem(k)
        end 
        -- all ok
        --for k,v in pairs(recipe.output) do
            MsgN("cr",recipe.output.item,recipe.output.count)
            local critem = forms.GetItem(recipe.output.item,0)
            local freeslot = storage:GetFreeSlot()
            storage:PutItemAsData(freeslot,critem)
        --end
        return true
    end
end

crafting.LoadRecipes()