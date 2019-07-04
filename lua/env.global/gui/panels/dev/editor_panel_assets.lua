
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
				p:AddTag(TAG_EDITORNODE) 
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
			p:AddTag(TAG_EDITORNODE)
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
		actorD:AddTag(TAG_EDITORNODE)
		actorD:SetSeed(GetFreeUID())
		actorD:SetCharacter(type)
		actorD:Spawn()
		actorD:SetPos(wtr.Position+Vector(0,1/node:GetSizepower(),0))
		return actorD 
	end},
	apparel = {directory = "forms/apparel/", spawn = function(type,node)
		local ap = SpawnIA(type,node,Vector(0,0,0),GetFreeUID())
		ap:AddTag(TAG_EDITORNODE)
		return ap
	end},
	surfacemod = {directory = "forms/surfacemods/", spawn = function(type,node)
		if not worldeditor then return nil end
		local wtr = worldeditor.wtrace
		if not wtr or not wtr.Hit then return nil end
		
		local ap = ents.Create("planet_surface_mod")
		ap:SetSizepower(100)
		ap:SetParent(node)
		ap:AddTag(TAG_EDITORNODE)
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
		d1:AddTag(TAG_EDITORNODE)
		d1:SetSeed(GetFreeUID())
		d1.target = {"models/dyntest/sdm/interior_main.dnmd","foyer.flatgrass.door"}
		d1:SetParameter(VARTYPE_CHARACTER,"models/dyntest/sdm/interior_main.dnmd:foyer.flatgrass.door")
		return d1
	end},

}
local PREFIX = ""
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

			data = PREFIX..'/'..data
			local aparts = string.split(data,'/') 
			local type = string.join('.',table.Skip(aparts,1))
			if type and forms.GetForm(aparts[1]..'.'..type) then
				local pnl = panel.Create('thumbnail')
				pnl:SetSize(32,32)
				pnl:Dock(DOCK_RIGHT)
				pnl:SetCanRaiseMouseEvents(false)
				pnl:SetForm(aparts[1]..'.'..type,item)
				item:Add(pnl) 
				local oldclc = item.OnClick
				item.OnClick = function(a,b,c,...)
					if input.rightMouseButton() then
						local context = {
							{text = "huh"}, 
							{text = "drop",action = function(item)  end}, 
							{text = "destroy",action = function(item)    end}, 
							{text = "info",action = function(item)    end}, 
						 
						}  
						ContextMenu(item,context)
					else
						oldclc(a,b,c,...)
					end
				end
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
	cdtype = PREFIX..'/'..cdtype
	MsgN("SPAWN REQUEST?",cdtype)
	local aparts = string.split(cdtype,'/')

	local validtype = assettypes[aparts[1]]
	if validtype then 
		local type = string.join('.',table.Skip(aparts,1))
		MsgN("VALIDTYPE",type,unpack(aparts))
		local e = validtype.spawn(type,GetCamera():GetParent(),cdtype)
		if e then
			local edt = e.editor
			if edt and edt.onSpawn then
				edt.onSpawn(e)
			end
			worldeditor:Select(e)
		end
	end 
end
 
function PANEL:Init()  
	local sty = {
		bmenu = {type = "button", 
			size = {40,40},
			dock = DOCK_LEFT,
			states = {
				pressed    = {color = {255/255*2, 164/255*2, 83/255*2}},
				hover   = {color = {100/255,200/255, 255/255}},
				idle = {color = {53/255, 104/255, 205/255}},
			}, 
			state = 'idle'
		},
		bmenutoggle = {type = "button", 
			size = {40,40},
			dock = DOCK_LEFT,
			states = {
				pressed    = {color = {255/255*2, 164/255*2, 83/255*2}},
				hover   = {color = {100/255,200/255, 255/255}},
				idle = {color = {53/255, 104/255, 205/255}},
			}, 
			state = 'idle',
			toggleable = true,
		},
		menu_separator = {type = "panel", 
			size = {2,2},
			dock = DOCK_LEFT,
			color = {83/255, 164/255, 255/255}
		}
	}
	gui.FromTable({ 
		color = {0,0,0},
		subs = {
			{ name = "menus",
				size = {40,40},
				color = {0,0,0},
				dock = DOCK_TOP,
				subs = {
					{ class = "bmenu", texture = "textures/gui/panel_icons/new.png",
						OnClick = function()
							local cparent = GetCamera():GetParent()
							for k,v in pairs(cparent:GetChildren()) do
								if v:HasTag(TAG_EDITORNODE) then
									v:Despawn()
								end
							end
						end,
						contextinfo='Clear nodes'
					},
					{ class = "bmenu",  name = "bsavenode", texture = "textures/gui/panel_icons/save.png", 
						OnClick = function()
							local cparent = GetCamera():GetParent()
							local cseed = cparent:GetSeed()
							if cseed ~= 0 then
								engine.SaveNode(cparent, tostring(cseed), TAG_EDITORNODE)
							end
						end,
						contextinfo = 'Load nodes by current seed'
					},
					{ class = "bmenu", name = "bsave", texture = "textures/gui/panel_icons/save.png", 
						OnClick = function()
							local cparent = GetCamera():GetParent()
							if cparent then
								local s = panel.Create("window_save")
								s:SetTitle("Save node") 
								s:SetButtons("Save","Back") 
								s.OnAccept = function(s,name) engine.SaveNode(cparent, "manual/"..name, TAG_EDITORNODE) end
								s:Show() 
							end
						end,
						contextinfo = 'Save nodes as'
					}, 
					{ class = "bmenu",  name = "bload", texture = "textures/gui/panel_icons/load.png",  
						OnClick = function()
							local cparent = GetCamera():GetParent() 
							if cparent then
								local s = panel.Create("window_save")
								s:SetTitle("Load node") 
								s:SetButtons("Load","Back") 
								s.OnAccept = function(s,name) engine.LoadNode(cparent, "manual/"..name) end
								s:Show() 
							end 
						end,
						contextinfo = 'Load nodes'
					}, 
					{class="menu_separator"},
					{ class = "bmenu", texture = "textures/gui/panel_icons/left.png", contextinfo='Undo'},
					{ class = "bmenu", texture = "textures/gui/panel_icons/left.png", contextinfo='Redo', rotation = 180},
					{class="menu_separator"},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/move.png", contextinfo='Move mode'},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/rotate.png", contextinfo='Rotation mode'},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/scale.png", contextinfo='Scailing mode'},
					{class="menu_separator"},
					{ class = "bmenu", texture = "textures/gui/panel_icons/localspace.png", contextinfo='Local grid',
						OnClick = function() worldeditor:SetGridMode("local") end},
					{ class = "bmenu", texture = "textures/gui/panel_icons/parentspace.png", contextinfo='Parent grid',
						OnClick = function() worldeditor:SetGridMode("parent") end},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/possnap.png", contextinfo='Position snap',
						OnClick = function(s,val) worldeditor:SetPosSnap(val) end},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/anglesnap.png", contextinfo='Angle snap'},
					{class="menu_separator"},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/localorigin.png", contextinfo='Local origin'},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/medorigin.png", contextinfo='Median origin'},
					{ class = "bmenutoggle", texture = "textures/gui/panel_icons/otherorigin.png", contextinfo='Point origin'},
					{class="menu_separator"},
				}
			},
			{ name = "rightpanel", type = 'node_properties',name = "node_props",
				size = {300,300},
				color = {0,0,0},
				dock = DOCK_RIGHT, 
			},
			{ type = "editor_panel_node",name = "pnode",
				size = {300,100},
				dock = DOCK_LEFT
			},
			{ type = "panel", --assets
				color = {0,0,0},
				size = {200,300},
				dock = DOCK_BOTTOM,
				subs = {
					{ name = "header",
						size = {100,20},
						dock = DOCK_TOP,
						textalignment = ALIGN_CENTER,
						text = "Asset browser",
						color = {0.3,0.6,0.9}
					},
					{type="tree",name = "classtree",
						size = {200,400},
						dock = DOCK_LEFT,
						TableType = 1,
						sortitems = true
					},
					{type="files",name = "dirtree2",
						size = {500,400},
						dock = DOCK_LEFT,
						OnDisplay = on_dt_display,
						OnItemClick = on_dt_click
					},
					{type="files",name = "dirtree3",
						size = {500,400},
						dock = DOCK_LEFT,
						OnDisplay = on_dt_display2
					}
				}
			},
			{type='viewport',name="vp",dock=DOCK_FILL}
		} 
	},self,sty,self)
	   
 
	local flist = forms.GetList()
	local classlist = json.Read("forms/_meta/formtypedecl_main.json")
	 
	local table = {}
	for k,v in SortedPairs(classlist.types) do
		local g = v.group or "other"
		local st = table[g] or {}
		table[g] = st 
		st[v.name] = {}
	end
	table.world.staticprop = {}
	self.classtree:FromTable(table)
	self.classtree.OnItemClick = function(s,i,t) 
		PREFIX = t:GetText()
		self.dirtree2:SetFormFS(PREFIX) 
		if PREFIX == 'staticprop' then
			self.dirtree2:SetVisible(false)
			self.dirtree3:SetVisible(true)
		else
			self.dirtree2:SetVisible(true)
			self.dirtree3:SetVisible(false)
		end
		self:UpdateLayout()
	end
	  
	self.dirtree2:SetFormFS("prop")  
	self.vp:InitializeFromTexture(1,"@main_final")  
	self.dirtree2:SetVisible(true)
	self.dirtree3:SetVisible(false)

	self:UpdateLayout()
	self.classtree:ScrollToTop()
end 

