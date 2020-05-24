

local t_mpanel =  "textures/gui/nodes/cnode.png" 
function PANEL:Init(mode) 
	
	--self.base.Init(self)
	self.xvalues = {}
	self.isnode = true

	self.mode = mode
	if mode == "single" then
		gui.FromTable({
			size = {256,128},
			alpha = 0.5,
			subs={
				{	name = "ftop",
					size = {1,1},
					dock = DOCK_TOP,
					mouseenabled = false,
				},
				{	name = "fbot",
					size = {1,1},
					dock = DOCK_BOTTOM,
					mouseenabled = false,
				},
				{	name = "fleft",
					size = {1,1},
					dock = DOCK_LEFT,
					mouseenabled = false,
				},
				{	name = "fright",
					size = {1,1},
					dock = DOCK_RIGHT,
					mouseenabled = false,
				},
				{ name = "anchl",
					textonly = true,
					interactive = false,
					size = {18,18},
					dock = DOCK_LEFT,
				},
				{ name = "anchr",
					textonly = true,
					interactive = false,
					size = {18,18},
					dock = DOCK_RIGHT,
				},
				{ name = "textl",
					textonly = true,
					interactive = false,
					size = {128-18,18},
					dock = DOCK_LEFT,
				},
				{ name = "textr",
					textonly = true,
					interactive = false,
					size = {128-18,18},
					dock = DOCK_RIGHT,
				},
				{	name= "atext", 
					pos = {-0,0},
					size = {256,20},
					text = "NODE",
					anchors = ALIGN_LEFT,
					textalignment = ALIGN_LEFT,
					textonly = true,
					mouseenabled = false,
				}
			}
		},self,{},self)
	else
		gui.FromTable({
			size = {256,128},
			alpha = 0.5,
			subs={
				{	name= "atext",
					dock = DOCK_TOP,
					size = {20,20},
					text = "NODE",
					textalignment = ALIGN_LEFT,
					interactive = false,
				},
				{	name = "fbot",
					size = {1,1},
					dock = DOCK_BOTTOM,
					mouseenabled = false,
				},
				{	name = "fleft",
					size = {1,1},
					dock = DOCK_LEFT,
					mouseenabled = false,
				},
				{	name = "fright",
					size = {1,1},
					dock = DOCK_RIGHT,
					mouseenabled = false,
				},
				{	name= "bcontext",
					dock = DOCK_BOTTOM,
					size = {20,20}, 
					color = {0,0,0},
					alpha = 0.5,
					interactive = false,
				},
				{ name = "anchl",
					textonly = true,
					interactive = false,
					size = {18,18},
					dock = DOCK_LEFT,
				},
				{ name = "anchr",
					textonly = true,
					interactive = false,
					size = {18,18},
					dock = DOCK_RIGHT,
				},
				{ name = "textl",
					textonly = true,
					interactive = false,
					size = {128-18,18},
					dock = DOCK_LEFT,
				},
				{ name = "textr",
					textonly = true,
					interactive = false,
					size = {128-18,18},
					dock = DOCK_RIGHT,
				},
			}
		},self,{},self)
	end
	--self:SetSize(256,128)
	--self:SetTexture(t_mpanel)
	self.anchors = {}
	self.outputs = {}
	self.inputs = {}
	
	--local atext = panel.Create()
	--atext:SetSize(253,20)
	--atext:SetPos(0,110)
	--atext:SetText("Node")
	--atext:SetTextAlignment(ALIGN_LEFT)
	--atext:SetTextColor(Vector(0.5,0.8,1)*2)
	--atext:SetTextOnly(true)
	--atext:SetCanRaiseMouseEvents(false)
	--self:Add(atext)
	--self.atext = atext
	
	self:SetColor(Vector(83,164,255)/255)
	self.name = "Node"
	
	--local ebtn = panel.Create("button")
	--ebtn:SetSize(50,20)
	--ebtn:SetPos(100,-100)
	--function ebtn.OnClick()
	--	self:Exec()
	--end
	--self.ebtn = ebtn
	--self:Add(ebtn)
	self:UpdateLayout()
end
function PANEL:AddAnchor(id,name,valtype)
	local a = panel.Create("graph_anchor")

	local anch_dock = self.anchl
	if id>0 then anch_dock = self.anchr end
	 
	a:Attach(self,id,name,valtype,anch_dock)
	self.anchors[id] = a
	 
	
	local atext = panel.Create("button")
	atext:SetSize(100,16)
	--atext:SetParent(self)
	if id<0 then
		--atext:AlignTo(a,ALIGN_LEFT,ALIGN_RIGHT) 
	else
		self.outputs[id] = a
		--atext:AlignTo(a,ALIGN_RIGHT,ALIGN_LEFT)
		atext:SetTextAlignment(ALIGN_RIGHT) 
	end
	atext:SetCanRaiseMouseEvents(false)
	atext:SetText(name)
	atext:SetTextColor(Vector(0.5,0.8,1)*2)
	atext:SetTextOnly(true)
	--atext:SetAnchors(ALIGN_TOPLEFT) 
	atext:SetAutoSize(true,false)
	atext:Dock(DOCK_TOP)
	if id<0 then --is input
		if valtype=="float" or valtype=="double" or valtype=="single" 
			or valtype=="int64" or valtype=="int32" 
			or valtype=="uint64" or valtype=="uint32"  then
			local xvalue = 0 
			atext:SetCanRaiseMouseEvents(true)
			atext.contextinfo = "edit value"
			atext.OnClick = function()
				MsgBox({
					name = "valinput",
					type = "input_text",
					restnumbers = true,
					text = tostring(xvalue),
					size = {20,20},
					dock = DOCK_TOP 
				},"Set value: "..valtype,{"set","cancel","clear"},function(val,s)
					if val == "set" then
						xvalue = tonumber(s.valinput:GetText()) 
						a:SetInnerValue(xvalue)
						self.xvalues[id] = {"VALUE",valtype,xvalue}
						atext:SetText(name..': '..xvalue)
					elseif val == 'clear' then
						xvalue = ""
						a:SetInnerValue(nil)
						self.xvalues[id] = nil
						atext:SetText(name) 
					end
				end)	
			end
		elseif valtype=="string" then 
			local xvalue = ""
			atext:SetCanRaiseMouseEvents(true)
			atext.contextinfo = "edit value"
			atext.OnClick = function()
				MsgBox({
					name = "valinput",
					type = "input_text",
					text = xvalue,
					size = {20,20},
					dock = DOCK_TOP 
				},"Set value: "..valtype,{"set","cancel","clear"},function(val,s)
					if val == "set" then
						xvalue = s.valinput:GetText()
						a:SetInnerValue(xvalue)
						self.xvalues[id] = {"VALUE",valtype,xvalue}
						atext:SetText(name..': '..xvalue)
					elseif val == 'clear' then
						xvalue = ""
						a:SetInnerValue(nil)
						self.xvalues[id] = nil
						atext:SetText(name) 
					end
				end)	
			end
		end
	end
	
	a:SetAnchors(ALIGN_TOPLEFT) 
	a.atext = atext
	if id<0 then
		self.textl:Add(atext)
	else
		self.textr:Add(atext)
	end
end
function PANEL:Load()  
end
function PANEL:ToData() 
	local pos = self:GetPos() 
	local p = self:GetParent()
	local j = {id = self.id,pos = {pos.x,pos.y}} 
	if p.id then
		j.parent = p.id
	end
	return j
end
function PANEL:FromData(data,mapping,posoffset,blocknext) 
	if data.pos then self:SetPos(data.pos[1]+posoffset.x,data.pos[2]+posoffset.y) end
	self.id = data.id
	local e = self.editor.editor 
	if data.parent then
		local parent = e.named[mapping(data.parent)]
		MsgN("par",data.parent,parent)
		if parent then
			self:GetParent():Remove(self)
			parent:Add(self)
		end 
	end
	
	if data.next and not blocknext then
		local e = self.editor.editor 
		local f = self.outputs[1]
		local t = e.named[mapping(data.next[1])].anchors[data.next[2]] 
		f:CreateLink(f,t)
	end
	
	self:SetAnchors(ALIGN_TOPLEFT)
end
function PANEL:AddAnchorPadding(size)
	local padding = {
		textonly = true,
		mouseenabled = false,
		size = {size,size},
		dock = DOCK_TOP,
	}
	self.anchl:Add(gui.FromTable(padding));
	self.anchr:Add(gui.FromTable(padding));
	self.textl:Add(gui.FromTable(padding));
	self.textr:Add(gui.FromTable(padding));
end

function PANEL:SetTitle(text)
	self.name = text
	self.atext:SetText(tostring(text))
end

function PANEL:Exec()
	MsgN("EXEC ",self.name)
	local execf = self.OnExec 
	if execf then execf(self) end
	for k,v in pairs(self.outputs) do 
		if v.to and v.to.node~=self then
			v.to.node:Exec()
		end
	end
end
function PANEL:GetInput(name)
	for k,v in pairs(self.anchors) do
		if k<0 and v.name==name then
			return v,k
		end
	end
end
function PANEL:GetOutput(name)
	for k,v in pairs(self.anchors) do
		if k>=0 and v.name==name then
			return v,k
		end
	end
end
function PANEL:Reload(...)
	local leftdata = {}
	local rightdata = {}
	local xdata = {}
	
	for k,v in pairs(self.anchors) do
		if k<0 then 
			if v.from then
				leftdata[v.name] = v.from
			end
		else 
			rightdata[v.name] = v.to:ToTable()
		end 
	end
	for k,v in pairs(self.xvalues) do
		local a = self.anchors[k]  
		xdata[a.name] = v
	end
	MsgN("leftdata")
	PrintTable(leftdata)
	MsgN("rightdata")
	PrintTable(rightdata)
	MsgN("xdata")
	PrintTable(xdata)

	
	self:RemoveAnchors() 
	self.xvalues = {}
	
	self:Load(...)
	
	for k,v in pairs(leftdata) do
		local a = self:GetInput(k) 
		if a then a:CreateLink(a,v) end
	end
	for k,v in pairs(rightdata) do
		local a = self:GetOutput(k)
		if a then  
			for k,vv in pairs(v) do
				a:CreateLink(a,vv)  
			end 
		end
	end 
	for k,v in pairs(xdata) do 
		local a = self:GetInput(k)  
		local xvalue = v[3] 
		a:SetInnerValue(xvalue) 
		a.atext:SetText(a.name..': '..xvalue)
		self.xvalues[a.id] = v
	end
end
function PANEL:Select(selector) 
	self:SetColor(Vector(83,255,164)/255)
	self.selector = selector
end
function PANEL:Deselect() 
	self:SetColor(Vector(83,164,255)/255)
	self.selector = nil
end 
function PANEL:SetError(error) 
	if self.borders then
		for k,v in pairs(self.borders ) do
			self:Remove(v)
		end
	end 
	if error then 
		local brd = {}
		local size = self:GetSize()
		gui.FromTable({
			subs = { 
				{name = "t", class = "border", size = {size.x,1},pos={0,size.y}},
				{name = "b", class = "border", size = {size.x,1},pos={0,-size.y}},
				{name = "l", class = "border", size = {1,size.y},pos={-size.x,0}},
				{name = "r", class = "border", size = {1,size.y},pos={size.x,0}},
			}
		},self,{
			border={color= {1,0,0},size = {2,2}}
		},brd)
		self.borders = brd
		self:UpdateLayout() 
	end
	self.contextinfo = error
end

function PANEL:SetColor(c)
	local bscol = PANEL.base.SetColor
	local ddcol = c*0.5
	self._color = c
	bscol(self.fbot,ddcol)
	bscol(self.fleft,ddcol)
	bscol(self.fright,ddcol)
	if self.mode=="single" then
		bscol(self.ftop,ddcol)
		bscol(self,c*0.3) 
	else
		bscol(self.atext,ddcol)
		bscol(self,c*0.1) 
	end
	self.atext:SetTextColor(c*2)  
end
function PANEL:GetColor()
	return self._color or Vector(1,1,1)
end
function PANEL:UnlinkAll()
	for k,v in pairs(self.anchors) do
		v:UnlinkAll()
	end
end
function PANEL:RemoveAnchors()
	for k,v in pairs(self.anchors) do
		if v.atext then
			self:Remove(v.atext)
		end
		v:UnlinkAll()
		self:Remove(v)
	end
	self.anchl:Clear()
	self.anchr:Clear()
	self.textl:Clear()
	self.textr:Clear()
	self.anchors = {}
end

function PANEL:GetInputData(id)
	local a = self.inputs[id]
	if self.xvalues then  
		local xvalue = self.xvalues[-id] 
		if xvalue then 
			return xvalue
		end
	end
	if a and a.node then
		return {a.node.id,a.id,a.name}
	end
end
function PANEL:GetOutputData(id)
	local a = self.outputs[id]
	local to = a.to:First()
	if to and to.node then
		return {to.node.id,to.id,to.name}
	end
end

function PANEL:LinkNext(data)
	
end

function PANEL:MouseDown(id)
	if id == 1 then
		local sel = self.selector
		if sel then
			panel.start_drag(sel:GetSelected(),1,true,20)
		else
			if panel.start_drag(self,1,function() self:SetCanRaiseMouseEvents(true) end,20) then 
				local p = self:GetParent()
				if p then 
					p:Remove(self)
					p:Add(self)
				end
				self:SetCanRaiseMouseEvents(false)
			end			
		end
	elseif id == 2 then
		--self:Select()
		self.editor.selector:Select({self})
	elseif id == 3 then
		panel.start_drag(self.editor,3) 
	end
end
function PANEL:OnDropped(onto) 
	self:SetCanRaiseMouseEvents(true)
	if onto then
		local p = self:GetParent()
		if onto ~= p then
			if p then p:Remove(self) end
			onto:Add(self)
			for k,v in pairs(self.anchors) do
				v:UpdateVarLink()
			end
		end
	end
end 