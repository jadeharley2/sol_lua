ability.icon = "hex"
ability.type = "target" 
ability.cooldownDelay = 0.1  
ability.dispelDelay = 0.1
ability.name = "Starship remote"  

function ability:Begin(caster)   
	if TSHIP and TSHIP.starmap then
		TSHIP.starmap:OpenMap(caster,"system")
	end
	return true
end
function ability:End(caster)  
end
    