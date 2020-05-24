
panel._localpanels = panel._localpanels or {}

function panel.Toggle(name,type)
	local lp = panel._localpanels
	local pn = lp[name]
	if pn then
		pn:Close()
		lp[name] = nil
	else
		pn = panel.Create(type) 
		pn:Show()
		lp[name] = pn
	end
end 

function panel.IsUpMbutton(id) 
	if id == 2 then
		return not input.rightMouseButton()
	elseif id == 3 then
		return not input.middleMouseButton() 
	end
	 -- 0 and 1
	return not input.leftMouseButton()
end


function panel.Contains(posA,sizeA,posB,sizeB)
	
	local leftIN = posA.x-sizeA.x > posB.x-sizeB.x
	local rightIN = posA.x+sizeA.x < posB.x+sizeB.x 
	local topIN = posA.y-sizeA.y > posB.y-sizeB.y
	local bottomIN = posA.y+sizeA.y < posB.y+sizeB.y
	
	if leftIN and rightIN and topIN and bottomIN then
		return true 
	end
	return false
end

function panel.callrecursively(pn,funcname,...) 
	local fn = pn[funcname]
	if fn then 
		return fn(pn,...) 
	else
		local par = pn:GetParent()
		if par then
			return panel.callrecursively(par,funcname,...) 
		end
	end
end
function panel.getwith(pn,funcname) 
	if pn then
		local fn = pn[funcname] 
		if fn then 
			return pn
		else
			local par = pn:GetParent()
			if par then
				return panel.getwith(par,funcname) 
			end
		end
	end
end
function panel.call(pn,funcname,...) 
	local fn = pn[funcname]
	if fn then 
		return fn(pn,...)  
	end
end

--DRAG_DROP
 
	panel.current_drag = false
	panel.current_drag_pointpos = Point(0,0)
	panel.current_drag_movepos = Point(0,0)
	panel.current_drag_mbuttonid = 0
	panel.current_drag_on_drop = false
	panel.current_drag_over = false

	panel.current_drag_pointpos = 10
	panel.current_drag_args = false
	panel.current_drag_ontrue = false

	panel.current_scale = false

	function panel.start_drag_on_shift(node,mbuttonid,ontrue,...)
		if not panel.current_drag and not MOUSE_LOCKED then 
			--MsgN("drag test start at ",node,...)
			panel.current_drag = node 
			panel.current_drag_mbuttonid = mbuttonid or 0
			panel.current_drag_pointpos = input.getMousePosition() 
			panel.current_drag_args = {mbuttonid,...}
			panel.current_drag_ontrue = ontrue
			LockMouse()
			hook.Add(EVENT_GLOBAL_PREDRAW, "gui.drag.check", panel.function_drag_check)
		end
	end

	function panel.function_drag_check()
		local node = panel.current_drag 
		if node then   
			local isup =  panel.IsUpMbutton(panel.current_drag_mbuttonid) 
			if isup then 
				--MsgN("drag FALSE")
				panel.current_drag = false
				UnlockMouse()
				hook.Remove(EVENT_GLOBAL_PREDRAW, "gui.drag.check")  
			else
				local startpos = panel.current_drag_pointpos
				local cpos = input.getMousePosition() 
				if(startpos:Distance(cpos)>5) then
					--MsgN("drag TRUE")
					panel.current_drag = false
					UnlockMouse()
					hook.Remove(EVENT_GLOBAL_PREDRAW, "gui.drag.check")  
					
					local ontrue = panel.current_drag_ontrue
					if ontrue then
						if ontrue(node) then
							panel.start_drag(node,unpack(panel.current_drag_args))
						end
					else 
						panel.start_drag(node,unpack(panel.current_drag_args))
					end
				end 
			end 
		end
	end

	function panel.start_drag(node,mbuttonid,on_drop,snap)
		if not panel.current_drag and not MOUSE_LOCKED then
		
			panel.current_drag_snap = snap or false
			panel.current_drag_mbuttonid = mbuttonid or 0
			panel.current_drag_pointpos = input.getMousePosition() 
			panel.current_drag_on_drop = on_drop
			panel.current_drag_over = false
			
			if istable(node) then 
				local tab = {}
				for k,v in pairs(node) do
					tab[v] = v:GetPos()
				end
				panel.current_drag = tab
				LockMouse()
				hook.Add(EVENT_GLOBAL_PREDRAW, "gui.drag", panel.function_drag_multiple)
			else
				panel.current_drag_movepos = node:GetPos()
				panel.current_drag = node 
				LockMouse()
				hook.Add(EVENT_GLOBAL_PREDRAW, "gui.drag", panel.function_drag)
			end
			return true
		end
	end

	function panel.function_drag()
		local node = panel.current_drag
		local dragover = panel.current_drag_over
		if node then   
			local nparent = node:GetParent() 
			local scalemul = 1
			if nparent then scalemul = nparent:GetTotalScaleMul() end
			
			local mousePos = input.getMousePosition() 
			local mouseDiff = mousePos - panel.current_drag_pointpos   
			local mouseDiffF = Point(mouseDiff.x*2/scalemul,mouseDiff.y*-2/scalemul)
			local newPos = panel.current_drag_movepos + mouseDiffF
			
			local snap = panel.current_drag_snap
			if snap then
				newPos = Point( math.snap( newPos.x,snap), math.snap( newPos.y,snap)) 
			end
			
			node:SetPos(newPos)
			
			local isup =  panel.IsUpMbutton(panel.current_drag_mbuttonid) 
			
			
			
			
			local top = panel.getwith(panel.GetTopElement(),"DragDrop")
			
			if panel.current_drag_on_drop then 
				
				if top then
					local DragHover = top.DragHover
					if DragHover then DragHover(top,node) end 
				end 
				if dragover ~= top then
					MsgN("top",top) 
					if dragover then 
						panel.call(dragover,"DragExit",node)
					end
					if top then 
						panel.call(top,"DragEnter",node)
					end 
					panel.current_drag_over = top
				end
			end
			
			
			if isup then
				panel.current_drag = false
				UnlockMouse()
				hook.Remove(EVENT_GLOBAL_PREDRAW, "gui.drag")
				
				if panel.current_drag_on_drop then 
					if top then
						result = panel.call(top,"DragDrop",node) 
					end
					
					panel.call(node,"OnDropped",top)
					
					if isfunction(panel.current_drag_on_drop) then
						panel.current_drag_on_drop(node)
					end 
					
					if dragover then
						panel.call(dragover,"DragExit",node) 
					end
				end
			end
		end
	end

	function panel.function_drag_multiple()
		local tab = panel.current_drag
		if tab then   
			local mousePos = input.getMousePosition() 
			local mouseDiff = mousePos - panel.current_drag_pointpos   
			for node,pos in pairs(tab) do
				local par = node:GetParent()
				local scalemul = 1
				if par then scalemul = par:GetTotalScaleMul() end
				local mouseDiffF = Point(mouseDiff.x*2/scalemul,mouseDiff.y*-2/scalemul)
				local newPos = pos + mouseDiffF
				
				
				local snap = panel.current_drag_snap
				if snap then
					newPos = Point( math.snap( newPos.x,snap), math.snap( newPos.y,snap))
				end
				
				node:SetPos(newPos)
			end
			
			local isup =  panel.IsUpMbutton(panel.current_drag_mbuttonid) 
			
			if isup then
				panel.current_drag = false
				UnlockMouse()
				hook.Remove(EVENT_GLOBAL_PREDRAW, "gui.drag")
				if panel.current_drag_on_drop and isfunction(panel.current_drag_on_drop) then
					panel.current_drag_on_drop(node)
				end
			end
		end
	end
--END

--RESIZE

	
	panel.current_resize = false
	panel.current_resize_pointpos = false
	panel.current_resize_size = false
	panel.current_resize_pos = false
	panel.current_resize_dir = false
	panel.current_resize_mbuttonid = 0
	panel.current_resize_on_drop = false

	function panel.cursor_resize(dir)
		local dx = dir.x
		local dy = dir.y
		if dx == 0 then
			panel.SetCursor(4)
		elseif dx>0 then
			if dy==0 then panel.SetCursor(5)
			elseif dy<0 then panel.SetCursor(6)
			else panel.SetCursor(7)
			end
		else
			if dy==0 then panel.SetCursor(5)
			elseif dy<0 then panel.SetCursor(7)
			else panel.SetCursor(6)
			end
		end
	end

	function panel.start_resize(node,mbuttonid,dir,ondrop,snap)
		if not panel.current_resize then 
			panel.current_resize_size = node:GetSize()
			panel.current_resize_pos = node:GetPos()
			panel.current_resize_pointpos =  input.getMousePosition()
			panel.current_resize_dir = dir
			panel.current_resize_mbuttonid = mbuttonid
			panel.current_resize = node
			panel.current_resize_on_drop = ondrop
			panel.current_resize_snap = snap or false
			
			panel.cursor_resize(dir)
			
			hook.Add(EVENT_GLOBAL_PREDRAW, "gui.panel.resize", panel.function_resize) 
			return true
		end
	end 


	function panel.function_resize()
		local node = panel.current_resize
		if node then 
			local nparent = node:GetParent() 
			local scalemul = 1
			if nparent then scalemul = nparent:GetTotalScaleMul() end
			
			local dir = panel.current_resize_dir
			local posdir = Point(dir.x,-dir.y)
			local mousePos = input.getMousePosition() 
			local mouseDiff = (mousePos - panel.current_resize_pointpos)/scalemul 
			local newSize = panel.current_resize_size + mouseDiff * dir 
			
			local snap = panel.current_resize_snap
			if snap then
				newSize = Point( math.snap( newSize.x,snap), math.snap( newSize.y,snap)) 
			end
			
			node:SetSize(newSize)
			
			local rrs = node:GetSize() - panel.current_resize_size
			local newPos = panel.current_resize_pos + rrs * posdir
			node:SetPos(newPos)
			
			local isup =  panel.IsUpMbutton(panel.current_resize_mbuttonid) 
			if node:GetDock()~=DOCK_NONE then 
				node:GetParent():UpdateLayout()
			end
			if isup then
				panel.SetCursor(0)
				panel.current_resize = false
				UnlockMouse()
				hook.Remove(EVENT_GLOBAL_PREDRAW, "gui.panel.resize")
				if panel.current_resize_on_drop then
					panel.current_resize_on_drop(node)
				end 
			end
		end
	end 
--END

















--SELECT

	local Selector = DEFINE_METATABLE("Selector")
	
	
	function Selector:BeginSelection(node,mbuttonid,overridestartpos)
		if not self.current_select and not MOUSE_LOCKED then 
			self:Deselect() 
			
			self.current_select_mbuttonid = mbuttonid or 0 
			self.current_select_pointpos = input.getMousePosition() 
			self.current_select_movepos = overridestartpos or node:GetLocalCursorPos()
			self.current_select = node
			--self.current_recursive = recursive
			--self.current_testfunction = testfunction
			LockMouse()
			
			local frame = panel.Create()
			frame:SetSize(5,5)
			frame:SetColor(Vector(1,1,1))
			frame:SetAlpha(0.1)
			frame:SetCanRaiseMouseEvents(false) 
			node:Add(frame)  
			self.current_select_frame = frame
			
			
			local frame_top = panel.Create()
			frame_top:SetColor(Vector(1,1,1))
			frame_top:Dock(DOCK_TOP)
			frame:Add(frame_top)  
			
			local frame_bottom = panel.Create()
			frame_bottom:SetColor(Vector(1,1,1))
			frame_bottom:Dock(DOCK_BOTTOM)
			frame:Add(frame_bottom)  
			
			local frame_left = panel.Create()
			frame_left:SetColor(Vector(1,1,1))
			frame_left:Dock(DOCK_LEFT)
			frame:Add(frame_left) 
			
			local frame_right = panel.Create()
			frame_right:SetColor(Vector(1,1,1))
			frame_right:Dock(DOCK_RIGHT)
			frame:Add(frame_right) 
			
			hook.Add(EVENT_GLOBAL_PREDRAW, "gui.select", function() self:function_select() end)
		
		end
	end

	function Selector:function_select()
		local node = self.current_select
		local frame = self.current_select_frame
		local selected = self.selected
		if node and frame then  
			local scalemul = 1
			if node:GetParent() then scalemul = node:GetParent():GetTotalScaleMul() end
			local startPos = self.current_select_movepos
			local endPos = node:GetLocalCursorPos()
			local diff = endPos-startPos
			local newPos = startPos+diff/2
			local newSize = Point(math.abs(diff.x/2),math.abs(diff.y/2))
			--local recursive = self.current_recursive
			frame:SetPos(newPos)
			frame:SetSize(newSize)
			
			local isup = panel.IsUpMbutton(self.current_select_mbuttonid) 
			
			if self.onupdate then
				self:onupdate(startPos,endPos)
			end
			
			if isup then 
				self.current_select = false
				UnlockMouse()
				node:Remove(frame)
				hook.Remove(EVENT_GLOBAL_PREDRAW, "gui.select")
			else
				self:function_select_child(node,newPos,newSize)
			end
		end
	end
	function Selector:function_select_child(node,newPos,newSize)
		local children = node:GetChildren()
		local selected = self.selected
		for k,v in pairs(children) do
			if v ~= frame and v.Select then
				local vp = v:GetPos()
				local vs = v:GetSize()
				if panel.Contains(vp,vs,newPos,newSize) then
				--if vp.x > (newPos.x-newSize.x) and vp.y > (newPos.y-newSize.y) 
				--and vp.x < (newPos.x+newSize.x) and vp.y < (newPos.y+newSize.y) then
					v:Select(self)
					
					if not self:Contains(v) then
						selected[v] = true
						--MsgN("Add!",v)
					end
				else
					v:Deselect() 
					self:Remove(v)
				end
			end
		end
	end

	function Selector:Contains(vv)
		for k,v in pairs(self.selected) do
			local eee = k==vv
			--MsgN(k," ",vv, eee)
			if eee then return true end
			
		end
		return false
	end
	function Selector:Remove(vv)
		for k,v in pairs(self.selected) do
			if k==vv then 
				self.selected[k] = nil
			end
		end
		return false
	end
	function Selector:GetSelected()
		local t = {} 
		for k,v in pairs(self.selected) do
			t[#t+1] = k
		end
		--PrintTable(t)
		return t
	end
	function Selector:Deselect() 
		for k,v in pairs(self.selected) do
			if k.Deselect then k:Deselect() end
		end
		self.selected = {} 
	end
	function Selector:Select(tbl) 
		self:Deselect() 
		for k,v in pairs(tbl) do
			if v.Select then 
				v:Select(self)  
				self.selected[v] = true
			end
		end
	end
	function Selector:Clear()  
		self.selected = {} 
	end

	Selector.__index = Selector

	function panel.Selector()
		local s = {
			current_select = false,
			current_select_frame = false,
			current_select_pointpos = Point(0,0), 
			current_select_movepos = Point(0,0), 
			current_select_mbuttonid = 0,
			selected = {},
		}
		setmetatable(s,Selector)
		return s
	end
--END





