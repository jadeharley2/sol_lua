
PANEL.assettypes = {
	prop = {directory = "forms/props/", recursive=true, spawn = function(type,node,fulltype) 
		--local j = json.Read(fulltype)--"forms/props/"..type..".json")
		if not worldeditor then return nil end
		local wtr = worldeditor.wtrace
		local pos = Vector(0,0,0)
		if not wtr or not wtr.Hit then --return nil
		else
			pos = wtr.Position
		end
		 
		local p = SpawnPV(fulltype,node,wtr.Position)--,j.scale,false,false)
		if p then
			p:AddFlag(FLAG_EDITORNODE)
			p:SetSeed(GetFreeUID())
		end
		--if p then
		--	local random_ry = false
		--	if j.tags then
		--		for k,v in pairs(j.tags) do
		--			if v=="random_ry" then random_ry = true end
		--		end
		--	end
		--	local r = Vector(0,0,0)
		--	if j.rotation then r = r + Vector(j.rotation[1],j.rotation[2],j.rotation[3]) end
		--	if random_ry then r = r + Vector(0,math.random(-1800,1800)/10,0) end
		--	p:SetAng(r)
		--end
		return p
	end}, 
	particle = {directory = "particles/",spawn = function(type,node,fulltype) 
		if not worldeditor then return nil end
		local wtr = worldeditor.wtrace
		if not wtr or not wtr.Hit then return nil end
		
		local p = SpawnParticles(node,type,wtr.Position,0,1,1)
		if p then
			p:AddFlag(FLAG_EDITORNODE)
			p:SetSeed(GetFreeUID())
		end
		return p
	end},
	font = {directory = "fonts/"},
	
	species = {directory = "forms/species/"},
	character = {directory = "forms/characters/", spawn = function(type,node)  
	
		if not worldeditor then return nil end
		local wtr = worldeditor.wtrace
		if not wtr or not wtr.Hit then return nil end
		  
		
		local actorD = ents.Create("base_actor")
		actorD:SetSizepower(1000)
		actorD:SetParent(node)
		actorD:AddFlag(FLAG_EDITORNODE)
		actorD:SetSeed(GetFreeUID())
		actorD:SetCharacter(type)
		actorD:Spawn()
		actorD:SetPos(wtr.Position+Vector(0,1/node:GetSizepower(),0))
		return actorD 
	end},
	apparel = {directory = "forms/apparel/", spawn = function(type,node)
		local ap = SpawnIA(type,node,Vector(0,0,0),GetFreeUID())
		ap:AddFlag(FLAG_EDITORNODE)
		return ap
	end},
	surfacemod = {directory = "forms/surfacemods/", spawn = function(type,node)
		if not worldeditor then return nil end
		local wtr = worldeditor.wtrace
		if not wtr or not wtr.Hit then return nil end
		
		local ap = ents.Create("planet_surface_mod")
		ap:SetSizepower(100)
		ap:SetParent(node)
		ap:AddFlag(FLAG_EDITORNODE)
		ap:SetSeed(GetFreeUID())
		ap:SetParameter(VARTYPE_CHARACTER,type)
		ap:SetPos(wtr.Position+Vector(0,1/node:GetSizepower(),0))
		ap:SetAng(Vector(90,0,0))
		ap:Spawn()  
		return ap
	end},
	--tool = {},
	--planet = {directory = "forms/planets/"},
	

}
PANEL.specialtypes = {
	door = {spawn = function(node)
		if not worldeditor then return nil end
		local wtr = worldeditor.wtrace
		if not wtr or not wtr.Hit then return nil end
		
		local d1 = SpawnDT("door/door2.stmd",node,wtr.Position+Vector(0,1/node:GetSizepower(),0),Vector(0,0,0),0.05) 
		d1:SetGlobalName("flatgrass.door")
		d1:AddFlag(FLAG_EDITORNODE)
		d1:SetSeed(GetFreeUID())
		d1.target = {"models/dyntest/sdm/interior_main.dnmd","foyer.flatgrass.door"}
		d1:SetParameter(VARTYPE_CHARACTER,"models/dyntest/sdm/interior_main.dnmd:foyer.flatgrass.door")
		return d1
	end},

}

function PANEL:Scandir(name,dir,onclick,recursive,keytable)
	local files = file.GetFiles(dir,".json",false)  
	
	local tb = {} 
	for k,v in pairs(files) do
		local ltp = file.GetFileNameWE(v)
		keytable[ltp] = v
		tb[#tb+1] = ltp
	end 
	local tb2 = {name}
	if recursive then
		local subdirs = file.GetDirectories(dir)  
		for k,v in pairs(subdirs) do
			tb2[#tb2+1] = self:Scandir(file.GetFileNameWE(v),v,onclick,recursive,keytable) 
		end
	end
	table.sort(tb)
	for kk,vv in pairs(tb) do 
		tb2[#tb2+1] = {vv,OnClick=onclick} 
	end
	return tb2
end
function PANEL:InitTabAssets()
	local P = panel.Create()
	P:SetColor(Vector(0,0,0))
	
	
	local mpanel = panel.Create()
	mpanel:SetSize(20,20)
	mpanel:SetColor(Vector(0.1,0.1,0.1))
	mpanel:Dock(DOCK_TOP)
	P:Add(mpanel)
	
	
	local bsave = panel.Create("button")
	bsave:SetSize(100,40)
	bsave:SetText("Save")
	bsave:Dock(DOCK_LEFT)
	bsave.OnClick = function()
		local cparent = GetCamera():GetParent()
		if cparent then
			local s = panel.Create("window_save")
			s:SetTitle("Save node") 
			s:SetButtons("Save","Back") 
			s.OnAccept = function(s,name) engine.SaveNode(cparent, "manual/"..name, FLAG_EDITORNODE) end
			s:Show() 
		end
	end 
	mpanel:Add(bsave)
	
	
	 
	local bload = panel.Create("button")
	bload:SetSize(100,40)
	bload:SetText("Load")
	bload.OnClick = function() 
		local cparent = GetCamera():GetParent() 
		if cparent then
			local s = panel.Create("window_save")
			s:SetTitle("Load node") 
			s:SetButtons("Load","Back") 
			s.OnAccept = function(s,name) engine.LoadNode(cparent, "manual/"..name) end
			s:Show() 
		end 
	end
	bload:Dock(DOCK_LEFT)
	mpanel:Add(bload)
	
	
	
	local bsaveStatic = panel.Create("button")
	bsaveStatic:SetSize(100,40)
	bsaveStatic:SetText("SaveNode")
	bsaveStatic:Dock(DOCK_LEFT)
	bsaveStatic.OnClick = function()
		local cparent = GetCamera():GetParent()
		local cseed = cparent:GetSeed()
		if cseed ~= 0 then
			engine.SaveNode(cparent, tostring(cseed), FLAG_EDITORNODE)
		end
	end 
	mpanel:Add(bsaveStatic)
	
	----------
	
	local dirtree = panel.Create("tree")
	dirtree:SetSize(200,400)
	dirtree:Dock(DOCK_TOP)
	P:Add(dirtree)
	
	
	self.dirtree = dirtree
	
	
	local rtb = {"types"}
	 
	local linkt = {}
	for k,v in pairs(self.assettypes) do
		linkt[k] = {}
		local spt = v
		local onclick = function(b)
			local type = b:GetText()
			local fulltype = linkt[k][type]
			MsgN(type)
			if(spt.spawn) then
				local e = spt.spawn(type,GetCamera():GetParent(),fulltype)
				worldeditor:Select(e)
			end
		end  
		---local tbl = file.GetFiles(v.directory,".json",true)  
		---local tb = {} 
		---local tb2 = {k} 
		---for kk,vv in pairs(tbl) do
		---	local ltp = file.GetFileNameWE( vv)
		---	linkt[k][ltp] = vv
		---	tb[#tb+1] = ltp
		---end 
		---table.sort(tb)
		---for kk,vv in pairs(tb) do 
		---	tb2[#tb2+1] = {vv,OnClick=onclick}
		---end
		rtb[#rtb+1] = self:Scandir(k,v.directory,onclick,v.recursive,linkt[k])-- tb2
	end
	for k,v in pairs(self.specialtypes) do
		linkt[k] = {}
		local spt = v
		local onclick = function(b) 
			if(spt.spawn) then
				local e = spt.spawn(GetCamera():GetParent())
				worldeditor:Select(e)
			end
		end   
		rtb[#rtb+1] ={k,OnClick=onclick}-- self:Scandir(k,v.directory,onclick,v.recursive,linkt[k])-- tb2
	end
	dirtree:SetTableType(2)
	
	dirtree:FromTable(rtb)
	dirtree:SetSize(200,400)
	
	return P
end
--function PANEL:InitTabNodes()
--	local P = panel.Create()
--	P:SetColor(Vector(0,0,0))
--	
--	local nodetree = panel.Create("tree")
--	nodetree:SetSize(200,400)
--	nodetree:Dock(DOCK_TOP)
--	P:Add(nodetree)
--	
--	
--	self.nodetree = nodetree
--	
--	local rtb = {"types"}
--	local cam = GetCamera()
--	local camp = cam:GetParent()
--	local chp = camp:GetChildren()
--	  
--	for k,v in pairs(chp) do 
--		local onclick = function(b)  
--			worldeditor:Select(v)
--		end 
--		local tb2 = {tostring(v),OnClick=onclick}  
--		rtb[#rtb+1] = tb2
--	end
--	nodetree:SetTableType(2)
--	
--	nodetree:FromTable(rtb)
--	nodetree:SetSize(200,400)
--	return P
--end

function PANEL:Init() 
	self:SetColor(Vector(0,0,0))
	
	
	local testtabmenu = panel.Create("tabmenu")
	testtabmenu:AddTab("Assets",self:InitTabAssets())
	local pnode = panel.Create("editor_panel_node")   
	self.pnode = pnode
	testtabmenu:AddTab("Nodes",pnode)
	
	--testtabmenu:AddTab("Hierarchy",self:InitTabNodes())
	
	testtabmenu:SetSize(100,100)
	testtabmenu:Dock(DOCK_FILL)
	testtabmenu:ShowTab(1)
	self:Add(testtabmenu)
	self:UpdateLayout()
end 

