



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
	

	local sep = panel.Create()
	sep:Dock(DOCK_TOP)
	sep:SetColor(Vector(0.5,0.5,0.5))
	sep:SetSize(200,5)
	self:Add(sep)


	local ff_grid_floater = panel.Create()  
	ff_grid_floater:SetSize(400,800)  
	--ff_grid_floater:SetAutoSize(false,true) 
	ff_grid_floater:SetColor(Vector(0.2,0.2,0.2))
	 


	local peditor = panel.Create("floatcontainer")
	peditor:SetSize(200,400)
	peditor:Dock(DOCK_FILL)
	peditor:SetScrollbars(1) 
	peditor:SetFloater(ff_grid_floater) 
	peditor:SetColor(Vector(0,0,0)) 
	peditor:UpdateLayout()
	ff_grid_floater.level = 0
	self:Add(peditor)
	
	self.nodetree = nodetree
	self.peditor = peditor

	self.pe_in = ff_grid_floater
	
	self:UpdateCnodes() 
	
end 
function PANEL:UpdateCnodes(root) 
	local nodetree = self.nodetree
	local rtb = {"types"}
	
	root = root or GetCamera():GetParent()
	local chp = root:GetChildren()
	  
	local tb2 = {"<<parent>>",OnClick=function(b) 
		local ct = CurTime()
		if b.lastclc and b.lastclc>(ct-0.5) then
			if root:GetParent() then
				self:UpdateCnodes(root:GetParent())
			end
		else
			b.lastclc = ct 
			worldeditor:Select(root)
		end
	end}  
	rtb[#rtb+1] = tb2

	for k,v in SortedPairs(chp) do 
		if v then
			local hide = v.editor and v.editor.hide
			if not hide then
				local onclick = function(b) 
					local ct = CurTime()
					if b.lastclc and b.lastclc>(ct-0.5) then
						self:UpdateCnodes(v)
					else
						b.lastclc = ct 
						worldeditor:Select(v)
					end
				end 
				local tb2 = {tostring(v),OnClick=onclick}  
				rtb[#rtb+1] = tb2
			end
		end
	end
	nodetree:SetTableType(2)
	
	nodetree:FromTable(rtb)
	nodetree:SetSize(430,400) 
	nodetree:UpdateLayout()
end

 
function PANEL:RefreshPanel() 
	if self.cnode then
		self:SelectNode(self.cnode)
	end  
end
function PANEL:SelectNode(node) 
	self.cnode = node
	
	local peditor = self.pe_in--self.peditor
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
			self:ConstructParams(node,self.ent_meta_base,peditor,node)
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
			--np.ty = 200
			np:SetColor(Vector(0.2,0.2,0.2)) 
			np:Dock(DOCK_TOP)
			np:SetMargin(0,2,0,0)
			np:SetAutoSize(false,true)
			
			local nph = panel.Create()
			nph:SetSize(100,20)
			nph:SetColor(Vector(1,1,0))
			nph:Dock(DOCK_TOP)
			nph:SetText(type)
			
			local npb = panel.Create()
			npb:SetSize(100,0)
			npb:SetColor(Vector(0.3,0.3,0.3))
			npb:Dock(DOCK_TOP) 
			npb:SetAutoSize(false,true)
			
			function np:RezToggle(b)
				if np.minimized then
					np.minimized = false
					--np:SetSize(100,np.ty)
					--npb:SetSize(100,np.ty-20)
					npb:SetVisible(true)
					b:SetText("-")
				else
					np.minimized = true
					--np:SetSize(100,20)
					--npb:SetSize(100,0)
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
			delcom:SetMargin(1,1,1,1)
			delcom.OnClick = function() node:RemoveComponent(v) self:RefreshPanel() end
			nph:Add(delcom)
			
			local rezcom = panel.Create("button") 
			rezcom:SetColorAuto(Vector(0.2,0.6,0.8))
			rezcom:SetSize(20,20)
			rezcom:Dock(DOCK_RIGHT)
			rezcom:SetText("-")
			rezcom:SetMargin(1,1,1,1)
			rezcom:SetTextAlignment(ALIGN_CENTER)
			rezcom.OnClick = function(b) np:RezToggle(b) peditor:UpdateLayout() end
			nph:Add(rezcom)
			
			np:Add(nph)
			np:Add(npb)
			
			peditor:Add(np)
			
			local meta = components:GetType(type)
			if meta then
				local totalY = self:ConstructParams(node,meta,npb,v) 
				--np:SetSize(100,20+totalY) 
				--npb:SetSize(100,totalY) 
				--np.ty = 20+totalY
				--nph:Add(rezcom)
			else
				--np:SetSize(100,20) 
				--npb:SetSize(100,0) 
				--np.ty = 20
			end
			
			local type_metaname = v.__metaname

			if type_metaname then
				local metainfo = debug.GetAPIInfo(type_metaname)
				if metainfo then
					--for k,v in pairs(metainfo) do 
					--	local pva = panel.Create("button") 
					--	pva:SetColorAuto(Vector(0.6,0.6,0.6))
					--	pva:SetSize(20,20)
					--	pva:Dock(DOCK_TOP)
					--	pva:SetTextAlignment(ALIGN_LEFT)
					--	pva:SetText(v.text..":")
					--	node:Add(pva)
					--end
				end
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
			pva:SetMargin(5,2,0,0)
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
				elseif v.valtype == "vector" then 
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
							--
						end
					end
				elseif v.valtype == "color" then 

				--	MsgN(v.name,value)
					inp = panel.Create()   
					inp:SetSize(220,20) 
					if(v.get) then 
						inp:SetColor(v.get(node,com,v))  
					else
						inp:SetColor(value or Vector(0,0,0))  
					end
					inp:SetCanRaiseMouseEvents(false)
					pva.OnClick = function(s) 
						ColorPicker(inp:GetColor(),
						function(ee,cc) 
							local n = inp
							inp:SetColor(cc) 
							if v.apply then
								v.apply(n.node,n.m,n.v,cc)
							else
								self:SetParam(n.node,n.v,cc)
							end
						end) end
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

PANEL.ent_meta_base = {
	editor = {
		properties = {
			position = {text = "position",valtype="vector",
				apply = function(n,u,k,v) n:SetPos(v) end,
				get = function(n,u,k) 
					return n:GetPos()
				end 
			},
			rotation = {text = "rotation",valtype="vector",
				--apply = function(n,u,k,v) n:SetPos(v) end,
				--get = function(n,u,k) 
				--	return n:GetPos()
				--end
			},
			scale = {text = "scale",valtype="vector",
				apply = function(n,u,k,v) n:SetPos(v) end,
				get = function(n,u,k) 
					return n:GetPos()
				end 
			},
		}
	}
}