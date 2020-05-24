PANEL.basetype = "graph_node" 
PANEL.datakeys = {
	signalenabled="signal"
}
local t_xtoggle = "textures/gui/nodes/xtoggle.png"
function PANEL:Init() 
	self.base.Init(self) 
end 
function PANEL:Load(funcname,enableSignal) 
	if enableSignal==nil then enableSignal = self.signalenabled end 
	funcname = funcname or self.func
	self.func = funcname
	self.base.SetTitle(self,funcname)
	 
	
	local ftype = flowbase.GetMethodInfo(funcname)
	if ftype then
		if not self.toggle_signal and not ftype.signaled then 
			gui.FromTable({ 
				subs = { 
					{ name = "toggle_signal", type = "button",
						size = {20,20},
						dock = DOCK_RIGHT,
						texture = t_xtoggle,
						ColorAuto = self:GetColor(),
						contextinfo = "Toggle signal mode",
						OnClick = function (x)
							self:ToggleSignal()
						end
					}  
				}
			},self.bcontext,{},self) 
		end

		local off = 0
		local signalenabled = enableSignal or ftype.signaled 
		self.signalenabled = signalenabled

		local argmaxnum = 1
		if signalenabled then
			self.signaled = true
			self.base.AddAnchor(self,-1,">>","signal")
			self.base.AddAnchor(self,1,">>","signal")
			off = 1
		end
		for k,v in pairs(ftype.inputs) do
			self.base.AddAnchor(self,-k-off,v.name,v.type or "float")
			argmaxnum= math.max(argmaxnum,k+off)
		end
		
		for k,v in pairs(ftype.outputs) do
			self.base.AddAnchor(self,k+off,"output",v.type or "float")--v.name
			argmaxnum= math.max(argmaxnum,k+off)
		end

		self:SetSize(256,argmaxnum*16+40)
	
	--self:AddAnchor(-1,"a","float")
	--self:AddAnchor(-2,"b","float")
	--self:AddAnchor(1,"output","float") 
	end
	self:Deselect() 
	self:UpdateLayout()
end
function PANEL:ToggleSignal()  
	self:Reload(nil, not self.signalenabled) 
end
function PANEL:ToData() 
	local args = {}
	local signaled = self.signalenabled
	for k,v in pairs(self.xvalues) do
		local a = self.anchors[k]
		args[a.name] = self:GetInputData(-k)
	end
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
			if( v[1]=='VALUE')then
				local xval = v[3]
				local an = namedAnchors[k] 
				self.xvalues[an.id] =v
				an:SetInnerValue(xval)
				an.atext:SetText(an.name..': '..tostring(xval))
			else
				local f = e.named[mapping(v[1])].anchors[v[2]] 
				local t = namedAnchors[k]
				if f and t then
					f:CreateLink(f,t)
				end
			end
		end
	end
	
end
  
