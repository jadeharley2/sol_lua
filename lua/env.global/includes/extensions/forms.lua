
local forms = forms

function forms.ReadForm(form)
	local path = forms.GetForm(form)
	if path then
		local j = json.Read(path)
		return j
	end
end
function forms.LoadForm(form)
	local path = forms.GetForm(form)
	if path then
		local j = json.Load(path)
		return j
	end
end

function forms.Spawn(form,parent,arguments) 
	local aparts = string.split(form,'.')
	local loctype = string.join('.',table.Skip(aparts,1)) 
	MsgN(aparts[1],loctype)
	if aparts[1]=='prop' then 
		local fn = forms.GetForm('prop',loctype)
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
		
		local fn = forms.GetForm('apparel',loctype)

		return SpawnPV(fn,parent,
			arguments.pos or Vector(0,0,0),
			arguments.ang or Vector(0,0,0),
			arguments.seed or 0)
	
	end
	--for k,v in pairs(arguments)
end

function ItemRES(type)
	local j = json.Read(type) 
	if not j then return nil end 
	local t = {
		sizepower=1, 
		seed= 0, 
		updatespace= 0,
		parameters =  { 
			name = j.name,
			icon = j.icon,
			form = type,
		}, 
	} 
	return json.ToJson(t)
end

function forms.GetItem(formid,seed)
	local aparts = string.split(formid,'.')
	local loctype = string.join('.',table.Skip(aparts,1)) 
	if aparts[1]=='prop' then 
		seed = seed or GetFreeUid()
		local fn = forms.GetForm('prop',loctype)
		return ItemPV(fn,seed)
	elseif aparts[1]=='character' then 
 
	elseif aparts[1]=='apparel' then   
		seed = seed or GetFreeUid()
		local fn = forms.GetForm('apparel',loctype)
		return ItemIA(fn,seed)
	elseif aparts[1]=='resource' then    
		local fn = forms.GetForm('resource',loctype)
		return ItemRES(fn)
	end
end