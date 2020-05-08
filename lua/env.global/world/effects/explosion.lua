ability.icon = "hex" 
ability.name = "Explosion"  


effect.magnitude = 1
 

function effect:Begin(source,target,pos) 
    if pos then 
        local em =  SpawnExplosion(target,pos,self.magnitude)
        return em~=nil
    end
    return false
end

function effect:End(source,target)

end