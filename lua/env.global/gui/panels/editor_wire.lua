
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
	if n==node or node == nil then 
		if wio then
			local cc = 0
			for k,v in pairs(wio.inputs) do
				local btn = panel.Create("button")
				btn:SetSize(15,15)
				btn:Dock(DOCK_TOP)
				btn:SetText(k)
				if v.target then
					btn:SetColorAuto(Vector(0,1,1))
					local cbtn = panel.Create("button")
					cbtn:SetSize(15,15)
					cbtn:Dock(DOCK_RIGHT)
					cbtn:SetColorAuto(Vector(1,0.3,0))
					function cbtn:OnClick() 
						WireUnLink(n,k)
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
			self:SetSize(100,cc)
		else
			self:SetColor(Vector(1,0,0))  
		end 
	else
		local cc = 0
		for k,v in pairs(wio.outputs) do
			local btn = panel.Create("button")
			btn:SetSize(15,15)
			btn:Dock(DOCK_TOP)
			btn:SetText(k)
			function btn:OnClick()
				hook.Call("ed_wire_setout",n,k)
			end
			self:Add(btn)
			cc = cc + 15
		end
		self:SetSize(100,cc)
	end
	self:UpdateLayout()
end 