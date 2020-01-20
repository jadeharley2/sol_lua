ability.icon = "hex" 
ability.name = "SpawnForm"  


effect.form = false
 

function effect:Begin(source,target,pos) 
    if pos and self.form then
        local ang = Vector(0,0,0) 
        if self.random then
            local rrot = self.random.rotation
            if rrot then
                local rx = 0
                local ry = 0 
                local rz = 0
                if string.match(rrot,'x') then
                    rx = math.random(-180,180)
                end
                if string.match(rrot,'y') then
                    ry = math.random(-180,180)
                end
                if string.match(rrot,'z') then
                    rz = math.random(-180,180)
                end
                ang = Vector(rx,ry,rz)
            end 
        end
        local em = forms.Spawn(self.form,target:GetParent(),{
            pos = pos,
            ang = ang
        }) 
        return em~=nil
    end
    return false
end

function effect:End(source,target)

end