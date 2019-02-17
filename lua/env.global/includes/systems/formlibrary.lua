forms = forms or {
	--_types={},
}
  
--forms.GetList = function(type)
--	return forms._types[type]
--end

--forms.AddForm = function(type,key,path)
--	local list = forms._types[type] or {}
--	list[key] = path
--	forms._types[type] = list
--end

forms.HasForm = function(type,key)
	--local list = forms._types[type]
	--if list then
	--	return list[key] ~= nil
	--end
	--return false
	return forms.GetForm(type,key)~=nil
end
forms.GetPath = forms.GetForm --[[ function(type,key)
	local list = forms._types[type]
	if list then
		return list[key]
	end 
	return nil
end

forms.UpdateList = function(type,path,ext,recursive)
	local list = forms._types[type] or {}
	for k,v in pairs(file.GetFiles(path,ext,recursive)) do
		list[string.lower(file.GetFileNameWE(v))] = v   
	end
	forms._types[type] = list
end

forms.UpdateLists = function()
	forms.UpdateList("apparel","forms/apparel/","json",true)
	forms.UpdateList("tool","forms/items/tools/","json",true)
	forms.UpdateList("character","forms/characters/","json",true)
	forms.UpdateList("ability","forms/abilities/","json",true)
end

forms.UpdateLists() 
]]


  