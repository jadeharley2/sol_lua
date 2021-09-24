
local assettypes = {
	--prop = {directory = "forms/props/", recursive=true, spawn = function(type,node,fulltype) 
	--	--local j = json.Read(fulltype)--"forms/props/"..type..".json")
	--	if not worldeditor then return nil end
	--	local wtr = worldeditor.wtrace
--
	--	local pos = Vector(0,0,0)
	--	if not wtr or not wtr.Hit then --return nil
	--	else pos = node:GetLocalCoordinates(wtr.Node,wtr.Position) end
--
	--	local fpath = "prop."..type-- forms.GetForm("prop",type)
	--	if fpath then
	--	 	MsgN("spawnprop:",fpath)
	--		local p = SpawnPV(fpath,node,pos,nil,GetFreeUID())--,j.scale,false,false)
	--		if p then
	--			p:AddTag(TAG_EDITORNODE) 
	--		end
	--		return p
	--	end 
	--	return nil
	--end}, 
	particle = {directory = "particles/",spawn = function(type,node,fulltype) 
		if not worldeditor then return nil end
		local wtr = worldeditor.wtrace
		if not wtr or not wtr.Hit then return nil end
		local pos = node:GetLocalCoordinates(wtr.Node,wtr.Position) 

		local p = SpawnParticles(node,type,pos,0,1,1)
		if p then
			p:AddTag(TAG_EDITORNODE)
			p:SetSeed(GetFreeUID())
		end
		return p
	end},
	font = {directory = "fonts/"},
	
	--species = {directory = "forms/species/"},
	--character = {directory = "forms/characters/", spawn = function(type,node)  
	--
	--	if not worldeditor then return nil end
	--	local wtr = worldeditor.wtrace
	--	if not wtr or not wtr.Hit then return nil end
	--	local pos = node:GetLocalCoordinates(wtr.Node,wtr.Position) 
	--	  
	--	
	--	local actorD = ents.Create("base_actor")
	--	actorD:SetSizepower(1000)
	--	actorD:SetParent(node)
	--	actorD:AddTag(TAG_EDITORNODE)
	--	actorD:SetSeed(GetFreeUID())
	--	actorD:SetCharacter(type)
	--	actorD:Spawn() 
	--	actorD:SetPos(pos)
	--	return actorD 
	--end},
	--apparel = {directory = "forms/apparel/", spawn = function(type,node)
	--	if not worldeditor then return nil end
	--	local wtr = worldeditor.wtrace
	--	if not wtr or not wtr.Hit then return nil end
	--	local pos = node:GetLocalCoordinates(wtr.Node,wtr.Position) 
--
	--	local ap = SpawnIA(type,node,Vector(0,0,0),GetFreeUID())
	--	ap:AddTag(TAG_EDITORNODE)
	--	ap:SetPos(pos+Vector(0,1/node:GetSizepower(),0))
	--	return ap
	--end},
	surfacemod = {directory = "forms/surfacemods/", spawn = function(type,node)
		if not worldeditor then return nil end
		local wtr = worldeditor.wtrace
		local pos = ssstest or Vector(0,0,0)
		if not wtr or not wtr.Hit then 
			if not ssstest then
				return nil 
			end
		else
			pos = node:GetLocalCoordinates(wtr.Node,wtr.Position) 
		end 
		
		local ap = ents.Create("planet_surface_mod")
		ap:SetSizepower(100)
		ap:SetParent(node)
		ap:AddTag(TAG_EDITORNODE)
		ap:SetSeed(GetFreeUID())
		ap:SetParameter(VARTYPE_CHARACTER,type)
		ap:SetPos(pos+Vector(0,1/node:GetSizepower(),0))
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
		local pos = node:GetLocalCoordinates(wtr.Node,wtr.Position) 
		
		local d1 = SpawnDT("door/door2.stmd",node,pos+Vector(0,1/node:GetSizepower(),0),Vector(0,0,0),0.05) 
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
local whitelisted_ext = Set('.dds','.png','.smd','.stmd','.dnmd','.mdl','.jpg','.tga','.nif')
local on_dt_display2 = function(files,item,data,isdir) 
	if data then 
		if isdir then
			item:SetSize(20,20)
		else 
			local ext = file.GetExtension(data) 
			if not whitelisted_ext:Contains(ext) then
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
local select_form = function(b,cdtype)   
	if not worldeditor then return nil end
	MsgN("SELECT FORM:",cdtype) 
	worldeditor.selected_formid = cdtype 
end
local on_dt_click = function(b,cdtype,mousespawn,randomYaw)  
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
	else--form spawn
		local type = string.join('.',aparts)
		local node = GetCamera():GetParent()
 
		if not worldeditor then return nil end
		
		local wtr = worldeditor.wtrace
		if mousespawn then
			local vp = ViewportGetMousePos()
			wtr = GetMousePhysTrace(cam,nil,vp)
		end
		if wtr and wtr.Hit then 
			local pos = node:GetLocalCoordinates(wtr.Node,wtr.Position) 
			local uid = GetFreeUID()
	
			MsgN("form spawn",type)
			local e = ent_worldeditor:SendEvent(EVENT_EDITOR_SPAWN_FORM,type,node, pos, uid)
			if e then
				worldeditor:Select(e)
				if randomYaw then
					e:TRotateAroundAxis(Vector(0,1,0),math.random()*360)
				end
			end
		end
	end 
end
WE_SpawnOnMouse = function(randomYaw)
	local form = worldeditor.selected_formid
	if form then
		on_dt_click(nil,form,true,randomYaw)
	end
end
local on_static_spawn = function(b,cdtype)   
	MsgN("STATIC REQUEST?",cdtype) 
	local node = GetCamera():GetParent()

	if not worldeditor then return nil end
	local wtr = worldeditor.wtrace
	if wtr and wtr.Hit then 
		local pos = node:GetLocalCoordinates(wtr.Node,wtr.Position) 
		local e = SpawnSO(cdtype,node,pos,1)
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
	gui.FromTable({  class = "back",   
        size = {200,300},
        dock = DOCK_BOTTOM,
        subs = {
            --{ name = "header", class = "header_0", 
            --    text = "Asset browser", 
            --},
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
                OnItemDoubleClick = on_dt_click,
				OnItemClick = select_form 
            },
            {type="files",name = "dirtree3",
                size = {500,400},
                dock = DOCK_LEFT,
				OnDisplay = on_dt_display2,
				OnItemDoubleClick = on_static_spawn,
				--OnItemClick = select_form 
            }
        }
    },self,global_editor_style,self)
	   
 
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
	self.dirtree2:SetVisible(true)
	self.dirtree3:SetVisible(false)

	--self.pnode:UpdateLayout()
 	--self.pterr:UpdateLayout()

	self:UpdateLayout()
	self.classtree:ScrollToTop()
end 

