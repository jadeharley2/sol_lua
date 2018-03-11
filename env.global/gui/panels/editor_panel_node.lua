



function PANEL:Init() 
	self:SetColor(Vector(0,0,0))
	self:SetSize(200,200)
end 

 
function PANEL:SelectNode(node) 
	self.cnode = node
	self:Clear()
	if node then
	
		local metacom = panel.Create("button") 
		metacom:SetColorAuto(Vector(0.3,0.6,0.9))
		metacom:SetSize(100,20)
		metacom:Dock(DOCK_TOP)
		metacom:SetText("Components")
		metacom:SetTextAlignment(ALIGN_CENTER)
		metacom.OnClick = function()  end 
		self:Add(metacom)
		
		for k,v in pairs(node:GetComponents()) do
		
			local type = "none"
			
			if v.GetTypename then
				type = tostring(v:GetTypename())
			end
			
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
			nph:Dock(DOCK_TOP)
			nph:SetText(type)
			
			
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
			
			local meta = components:GetType(type)
			if meta then
				self:ConstructParams(node,meta,np)
			end
			
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
		
		local meta = node
		if meta and node.editor then
			local metacom = panel.Create("button") 
			metacom:SetColorAuto(Vector(0.3,0.6,0.9))
			metacom:SetSize(100,20)
			metacom:Dock(DOCK_TOP)
			metacom:SetText(meta.editor.name or "Entity")
			metacom:SetTextAlignment(ALIGN_CENTER)
			metacom.OnClick = function()  end 
			self:Add(metacom)
			
			self:ConstructParams(node,meta,self)
		end
			
		self:UpdateLayout()
	end
end

function PANEL:ConstructParams(node,meta,parent) 
	MsgN("meta of ",type)
	if meta.editor and meta.editor.properties then
		for k,v in pairs(meta.editor.properties) do 
			local pva = panel.Create("button") 
			pva:SetColorAuto(Vector(0.6,0.6,0.6))
			pva:SetSize(20,20)
			pva:Dock(DOCK_TOP)
			pva:SetTextAlignment(ALIGN_LEFT)
			pva:SetText(v.text..":")
			pva.OnClick = function() end
			
			local value = false
			if v.type=="parameter" then
				value = node:GetParameter(v.key)
				
				local inp = false
				if v.valtype == "bool" then
					inp = panel.Create("checkbox") 
					inp:SetValue(value or false)
				elseif v.valtype == "number" then 
					inp = panel.Create("input_text")   
					inp:SetSize(220,20) 
					inp.rest_numbers = true
					inp:SetText(tostring(value or "")) 
					inp.OnKeyDown = function(n,key) 
						if key== KEYS_ENTER then
							self:SetParam(n.node,n.v,tonumber(n:GetText()))
						end
					end
					--inp.evalfunction = v2.proc 
				elseif v.valtype == "string" then 
					inp = panel.Create("input_text")  
					inp:SetSize(220,20)
					inp:SetText(tostring(value or "")) 
					--inp.evalfunction = v2.proc 
					inp.OnKeyDown = function(n,key) 
						if key== KEYS_ENTER then
							self:SetParam(n.node,n.v,n:GetText())
						end
					end
				end
				inp.v = v
				inp.node = node
				inp:Dock(DOCK_RIGHT)
				pva:Add(inp)
			elseif v.type == "action" then 
				pva.OnClick = function(b) v.action(node,b) end
			end
			
			 
			parent:Add(pva)
		end
	end
end
function PANEL:SetParam(node,metaparam,value)  
	if metaparam.type=="parameter" then
		node:SetParameter(metaparam.key,value)
	end
	if metaparam.reload and node.Load then
		node:Load()
	end
end