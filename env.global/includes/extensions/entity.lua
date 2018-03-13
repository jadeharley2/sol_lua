--auto reload

 

-- do for all items in table or for one
function tableq(t)
	if istable(t) then return pairs(t) 
	else
		return function(t,c)  
			if c==0 then
				return 1, t
			else
				return nil
			end
		end, t, 0
	end
end
 
hook.Add("script.reload","entity", function(filename)
	if string.starts(filename,"env.global/world/entities/") then 
		ents.LoadType(filename)
		return true
	end
end)

Entity = ents.GetById
