
function PANEL:Init() 
	self:SetColor(Vector(0,0,0))  
end
function PANEL:SetNode(n) 
	self.node = n
	local wio = n.wireio
	if wio then
		self:OnSetOutput()
	else
		self:SetColor(Vector(1,0,0))  
	end
end 
function PANEL:OnSetOutput(node,key)
	local n = self.node
	local wio = n.wireio
	self:Clear()
	local cc = 15
	self.invalues = {}
	self.outvalues = {}

	local aact = panel.Create("panel")
	aact:SetSize(15,15) 
	aact:Dock(DOCK_TOP)
	aact:SetText(n:GetName())
	self:Add(aact)

	if n==node or node == nil then 
		if wio then 
			for k,v in pairs(wio.inputs) do
				local btn = panel.Create("button")
				btn:SetSize(15,15)
				self.invalues[k] = btn
				btn:Dock(DOCK_TOP)
				btn:SetText(k)
				if v.target then
					btn:SetColorAuto(Vector(0,1,1))
					local cbtn = panel.Create("button")
					cbtn:SetSize(15,15)
					cbtn:Dock(DOCK_RIGHT)
					cbtn:SetColorAuto(Vector(1,0.3,0))
					function cbtn:OnClick() 
						hook.Call("ed_wire_unlink",n,k)
						--WireUnLink(n,k)
						hook.Call("ed_wire_setin")
					end
					btn:Add(cbtn)
				end
				if k ==key then
					btn:SetColorAuto(Vector(0,1,0))
					function btn:OnClick()
						hook.Call("ed_wire_setin")
					end
				else
					function btn:OnClick()
						hook.Call("ed_wire_setin",n,k)
					end
				end
				
				self:Add(btn)
				cc = cc + 15
			end
		else
			self:SetColor(Vector(1,0,0))  
		end 
		for k,v in pairs(wio.outputs) do
			local btn = panel.Create("button")
			btn:SetSize(15,15)
			btn:Dock(DOCK_TOP)
			btn:SetText(k)
			self.outvalues[k] = btn
			self:Add(btn)
			cc = cc + 15
		end
	else
		for k,v in pairs(wio.outputs) do
			local btn = panel.Create("button")
			btn:SetSize(15,15)
			btn:Dock(DOCK_TOP)
			btn:SetText(k)
			self.outvalues[k] = btn
			function btn:OnClick()
				hook.Call("ed_wire_setout",n,k)
			end
			self:Add(btn)
			cc = cc + 15
		end 
	end
	self:SetSize(100,cc)
	self:UpdateLayout()
end 
function PANEL:UpdateValues()
	local n = self.node
	local wio = n.wireio
	
	for k,v in pairs(self.outvalues) do
		local val = wio.outputs[k].v
		if val~=nil then
			v:SetText(k..': '..tostring(val or '')) 
		else
			v:SetText(k) 
		end
	end
	for k,v in pairs(self.invalues) do
		local val = wio.inputs[k].v
		if val~=nil then
			v:SetText(k..': '..tostring(val or '')) 
		else
			v:SetText(k) 
		end
	end
end