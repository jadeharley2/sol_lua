effect.name = "EmitSound"  
effect.singlecast = true

effect.path = false

function effect:Begin(source,target,pos) 
    if self.path then
        target:EmitSound(self.path, self.volume or 1, self.pitch or 1)
        return true
    end
    return false
end 