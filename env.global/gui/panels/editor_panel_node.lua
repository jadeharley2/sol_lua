
function PANEL:Init() 
	self:SetColor(Vector(0,0,0))
	self:SetSize(200,200)
end 

 
function PANEL:SelectNode(node) 
	self.cnode = node
	self:Clear()
	if node then
		for k,v in pairs(node:GetComponents()) do
			local np = panel.Create() 
			np:SetSize(100,200)
			np:SetColor(Vector(0.2,0.2,0.2)) 
			np:Dock(DOCK_TOP)
			
			function np:RezToggle()
				if np.minimized then
					np.minimized = false
					np:SetSize(100,200)
				else
					np.minimized = true
					np:SetSize(100,20)
				end
			end
			
			local nph = panel.Create()
			nph:SetSize(100,20)
			nph:SetColor(Vector(20,20,0))
			if v.GetTypename then
				nph:SetText(tostring(v:GetTypename()))
			end
			nph:Dock(DOCK_TOP)
			
			
			
			local delcom = panel.Create("button") 
			delcom:SetColorAuto(Vector(0.8,0,0))
			delcom:SetSize(20,20)
			delcom:Dock(DOCK_RIGHT)
			delcom:SetText("x")
			delcom:SetTextAlignment(ALIGN_CENTER)
			delcom.OnClick = function()  end
			nph:Add(delcom)
			
			local rezcom = panel.Create("button") 
			rezcom:SetColorAuto(Vector(0,0.3,0.8))
			rezcom:SetSize(20,20)
			rezcom:Dock(DOCK_RIGHT)
			rezcom:SetText("-")
			rezcom:SetTextAlignment(ALIGN_CENTER)
			rezcom.OnClick = function() np:RezToggle() self:UpdateLayout() end
			nph:Add(rezcom)
			
			
			np:Add(nph)
			
			self:Add(np)
			--MsgN(k," - ",v)
		end
		local addcom = panel.Create("button") 
		addcom:SetColorAuto(Vector(0,0.8,0))
		addcom:SetSize(100,20)
		addcom:Dock(DOCK_TOP)
		addcom:SetText("+")
		addcom:SetTextAlignment(ALIGN_CENTER)
		addcom.OnClick = function()  end
		self:Add(addcom)
		
			
		self:UpdateLayout()
	end
end