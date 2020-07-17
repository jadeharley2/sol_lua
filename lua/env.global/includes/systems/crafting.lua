crafting = crafting or {}
crafting.recipes =  {} 

if not crafting.ent_craft  then
	local e = ents.Create() 
	e:SetSeed(3838104)
    e:SetName("ent_craft")
    e:Spawn()
	e._events = e._events or {} 
	crafting.ent_craft = e 
end 

local ent_craft = crafting.ent_craft
local events = crafting.ent_craft._events

function crafting.LoadRecipes()
    local lst = forms.GetList('recipe')
    for id,v in pairs(lst) do
        local data = forms.ReadForm('recipe.'..id) 
        --MsgN("c",id,v,data)      
        if data then
            local path = forms.GetForm('recipe.'..id) 
            local outform = data.output.item 
            if outform then
                local rectable = crafting.recipes[outform] or {}
                crafting.recipes[outform] = rectable
                data.category = string.join('.',table.SubTrim(string.split(path,'/'),2,1))
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

--[[## COMBINE ##]]
function crafting.GetCombineOptions(item_data_a,item_data_b)
    if item_data_a and item_data_b then
        local formid_a = item_data_a:Read("/parameters/form")
        local formid_b = item_data_b:Read("/parameters/form")
        
        return hook.Collect('craft.can_combine',formid_a,formid_b)

        --if(forms.HasTag(formid_a,'dyeable') and forms.HasTag(formid_b,'dye')) then
        --    return {dye="dye"}
        --end

        --hook.Call("itemcombine")
    end
    return {}
end

crafting.combination_types = crafting.combination_types or {}
function crafting.AddCombination(type,func)
    crafting.combination_types[type] = func
end


function crafting.Combine(item_data_a,item_data_b,type,storage)
    if item_data_a and item_data_b then
        local combofunc = crafting.combination_types[type]
        MsgN("combine:",type,combofunc)
        if combofunc then
            local formid_a = item_data_a:Read("/parameters/form")
            local formid_b = item_data_b:Read("/parameters/form")
            local data_a = forms.ReadForm(formid_a)
            local data_b = forms.ReadForm(formid_b)
            MsgN("combine:",formid_a,formid_b,data_a,data_b)

            local slotA = storage:GetItemSlot(formid_a)
            local slotB = storage:GetItemSlot(formid_b)
            if slotA and slotB then 
               
                local newid, newdata, newcount = combofunc(formid_a,data_a,formid_b,data_b)
                if newid then 
                    local idparts = string.split(formid_a,'.')
                    local critem = false
                    if newdata then
                        MsgN("new form id:",idparts[1],newid)
                        if forms.CreateForm(idparts[1],newid) then
                            forms.SetData(idparts[1],newid,json.ToJson(newdata))
                        end
                        critem = forms.GetItem(idparts[1]..'.'..newid,0)
                    else
                        critem = forms.GetItem(newid,0)
                    end 
                        
                    -- MsgN("ni",newid,critem)
                    if critem then
                        --storage:PutItemAsData(nil,critem,newcount or 1)
                        storage:GetNode():SendEvent(EVENT_ITEM_ADDED,10,critem,newcount or 1)
                        storage:TakeItemAsData(slotA,1)
                        storage:TakeItemAsData(slotB,1)
                        return true
                    end

                end 
            end
        end
    end
end
--[[## DECONSTRUCT ##]]
function crafting.GetDeconstructResult(item_data)
    if item_data then
        local formid = item_data :Read("/parameters/form")
        
        local form_data = forms.ReadForm(formid) 
        if form_data then 
            PrintTable(form_data)
            return form_data.composition 
        end 
    end
    return false
end
function crafting.Deconstruct(item_data,storage)
    if item_data then
        local formid = item_data:Read("/parameters/form")
        
        local form_data = forms.ReadForm(formid) 
        local slotA = storage:GetItemSlot(formid)
        if form_data and form_data.composition and slotA then  
            for k,v in pairs(form_data.composition) do
                local critem = forms.GetItem(k,0)
                storage:PutItemAsData(nil,critem,v)
            end
            storage:TakeItemAsData(slotA,1)
            MsgInfo("deconstruction complete: "..(forms.GetName(formid) or formid) )
            return true
        end 
    end
    return false
end