
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
	
	SetController("freecameracontroller")
	
	editor.Select(editor.selected)
end
function editor.Stop()
	if editor.node then editor.node:Close() editor.node = nil end
	if editor.assets then editor.assets:Close() editor.assets = nil end
	hook.Remove("main.predraw","EDITOR")
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
				local wcpos = editor.curtrace 
				if wcpos and wcpos.Hit then
					if wcpos.Entity then
						local OnClick = wcpos.Entity.OnClick
						if OnClick then
							OnClick(wcpos.Entity)
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

function editor.Update()
	if not input.MouseIsHoveringAboveGui() then
	 
		local wcpos = GetMousePhysTrace(GetCamera(),editor.selected)--,editor.selected)
		editor.curtrace = wcpos
		
		if wcpos and wcpos.Hit then
			if(input.KeyPressed(KEYS_V)) and editor.selected then 
				local newPos = wcpos.Position
				if input.KeyPressed(KEYS_SHIFTKEY) then
					newPos = Vector(math.round(newPos.x,3),math.round(newPos.y,3),math.round(newPos.z,3))
				end
				editor.selected:SetPos(newPos)
			end
			
			local m = wcpos.Entity.model
			if m then
				local vpos,vsize = m:GetVisBox()
				debug.ShapeBoxCreate(100,wcpos.Entity,matrix.Translation(Vector(-0.5,-0.5,-0.5))*matrix.Scaling(vsize*2)*matrix.Translation(vpos))
			else
				debug.ShapeBoxCreate(100,wcpos.Entity,matrix.Scaling(1)*matrix.Translation(Vector(-0.5,-0.5,-0.5))) 
			end
		end 
	end
	local gizmo = editor.gizmo 
	if gizmo then
		gizmo:SetPos(gizmo.mnode:GetPos())
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
	if m then
		local vpos,vsize = m:GetVisBox()
		debug.ShapeBoxCreate(101,node,matrix.Translation(Vector(-0.5,-0.5,-0.5))*matrix.Scaling(vsize*1.9)*matrix.Translation(vpos))
	else
		debug.ShapeBoxCreate(101,node,matrix.Scaling(0.9)*matrix.Translation(Vector(-0.5,-0.5,-0.5))) 
	end
end
 

