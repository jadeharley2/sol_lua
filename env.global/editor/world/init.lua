
include("gizmo.lua")


editor.undo = editor.undo or UndoManager(50)
editor.action_select = function(node) worldeditor.selected:Add(node) worldeditor:AddSelectionModel(node) end
editor.action_deselect = function(node) worldeditor.selected:Remove(node) worldeditor:RemoveSelectionModel(node) end
editor.action_move = function(from,to) node:SetPos(to) end 
editor.action_moveundo = function(from,to) node:SetPos(from) end 

function editor:Open()
	--MsgInfo("OPEN!") 
	self.selected = self.selected or Set() 
	self.mode = false
	self:Close()
	engine.PausePhysics()
	local vsize = GetViewportSize()
	
	local nsi = 430
	 
	--self.node = panel.Create("editor_panel_node")
	--self.node:Dock(DOCK_RIGHT)
	--self.node:SetSize(nsi-2,vsize.y-2)
	--self.node:SetPos(vsize.x-nsi,0)
	--self.node:Show()
	
	self.selectortemp = panel.Create()
	self.selectortemp:SetSize(vsize.x,vsize.y)
	self.selectortemp:SetCanRaiseMouseEvents(false)
	self.selectortemp:SetAlpha(0)
	self.selectortemp:Show()
	
	self.selector = panel.Selector() 
	self.selector.onupdate = function(s,p1,p2)
		local sel = self.selected
		self:Select() 
		local rtd = {}
		for k,v in pairs(render.GetDrawablesByScreenBox(self.mousedownpos or p1,p2)) do 
			if v then
				local vn = v:GetNode()
				if vn and IsValidEnt(vn) then
					if not vn.root then  
						rtd[#rtd+1] = vn
					end
				end
			end
		end
		if #rtd>0 then
			self:SelectMany( rtd) 
		end
	end
	
	self.assets = panel.Create("editor_panel_assets")
	self.assets:Dock(DOCK_RIGHT)
	self.assets:SetSize(nsi-2,vsize.y-2)--SetSize(vsize.x-2-nsi,nsi-2)
	self.assets:SetPos(vsize.x-nsi,0)--SetPos(0-nsi,-vsize.y+nsi)
	self.assets:Show()
	self.node = self.assets.pnode
	
	render.DCISetEnabled(true)
	
	hook.Add(EVENT_GLOBAL_PREDRAW,"editor",function() self:Update() end)
	hook.Add("input.mousedown","editor",function() self:MouseDown() end )
	hook.Add("input.keydown","editor", function() self:KeyDown() end )
	--hook.Add("input.doubleclick","editor",editor.DoubleClick)
	
	SetController("freecamera")
	
	self:Select(self.selected)
	self.isopen = true
end
function editor:Close()  
	render.DCISetEnabled(false)
	
		self.selected:Clear()
	--if self.node then self.node:Close() self.node = nil end
	if self.assets then 
		if not isfunction(self.assets) then self.assets:Close() end
		self.assets = nil 
	end
	if self.selectortemp then 
		if not isfunction(self.selectortemp) then self.selectortemp:Close() end
		self.selectortemp = nil 
	end 
	hook.Remove(EVENT_GLOBAL_PREDRAW,"editor")
	hook.Remove("input.mousedown","editor")
	hook.Remove("input.keydown","editor")
	--hook.Remove("input.doubleclick","editor")
	
	debug.ShapeDestroy(100)
	debug.ShapeDestroy(101)
	
	local gizmo = self.gizmo 
	if gizmo then
		gizmo:Despawn()
		self.gizmo = nil
	end  
	engine.ResumePhysics()
	self.isopen = false
end
function editor:Toggle()
	if self.isopen then self:Close() 
	else self:Open() end
end
function editor:Enabled() 
	return editor.node ~= nil 
end

function editor:Undo()
	MsgN("undo:",self.undo:Undo())
end
function editor:Redo()
	MsgN("redo:",self.undo:Redo()) 
end

function editor:MouseDown()  
	--if not input.MouseIsHoveringAboveGui() then
	--	local LMB = input.leftMouseButton() 
	--	local RMB = input.rightMouseButton()
	--	local MMB = input.middleMouseButton()
	--	if not self.mode then
	--		if LMB and not RMD and not MMB then
	--			local wcposgizmo = GetMousePhysTrace(GetCamera(),-CGROUP_NOCOLLIDE_PHYSICS)
	--			if wcposgizmo and wcposgizmo.Hit then
	--				if wcposgizmo.Entity then
	--					--MsgInfo("das?")
	--					local OnClick = wcposgizmo.Entity.OnClick
	--					if OnClick then
	--						OnClick(wcposgizmo.Entity) 
	--					end 
	--				end
	--			else
	--				local wcpos = GetMousePhysTrace(GetCamera(),self.selected)--,self.selected)  
	--				if wcpos and wcpos.Hit then
	--					if wcpos.Entity then
	--						local OnClick = wcpos.Entity.OnClick
	--						if OnClick then 
	--							OnClick(wcpos.Entity)
	--						else
	--							--self:Select( wcpos.Entity )
	--						end
	--					else
	--						--self:Select( wcpos.Entity )
	--					end
	--				end 
	--			end 
	--			
	--		end
	--	end
	--end
	
	
	self:DoubleClick() 
end
function editor:GetNodeUnderCursor()
	local drw = render.DCIGetDrawable()
	if drw then
		return drw:GetNode()
	end
end
function editor:DoubleClick() 
	self.mousedowntime = nil
	if not input.MouseIsHoveringAboveGui() then
		local LMB = input.leftMouseButton() 
		local RMB = input.rightMouseButton()
		local MMB = input.middleMouseButton()
		local multiselect = input.KeyPressed(KEYS_CONTROLKEY)
		if not self.mode then
			--MsgInfo("CLICL!")
			if LMB and not RMD and not MMB then
				----  local tbl = {}
				----  for k,v in pairs(self.selected) do 
				----  	tbl[#tbl+1] = k
				----  end
				----  local wcpos = false 
				----  if #tbl>0 and not multiselect then
				----  	wcpos = GetMousePhysTrace(GetCamera(),tbl)
				----  else
				----  	wcpos = GetMousePhysTrace(GetCamera())
				----  end
				----  --local wcpos = self.curtrace 
				----  if wcpos and wcpos.Hit then
				----  	---MsgN("hit!",wcpos.Entity)
				----  	if wcpos.Entity then
				----  		local OnClick = wcpos.Entity.OnClick
				----  		if OnClick then
				----  			--OnClick(wcpos.Entity)
				----  		else
				----  			self:Select( wcpos.Entity,multiselect)
				----  		end 
				----  	else
				----  		self:Select( wcpos.Entity )
				----  	end
				----  end 
				
				local complete = false
				local under = self:GetNodeUnderCursor()
				if under and IsValidEnt(under) then
					if under.root then
						complete = true
						under:OnClick()
					else
						self:Select( under,multiselect)  
					end
				end
				if not complete then
					self.mousedowntime = CurTime()
					self.mousedownpos = self.selectortemp:GetLocalCursorPos()
				end
				--self.selector:BeginSelection(self.selectortemp,1)
			end
		end
	end 
end
function editor:KeyDown()  
	if (input.KeyPressed(KEYS_F)) then  
		if self.gizmo then
			self.gizmo:ChangeMode()
		end
	elseif (input.KeyPressed(KEYS_DELETE)) then  
		for k,v in pairs(self.selected) do 
			k:Despawn() 
		end
		self.selected:Clear()
		self:ClearSelectionModels()  
		local gizmo = self.gizmo 
		if gizmo then
			gizmo:Despawn()
			self.gizmo = nil
		end  
	elseif (input.KeyPressed(KEYS_Z)) then  
		if (input.KeyPressed(KEYS_CONTROLKEY)) then  
			self:Undo()
		end
	elseif (input.KeyPressed(KEYS_Y)) then  
		if (input.KeyPressed(KEYS_CONTROLKEY)) then  
			self:Redo()
		end
	end
end

--{ent,-group,ent,ent,-ent}

function editor:Update()
	render.DCIRequestRedraw()
	if not input.MouseIsHoveringAboveGui() then
	 
		if self.mousedowntime and input.leftMouseButton() and CurTime()>self.mousedowntime+0.2 then
			self.mousedowntime = nil 
			self.selector:BeginSelection(self.selectortemp,1,self.mousedownpos)
		end
	
		local mode = self.mode
		local cam = GetCamera()
		self.wtrace = GetCameraPhysTrace(cam,tbl)
		
		if(input.KeyPressed(KEYS_V)) and #self.selected>0 then 
			local tbl = {}
			for k,v in pairs(self.selected) do 
				tbl[#tbl+1] = k
			end
			tbl[#tbl+1] = CGROUP_NOCOLLIDE_PHYSICS
			local wcpos = GetMousePhysTrace(cam,tbl)--,self.selected)
			local newPos = wcpos.Position
			if input.KeyPressed(KEYS_SHIFTKEY) then
				newPos = Vector(math.round(newPos.x,3),math.round(newPos.y,3),math.round(newPos.z,3))
			end
			
			for k,v in pairs(self.selected) do
				k:SetPos(newPos)
			end
		end
		
		
		if self.gizmo and not self.gizmo.GIZMO_DRAG then 
			local under = self:GetNodeUnderCursor()
			local hlt = true
			if under and IsValidEnt(under) then
				if under.root then
					under.root:Highlight(under)
					hlt = false
				end
			end
			if hlt then
					self.gizmo:Highlight(nil) 
			end
		end
		---local wcposgizmo = GetMousePhysTrace(cam,-CGROUP_NOCOLLIDE_PHYSICS)
		---if wcposgizmo and wcposgizmo.Hit and wcposgizmo.Entity then 
		---	if wcposgizmo.Entity.Highlight then
		---		self.gizmo:Highlight(wcposgizmo.Entity)
		---	else
		---		if self.gizmo then
		---			self.gizmo:Highlight(nil)
		---		end
		---	end
		---else
		---	local tbl = {}
		---	for k,v in pairs(self.selected) do 
		---		tbl[#tbl+1] = k
		---	end
		---	local wcpos = GetMousePhysTrace(cam,tbl)--,self.selected)
		---	self.curtrace = wcpos
		---	--if wcpos and wcpos.Hit then
		---	--	if mode ~= "drag" and wcpos.Entity then
		---	--		if wcpos.Entity.Highlight then
		---	--			self.gizmo:Highlight(wcpos.Entity)
		---	--		else
		---	--			--local m = wcpos.Entity.model
		---	--			--if m then
		---	--			--	local vpos,vsize = m:GetVisBox()
		---	--			--	debug.ShapeBoxCreate(100,wcpos.Entity,matrix.Translation(Vector(-0.5,-0.5,-0.5))*matrix.Scaling(vsize*2)*matrix.Translation(vpos))
		---	--			--else
		---	--			--	debug.ShapeBoxCreate(100,wcpos.Entity,matrix.Scaling(1)*matrix.Translation(Vector(-0.5,-0.5,-0.5))) 
		---	--			--end
		---	--			
		---	--			if self.gizmo then
		---	--				self.gizmo:Highlight(nil)
		---	--			end
		---	--		end
		---	--	end
		---	--end 
		---	if self.gizmo then
		---		self.gizmo:Highlight(nil)
		---	end
		---end
		
		
	end
	local gizmo = self.gizmo 
	if gizmo then
		if gizmo.mnode and IsValidEnt(gizmo.mnode) then
			gizmo:SetPos(gizmo.mnode:GetPos())
		end
		local s = false
		for k,v in pairs(self.selected) do s = k break end 
		if s and IsValidEnt(s) and gizmo.parts[1] then
			local gsz = gizmo.parts[1]:GetParent():GetSizepower()
			local psz = s:GetParent():GetSizepower()
			local dist = s:GetPos():Distance(GetCamera():GetPos())*(gsz/psz)
			gizmo:Rescale(dist)  
		else
		end
			--local sssd = ""
			--for k,v in pairs(self.selected) do sssd = sssd .. ", {".. tostring(k).."} " end
			--if math.floor(CurTime()*10)%10==0 then MsgInfo(sssd) end
	end
end

function editor:SelectMany(nodes)
	if istable(nodes) then
		local selected = self.selected
		local last = false
		local medpos = Vector(0,0,0)
		local ncount = 0
		for k,v in pairs(nodes) do
			if not selected:Contains(v) then 
				self.selected:Add(v)
				self:AddSelectionModel(v)  
				medpos = medpos + v:GetPos()
				last = v
				ncount = ncount + 1
			end
		end
		if last then
			local gizmo = self.gizmo or CreateGizmo(last:GetParent())
			gizmo:SetParent(last:GetParent())
			gizmo:SetPos(medpos/ncount) 
			gizmo:SetAng(last:GetMatrixAng())
			gizmo.mnode = last
			self.gizmo = gizmo 
		end
	end
end
function editor:Select(node,multiselect)
	--MsgInfo("select: "..tostring(node))
	--MsgN("multiselect",multiselect)
	--MsgInfo("Select: "..tostring(node))
	--multiselect = multiselect or false
	if not IsValidEnt(node) then
		self:ClearSelectionModels() 
		self.selected:Clear()
		local gizmo = self.gizmo
		if gizmo then
			gizmo:SetPos(Vector(0,0,99999999999))
		end
		return nil
	end
	
	if node then
		local gizmo = self.gizmo or CreateGizmo(node:GetParent())
		gizmo:SetParent(node:GetParent())
		gizmo:SetPos(node:GetPos())
		gizmo:SetAng(node:GetMatrixAng())
		gizmo.mnode = node
		self.gizmo = gizmo
	end
	if multiselect then 
		if self.selected:Contains(node) then
			self.selected:Remove(node)
			self:RemoveSelectionModel(node) 
			--self.undo:Add(self.action_deselect, self.action_select, node)
		else
			self.selected:Add(node)
			self:AddSelectionModel(node) 
			--self.undo:Add(self.action_select, self.action_deselect, node)
		end
	else
		local tbl = {} for k,v in pairs(self.selected) do tbl[#tbl+1] = k end
		self.selected:Clear()
		self.selected:Add(node)
		self:ClearSelectionModels() 
		self:AddSelectionModel(node) 
		
		--self.undo:Add(
		--	function(a,b) self.action_deselect(a) for k,v in pairs(b) do MsgN(k,v) self.action_select(v) end end, 
		--	function(a) self:ClearSelectionModels() self.action_select(a) end, node,tbl)
	end
	
	--MsgN("sadsa")
	--for k,v in pairs(self.selected) do
	--	MsgN(k,v)
	--end
	self.node:SelectNode(node)
end

function editor:AddSelectionModel(ent) 
	local models = self.smodels or {}
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
	self.smodels = models
end
function editor:RemoveSelectionModel(ent) 
	local models = self.smodels or {} 
	local id = models[ent]
	if id then
		debug.ShapeDestroy(100+id)
		models[ent] = nil 
	end  
end
function editor:ClearSelectionModels() 
	local models = self.smodels or {}
	if models then
		for k,v in pairs(models) do
			debug.ShapeDestroy(100+v)
		end
		self.smodels = {}
	end
end
 
function editor:Copy(ent)  
	local ne = ents.Create(ent:GetClass() )
	local uid =  (GetFreeUID()) 
	ne:SetParent(ent:GetParent())
	ne:SetSizepower(ent:GetSizepower())
	ne:SetSeed(uid) 
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
	ne:SetSeed(uid) 
	return ne
end

local W = editor
W.worldeditor = W.worldeditor or false

worldeditor = worldeditor or false

function WorldeditorOpen()
	W.worldeditor = W.worldeditor or Editor("world")
	worldeditor = W.worldeditor
	W.worldeditor:Open()
end
function WorldeditorToggle()
	W.worldeditor = W.worldeditor or Editor("world")
	worldeditor = W.worldeditor
	W.worldeditor:Toggle()
end
console.AddCmd("ed_world",WorldeditorToggle)

W.wireeditor = W.wireeditor or {} 

function WireEditorUpdate()
	pnls = W.wireeditor.panels
	if pnls then
		local camera = GetCamera()
		local cparent = camera:GetParent()
		local cpos = camera:GetPos()
		local vsize = GetViewportSize()  
	 
		for k,v in pairs(pnls) do
			local wpos = cparent:GetLocalCoordinates( v.node)-cpos
			local spos = camera:Project(wpos)*Vector(vsize.x,vsize.y,1)
			if spos.z>1 then
				v:SetPos(Point(-10000,0))
			else
				v:SetPos(spos)
			end
			--MsgN(v.node," : ",wpos," => ",spos)
		end
	end
	
end
function WireEditorOpen() 
	WireEditorClose()
	local pnls = {}
	W.wireeditor.panels = pnls
	MsgN("open!")
	local cpr = GetCamera():GetParent()
	if cpr == LocalPlayer() then cpr = cpr:GetParent() end
	for k,v in pairs(cpr:GetChildren()) do
		if v and IsValidEnt(v) and v.wireio then
			local btn = panel.Create("editor_wire")
			btn:SetSize(15,15)
			btn:SetNode( v)
			btn:Show()
			pnls[#pnls+1] = btn 
			MsgN("asd!")
		end
	end 
	hook.Add("main.predraw","editor_wire",function() WireEditorUpdate() end)
end
function WireEditorClose()
	hook.Remove("main.predraw","editor_wire")
	pnls = W.wireeditor.panels
	if pnls then
		for k,v in pairs(pnls) do
			v:Close()
		end
		W.wireeditor.panels = nil
	end
end

function WireEditorToggle()
	if W.wireeditor.panels then
		WireEditorClose()
	else
		WireEditorOpen()
	end
end
function WireEditorSetOutput(outnode,outkey)  
	local innode = W.wireeditor.node
	local inkey = W.wireeditor.output
	if outnode and outkey and innode and inkey then
		MsgN(outnode,":",outkey," => ",innode,":",inkey)
		WireLink(outnode,outkey,innode,inkey) 
	end
	
	pnls = W.wireeditor.panels
	if pnls then
		for k,v in pairs(pnls) do
			v:OnSetOutput()
		end
	end
end
function WireEditorSetInput(innode,inkey) 
	W.wireeditor.node = innode
	W.wireeditor.output = inkey
	
	pnls = W.wireeditor.panels
	if pnls then
		for k,v in pairs(pnls) do
			v:OnSetOutput(innode,inkey)
		end
	end
end
hook.Add("ed_wire_setout","ed",WireEditorSetOutput)
hook.Add("ed_wire_setin","ed",WireEditorSetInput)
console.AddCmd("ed_wire",WireEditorToggle)
