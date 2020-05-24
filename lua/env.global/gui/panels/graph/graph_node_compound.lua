PANEL.basetype = "graph_node" 
local t_xtoggle = "textures/gui/nodes/xtoggle.png"
function PANEL:Init() 
	self.base.Init(self) 
end 
function PANEL:Load(func,signalenabled) 
	if signalenabled==nil then signalenabled = self.signalenabled end 
	func = func or self.func

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
		local argmaxnum = 1
		for k,v in pairs(data.input) do
			self.base.AddAnchor(self,-k-off,v.name,v.vtype or "float")
			argmaxnum= math.max(argmaxnum,k+off)
		end
		
		for k,v in pairs(data.output) do
			self.base.AddAnchor(self,k+off,v.name,v.vtype or "float")
			argmaxnum= math.max(argmaxnum,k+off)
		end
		self:SetSize(256,argmaxnum*18+40)
	end
	
	self:Deselect()  
	if not self.toggle_signal then
	 
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
				},
				{ name = "open_compound", type = "button",
					size = {20,20},
					dock = DOCK_RIGHT,
					texture = t_xtoggle,
					ColorAuto = self:GetColor(),
					contextinfo = "Open compound flow",
					OnClick = function (x)
						self.editor.editor:Open("forms/flow/functions/"..func..".json")
					end
				} 
			}
		},self.bcontext,{},self)  
		
	end
	self:UpdateLayout()
	--self:AddAnchor(-1,"a","float")
	--self:AddAnchor(-2,"b","float")
	--self:AddAnchor(1,"output","float") 
end
function PANEL:ToggleSignal()  
	self:Reload(nil, not self.signalenabled) 
end
function PANEL:ToData() 
	local args = {}
	local signaled = self.signaled
	for k,v in pairs(self.xvalues) do
		local a = self.anchors[k]
		args[a.name] = self:GetInputData(-k)
	end
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
			if( v[1]=='VALUE')then
				local xval = v[3]
				local an = namedAnchors[k] 
				self.xvalues[an.id] =v
				an:SetInnerValue(xval)
				an.atext:SetText(an.name..': '..tostring(xval))
			else
				local e = self.editor.editor 
				local f = e.named[mapping(v[1])].anchors[v[2]] 
				local t = namedAnchors[k]
				if f and t then
					f:CreateLink(f,t)
				end
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
