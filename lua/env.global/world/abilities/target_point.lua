
function ability:Begin(caster)   
    if SERVER or not network.IsConnected() then
        local eyetarget = caster:GetEyeTarget()
        

        local target = caster
        
        if eyetarget then 
            if self:ApplyEffects(caster,target,eyetarget) then
                self:ApplyVisuals(caster,target,eyetarget)
                return true 
            end
        end 
    end

	return false
end 