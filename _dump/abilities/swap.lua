

function AB:Cast(caster, target)
	
	if caster and caster.player and target and target.player then
		swap(caster.player:GetTag(1000),target.player:GetTag(1000))
	end
end