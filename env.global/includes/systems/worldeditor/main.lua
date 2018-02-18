
editor = editor or {} 
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
	hook.Add("input.doubleclick","EDITOR",editor.DoubleClick)
	
	SetController("freecameracontroller")
	
	editor.Select(editor.selected)
end
function editor.Stop()
	if editor.node then editor.node:Close() editor.node = nil end
	if editor.assets then editor.assets:Close() editor.assets = nil end
	hook.Remove("main.predraw","EDITOR")
	hook.Remove("input.mousedown","EDITOR")
	hook.Remove("input.keydown","EDITOR")
	hook.Remove("input.doubleclick","EDITOR")
	
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
end

function editor.DoubleClick() 
	if not input.MouseIsHoveringAboveGui() then
		local LMB = input.leftMouseButton() 
		local RMB = input.rightMouseButton()
		local MMB = input.middleMouseButton()
		if not editor.mode then
			if LMB and not RMD and not MMB then
				local wcpos = GetMousePhysTrace(GetCamera(),{editor.selected})
				--local wcpos = editor.curtrace 
				if wcpos and wcpos.Hit then
					if wcpos.Entity then
						local OnClick = wcpos.Entity.OnClick
						if OnClick then
							--OnClick(wcpos.Entity)
						else
							editor.Select( wcpos.Entity )
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
	end
end

--{ent,-group,ent,ent,-ent}

function editor.Update()
	if not input.MouseIsHoveringAboveGui() then
		local mode = editor.mode
		
		if(input.KeyPressed(KEYS_V)) and editor.selected then 
			local wcpos = GetMousePhysTrace(GetCamera(),{editor.selected,CGROUP_NOCOLLIDE_PHYSICS})--,editor.selected)
			local newPos = wcpos.Position
			if input.KeyPressed(KEYS_SHIFTKEY) then
				newPos = Vector(math.round(newPos.x,3),math.round(newPos.y,3),math.round(newPos.z,3))
			end
			editor.selected:SetPos(newPos)
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
			local wcpos = GetMousePhysTrace(GetCamera(),editor.selected)--,editor.selected)
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
		end
		
		
	end
	local gizmo = editor.gizmo 
	if gizmo then
		gizmo:SetPos(gizmo.mnode:GetPos())
		local s = editor.selected
		if s then
			local dist = s:GetPos():Distance(GetCamera():GetPos())*100
			gizmo:Rescale(dist)
		end
	end
end

function editor.Select(node)
	if not IsValidEnt(node) then
		editor.selected = nil 
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
	editor.selected = node
	editor.node:SelectNode(node)
	
	--debug.ShapeBoxCreate(101,wcpos.Entity,matrix.Translation(Vector(-0.5,-0.5,-0.5))*matrix.Scaling(0.9))
	
	local m = node.model
	--if m then
	--	local vpos,vsize = m:GetVisBox()
	--	debug.ShapeBoxCreate(101,node,matrix.Translation(Vector(-0.5,-0.5,-0.5))*matrix.Scaling(vsize*1.9)*matrix.Translation(vpos))
	--else
	--	debug.ShapeBoxCreate(101,node,matrix.Scaling(0.9)*matrix.Translation(Vector(-0.5,-0.5,-0.5))) 
	--end
	if m then
		local vpos,vsize = m:GetVisBox()
		debug.ShapeBoxCreate(101,node,matrix.Translation(Vector(-0.5,-0.5,-0.5))*matrix.Scaling(vsize*2)*matrix.Translation(vpos))
	else
		debug.ShapeBoxCreate(101,node, matrix.Translation(Vector(-0.5,-0.5,-0.5))) 
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
