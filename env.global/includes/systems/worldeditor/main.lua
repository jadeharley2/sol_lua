
editor = editor or {} 
editor.selected = editor.selected or Set()
editor.undo = editor.undo or UndoManager(50)
editor.action_select = function(node) editor.selected:Add(node) editor.AddSelectionModel(node) end
editor.action_deselect = function(node) editor.selected:Remove(node) editor.RemoveSelectionModel(node) end
editor.action_move = function(from,to) node:SetPos(to) end 
editor.action_moveundo = function(from,to) node:SetPos(from) end 

function editor.Run()
	editor.Stop()
	--engine.PausePhysics()
	local vsize = GetViewportSize()
	
	local nsi = 300
	
	editor.node = panel.Create("editor_panel_node")
	editor.node:Dock(DOCK_RIGHT)
	editor.node:SetSize(nsi-2,vsize.y-2)
	editor.node:SetPos(vsize.x-nsi,0)
	editor.node:Show()
	
	editor.assets = panel.Create("editor_panel_assets")
	editor.assets:Dock(DOCK_BOTTOM)
	editor.assets:SetSize(vsize.x-2-nsi,nsi-2)
	editor.assets:SetPos(0-nsi,-vsize.y+nsi)
	editor.assets:Show()
	
	hook.Add("main.predraw","EDITOR",editor.Update)
	hook.Add("input.mousedown","EDITOR",editor.MouseDown)
	hook.Add("input.keydown","EDITOR",editor.KeyDown)
	--hook.Add("input.doubleclick","EDITOR",editor.DoubleClick)
	
	SetController("freecameracontroller")
	
	editor.Select(editor.selected)
end
function editor.Stop()
	if editor.node then editor.node:Close() editor.node = nil end
	if editor.assets then editor.assets:Close() editor.assets = nil end
	hook.Remove("main.predraw","EDITOR")
	hook.Remove("input.mousedown","EDITOR")
	hook.Remove("input.keydown","EDITOR")
	--hook.Remove("input.doubleclick","EDITOR")
	
	debug.ShapeDestroy(100)
	debug.ShapeDestroy(101)
	
	local gizmo = editor.gizmo 
	if gizmo then
		gizmo:Despawn()
		editor.gizmo = nil
	end  
	--engine.ResumePhysics()
end
function editor.Toggle()
	if editor.node then editor.Stop() 
	else editor.Run() end
end

function editor.Undo()
	MsgN("undo:",editor.undo:Undo())
end
function editor.Redo()
	MsgN("redo:",editor.undo:Redo()) 
end

function editor.MouseDown() 
	if not input.MouseIsHoveringAboveGui() then
		local LMB = input.leftMouseButton() 
		local RMB = input.rightMouseButton()
		local MMB = input.middleMouseButton()
		if not editor.mode then
			if LMB and not RMD and not MMB then
				local wcposgizmo = GetMousePhysTrace(GetCamera(),-CGROUP_NOCOLLIDE_PHYSICS)
				if wcposgizmo and wcposgizmo.Hit then
					if wcposgizmo.Entity then
						local OnClick = wcposgizmo.Entity.OnClick
						if OnClick then
							OnClick(wcposgizmo.Entity) 
						end 
					end
				else
					local wcpos = GetMousePhysTrace(GetCamera(),editor.selected)--,editor.selected)  
					if wcpos and wcpos.Hit then
						if wcpos.Entity then
							local OnClick = wcpos.Entity.OnClick
							if OnClick then 
								OnClick(wcpos.Entity)
							else
								--editor.Select( wcpos.Entity )
							end
						else
							--editor.Select( wcpos.Entity )
						end
					end 
				end 
				
			end
		end
	end
	editor.DoubleClick() 
end

function editor.DoubleClick() 
	if not input.MouseIsHoveringAboveGui() then
		local LMB = input.leftMouseButton() 
		local RMB = input.rightMouseButton()
		local MMB = input.middleMouseButton()
		local multiselect = input.KeyPressed(KEYS_CONTROLKEY)
		if not editor.mode then
			if LMB and not RMD and not MMB then
				local tbl = {}
				for k,v in pairs(editor.selected) do 
					tbl[#tbl+1] = k
				end
				local wcpos = false 
				if #tbl>0 and not multiselect then
					wcpos = GetMousePhysTrace(GetCamera(),tbl)
				else
					wcpos = GetMousePhysTrace(GetCamera())
				end
				--local wcpos = editor.curtrace 
				if wcpos and wcpos.Hit then
					---MsgN("hit!",wcpos.Entity)
					if wcpos.Entity then
						local OnClick = wcpos.Entity.OnClick
						if OnClick then
							--OnClick(wcpos.Entity)
						else
							editor.Select( wcpos.Entity,multiselect)
						end 
					else
						editor.Select( wcpos.Entity )
					end
				end 
			end
		end
	end
end
function editor.KeyDown() 
	if (input.KeyPressed(KEYS_C)) then  
		if editor.gizmo then
			editor.gizmo:ChangeMode()
		end
	elseif (input.KeyPressed(KEYS_DELETE)) then  
		for k,v in pairs(editor.selected) do 
			k:Despawn() 
		end
		editor.selected:Clear()
		editor.ClearSelectionModels() 
	elseif (input.KeyPressed(KEYS_Z)) then  
		--if (input.KeyPressed(KEYS_CONTROLKEY)) then  
			editor.Undo()
		--end
	elseif (input.KeyPressed(KEYS_Y)) then  
		--if (input.KeyPressed(KEYS_CONTROLKEY)) then  
			editor.Redo()
		--end
	end
end

--{ent,-group,ent,ent,-ent}

function editor.Update()
	if not input.MouseIsHoveringAboveGui() then
		local mode = editor.mode
		
		if(input.KeyPressed(KEYS_V)) and #editor.selected>0 then 
			local tbl = {}
			for k,v in pairs(editor.selected) do 
				tbl[#tbl+1] = k
			end
			tbl[#tbl+1] = CGROUP_NOCOLLIDE_PHYSICS
			local wcpos = GetMousePhysTrace(GetCamera(),tbl)--,editor.selected)
			local newPos = wcpos.Position
			if input.KeyPressed(KEYS_SHIFTKEY) then
				newPos = Vector(math.round(newPos.x,3),math.round(newPos.y,3),math.round(newPos.z,3))
			end
			
			for k,v in pairs(editor.selected) do
				k:SetPos(newPos)
			end
		end
		
		local wcposgizmo = GetMousePhysTrace(GetCamera(),-CGROUP_NOCOLLIDE_PHYSICS)
		if wcposgizmo and wcposgizmo.Hit and wcposgizmo.Entity then 
			if wcposgizmo.Entity.Highlight then
				editor.gizmo:Highlight(wcposgizmo.Entity)
			else
				if editor.gizmo then
					editor.gizmo:Highlight(nil)
				end
			end
		else
			local tbl = {}
			for k,v in pairs(editor.selected) do 
				tbl[#tbl+1] = k
			end
			local wcpos = GetMousePhysTrace(GetCamera(),tbl)--,editor.selected)
			editor.curtrace = wcpos
			--if wcpos and wcpos.Hit then
			--	if mode ~= "drag" and wcpos.Entity then
			--		if wcpos.Entity.Highlight then
			--			editor.gizmo:Highlight(wcpos.Entity)
			--		else
			--			--local m = wcpos.Entity.model
			--			--if m then
			--			--	local vpos,vsize = m:GetVisBox()
			--			--	debug.ShapeBoxCreate(100,wcpos.Entity,matrix.Translation(Vector(-0.5,-0.5,-0.5))*matrix.Scaling(vsize*2)*matrix.Translation(vpos))
			--			--else
			--			--	debug.ShapeBoxCreate(100,wcpos.Entity,matrix.Scaling(1)*matrix.Translation(Vector(-0.5,-0.5,-0.5))) 
			--			--end
			--			
			--			if editor.gizmo then
			--				editor.gizmo:Highlight(nil)
			--			end
			--		end
			--	end
			--end 
			if editor.gizmo then
				editor.gizmo:Highlight(nil)
			end
		end
		
		
	end
	local gizmo = editor.gizmo 
	if gizmo then
		gizmo:SetPos(gizmo.mnode:GetPos())
		local s = false
		for k,v in pairs(editor.selected) do s = k break end 
		if s and IsValidEnt(s) then
			local dist = s:GetPos():Distance(GetCamera():GetPos())*100
			gizmo:Rescale(dist)
		end
	end
end

function editor.Select(node,multiselect)
	MsgN("multiselect",multiselect)
	--multiselect = multiselect or false
	if not IsValidEnt(node) then
		editor.selected:Clear()
		return nil
	end
	
	if node then
		local gizmo = editor.gizmo or CreateGizmo(node:GetParent())
		gizmo:SetParent(node:GetParent())
		gizmo:SetPos(node:GetPos())
		gizmo:SetAng(node:GetMatrixAng())
		gizmo.mnode = node
		editor.gizmo = gizmo
	end
	if multiselect then 
		if editor.selected:Contains(node) then
			editor.selected:Remove(node)
			editor.RemoveSelectionModel(node) 
			editor.undo:Add(editor.action_deselect, editor.action_select, node)
		else
			editor.selected:Add(node)
			editor.AddSelectionModel(node) 
			editor.undo:Add(editor.action_select, editor.action_deselect, node)
		end
	else
		editor.selected:Clear()
		editor.selected:Add(node)
		editor.ClearSelectionModels() 
		editor.AddSelectionModel(node) 
		
		local tbl = {} for k,v in pairs(editor.selected) do tbl[#tbl+1] = k end
		editor.undo:Add(
			function(a,b) editor.action_deselect(a) for k,v in pairs(b) do MsgN(k,v) editor.action_select(v) end end, 
			function(a) editor.ClearSelectionModels() editor.action_select(a) end, node,tbl)
	end
	
	MsgN("sadsa")
	for k,v in pairs(editor.selected) do
		MsgN(k,v)
	end
	editor.node:SelectNode(node)
end

function editor.AddSelectionModel(ent) 
	local models = editor.smodels or {}
	local id = (models._count or 0)+1
	models[ent] = id
	models._count = id
	local m = ent.model
	if m then
		local vpos,vsize = m:GetVisBox()
		debug.ShapeBoxCreate(100+id,ent,matrix.Translation(Vector(-0.5,-0.5,-0.5))*matrix.Scaling(vsize*2)*matrix.Translation(vpos))
	else
		debug.ShapeBoxCreate(100+id,ent, matrix.Translation(Vector(-0.5,-0.5,-0.5))) 
	end
	editor.smodels = models
end
function editor.RemoveSelectionModel(ent) 
	local models = editor.smodels or {} 
	local id = models[ent]
	if id then
		debug.ShapeDestroy(100+id)
		models[ent] = nil 
	end  
end
function editor.ClearSelectionModels() 
	local models = editor.smodels or {}
	if models then
		for k,v in pairs(models) do
			debug.ShapeDestroy(100+v)
		end
		editor.smodels = {}
	end
end

function editor.Copy(ent)  
	local ne = ents.Create(ent:GetClass() )
	ne:SetParent(ent:GetParent())
	ne:SetSizepower(ent:GetSizepower())
	ne:SetSeed(252326+math.random(0,100000)) 
	ent:CopyFlags(ne)
	ent:CopyParameters(ne)
	
	if ne.SetCharacter then
		ne:SetCharacter(ent:GetParameter(VARTYPE_CHARACTER))
	end
	ne:SetName(ent:GetName())
	ne:SetPos(ent:GetPos()) 
	ne:CopyAng(ent) 
	ne:SetScale(ent:GetScale())  
	ne:Spawn()
	
	ent:CopyFlags(ne)
	ent:CopyParameters(ne)
	return ne
end
