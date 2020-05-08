ability.icon = "hex" 
ability.name = "Nightvision"  

 
 

function effect:Begin(source,target) 
    if target then
        local pp = target:RequireComponent(CTYPE_POSTPARAMS)
        if pp then
            self.cmaterial = pp:get_ppmaterial()
            pp:set_ppmaterial(LoadMaterial('post/nightvision.json'))
            return true
        end
    end
    return false
end

function effect:End(source,target) 
    local pp = target:GetComponent(CTYPE_POSTPARAMS)
    if pp then
        pp:set_ppmaterial(self.cmaterial)
    end
end