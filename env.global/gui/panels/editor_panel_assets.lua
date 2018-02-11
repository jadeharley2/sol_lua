
PANEL.assettypes = {
	prop = {directory = "forms/props/", spawn = function(type,node) 
		local j = json.Read("forms/props/"..type..".json")
		local p = SpawnSO(j.model,node,Vector(0,0,0),j.scale,false,false)
		if p then
			local random_ry = false
			if j.tags then
				for k,v in pairs(j.tags) do
					if v=="random_ry" then random_ry = true end
				end
			end
			local r = Vector(0,0,0)
			if j.rotation then r = r + Vector(j.rotation[1],j.rotation[2],j.rotation[3]) end
			if random_ry then r = r + Vector(0,math.random(-1800,1800)/10,0) end
			p:SetAng(r)
		end
		return p
	end},
	particle = {directory = "particles/"},
	font = {directory = "fonts/"},
	
	species = {directory = "forms/species/"},
	character = {directory = "forms/characters/", spawn = function(type,node) 
		local actorD = ents.Create("base_actor")
		actorD:SetSizepower(1000)
		actorD:SetParent(node)
		actorD:SetSeed(GetFreeUID())
		actorD:SetCharacter(type)
		actorD:Spawn()   
		return actorD
	end},
	apparel = {directory = "forms/apparel/", spawn = function(type,node)
		return SpawnIA(type,node,Vector(0,0,0),GetFreeUID())
	end},
	--tool = {},
	planet = {directory = "forms/planets/"},
	

}

function PANEL:Init() 
	self:SetColor(Vector(0,0,0))
	
	local dirtree = panel.Create("tree")
	dirtree:SetSize(400,400)
	dirtree:Dock(DOCK_LEFT)
	self:Add(dirtree)
	
	
	self.dirtree = dirtree
	
	local rtb = {"types"}
	
	
	for k,v in pairs(self.assettypes) do
		local spt = v
		local onclick = function(b)
			local type = b:GetText()
			MsgN(type)
			if(spt.spawn) then
				local e = spt.spawn(type,GetCamera():GetParent())
				editor.Select(e)
			end
		end 
		local tbl = file.GetFiles(v.directory,".json",true)  
		local tb = {} 
		local tb2 = {k} 
		for kk,vv in pairs(tbl) do 
			tb[#tb+1] = file.GetFileNameWE( vv)
		end 
		table.sort(tb)
		for kk,vv in pairs(tb) do 
			tb2[#tb2+1] = {vv,OnClick=onclick}
		end
		rtb[#rtb+1] = tb2
	end
	dirtree:SetTableType(2)
	
	dirtree:FromTable(rtb)
	
end 

