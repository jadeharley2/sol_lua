


local flaginfo = table.KVSwitch(debug.GetAPIInfo('FLAG_'))
local fntemp = {}
for k,v in pairs(flaginfo) do 
	local nk = tonumber(k)
	flaginfo[k] = nil
	if nk~=nil then
		fntemp[nk] = v
	end
end
flaginfo = fntemp

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
			local hide = (v.editor and v.editor.hide) or v:HasFlag(320230)
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
local textsize = 16
local style = {
	btitle = { type = "button",
		dock=DOCK_RIGHT,
		size = {20,textsize},
		margin = {1,1,1,1},
		textalignment = ALIGN_CENTER,
	},
	bgroup = { type="group",  
		dock=DOCK_TOP,
		_sub_header = {
			color = {0.3,0.6,0.9},
			size = {20,textsize},
			textcolor = {0,0,0}
		} 
	},
	cgroup = { type="group",  
		dock=DOCK_TOP,
		_sub_header = {
			color = {0.9,0.6,0.3},
			textcolor = {0,0,0},
			size = {20,textsize},
			textalignment = ALIGN_LEFT
		} 
	}
}
function PANEL:SelectNode(node) 
	self.cnode = node
	
	local peditor = self.pe_in--self.peditor
	peditor:Clear()
	
	
	
	
	
	if node then
	
		local grouptest = gui.FromTable({
				subs = {
					{ class="bgroup", name = "entbase", Title="Ent Base"},
					{ class="bgroup", name = "luabase", Title="Lua Base"},
					{ class="bgroup", name = "flags", Title="Flags"},
					{ class="bgroup", name = "com", Title="Components" }
				}
			},peditor,style,peditor)
		--peditor:Add(grouptest)
 
 
		local meta = node
		if meta then 
			
			if node.editor  then
				peditor.luabase:SetTitle("Lua BaseType: ".. (meta.editor.name or "Entity"))
				self:ConstructParams(node,meta,peditor.luabase.contents,node)
			end
			self:ConstructParams(node,self.ent_meta_base,peditor.entbase.contents,node)
		end
		 
		local contents = peditor.flags.contents
		contents.selectNewFlag = function(s) 
			if s.key then
				node:AddFlag(s.key)
				contents.populateFlags()
			else
				contents.plus:SetVisible(true)
				for k,v in pairs(contents.btns) do
					contents:Remove(v)
				end
			end
			self:UpdateLayout()
		end
		contents.addFlag = function(s)
			local knownFlags = flaginfo
			local btns = {}
			contents.plus = s
			s:SetVisible(false)
			for k,v in SortedPairs(knownFlags) do
				if not node:HasFlag(k) then
					local b = gui.FromTable({ type = "button",
						dock=DOCK_TOP,
						size = {20,textsize},
						margin = {1,1,1,1},
						ColorAuto = Vector(0.5,0.7,0.5), 
						text = '['..k..'] '..v, 
						key = k,
						OnClick = contents.selectNewFlag
					},nil,style)
					btns[k] = b
					contents:Add(b)  
				end
			end
			local b = gui.FromTable({ type = "button",
				dock=DOCK_TOP,
				size = {20,textsize},
				margin = {1,1,1,1},
				ColorAuto = Vector(0.5,0.7,0.5), 
				textalignment = ALIGN_CENTER,
				text = 'CANCEL', 
				OnClick = contents.selectNewFlag
			},nil,style)
			btns['cncl'] = b
			contents:Add(b)  


			contents.btns = btns
			self:UpdateLayout()
		end
		contents.populateFlags = function()
			contents:Clear()
			local cflags = node:GetFlags()
			for k,v in SortedPairs(cflags) do
				contents:Add(gui.FromTable({
					size = {20,textsize},
					dock = DOCK_TOP,
					text = '['..tostring(v)..'] '..(flaginfo[v] or 'unknown flag'),
					margin = {5,2,0,0},
					color = {0.1,0.1,0.1},
					textcolor = {1,1,1},
					subs = {
						{ class = "btitle", text = "x", 
							node = node, tag = v,
							OnClick =  function(s) s.node:RemoveFlag(v) contents.populateFlags() self:UpdateLayout()  end
						}
					}
				},nil,style))  
			end
			contents:Add(gui.FromTable({ type = "button",
				dock=DOCK_TOP,
				size = {20,textsize},
				margin = {1,1,1,1},
				ColorAuto = Vector(0.2,1,0.2),
				textalignment = ALIGN_CENTER,
				text = "+",
				node = node,
				OnClick = contents.addFlag
			},nil,style))  
		end
		contents.populateFlags()

		local con_contents = peditor.com.contents
		for k,v in pairs(node:GetComponents()) do
		
			local type = tostring(ifthen(v.GetTypename,v:GetTypename(),v)) 

			local con_grp = gui.FromTable({class="cgroup",  Title=type,
				buttons = {
					{class = "btitle",text="x",OnClick=function() node:RemoveComponent(v) self:RefreshPanel() end}
				}
			},nil,style)
			con_contents:Add(con_grp)  
			   
			
			local meta = components:GetType(type)
			if meta then
				local totalY = self:ConstructParams(node,meta,con_grp.contents,v)  
			end
			 
		end
		con_contents:Add(gui.FromTable({ type = "button",
			dock=DOCK_TOP,
			size = {20,textsize},
			margin = {1,1,1,1},
			ColorAuto = Vector(0.2,1,0.2),
			textalignment = ALIGN_CENTER,
			text = "+"
		},nil,style))
		 
		
			
		peditor:UpdateLayout()
	end
end

function PANEL:ConstructParams(node,meta,parent,com)  
	local totalY = 0
	if meta.editor and meta.editor.properties then
		for k,v in SortedPairs(meta.editor.properties) do 
			local pva = panel.Create("button") 
			pva:SetColorAuto(Vector(0.6,0.6,0.6),0)
			pva:SetSize(20,textsize)
			pva:Dock(DOCK_TOP)
			pva:SetMargin(5,2,0,0)
			pva:SetTextAlignment(ALIGN_LEFT)
			pva:SetText(v.text..":")
			--pva.OnClick = function() end
			parent:Add(pva)
			
			local value = false
			if v.type=="parameter" then
				value = node:GetParameter(v.key)
				
				local inp = false
				if v.valtype == "bool" then
					inp = panel.Create("checkbox") 
					inp:SetValue(value or false)
					inp:Dock(DOCK_RIGHT)
					pva:Add(inp)
				elseif v.valtype == "number" then 
					inp = panel.Create("input_text")   
					inp:SetSize(220,textsize) 
					inp:Dock(DOCK_RIGHT)
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
					pva:Add(inp)
					--inp.evalfunction = v2.proc 
				elseif v.valtype == "string" then 
					inp = panel.Create("input_text")  
					inp:SetSize(220,textsize)
					inp:Dock(DOCK_RIGHT)
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
					pva:Add(inp)
				elseif v.valtype == "path" then 
   
					local val = ""
					if(v.get) then
						val = tostring(v.get(node,com,v))
					else
						val = tostring(value or "")
					end

					local vargs = string.split(val,'?')
					



					inp = panel.Create("input_text")  
					inp.vargs = vargs
					inp:SetSize(220,textsize)
					inp:Dock(DOCK_RIGHT)

					inp:SetText(vargs[1] or '')

					pva:Add(inp)
					pva:SetColorAuto(Vector(0.6,0.6,0.6))
					--inp.evalfunction = v2.proc 

					local mgr = gui.FromTable({class = 'cgroup', Title = 'arguments',margin = {5,2,0,0},
						_sub_header = { color = {0.6,0.6,0.6} } 
					},nil,style) 

					local fApply =  function(n)
						local path = n:GetText()
						local cvargs =  mgr:GetItems() 
						if cvargs and #cvargs > 0 then 
							cvargs = table.Select(cvargs,function(s) return s:GetChildren()[2] end) 
							path = path .. '?' .. string.join('&',table.Select(cvargs,'GetText'))
						end 
						--MsgInfo(path)
						if v.apply then
							v.apply(n.node,n.m,n.v,path)
						else
							self:SetParam(n.node,n.v,path)
						end
					end

					local fArgApply = function(n,key)
						if key== KEYS_ENTER then 
							fApply(inp)
						end
					end
					local fArgRemove = function(n)
						local arg = n:GetParent() 
						mgr:RemoveItem(arg)
						self:UpdateLayout()
					end

					inp.OnKeyDown = function(n,key) 
						if key== KEYS_ENTER then fApply(n) end
					end 

					local arg_template = { 
						size = {220,textsize}, 
						dock = DOCK_TOP, 
						color = {0,0,0},
						subs ={
							{ class = "btitle", text = 'x', OnClick = fArgRemove},
							{ name = 'val', type = "input_text", text = '', dock = DOCK_FILL, OnKeyDown = fArgApply }
						}
					}
					if vargs[2] then
						for k,v in pairs(string.split(vargs[2],'&')) do
							local it = {}
							mgr:AddItem(gui.FromTable(arg_template,nil,style,it))
							it.val:SetText(v)
						end
					end
					
					mgr:AddButton(gui.FromTable({ class = 'btitle',
						text = 'add', ColorAuto = Vector(0.2,1,0.2), OnClick = function()
							mgr:AddItem(gui.FromTable(arg_template,nil,style))
							self:UpdateLayout()
						end
					},nil,style))
					mgr:AddButton(gui.FromTable({ class = 'btitle',
						text = 'sel', ColorAuto = Vector(0.5,0.9,0.9), OnClick = function()
							local lp = file.GetDirectory(inp:GetText())
							OpenFileDialog(lp,nil,function(path) 
								inp:SetText(path)
								fApply(inp)
							end)
						end
					},nil,style))
					mgr:AddButton(gui.FromTable({ class = 'btitle',
						text = 'clr', ColorAuto = Vector(0.5,0.9,0.9), OnClick = function()
							inp:SetText('')
							fApply(inp)
						end
					},nil,style))

					--mgr:Add(gui.FromTable({ type = "button",
					--	dock=DOCK_TOP,
					--	size = {20,textsize/2},
					--	margin = {1,1,1,1},
					--	ColorAuto = Vector(0.6,0.6,0.6),--0.2,1,0.2),
					--	textalignment = ALIGN_CENTER,
					--	text = "+", 
					--	OnClick = function() 
					--		mgr:AddItem(gui.FromTable(arg_template,nil,style))
					--		self:UpdateLayout()
					--	end
					--},nil,style))

					--mgr:SetVisible(false)
					parent:Add(mgr)

					pva.OnClick = function() 
						local isvisible = not mgr:GetVisible()
						mgr:SetVisible(isvisible) 
						if isvisible then

						end
						self:UpdateLayout()
					end
				elseif v.valtype == "vector" then 
					inp = panel.Create("input_text")  
					inp:SetSize(220,textsize)
					inp:Dock(DOCK_RIGHT)
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
					pva:Add(inp)
				elseif v.valtype == "color" then 

				--	MsgN(v.name,value)
					inp = panel.Create()   
					inp:SetSize(220,textsize) 
					if(v.get) then 
						inp:SetColor(v.get(node,com,v))  
					else
						inp:SetColor(value or Vector(0,0,0))  
					end
					inp:SetCanRaiseMouseEvents(false)
					inp:Dock(DOCK_RIGHT)
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
					pva:Add(inp)
				end
				inp.m = com
				inp.v = v 
				inp.node = node
			elseif v.type == "action" then 
				pva:SetColorAuto(Vector(0.6,0.6,0.8))
				pva:SetText("click to "..v.text)
				pva.OnClick = function(b) v.action(node,b) end 
			elseif v.type == "scripted" then  
				if v.getvalue then pva:SetText(v.text..":"..tostring(v.getvalue(node,com) or "")) end
			end
			totalY = totalY + textsize
			 
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
			name = {text = "name",type="parameter",valtype="string",key=VARTYPE_NAME}, 
			seed = {text = "seed",type="parameter",valtype="number",key=VARTYPE_SEED}, 
			--flags = {text = "flags",type="flags",action = function(ent)   end},
			position = {text = "position",type="parameter",valtype="vector",
				apply = function(n,u,k,v) n:SetPos(v) end,
				get = function(n,u,k) 
					return n:GetPos()
				end 
			},
			rotation = {text = "rotation",type="parameter",valtype="vector",
				--apply = function(n,u,k,v) n:SetPos(v) end,
				--get = function(n,u,k) 
				--	return n:GetPos()
				--end
			},
			scale = {text = "scale",type="parameter",valtype="vector",
				apply = function(n,u,k,v) n:SetScale(v) end,
				get = function(n,u,k) 
					return n:GetScale()
				end 
			},
		}
	}
}