PANEL.basetype = "graph_node" 
local t_xtoggle = LoadTexture("gui/nodes/xtoggle.png")
function PANEL:Init() 
	self.base.Init(self) 
end 
function PANEL:Load(funcname,enableSignal) 
	enableSignal = enableSignal or false 
	self.func = funcname 
	self.base.SetTitle(self,funcname)
	 
	
	local ftype = flowbase.GetMethodInfo(funcname)
	if ftype then
		local off = 0
		local signalenabled = enableSignal or ftype.signaled 
		
		if signalenabled then
			self.signaled = true
			self.base.AddAnchor(self,-1,">>","signal")
			self.base.AddAnchor(self,1,">>","signal")
			off = 1
		end
		
		for k,v in pairs(ftype.inputs) do
			self.base.AddAnchor(self,-k-off,v.name,v.type or "float")
		end
		
		for k,v in pairs(ftype.outputs) do
			self.base.AddAnchor(self,k+off,"output",v.type or "float")--v.name
		end
	
		if not self.toggle_signal and not ftype.signaled then
			local ssz = self:GetSize()
			local toggle_signal = panel.Create("button")
			toggle_signal:SetSize(8,8)
			toggle_signal:SetPos(-ssz.x+10,-ssz.y+10)   
			toggle_signal:SetTexture(t_xtoggle) 
			toggle_signal:SetColorAuto(self:GetColor())
			local s = self 
			function toggle_signal:OnClick() s:ToggleSignal() end
			self:Add(toggle_signal)
			self.toggle_signal = toggle_signal
		end
	--self:AddAnchor(-1,"a","float")
	--self:AddAnchor(-2,"b","float")
	--self:AddAnchor(1,"output","float") 
	end
	self:Deselect() 
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
			--local a = self.anchors[-k]
			--if v and v.node then
			--	args[a.name] = GetInputData(-k) --(v.node.id or "")
			--else
			--	args[a.name] = ""
			--end
		end
	end
	local j = PANEL.base.ToData(self)
	j.type = "func" 
	j.func = self.func
	j.args = args
	j.signal = signaled 
	
	if signaled then
		j.next = self:GetOutputData(1) 
	end
	return j
end 
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset) 
	self.func = data.func 
	
	local off = 0
	if self.signaled then off = 1 end
	
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
  
