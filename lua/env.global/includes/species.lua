--TEMP FUNCTIONS

function SPECIES_GetParts(char,name)
    if IsValidEnt(char) then
        local species = char.species
        if species then
            if species.bodyparts and species.bodyparts.groups then
                local sp = species.bodyparts.groups[name]
                if sp then
                    local lst = List()
                    for k,v in pairs(sp) do
                        lst:AddRange(char:GetByName(v,true,true))
                    end
                    return lst:ToTable()
                end 
            end
        end
        return char:GetByName(name,true,true)

    end
end