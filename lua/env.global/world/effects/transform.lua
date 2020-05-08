ability.icon = "hex" 
ability.name = "Swap"  


effect.character = "kindred"
 

function effect:Begin(source,target) 
    if target and target.GetCharacter then
        self.prev_char = target:GetCharacter()
        target:UnequipAll()
        target:SetCharacter(self.character)
        MsgN(target,self.character)
        return true
    end
    return false
end

function effect:End(source,target)
    target:UnequipAll()
    target:SetCharacter(self.prev_char)
end