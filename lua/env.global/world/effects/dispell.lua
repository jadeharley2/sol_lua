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
        if self.effects=='all' then
            for k,v in pairs(GetEffects(target)) do  
                MsgN("DISPELL TRY",k,v)
                v:Dispell()
            end 
        else
            for k,v in pairs(self.effects) do
                local e = GetEffect(target,v)
                MsgN("DISPELL TRY",target,v,e)
                if e and e~=self then
                    e:Dispell()  
                end
            end 
        end
        return true
    end
    return false
end

