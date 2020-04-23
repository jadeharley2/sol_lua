ability.icon = "hex" 
ability.name = "Dispell"  
ability.singlecast = true

ability.effects = {}
 

function effect:Begin(source,target) 
    if target then 
        local ex = GetEffect(target,'dispell')
        if ex then
            ex:Dispell()
        end
        for k,v in pairs(self.effects) do
            local e = GetEffect(target,v)
            if e then
                e:Dispell()  
            end
        end
        return true
    end
    return false
end

