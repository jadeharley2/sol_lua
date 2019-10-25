
local forms = forms

function forms.GetData2(formid)
	local aparts = string.split(formid,'.')
	local part2 = string.join('.',aparts,1)
	return forms.GetData(aparts[1],part2)
end
function forms.ReadForm(form)
	local data = forms.GetData2(form)
	if data then
		return  json.FromJson(data)
	end
	--local path = forms.GetForm(form)
	--if path then
	--	local j = json.FromJson( forms.GetData2(form))--json.Read(path)
	--	return j, path
	--end
end
function forms.LoadForm(form)
	local data = forms.GetData2(form)
	if data then
		return data
	end
	--local path = forms.GetForm(form)
	--if path then
	--	local j = forms.GetData2(form)--json.Load(path)
	--	return j, path
	--end
end

function forms.Spawn(form,parent,arguments) 
	arguments = arguments or {} 
	local aparts = string.split(form,'.')
	local loctype = string.join('.',table.Skip(aparts,1)) 
--	MsgN(aparts[1],loctype)
	if aparts[1]=='prop' then 
		local fn = form --forms.GetForm('prop',loctype) 
		return SpawnPV(fn,parent,
			arguments.pos or Vector(0,0,0),
			arguments.ang or Vector(0,0,0),
			arguments.seed or 0)
	elseif aparts[1]=='character' then 
 
		local actorD = ents.Create("base_actor")
		actorD:SetSizepower(1000)
		actorD:SetParent(parent)
		actorD:AddTag(TAG_EDITORNODE)
		actorD:SetSeed(arguments.seed or 0)
		actorD:SetCharacter(loctype)
		actorD:Spawn()
		actorD:SetPos(arguments.pos or Vector(0,0,0))

		return actorD
	elseif aparts[1]=='apparel' then  -- warning: thumbnail use only
		
		local fn =form-- forms.GetForm('apparel',loctype)

		return SpawnPV(fn,parent,
			arguments.pos or Vector(0,0,0),
			arguments.ang or Vector(0,0,0),
			arguments.seed or 0)
	
	end
	--for k,v in pairs(arguments)
end
CreateFORM = forms.Spawn

function ItemRES(formid)
	--local fn = forms.GetForm(formid)--'resource',loctype)
	local j = forms.ReadForm(formid) 
	if not j then return nil end 
	local t = {
		sizepower=1, 
		seed= 0, 
		updatespace= 0,
		parameters =  { 
			name = j.name,
			icon = j.icon,
			tint = j.tint,
			form = formid,
		}, 
	} 
	return json.ToJson(t)
end 


hook.Add('newitem.prop',"prop",function(formid,seed)
	return ItemPV(formid,seed)
end)
hook.Add('newitem.apparel',"new",function(formid,seed)
	return ItemIA(formid,seed)
end)
hook.Add('newitem.resource',"new",function(formid,seed)
	return ItemRES(formid)
end)
hook.Add('newitem.tool',"new",function(formid,seed)
	return ItemTOOL(formid)
end)

function forms.GetItem(formid,seed)
	local aparts = string.split(formid,'.')
	local loctype = string.join('.',table.Skip(aparts,1)) 
	seed = seed or GetFreeUID()

	return hook.Call('newitem.'..aparts[1],formid,seed)

	--if aparts[1]=='prop' then 
	--	local fn = formid --forms.GetForm('prop',loctype)
	--	return ItemPV(fn,seed)
	--elseif aparts[1]=='character' then 
 --
	--elseif aparts[1]=='apparel' then    
	--	local fn = formid-- forms.GetForm('apparel',loctype)
	--	return ItemIA(fn,seed)
	--elseif aparts[1]=='resource' then    
	--	return ItemRES(formid)
	--elseif aparts[1]=='tool' then    
	--	return ItemTOOL(formid)
	--	
	--end
end
function forms.GetIcon(formid)
	local data = forms.LoadForm(formid)
	if data then 
		local icon =   
			forms._checkIcon(data:Read("/icon")) or
			forms._checkIcon(data:Read("/parameters/icon")) or
			forms._checkIcon(data:Read("/parameters/form")) or
			forms._checkIcon(data:Read("/parameters/character")) or
			forms._checkIcon(data:Read("/parameters/luaenttype"))
		if icon then return icon end
		local tfname = 'textures/thumb/'..formid..'.png' 
		if file.Exists(tfname) then
			return tfname
		end
	end
end
function forms.GetName(formid)
	local data = forms.LoadForm(formid)
	if data then 
		return  
			data:Read("/name") or
			data:Read("/parameters/name") or
			data:Read("/parameters/form") or
			data:Read("/parameters/character") or
			data:Read("/parameters/luaenttype")
	end
end
function forms.HasTag(formid,tag)
	local data = forms.LoadForm(formid)
	if data then 
		local tags = data:Read("tags")
		if tags then
			for k,v in pairs(tags) do
				if v==tag then return true end
			end
		end
	end
	return false
end
function forms.GetTint(formid)
	local data = forms.LoadForm(formid)
	if data then 
		return  
			data:Read("/tint") or {1,1,1}
	end
	return {1,1,1}
end
local basedir = "textures/gui/icons/"
function forms._checkIcon(name)
	if not name then return nil end
	if not isstring(name) then return nil end
	local tfn = basedir..name..".png"
	--MsgN("iconsearch: ",tfn)       
	if file.Exists(tfn) then 
		return tfn 
	else
		return nil
	end
end