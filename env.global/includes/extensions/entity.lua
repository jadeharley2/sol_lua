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



Entity = ents.GetById
