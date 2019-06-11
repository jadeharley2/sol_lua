
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