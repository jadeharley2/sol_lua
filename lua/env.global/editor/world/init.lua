
include("gizmo.lua")


editor.undo = editor.undo or UndoManager(50)
editor.action_select = function(node) worldeditor.selected:Add(node) worldeditor:AddSelectionModel(node) end
editor.action_deselect = function(node) worldeditor.selected:Remove(node) worldeditor:RemoveSelectionModel(node) end
editor.action_move = function(from,to) node:SetPos(to) end 
editor.action_moveundo = function(from,to) node:SetPos(from) end 

if not editor.ent_worldeditor then
	local e = ents.Create() 
	e:SetSeed(55667722)
	e:SetName("ent_worldeditor")
    e:Spawn()
	e._events = e._events or {} 
	editor.ent_worldeditor = e 
end
ent_worldeditor = editor.ent_worldeditor

DeclareEnumValue("event","EDITOR_MOVE",				224980)
DeclareEnumValue("event","EDITOR_ROTATE",			224981)
DeclareEnumValue("event","EDITOR_SETANG",			2249812)
DeclareEnumValue("event","EDITOR_SCALE",			224982)

DeclareEnumValue("event","EDITOR_COPY",				224983)
DeclareEnumValue("event","EDITOR_REMOVE",			224984)

DeclareEnumValue("event","EDITOR_SPAWN_FORM",		224985)

DeclareEnumValue("event","EDITOR_WIRE",				225991)
DeclareEnumValue("event","EDITOR_UNWIRE",			225992)

local geventlist = editor.ent_worldeditor._events
geventlist[EVENT_EDITOR_SPAWN_FORM] = {networked = true, f = function(_,form,node,pos,seed)  
	MsgN("FORM CREATE "..form)
	 
--	--[[
	local e = forms.Create(form,node,{pos = pos, seed = seed})
	if IsValidEnt(e) then 
		if worldeditor.autochunknode then
			terrain_NodeSetChunk(e,true) 
		else
			e:AddTag(TAG_EDITORNODE)
		end
		local edt = e.editor
		if edt and edt.onSpawn then
			edt.onSpawn(e)
		end
	end
	return e
--	]]
end}
 
local _metaevents = debug.getregistry().Entity._metaevents 


_metaevents[EVENT_EDITOR_MOVE]   = {networked = true, f = function(self,pos)  self:SetPos(pos) end}
_metaevents[EVENT_EDITOR_ROTATE] = {networked = true, f = function(self,axis,ang)  self:TRotateAroundAxis(axis,ang) end}
_metaevents[EVENT_EDITOR_SETANG] = {networked = true, f = function(self,ang)  self:SetAng(ang) end}
_metaevents[EVENT_EDITOR_SCALE]  = {networked = true, f = function(self,sca)  self:SetScale(sca) end}

_metaevents[EVENT_EDITOR_COPY]  = {networked = true, f = function(self) 
	--[[
	local ne = ents.Create(self:GetClass() )
	local uid =  (GetFreeUID()) 
	ne:SetParent(self:GetParent())
	ne:SetSizepower(self:GetSizepower())
	ne:SetSeed(uid) 
	self:CopyTags(ne)
	self:CopyParameters(ne)
	
	if ne.SetCharacter then
		ne:SetCharacter(self:GetParameter(VARTYPE_CHARACTER))
	end
	ne:SetName(self:GetName())
	ne:SetPos(self:GetPos()) 
	ne:CopyAng(self) 
	ne:SetScale(self:GetScale())  
	ne:Create()
	ne:CopyAng(ne)  
	ne:SetPos(ne:GetPos())

	self:CopyTags(ne)
	self:CopyParameters(ne)
	ne:SetSeed(uid) 
	]]

	local data = ents.ToData(self)
	local ne = ents.FromData(data,self:GetParent()) 
	
	hook.Call("EditorNodeCopy",self,ne)

	editor.newent = ne
end}

_metaevents[EVENT_EDITOR_REMOVE]  = {networked = true, f = function(self)  
	self:Despawn() 
end}




function editor:Open()
	--MsgInfo("OPEN!") 
	self.selected = self.selected or Set() 
	self.mode = false
	self:Close()
	engine.PausePhysics()
	local vsize = GetViewportSize()
	
	local nsi = 430
	  
	
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
	
	self.gui = self.gui or panel.Create("world_editor")
	self.gui:Dock(DOCK_LEFT)
	self.gui:SetSize(vsize.x,vsize.y-20)--SetSize(vsize.x-2-nsi,nsi-2)
	self.gui:SetPos(0,-10)--SetPos(0-nsi,-vsize.y+nsi)
	GUI_MIDLAY:Add(self.gui)--:Show()
	
	
	render.DCISetEnabled(true)
	
	hook.Add(EVENT_GLOBAL_PREDRAW,"editor",function() self:Update() end)
	hook.Add("input.mousedown","editor",function() self:MouseDown() end )
	hook.Add("input.keydown","editor", function(key) self:KeyDown(key) end )
	--hook.Add("input.doubleclick","editor",editor.DoubleClick)
	
	SetController("editor")
	
	self:Select(self.selected)
	self.isopen = true
	hook.Call("editor.world.open")
end
function editor:Close()  
	render.DCISetEnabled(false)
	
	self.selected:Clear()
		
	if self.gui then 
		if not isfunction(self.gui) then 
			--self.gui:Close() 
			GUI_MIDLAY:Remove(self.gui)
		end
		--self.gui = nil 
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
	hook.Call("editor.world.close")
end
function editor:Toggle()
	if self.isopen then self:Close() 
	else self:Open() end 
end
function editor:Enabled() 
	return editor.node ~= nil 
end
function editor:IsOpen() 
	return self.isopen
end

function editor:Undo()
	MsgN("undo:",self.undo:Undo())
end
function editor:Redo()
	MsgN("redo:",self.undo:Redo()) 
end 

function editor:MouseDown()   
	
	 
	self:DoubleClick() 
end
function editor:SetGridMode(str)
	self.gridmode = str
	if self.gizmo then
		if str=="local" then 
			local s = next(self.selected)
			if s then
				self.gizmo:SetAng(s:GetMatrixAng())
			end
		else 
			self.gizmo:SetAng(matrix.Identity())
		end
	end
end 
function editor:GetGridMode()
	return self.gridmode  
end

function editor:SetPosSnap(value)
	if value==true then
		self.possnap = 0.01
	else
		self.possnap = value or false
	end
end
function editor:GetPosSnap()
	return self.possnap 
end
function editor:SetAngSnap(value)
	if value==true then
		self.angsnap = 45
	else
		self.angsnap = value or false
	end
end
function editor:GetAngSnap()
	return self.angsnap 
end

function editor:GetNodeUnderCursor(lp)
	local drw = false
	if lp then drw = render.DCIGetDrawable(lp) else drw = render.DCIGetDrawable() end
	if drw then
		return drw:GetNode()
	end
end
function editor:DoubleClick() 
	self.mousedowntime = nil
	local top = panel.GetTopElement() 
	if EDITOR_MODE == 'NODE' and ( not input.MouseIsHoveringAboveGui() or top.isviewport) then
		local LMB = input.leftMouseButton() 
		local RMB = input.rightMouseButton()
		local MMB = input.middleMouseButton()
		local multiselect = input.KeyPressed(KEYS_CONTROLKEY)
		if not self.mode then
			--MsgInfo("CLICL!")
			if LMB and not RMD and not MMB then 
				
				local vp = top 
				local vsr = ViewportMousePos(vp)

				local complete = false
				local under = self:GetNodeUnderCursor(vsr)
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
function editor:KeyDown(k)  
	if not input.GetKeyboardBusy() then
		if k==KEYS_TAB then
			self.tabtoggle = not (self.tabtoggle or false)
			if self.tabtoggle then
				--self.gui.vp:Close()
				self.gui:Show()
				self.gui:UpdateLayout()
			else
				self.gui:Close()
				--self.gui.vp:Show()
				--self.gui.vp:SetPos(0,0) 
				--self.gui.vp:SetSize(GetViewportSize())
				--self.gui.vp:Close()
			end
		end 
		if (input.KeyPressed(KEYS_F)) then  
			if self.gizmo then
				self.gizmo:ChangeMode()
			end
		elseif (input.KeyPressed(KEYS_DELETE)) then  
			for k,v in pairs(self.selected) do 
				--k:Despawn() 
				k:SendEvent(EVENT_EDITOR_REMOVE) 
			end
			self.selected:Clear()
			self:ClearSelectionModels()  
			hook.Call("editor_deselect");
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
end

--{ent,-group,ent,ent,-ent}
EDITOR_MODE = EDITOR_MODE or false
function editor:SetMode(mode)  
	EDITOR_MODE = mode
	MsgN("world editor mode:",mode)
	if mode~='NODE' then
		self:Select(nil) 
	end
end
function editor:GetMode()  
	return EDITOR_MODE
end

 
function editor:Update()
	local top = panel.GetTopElement()
	if EDITOR_MODE == 'NODE' and ( not input.MouseIsHoveringAboveGui()  or top.isviewport) then 
		self.dcicooldown = self.dcicooldown or 0
		if self.dcicooldown<0 then
			render.DCIRequestRedraw()
			self.dcicooldown = 10
		else
			self.dcicooldown = self.dcicooldown - 1
		end

		if self.mousedowntime and input.leftMouseButton() and CurTime()>self.mousedowntime+0.2 then
			self.mousedowntime = nil 
			self.selector:BeginSelection(self.selectortemp,1,self.mousedownpos)
		end
	
		local mode = self.mode
		local cam = GetCamera() 
		self.wtrace = GetCameraPhysTrace(cam,tbl)
		
		if self.wtrace then
			debug.ShapeBoxCreate(3030,self.wtrace.Node,
			matrix.Scaling(0.001) * matrix.Translation(self.wtrace.Position),Vector(1000,0,0))
		end

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
		
		
		local vp = top
		if vp then 

			local vsr = ViewportMousePos(vp) 

			local btrace = GetMousePhysTrace(cam,tbl,vsr)
		
			if btrace then
				debug.ShapeBoxCreate(3031,btrace.Node,
				matrix.Scaling(0.001) * matrix.Translation(btrace.Position),Vector(0,10,0))
				--MsgN(vsr,"->",btrace.Position,btrace.Hit)
			end
			 
			if self.gizmo and not self.gizmo.GIZMO_DRAG then 
				local under = self:GetNodeUnderCursor(vsr)
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
			local prnt =  s:GetParent()
			local gpr = gizmo.parts[1]:GetParent()
			if prnt and gpr then
				local gsz = gpr:GetSizepower()
				local psz = prnt:GetSizepower()
				local dist = s:GetPos():Distance(GetCamera():GetPos())*(gsz/psz)
				gizmo:Rescale(dist)  
			end
		else
		end
			--local sssd = ""
			--for k,v in pairs(self.selected) do sssd = sssd .. ", {".. tostring(k).."} " end
			--if math.floor(CurTime()*10)%10==0 then MsgInfo(sssd) end
	end
	for k,v in pairs(self.selected) do
		if k and k.editor then
			local ed = k.editor 
			if ed and ed.onUpdate then
				ed.onUpdate(k) 
			end
		end
	end 
end

SELECTION = {}

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
		SELECTION = self.selected:ToTable()
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
			gizmo:Despawn()
			self.gizmo = nil
		end  
		SELECTION = {}
		return nil
	end
	
	if node then
		if self.gizmo then
			self.gizmo:Despawn()
			self.gizmo = nil
		end
		local gizmo = self.gizmo or CreateGizmo(node:GetParent())
		gizmo:SetParent(node:GetParent())
		gizmo:SetPos(node:GetPos())
		if self.gridmode == "local" then 
			gizmo:SetAng(node:GetMatrixAng())
		else
			gizmo:SetAng(matrix.Identity())
		end
		gizmo.mnode = node
		self.gizmo = gizmo
	end
	if multiselect then 
		if self.selected:Contains(node) then
			self.selected:Remove(node)
			self:RemoveSelectionModel(node) 
			hook.Call("editor_deselect",node);
			--self.undo:Add(self.action_deselect, self.action_select, node)
		else
			self.selected:Add(node)
			self:AddSelectionModel(node) 
			hook.Call("editor_select",node);
			--self.undo:Add(self.action_select, self.action_deselect, node)
		end
	else
		local tbl = {} for k,v in pairs(self.selected) do 
			tbl[#tbl+1] = k 
			hook.Call("editor_deselect",k);
		end
		self.selected:Clear()
		self.selected:Add(node)
		self:ClearSelectionModels() 
		self:AddSelectionModel(node) 
		hook.Call("editor_select",node);
		
		--self.undo:Add(
		--	function(a,b) self.action_deselect(a) for k,v in pairs(b) do MsgN(k,v) self.action_select(v) end end, 
		--	function(a) self:ClearSelectionModels() self.action_select(a) end, node,tbl)
	end
	
	--MsgN("sadsa")
	--for k,v in pairs(self.selected) do
	--	MsgN(k,v)
	--end
	
	E_SELECTION = self.selected:ToTable()
	E_FS = E_SELECTION[1] -- first selected
end

function editor:AddSelectionModel(ent) 
	local models = self.smodels or {}
	local id = (models._count or 0)+1
	models[ent] = id
	models._count = id
	local m = ent.model
	if m and m.GetVisBox then
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
	ent:SendEvent(EVENT_EDITOR_COPY)
	return editor.newent 
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

console.AddCmd("ed_world_reset",function ()
	if worldeditor.isopen then worldeditor:Close() end
	worldeditor.gui = nil 
end)

W.wireeditor = W.wireeditor or {} 

function WireEditorUpdate()
	pnls = W.wireeditor.panels
	if pnls then
		local camera = GetCamera()
		local cparent = camera:GetParent()
		local cpos = camera:GetPos()
		local vsize = GetViewportSize()  
	 
		for k,v in pairs(pnls) do
			if IsValidEnt(v.node) then
				local wpos = cparent:GetLocalCoordinates( v.node)-cpos
				local spos = camera:Project(wpos)*Vector(vsize.x,vsize.y,1)
				if spos.z>1 then
					v:SetPos(Point(-10000,0))
				else
					v:SetPos(spos)
				end
				v:UpdateValues()
				--MsgN(v.node," : ",wpos," => ",spos)
			end
		end
	end
	
end
function WireEditorOpen() 
	WireEditorClose()
	local pnls = {}
	W.wireeditor.panels = pnls 
	local cpr = GetCamera():GetParent()
	if cpr == LocalPlayer() then cpr = cpr:GetParent() end
	for k,v in pairs(cpr:GetChildren()) do
		if v and IsValidEnt(v) and v.wireio then
			local btn = panel.Create("editor_wire")
			btn:SetSize(15,15)
			btn:SetNode( v)
			btn:Show()
			pnls[#pnls+1] = btn  
		end
	end 
	hook.Add(EVENT_GLOBAL_PREDRAW,"editor_wire",function() WireEditorUpdate() end)
end
function WireEditorClose()
	hook.Remove(EVENT_GLOBAL_PREDRAW,"editor_wire")
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
		--WireLink(outnode,outkey,innode,inkey) 
		ent_worldeditor:SendEvent(EVENT_EDITOR_WIRE,outnode,outkey,innode,inkey)
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
hook.Add("ed_wire_unlink","ed",function (n,k) 
	ent_worldeditor:SendEvent(EVENT_EDITOR_UNWIRE,n,k)
end)
console.AddCmd("ed_wire",WireEditorToggle)



geventlist[EVENT_EDITOR_UNWIRE] = {networked = true, f = function(_,n,k) 
	MsgN("dad",n,k) 
	WireUnLink(n,k)
end}
geventlist[EVENT_EDITOR_WIRE] = {networked = true, f = function(_,outnode,outkey,innode,inkey)  
	MsgN("asd",outnode,":",outkey," => ",innode,":",inkey)
	WireLink(outnode,outkey,innode,inkey) 
end}
