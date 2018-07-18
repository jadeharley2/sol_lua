
 
local t_resize = LoadTexture("gui/nodes/resizecorner.png")  
 
PANEL.basetype = "graph_node" 

function PANEL:Init() 
	--self.base.Init(self)
	
	self:SetSize(256,128) 
	self:SetAlpha(17/255)
	self.anchors = {}
	self.outputs = {}
	self.inputs = {}
	
	self.nodegroup = true
	self.name = "Node"
	
	local bottom = panel.Create("button")  
	bottom:Dock(DOCK_BOTTOM) 
	bottom:SetAlpha(0)  
	bottom:SetSize(20,20)
	self:Add(bottom)  
	local bright = panel.Create("button")  
	bright:Dock(DOCK_RIGHT)  
	bright.dir = Point(1,1) 
	bright:SetTexture(t_resize)
	bright:SetColorAuto(Vector(83,164,255)/255)
	bright:SetSize(20,20) 
	bright:SetAlpha(0.3)  
	bottom:Add(bright)  
	self.bright = bright
	 
	local sResize = function(s)
		panel.start_resize(self,1,s.dir,nil,20)
	end  
	local rmenter = function(s)  
		panel.cursor_resize(s.dir)
	end
	local rleave = function(s)  
		if not panel.current_resize then
			panel.SetCursor(0)
		end
	end 
	  
	bright.OnClick = sResize
	bright.OnEnter = rmenter
	bright.OnLeave = rleave
	
	local atext = panel.Create()
	atext:SetSize(253,20)
	atext:SetPos(0,110)
	atext:SetText("Group")
	atext:SetTextAlignment(ALIGN_LEFT)
	atext:Dock(DOCK_TOP)
	atext:SetTextColor(Vector(0.5,0.8,1)*2)
	atext:SetTextOnly(true)
	
	local s = self
	--function atext:MouseDown(id)
	--	MsgN("down",id)
	--	if id == 1 then
	--		local sel = s.selector 
	--		if sel then
	--			panel.start_drag(sel:GetSelected(),1,true,20)
	--		else
	--			panel.start_drag(s,1,true,20)  
	--		end
	--	end
	--end
	atext:SetCanRaiseMouseEvents(false)
	self:Add(atext)
	self.atext = atext
	
	self:SetColor(Vector(83,164,255)/255)

	self:AddAnchor(-1,"self","any") 

	self:UpdateLayout()
	
end 
function PANEL:Load() 
	--self:AddAnchor(-1,"a","float")
	--self:AddAnchor(-2,"b","float")
	--self:AddAnchor(1,"c","float") 
end
function PANEL:ToData() 
	local sz = self:GetSize()
	local j = PANEL.base.ToData(self)
	j.type = "group"
	j.size = {sz.x,sz.y}
	--local nodes = {}
	--for k,v in pairs(self:GetChildren()) do 
	--	if v and v.ToData then
	--		nodes[#nodes+1] = v:ToData()
	--	end
	--end
	--j.nodes = nodes
	local args = {}
	local a = self.anchors[-1]
	args[a.name] = self:GetInputData(1)
	
	j.args = args
	return j
end
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset) 
	if data.size then self:SetSize(data.size[1],data.size[2]) end
end

function PANEL:SetTitle(text)
	self.name = text
	self.atext:SetText(tostring(text))
end
 

function PANEL:Select(selector) 
	self:SetColor(Vector(83,255,164)/255)
	self.selector = selector
end
function PANEL:Deselect() 
	self:SetColor(Vector(83,164,255)/255)
	self.selector = nil
end 

function PANEL:SetColor(c)
	PANEL.base.SetColor(self,c)
	self.atext:SetTextColor(c*2)  
	self.bright:SetColor(c)  
end

 

function PANEL:MouseDown(id)
	if id == 1 then
		local sel = self.selector
		
		if sel then
			panel.start_drag(sel:GetSelected(),1,true,20)
		else
			--panel.start_drag(self,1,true,20) 
			self.editor.selector:BeginSelection(self,1)
		end
	elseif id == 2 then
		--self:Select()
		self.editor.selector:Select({self})
	elseif id == 3 then
		panel.start_drag(self.editor,3) 
	end
end
 

function PANEL:OnDropped(onto) 
end

function PANEL:DragEnter(node)  
	MsgN("DragEnter",node)
	if node == self then return end
	self:SetColor(Vector(83,255,164)/255)
end

function PANEL:DragExit(node)  
	if node == self then return end
	self:SetColor(Vector(83,164,255)/255)
end
function PANEL:DragHover(node)  
end
function PANEL:DragDrop(node)  
	MsgN("drop",node)
	if node == self or not node.isnode then return end
	local np = node:GetParent()
	if np~=self then
		np:Remove(node)
		self:Add(node)
		node:SetPos(node:GetPos()-self:GetPos())
		
		node:SetAnchors(ALIGN_TOPLEFT) 
		for k,v in pairs(node.anchors) do
			v:UpdateVarLink()
		end
	end 
end
