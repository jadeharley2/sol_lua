ability.name = "Projectile"  


effect.size = 0.2
effect.speed = 100
effect.color = Vector(1,1,1)
effect.glow = true
 
function effect:Begin(source,target,pos) 
    if pos then 
        self.source = source

        local sp = source:GetParent()
        local spos = source:GetPos()+Vector(0,1.8,0)/sp:GetSizepower()
        local tpos = pos
        local dir = (tpos-spos):Normalized()

        local projectile = SpawnProjectile(target:GetParent(),
            spos+dir/sp:GetSizepower(),dir*self.speed,self.size,
            self.color,self.glow,self.model,self.phys)
            projectile.source = self
        projectile.OnHit = self.Hit
        debug.Delayed(6000,function()   
            if IsValidEnt(projectile) then 
                projectile:Despawn() end 
            end)
				
        return em~=nil
    end
    return false
end


function effect.Hit(projectile, target)
    local self = projectile.source
    local pos = projectile:GetPos()--target:GetLocalCoordinates(self)
    local source = self.source
    MsgN("EX",source,target,pos)
    for k,v in pairs(self.hiteffect) do
        local eff = Effect(v.effect or k,v)
        if eff then 
            MsgN("E",eff)
            if v.targeton=='caster'then
                eff:Start(source,source,pos)
            else
                eff:Start(source,target,pos)
            end 
        end 
    end
    if self.freeze then
        constraint.Weld(projectile,target,pos)
    end
    return self.freeze
end
function effect:End(source,target)

end