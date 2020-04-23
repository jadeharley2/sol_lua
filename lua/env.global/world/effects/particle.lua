effect.name = "EmitParticles"  
effect.singlecast = true
effect.emit = false
effect.children = false

effect.path = false

function effect:Begin(source,target,pos) 
    if self.type then
        local lst = {target}
        if self.children then
            for k,v in pairs(target:GetChildren()) do
                MsgN("EXFON",v)
                lst[#lst+1] = v
            end
        end
        for k,v in pairs(lst) do
            MsgN("EFON",v)
            if self.emit then
                EmitParticles(v,self.type,pos,self.time or 1,self.size or 1,self.speed or 1)--~=nil
            else
                SpawnParticles(v:GetParent(),self.type,pos,self.time or 1,self.size or 1,self.speed or 1)--~=nil
            end
        end
        return true
    end
    return false
end 