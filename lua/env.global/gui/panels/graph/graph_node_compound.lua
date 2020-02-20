PANEL.basetype = "graph_node" 
local t_xtoggle = LoadTexture("gui/nodes/xtoggle.png")
function PANEL:Init() 
	self.base.Init(self) 
end 
function PANEL:Load(func,signalenabled) 
	
	self.signalenabled = signalenabled or false
	self.func = func 
	local data = json.Read("forms/flow/functions/"..func..".json")
	self.funcdata = data
	self.base.SetTitle(self,func)
	 
	if data then
		local off = 0
		if signalenabled then
			self.signaled = true
			self.base.AddAnchor(self,-1,">>","signal")
			self.base.AddAnchor(self,1,">>","signal")
			off = 1
		end
		
		for k,v in pairs(data.input) do
			self.base.AddAnchor(self,-k-off,v.name,v.vtype or "float")
		end
		
		for k,v in pairs(data.output) do
			self.base.AddAnchor(self,k+off,v.name,v.vtype or "float")
		end
	end
	
	self:Deselect()  
	if not self.toggle_signal then
	
		local s = self
	
		local ssz = self:GetSize()
		local toggle_signal = panel.Create("button")
		toggle_signal:SetSize(8,8)
		toggle_signal:SetPos(-ssz.x+10,-ssz.y+10)   
		toggle_signal:SetTexture(t_xtoggle) 
		toggle_signal:SetColorAuto(self:GetColor())
		toggle_signal.contextinfo = "Toggle signal mode"
		function toggle_signal:OnClick() s:ToggleSignal() end
		self:Add(toggle_signal)
		self.toggle_signal = toggle_signal
		
		
		local open_compound = panel.Create("button")
		open_compound:SetSize(8,8)
		open_compound:SetPos(-ssz.x+50,-ssz.y+10)   
		open_compound:SetTexture(t_xtoggle) 
		open_compound:SetColorAuto(self:GetColor()) 
		open_compound.contextinfo = "Open compound flow"
		function open_compound:OnClick() s.editor.editor:Open("forms/flow/functions/"..func..".json") end
		self:Add(open_compound)
		self.open_compound = open_compound
		
	end
	--self:AddAnchor(-1,"a","float")
	--self:AddAnchor(-2,"b","float")
	--self:AddAnchor(1,"output","float") 
end
function PANEL:ToggleSignal()  
	local func = self.func
	local signalenabled = self.signalenabled
	local tempdata = {}
	
	for k,v in pairs(self.anchors) do
		if k<0 then 
			if v.from then
				tempdata[k] = v.from
			end
		else 
			tempdata[k] = v.to:ToTable()
		end
	end
	self:RemoveAnchors() 
	local off = 0
	local signalenabled = self.signalenabled
	if signalenabled then off = 1 else off = -1 end
	self:Load(func, not signalenabled)
	for k,v in pairs(tempdata) do
		if k<0 then
			local a = self.anchors[k+off]
			if a then a:CreateLink(a,v) end
		else  
			local a = self.anchors[k-off]
			if a then 
				for k,vv in pairs(v) do
					a:CreateLink(a,vv)  
				end
			end
		end
	end 
end
function PANEL:ToData() 
	local args = {}
	local signaled = self.signaled
	for k,v in pairs(self.inputs) do
		if not signaled or k~=1 then
			local a = self.anchors[-k]
			args[a.name] = self:GetInputData(k) 
		end
	end
	local j = PANEL.base.ToData(self)
	j.type = "compound" 
	j.func = self.func
	j.args = args
	j.signal = signaled 
	
	if signaled then
		j.next = self:GetOutputData(1)
		--local out = self.outputs[1]
		--local to = out.to:First()
		--if to then
		--	j.next = to.node.id 
		--end
	end
	return j
end 
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset) 
	self.func = data.func 
	self.sub = data.sub 
	 
	local namedAnchors = {}
	for k,v in pairs(self.anchors) do
		namedAnchors[v.name] = v
	end
	
	if data.args then
		for k,v in pairs(data.args) do
			local e = self.editor.editor 
			local f = e.named[mapping(v[1])].anchors[v[2]] 
			local t = namedAnchors[k]
			if f and t then
				f:CreateLink(f,t)
			end
		end
	end
	 
end
  
function PANEL:Select(selector) 
	self:SetColor(Vector(83,255,164)/255)
	self.selector = selector
	
	---PrintTable(getmetatable(self))
end
function PANEL:Deselect() 
	self:SetColor(Vector(255,164,83)/255)
	self.selector = nil
end
