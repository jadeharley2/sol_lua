local templates = {}


function CreateEntity(name,...)
	if name then  -- if not then use ents.Create
		local ent = ents.Create() 
		local template = templates[name]
			if template then
			template.Init(ent,...)
			return ent
		end
	end
	return nil 
end


function CreateTemplate(name)
	local template = {name = name}
	templates[name] = template
	return template
end

