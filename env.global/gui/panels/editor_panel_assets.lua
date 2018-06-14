
PANEL.assettypes = {
	prop = {directory = "forms/props/", recursive=true, spawn = function(type,node,fulltype) 
		--local j = json.Read(fulltype)--"forms/props/"..type..".json")
		if not worldeditor then return nil end
		local wtr = worldeditor.wtrace
		if not wtr or not wtr.Hit then return nil end
		 
		local p = SpawnPV(fulltype,node,wtr.Position)--,j.scale,false,false)
		if p then
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
		actorD:SetSeed(GetFreeUID())
		actorD:SetCharacter(type)
		actorD:Spawn()
		actorD:SetPos(wtr.Position+Vector(0,1/node:GetSizepower(),0))
		return actorD 
	end},
	apparel = {directory = "forms/apparel/", spawn = function(type,node)
		return SpawnIA(type,node,Vector(0,0,0),GetFreeUID())
	end},
	--tool = {},
	planet = {directory = "forms/planets/"},
	

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
			s.OnAccept = function(s,name) engine.SaveNode(cparent, name) end
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
			s.OnAccept = function(s,name) engine.LoadNode(cparent, name) end
			s:Show() 
		end 
	end
	bload:Dock(DOCK_LEFT)
	mpanel:Add(bload)
	
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

