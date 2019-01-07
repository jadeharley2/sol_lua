



function PANEL:Init() 
	self:SetColor(Vector(0,0,0))
	self:SetSize(200,200)
	
	 
	
	local nph = panel.Create()
	nph:SetSize(100,20)
	nph:SetColor(Vector(0.3,0.6,0.9))
	nph:Dock(DOCK_TOP)
	nph:SetTextAlignment(ALIGN_CENTER)
	nph:SetText("Current space nodes")
	
	local refcom = panel.Create("button") 
	refcom:SetColorAuto(Vector(0,0.8,0.3))
	refcom:SetSize(20,20)
	refcom:Dock(DOCK_RIGHT)
	refcom:SetText("O")
	refcom:SetTextAlignment(ALIGN_CENTER)
	refcom.OnClick = function() self:UpdateCnodes() end
	nph:Add(refcom)
	self:Add(nph)
	
	local nodetree = panel.Create("tree")
	nodetree:SetSize(200,400)
	nodetree:Dock(DOCK_TOP)
	self:Add(nodetree)
	
	local peditor = panel.Create()
	peditor:SetSize(200,400)
	peditor:Dock(DOCK_TOP)
	peditor:SetColor(Vector(0,0,0))
	self:Add(peditor)
	
	self.nodetree = nodetree
	self.peditor = peditor
	
	self:UpdateCnodes() 
	
end 
function PANEL:UpdateCnodes() 
	local nodetree = self.nodetree
	local rtb = {"types"}
	local cam = GetCamera()
	local camp = cam:GetParent()
	local chp = camp:GetChildren()
	  
	for k,v in pairs(chp) do 
		if v then
			local hide = v.editor and v.editor.hide
			if not hide then
				local onclick = function(b)  
					worldeditor:Select(v)
				end 
				local tb2 = {tostring(v),OnClick=onclick}  
				rtb[#rtb+1] = tb2
			end
		end
	end
	nodetree:SetTableType(2)
	
	nodetree:FromTable(rtb)
	nodetree:SetSize(430,400)
end

 
function PANEL:SelectNode(node) 
	self.cnode = node
	
	local peditor = self.peditor
	peditor:Clear()
	
	
	
	
	
	if node then
	
		local meta = node
		if meta then
			local metacom = panel.Create("button") 
			metacom:SetColorAuto(Vector(0.3,0.6,0.9))
			metacom:SetSize(100,20)
			metacom:Dock(DOCK_TOP)
			metacom:SetText("Lua BaseType: ".. (node:GetParameter(VARTYPE_LUAENTTYPE) or "Entity"))
			metacom:SetTextAlignment(ALIGN_CENTER)
			metacom.OnClick = function()  end 
			peditor:Add(metacom)
			
			if node.editor  then
				metacom:SetText("Lua BaseType: ".. (meta.editor.name or "Entity"))
				self:ConstructParams(node,meta,peditor,node)
			end
		end
		
		
		local metacom = panel.Create("button") 
		metacom:SetColorAuto(Vector(0.3,0.6,0.9))
		metacom:SetSize(100,20)
		metacom:Dock(DOCK_TOP)
		metacom:SetText("Components")
		metacom:SetTextAlignment(ALIGN_CENTER)
		metacom.OnClick = function()  end 
		peditor:Add(metacom)
		
		for k,v in pairs(node:GetComponents()) do
		
			local type = "none"
			
			if v.GetTypename then
				type = tostring(v:GetTypename())
			else
				type = tostring(v)
			end
			
			local np = panel.Create() 
			np:SetSize(100,200)
			np.ty = 200
			np:SetColor(Vector(0.2,0.2,0.2)) 
			np:Dock(DOCK_TOP)
			
			local nph = panel.Create()
			nph:SetSize(100,20)
			nph:SetColor(Vector(20,20,0))
			nph:Dock(DOCK_TOP)
			nph:SetText(type)
			
			local npb = panel.Create()
			npb:SetSize(100,20)
			npb:SetColor(Vector(20,20,0))
			npb:Dock(DOCK_TOP) 
			
			function np:RezToggle(b)
				if np.minimized then
					np.minimized = false
					np:SetSize(100,np.ty)
					npb:SetSize(100,np.ty-20)
					npb:SetVisible(true)
					b:SetText("-")
				else
					np.minimized = true
					np:SetSize(100,20)
					npb:SetSize(100,0)
					npb:SetVisible(false)
					b:SetText("+")
				end
			end
			
			
			
			local delcom = panel.Create("button") 
			delcom:SetColorAuto(Vector(0.8,0.3,0.3))
			delcom:SetSize(20,20)
			delcom:Dock(DOCK_RIGHT)
			delcom:SetText("x")
			delcom:SetTextAlignment(ALIGN_CENTER)
			delcom.OnClick = function()  end
			nph:Add(delcom)
			
			local rezcom = panel.Create("button") 
			rezcom:SetColorAuto(Vector(0.2,0.6,0.8))
			rezcom:SetSize(20,20)
			rezcom:Dock(DOCK_RIGHT)
			rezcom:SetText("-")
			rezcom:SetTextAlignment(ALIGN_CENTER)
			rezcom.OnClick = function(b) np:RezToggle(b) peditor:UpdateLayout() end
			
			
			np:Add(nph)
			np:Add(npb)
			
			peditor:Add(np)
			
			local meta = components:GetType(type)
			if meta then
				local totalY = self:ConstructParams(node,meta,npb,v) 
				np:SetSize(100,20+totalY) 
				npb:SetSize(100,totalY) 
				np.ty = 20+totalY
				nph:Add(rezcom)
			else
				np:SetSize(100,20) 
				npb:SetSize(100,0) 
				np.ty = 20
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
		peditor:Add(addcom)
		
			
		peditor:UpdateLayout()
	end
end

function PANEL:ConstructParams(node,meta,parent,com)  
	local totalY = 0
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
					if(v.get) then
						inp:SetText(tostring(v.get(node,com,v))) 
					else
						inp:SetText(tostring(value or "")) 
					end
					inp.OnKeyDown = function(n,key) 
						if key== KEYS_ENTER then
							if v.apply then
								v.apply(n.node,n.m,n.v,tonumber(n:GetText()))
							else
								self:SetParam(n.node,n.v,tonumber(n:GetText()))
							end
						end
					end
					--inp.evalfunction = v2.proc 
				elseif v.valtype == "string" then 
					inp = panel.Create("input_text")  
					inp:SetSize(220,20)
					if(v.get) then
						inp:SetText(tostring(v.get(node,com,v))) 
					else
						inp:SetText(tostring(value or "")) 
					end
					--inp.evalfunction = v2.proc 
					inp.OnKeyDown = function(n,key) 
						if key== KEYS_ENTER then
							if v.apply then
								v.apply(n.node,n.m,n.v,n:GetText())
							else
								self:SetParam(n.node,n.v,n:GetText())
							end
						end
					end
				end
				inp.m = com
				inp.v = v 
				inp.node = node
				inp:Dock(DOCK_RIGHT)
				pva:Add(inp)
			elseif v.type == "action" then 
				pva:SetColorAuto(Vector(0.6,0.6,0.8))
				pva:SetText("click to "..v.text)
				pva.OnClick = function(b) v.action(node,b) end
			elseif v.type == "scripted" then  
				if v.getvalue then pva:SetText(v.text..":"..tostring(v.getvalue(node,com) or "")) end
			end
			totalY = totalY + 20
			 
			parent:Add(pva)
		end
	end
	return totalY
end
function PANEL:SetParam(node,metaparam,value)  
	if metaparam.type=="parameter" then
		node:SetParameter(metaparam.key,value)
	end
	if metaparam.reload and node.Load then
		node:Load()
	end
end