ability.icon = "hex" 
ability.name = "Starship remote"  

function ability:Begin(source,target)   
	if TSHIP and TSHIP.starmap then
		TSHIP.starmap:OpenMap(target,"system")
	end
	return true
end
function ability:End(source,target)  
end
    