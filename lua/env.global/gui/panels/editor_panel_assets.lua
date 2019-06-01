
local assettypes = {
	prop = {directory = "forms/props/", recursive=true, spawn = function(type,node,fulltype) 
		--local j = json.Read(fulltype)--"forms/props/"..type..".json")
		if not worldeditor then return nil end
		local wtr = worldeditor.wtrace
		local pos = Vector(0,0,0)
		if not wtr or not wtr.Hit then --return nil
		else
			pos = wtr.Position
		end
		local fpath = forms.GetForm("prop",type)
		if fpath then
		 	MsgN("spawnprop:",fpath)
			local p = SpawnPV(fpath,node,pos,nil,GetFreeUID())--,j.scale,false,false)
			if p then
				p:AddFlag(FLAG_EDITORNODE) 
			end
			return p
		end 
		return nil
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
local on_dt_display = function(files,item,data,isdir)
	--MsgN(">>>>>",files,item,data,isdir)
	if data then
		--item:SetColorAuto(Vector(0,0.3,0))
		if isdir then
			item:SetSize(20,20)
		else
			item:SetSize(32,32) 

			local aparts = string.split(data,'/') 
			local type = string.join('.',table.Skip(aparts,1))
			if forms.GetForm(aparts[1]..'.'..type) then
				local pnl = panel.Create('thumbnail')
				pnl:SetSize(32,32)
				pnl:Dock(DOCK_RIGHT)
				pnl:SetCanRaiseMouseEvents(false)
				pnl:SetForm(aparts[1]..'.'..type,item)
				item:Add(pnl) 
			end 
		end
	end
end 
local on_dt_display2 = function(files,item,data,isdir) 
	if data then 
		if isdir then
			item:SetSize(20,20)
		else
			if data:ends('.vvd') or data:ends('.vtx') or data:ends('.phy') or data:ends('.smd') then
				return false
			else
				item:SetSize(32,32)  
				local pnl = panel.Create('thumbnail')
				pnl:SetSize(32,32)
				pnl:Dock(DOCK_RIGHT)
				pnl:SetCanRaiseMouseEvents(false)
				pnl:SetPath(data,item)
				item:Add(pnl) 
			end
		end
	end
end 
local on_dt_click = function(b,cdtype) 
	MsgN("SPAWN REQUEST?",cdtype)
	local aparts = string.split(cdtype,'/')

	local validtype = assettypes[aparts[1]]
	if validtype then 
		local type = string.join('.',table.Skip(aparts,1))
		MsgN("VALIDTYPE",type,unpack(aparts))
		local e = validtype.spawn(type,GetCamera():GetParent(),cdtype)
		local edt = e.editor
		if edt and edt.onSpawn then
			edt.onSpawn(e)
		end
		worldeditor:Select(e)
	end 
end
function PANEL:InitTabAssets()
	local P = panel.Create()
	P:SetColor(Vector(0,0,0))
	
	
	
	----------
	 
	
	local dirtree2 = panel.Create("files")
	dirtree2:SetSize(500,400)
	dirtree2:Dock(DOCK_LEFT)
	dirtree2.OnDisplay = on_dt_display
	dirtree2.OnItemClick = on_dt_click
	dirtree2:SetFormFS()
	P:Add(dirtree2)
 
	self.dirtree2 = dirtree2

	
	local dirtree3 = panel.Create("files")
	dirtree3:SetSize(500,400)
	dirtree3:Dock(DOCK_LEFT)
	dirtree3.OnDisplay = on_dt_display2 
	P:Add(dirtree3)
	
	  
	P:UpdateLayout()

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
	local sty = {
		bmenu = {type = "button", size = {100,40},dock = DOCK_LEFT}
	}
	gui.FromTable({ 
		color = {0,0,0},
		subs = {
			{ name = "rightpanel",
				size = {300,300},
				color = {0,0,0},
				dock = DOCK_RIGHT,
				subs = {
					{	name = "mpanel",
						size = {20,20},
						color = {0.1,0.1,0.1},
						dock = DOCK_TOP,
						subs = {
							{ class = "bmenu", name = "bsave", text = "Save",
								OnClick = function()
									local cparent = GetCamera():GetParent()
									if cparent then
										local s = panel.Create("window_save")
										s:SetTitle("Save node") 
										s:SetButtons("Save","Back") 
										s.OnAccept = function(s,name) engine.SaveNode(cparent, "manual/"..name, FLAG_EDITORNODE) end
										s:Show() 
									end
								end 
							}, 
							{ class = "bmenu",  name = "bload", text = "Load", 
								OnClick = function()
									local cparent = GetCamera():GetParent() 
									if cparent then
										local s = panel.Create("window_save")
										s:SetTitle("Load node") 
										s:SetButtons("Load","Back") 
										s.OnAccept = function(s,name) engine.LoadNode(cparent, "manual/"..name) end
										s:Show() 
									end 
								end 
							}, 
							{ class = "bmenu",  name = "bsavenode", text = "SaveNode", 
								OnClick = function()
									local cparent = GetCamera():GetParent()
									local cseed = cparent:GetSeed()
									if cseed ~= 0 then
										engine.SaveNode(cparent, tostring(cseed), FLAG_EDITORNODE)
									end
								end 
							}
						}
					}
				}
			},
			{ type = "editor_panel_node",name = "pnode",
				size = {300,100},
				dock = DOCK_LEFT
			} 
		} 
	},self,sty,self)
	   
	   

	local assets = self:InitTabAssets()
	assets:SetSize(200,300)
	assets:Dock(DOCK_BOTTOM)
	self:Add(assets) 


	local view = panel.Create("viewport")
	view:SetSize(200,200)
	view:Dock(DOCK_FILL)
	view:InitializeFromTexture(1,"@main_diffuse")
	self.vp = view
	self:Add(view) 

	self:UpdateLayout()
end 

