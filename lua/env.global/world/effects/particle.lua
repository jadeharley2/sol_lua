effect.name = "EmitParticles"  
effect.singlecast = true

effect.path = false

function effect:Begin(source,target,pos) 
    if self.type then
        return SpawnParticles(target:GetParent(),self.type,pos,self.time or 1,self.size or 1,self.speed or 1)~=nil
    end
    return false
end 