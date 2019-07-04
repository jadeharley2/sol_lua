if SERVER then return nil end

chareditor = chareditor or {}
--chareditor.world  = nil

function chareditor.CreateStaticLight( pos, color,power)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2) 
	lighttest:SetParent(chareditor.space)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn() 
	if power then lighttest:SetBrightness(power) end
	lighttest:SetPos(pos)  
	return lighttest
end

function chareditor.SpawnWorld()
	local w = ents.Create("world_void")
	w:SetSeed(3245131)  
	w.subseed = 2482091
	w:Spawn()
	chareditor.world = w
	chareditor.space = w.space

	chareditor.CreateStaticLight(Vector(1,1,1), Vector(1,1,1),400000)

 
		
	local skybox = w:AddComponent(CTYPE_SKYBOX) 
	skybox:SetRenderGroup(RENDERGROUP_LOCAL) 
	skybox:SetTexture("textures/cubemap/bluespace.dds")
	chareditor.skybox = skybox

	local root_skyb =  ents.Create()
	root_skyb:SetSizepower(2000)
	root_skyb:SetParent(w.space)
	root_skyb:SetPos(Vector(0,100,0))
	root_skyb:Spawn()

	local cbm =  w.space:AddComponent(CTYPE_CUBEMAP)
	cbm:SetSize(512)
	cbm:SetTarget(nil,w.space) 
	cbm:RequestDraw()
	chareditor.cubemap = cbm 

	MsgInfo("new world")
end

function chareditor.CloseGui()
	if chareditor.panel then
		chareditor.panel:Close()
		chareditor.panel = nil
	end
end
local default_material = {
	shader="shader.model", 
	base_subsurface_val=0.5, 
	brightness=1,
	base_specular_intencity=0.1,
	mul_specular_intencity=1, 
	base_specular_power=0.2,
	mul_specular_power=1, 
	g_MeshTexture="textures/debug/white.png",  
	tint={1,1,1},
}
local global_color_options = { 
	keys = { "color_body_1","color_body_2","color_body_3","color_body_4" },
}
local test_options = {
	body = {
		body_ara={text="Ara",part="body_feline",materials={
			{   
				shader="shader.model",
				base_subsurface_val=0.5, 
				brightness=1,
				base_specular_intencity=0.1,
				mul_specular_intencity=1, 
				base_specular_power=0.2,
				mul_specular_power=1, 
				g_MeshTexture="models/species/anthro/materials/ara_body.png",  
				g_MeshTexture_e="models/species/anthro/materials/ara_body_e.png",  
			}
		},matdir="models/species/anthro/materials/"},
		body_vikna={text="Vikna",part="body_feline"},
		body_feline={text="Feline",part="body_feline",dynmaterial={
			matdir = "models/species/anthro/texparts/",
			basematerial = default_material,
			texparts = { 
				{file="textures/debug/white.png", color="color_body_1"},
				{file="models/species/anthro/texparts/body_feline_l1.png", color="color_body_2"},
				{file="models/species/anthro/texparts/body_feline_l2.png", color="color_body_3"} 
			}
		}},
	},
	head = {
		head_ara={text="Ara",part="head_ara"},
		head_vikna={text="Vikna",part="head_vikna"},
		head_feline={text="Feline",part="head_vikna",dynmaterial={
			matdir = "models/species/anthro/texparts/",
			basematerial = default_material,
			texparts = {
				{file="textures/debug/white.png", color="color_body_1"},
				{file="models/species/anthro/texparts/body_colors_l1.png", color="color_body_2"},
				{file="models/species/anthro/texparts/body_colors_l2.png", color="color_body_3"} ,
				{file="models/species/anthro/texparts/body_colors_l3.png", color="color_body_4"}
			}
		}},
	},
	tail = {
		tail_ara={text="Ara",part="tail_ara"},
		tail_vikna={text="Vikna",part="tail_vikna"},
		tail_feline={text="Feline",part="tail_vikna",dynmaterial={
			matdir = "models/species/anthro/texparts/",
			basematerial = default_material,
			texparts = {
				{file="textures/debug/white.png", color="color_body_1"},
				{file="models/species/anthro/texparts/body_colors_l1.png", color="color_body_2"},
				{file="models/species/anthro/texparts/body_colors_l2.png", color="color_body_3"} ,
				{file="models/species/anthro/texparts/body_colors_l3.png", color="color_body_4"}
			}
		}},
	},
	hair = {
		{text="Ara",part="hair_ara",colorable=true},
		{text="Vikna",part="hair_vikna",colorable=true},
	},
}
chareditor.colorray =chareditor.colorray or {}
chareditor.strings =chareditor.strings or {}
function chareditor.SetPart(type,partinfo,key)
	local char = chareditor.character
	local partlist = char.spparts

	local oldpart= partlist[type]
	if oldpart then
		oldpart:Despawn()
		partlist[type] = nil
	end

	local partname = partinfo.part

	local bpath = char.species.model.basedir

	local bp = SpawnBP(bpath..partname..".stmd",char,0.03)
	bp:SetName(type)
	bp.partname = key
	partlist[type] = bp
	
	if bp and partinfo.materials then  
		for mid,mvl in pairs(partinfo.materials) do
			local mat = dynmateial.LoadDynMaterial(mvl,partinfo.matdir)
			bp.model:SetMaterial(mat,mid-1)
		end
	end
	chareditor.UpdateDynamicTextures() 
end
function chareditor.SetPartColor(type,color) 
	local char = chareditor.character
	local partlist = char.spparts

	local bp= partlist[type] 
	ModModelMaterials(bp.model,{tint = color},false)
end
function chareditor.GetPartColor(type) 
	local char = chareditor.character
	local partlist = char.spparts

	local bp= partlist[type] 
	local mat = bp.model:GetMaterial(0)
	return GetMaterialProperty(mat,"tint")
end
function chareditor.UpdateDynamicTextures() 
	local char = chareditor.character
	local partlist = char.spparts
	local colors = chareditor.colorray 
	local strings = chareditor.strings 

	--for k,v in pairs(colors) do
	--	MsgN("color:",k,v)
	--end 

	local E = chareditor.species
	local mat_table = {}
	local function getTable(mat)
		local m = mat_table[mat] 
		if m then
			return m
		else
			m = E.materials[mat]
			if m then
				local t = {}
				local vartable = {}
				t.variables = vartable
				if m.parent then 	
					local pt = getTable(m.parent)
					for k,v in pairs(pt.variables) do vartable[k] = v end
					t.targets = pt.targets
					t.slot = pt.slot
					t.matid = pt.matid 
				end  
				if m.variables then 
					for k,v in pairs(m.variables)  		do vartable[k] = v end 
				end
				t.targets = m.targets or t.targets
				t.slot = m.slot or t.slot
				t.matid = m.matid or t.matid
				return t
			else
				return nil
			end
		end 
	end
	for k,v in pairs(E.materials) do
		local t = getTable(k) 
		if v.colorize then
			for k2,v2 in pairs(v.colorize) do
				t.variables[k2] = VectorJ( colors[v2] or Vector(1,1,1))
			end
		end
		mat_table[k] = t -- { variables = vartable, targets = v.targets, slot = v.slot, matid = v.matid }
	end

	for k,v in pairs(mat_table) do  
		local mat = NewMaterial(E.matdir, json.ToJson(v.variables)) 
		v.mat = mat
		if v.slot then 
			if v.targets then
				for target,data in pairs(v.targets) do
					local size = data.size or {512,512}
					local tab = {}
					for k2,v2 in pairs(data.layers) do
						local file = v2.file 
						if v2.filekey then 
							file = strings[v2.filekey] or file or "textures/debug/white.png"
						end
						tab[#tab+1] = {
							texture = file,
							color = VectorJ( colors[v2.tint] or Vector(1,1,1)),
							size = {512,512}
						}
					end
					local root = gui.FromTable({size = size, subs = tab})
					RenderTexture(size[1],size[2],root,function(rtex)
						SetMaterialProperty(mat,target,rtex) 
						for k2,v2 in pairs(v.slot) do
							partlist[v2].model:SetMaterial(mat,v.matid or 0)
							MsgN("setmat",k,v2,v.matid or 0)
						end 
					end)  
				end
			else
				for k,v in pairs(v.slot) do
					partlist[v].model:SetMaterial(mat,v.matid or 0)
					MsgN("setmat",k,v.matid or 0)
				end 
			end
		end
	end

end
-- OLD
--function chareditor.UpdateDynamicTexture(type,partinfo,colorray) 
--	local char = chareditor.character
--	local partlist = char.spparts
--
--	local bp= partlist[type] 
--	local DM = partinfo.dynmaterial
--	if bp and DM then 
--		local tab = {}
--		for k,v in pairs(DM.texparts) do
--			tab[#tab+1] = {
--				texture = v.file,
--				color = VectorJ( colorray[v.color] or Vector(1,1,1)),
--				size = {512,512}
--			}
--		end
--		local root = gui.FromTable({size ={512,512}, subs = tab})
--		local mat = NewMaterial(DM.matdir, json.ToJson(DM.basematerial)) 
--		--root:Show()
-- 
--		--debug.Delayed(2000,function()  root:Close() end)
--		RenderTexture(512,512,root,function(rtex)
--			SetMaterialProperty(mat,"g_MeshTexture",rtex) 
--			bp.model:SetMaterial(mat,DM.matid or 0)
--		end)   
--	end
--
--end
function chareditor.OpenGui()
	chareditor.CloseGui() 
	local layout = {type = "panel", 
		size = {200,600},
		dock = DOCK_TOP,  
		color = {0.2,0.2,0.2},  
		subs = {{type = "panel", 
				dock = DOCK_TOP,  
				text = "Character editor",
				size = {20,20},
				margin = {5,5,5,5}, 
				color = {1,1,1},  
			},
			
			{type = "panel", name ="race_group",
				dock = DOCK_TOP,   
				size = {20,20}, 
				color = {0,0.3,0},
				margin = {5,5,5,5}, 
				autosize={false,true}
			},

			{type = "panel", name ="cat_group",
				dock = DOCK_TOP,   
				size = {20,20}, 
				color = {0,0.3,0},
				margin = {5,5,5,5}, 
				autosize={false,true}
			},
			{type = "panel", name ="partlist",
				dock = DOCK_TOP,   
				size = {20,20}, 
				color = {0,0.3,0},
				margin = {5,5,5,5}, 
				autosize={false,true}
			},
			{type = "panel", name ="param_group",
				dock = DOCK_TOP,   
				size = {20,20}, 
				color = {0,0.3,0},
				margin = {5,5,5,5}, 
				autosize={false,true}
			}, 
			{type = "panel", name ="global_param_group",
				dock = DOCK_TOP,   
				size = {20,20}, 
				color = {0,0.3,0},  
				margin = {5,5,5,5},       
				autosize={false,true}
			},
			--{type = "list",
			--	dock = DOCK_FILL,   
			--	size = {200,100}, 
			--	color = {0,0,0},  
			--	subs= { 
			--		{type="floatcontainer",  -- class = "submenu",
			--			visible = true, 
			--			size = {200,100}, 
			--			dock = DOCK_FILL,
			--			color = {0,0,0}, 
			--			textonly=true, 
			--			Floater = {type="panel", 
			--				scrollbars = 1,
			--				color = {0,0,0}, 
			--				size = {200,200},  
			--				autosize={false,true},
			--				subs={ 
			--				}
			--			},
			--		}, 
			--	}
			--},  
		}
	} 
	local p = gui.FromTable(layout,nil,{},chareditor) 
	chareditor.panel = p  
	MsgN("aaaa",p,nt)
	PrintTable(nt)

	for k,v in pairs(forms.GetList('species')) do
		local path,name,tags = forms.GetForm('species',k)
		if table.HasValue(tags,'playable') then
			chareditor.race_group:Add(gui.FromTable({ type="button",  -- class = "submenu", 
				size = {20,20},
				states = {
					idle    = {color = {0,0,0}},
					hover   = {color = {0.3,0.3,0.3}},
					pressed = {color = {0.3,0.5,0.3}}, 
				}, 
				stat = "idle",
				color = {0,0,0}, 
				textcolor = {1,1,1},
				text = name,
				dock = DOCK_TOP,  
				toggleable = true,
				tag = k,
				margin = {1,1,1,1}, 
				OnClick = function(s) 
					chareditor.SelectSpecies(s.tag)
				end
			}))  
		end
		p:UpdateLayout()
	end 



	local vsize = GetViewportSize()  
	p:SetPos(vsize.x-300,0)
	p:Show()  
	p:UpdateLayout()
end
local selectOne = function(btn)
	local par = btn:GetParent()
	for k,v in pairs(par:GetChildren()) do if v~=btn then v:SetState("idle") end end 
end
function chareditor.SelectSpecies(type)
	local data = forms.ReadForm('species.'..type)
	
	local lst = chareditor.cat_group
	lst:Clear()
	chareditor.global_param_group:Clear()  
	
	if data and data.editor then
		local E = data.editor
		chareditor.species = E
		local char = chareditor.character
		char:SetCharacter(E.base)
		char:DisableGraphUpdate() 
		char:SetEyeAngles(0,0,true) 
		char.model:SetAnimation('idle')
		chareditor.UpdateDynamicTextures()
		
		for k,v in pairs(E.parameters.group_parts) do
			lst:Add(gui.FromTable({ type="button",  -- class = "submenu", 
				size = {20,20},
				states = {
					idle    = {color = {0,0,0}},
					hover   = {color = {0.3,0.3,0.3}},
					pressed = {color = {0.3,0.5,0.3}}, 
				}, 
				stat = "idle",
				color = {0,0,0}, 
				textcolor = {1,1,1},
				margin = {1,1,1,1}, 
				text = v.text or k,
				dock = DOCK_TOP,   
				toggleable = true,
				
				tag = k,
				OnClick = function(s) 
					chareditor.SelectPartType(s.tag)
					selectOne(s)
				end
			})) 
		end 
	
		local oncolorchange = function(s,c)
			chareditor.colorray[s.key] = c
			chareditor.UpdateDynamicTextures()--type,item,colorpickray)
		end
		local onselectorchange = function(s,k,v)
			MsgN(s.key,k,v)
			chareditor.strings[s.key] = v
			chareditor.UpdateDynamicTextures()--type,item,colorpickray)
		end
		for k,v in SortedPairs(E.parameters.group_colors) do
			if v.type=='color' then
				local cp = gui.FromTable({
					type = "color_param",
					dock = DOCK_TOP,
					key = k,
					margin = {1,1,1,1}, 
					OnPick = oncolorchange
				})
				--local cp = gui.FromTable(button_c)
				cp:SetText(v.text) 
				cp.OnPick = oncolorchange
				cp:SetValue(chareditor.colorray[k] or JVector(v.default) or Vector(1,1,1))
				chareditor.global_param_group:Add(cp)  
			elseif v.type=='selector' then
				local cp = gui.FromTable({
					type = "selector",
					dock = DOCK_TOP,
					key = k,
					margin = {1,1,1,1}, 
					OnPick = onselectorchange
				}) 
				cp:SetText(v.text) 
				cp.OnSelect = onselectorchange
				cp:SetVariants(v.variants)
				cp:SetValue(chareditor.strings[k] or v.default or "")
				chareditor.global_param_group:Add(cp)  
			end
		end  
	end
	chareditor.panel:UpdateLayout()
end
function chareditor.SelectPartType(type)
	chareditor.partlist:Clear()
	chareditor.param_group:Clear()
	local E = chareditor.species
	local typeinfo = E.parameters.group_parts[type]

	if typeinfo.variants then
		for k,v in pairs(typeinfo.variants) do
			chareditor.partlist:Add(gui.FromTable({ type="button",  -- class = "submenu", 
				size = {20,20},
				states = {
					idle    = {color = {0,0,0}},
					hover   = {color = {0.3,0.3,0.3}},
					pressed = {color = {1,1,1}},
				}, 
				stat = "idle",
				color = {0,0,0}, 
				textcolor = {1,1,1},
				text = v.text or k,
				dock = DOCK_TOP,  
				tag = {type,v,k},
				margin = {1,1,1,1}, 
				OnClick = function(s) 
					chareditor.SelectPartItem(s.tag[1],s.tag[2],s.tag[3])
				end
			}))  
		end  
	end
	chareditor.panel:UpdateLayout()
end
function chareditor.SelectPartItem(type,item,key) 
	chareditor.SetPart(type,item,key)

	chareditor.param_group:Clear()
	if item.colorable then
		local oncolorchange = function(s,c)
			chareditor.SetPartColor(type,c)
		end
		local cp = gui.FromTable({
			type = "color_param",
			dock = DOCK_TOP,
			text = "Part color",
			OnPick = oncolorchange
		})
		local ptcolor = chareditor.GetPartColor(type)
		cp:SetValue(ptcolor or Vector(1,1,1))
		chareditor.param_group:Add(cp) 
	end 

	chareditor.panel:UpdateLayout()
end 

function chareditor.Enable()
	if not chareditor.world  then chareditor.SpawnWorld() end
	chareditor.enabled = true
	local char =  LocalPlayer()
	chareditor.character = char
	if char then
		SetController("orbitingcamera")
		global_controller.center = Vector(0,0.001,0)
		global_controller.zoom = 1
		global_controller.mode = "restricted"
		GetCamera():SetParent(char)

		chareditor.savednode = char:GetParent()
		chareditor.savedpos = char:GetPos()
		--chareditor.savedw = char:GetWorld()
		char:DisableGraphUpdate() 
		char:SetParent(chareditor.space)
		char:SetPos(Vector(0,0,0))
		char:SetAng(Vector(0,0,0))
		char:SetEyeAngles(0,0,true) 
		local cm = char.model
		if cm then
			cm:SetPoseParameter("head_yaw",0,true)
			cm:SetPoseParameter("head_pitch",0,true) 
			cm:SetPoseParameter("eyes_x",0,true)
			cm:SetPoseParameter("eyes_y",0,true) 
		end
		local cq = char.equipment
		if cq then
			for k,v in pairs(cq:GetParts()) do v:SetVisible(false) end
		end  
		for k,v in pairs(char.spparts) do v:SetVisible(true) end 
	end
	--local list_view = nodeeditor._lv or panel.Create("graph_editor")
	--nodeeditor._lv = list_view
	--list_view:Show()
	chareditor.OpenGui()
end
function chareditor.Disable()
	chareditor.enabled = false
	local char = chareditor.character
	if char then
		if chareditor.savednode then
			char:SetParent(chareditor.savednode)
			char:SetPos(chareditor.savedpos)
			--char:SetWorld(chareditor.savedw)
			char:EnableGraphUpdate() 
		end
		local cq = char.equipment
		if cq then
			for k,v in pairs(cq:GetParts()) do v:SetVisible(true) end
		end 
		for k,v in pairs(char.spparts) do v:UpdateVisibility() end 
		SetController("actor")
	end
	chareditor.CloseGui() 
end
function chareditor.Toggle()
	if chareditor.enabled then
		chareditor.Disable()
	else
		chareditor.Enable()
	end
end 

console.AddCmd("ed_char", chareditor.Toggle)
---test

--render.SetRenderBounds(100,100,1000,1000)