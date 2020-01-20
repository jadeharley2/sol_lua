effect.name = "DelayedEffect"  
effect.singlecast = true

effect.delay = 1
effect.data = false
effect.delay_name = "effect"

function effect:Begin(source,target,pos) 
    if self.data then
        target:Delayed(self.delay_name,self.delay*1000,function ()
            for k,v in pairs(self.data) do
                local eff = Effect(v.effect or k,v)
                if eff then
                    if v.targeton=='caster'then
                        eff:Start(source,source,pos)
                    else
                        eff:Start(source,target,pos)
                    end 
                end 
            end
        end)
        return true
    end
    return false
end 