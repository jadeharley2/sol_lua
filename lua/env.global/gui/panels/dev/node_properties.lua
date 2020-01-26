


local function gettags(key)
	local taginfo = table.KVSwitch(debug.GetAPIInfo(key) or {})
	local fntemp = {}
	for k,v in pairs(taginfo) do 
		local nk = tonumber(k)
		taginfo[k] = nil
		if nk~=nil then
			fntemp[nk] = v
		end
	end
	return fntemp
end


taginfo = gettags('TAG_') 
taginfo2 = table.KVSwitch(taginfo)
comtypeinfo = table.KVSwitch(gettags('CTYPE_'))



local textsize = 16 
local layout = {
    color = {0,0,0},
    size = {200,200},
    subs = {
		{ name = "header", class = "header_0", 
			text = "Node properties",  
		},
		{ name = "nodename",
			size = {100,16},
			dock = DOCK_TOP,
			--textalignment = ALIGN_CENTER,
			text = "",
			color = {0.1,0.1,0.1}, 
			textcolor = {1,1,1}
		}, 
		{type="list", name = "propcontainer", class = "back",  
			size = {200,200},
            dock = DOCK_FILL, 
        }
    }   
}

function PANEL:Init()  

    gui.FromTable(layout,self,global_editor_style,self)
	--self.propcontainer = self.list.floater--ff_grid_floater
	
	hook.Add("editor_select","node_props",function(node)
		self:SelectNode(node)
	end)
	hook.Add("editor_deselect","node_props",function()
		self:SelectNode(nil)
	end)
end 
 
function PANEL:RefreshPanel() 
	if self.cnode then
		self:SelectNode(self.cnode)
	end  
end

function PANEL:SelectNode(node) 
	self.cnode = node
	
	self.nodename:SetText(tostring(node))
	local peditor = self.propcontainer--self.peditor
	peditor:ClearItems()
	
	 
	
	
	if node then
	
		local grouptest = gui.FromTable({
				items = {
					{ class="bgroup", name = "entbase", Title="Ent Base"},
					{ class="bgroup", name = "luabase", Title="Lua Base"},
					{ class="bgroup", name = "tags", Title="Tags"},
					{ class="bgroup", name = "com", Title="Components" }
				}
			},peditor,global_editor_style,peditor)
		--peditor:Add(grouptest)
 
 
		local meta = node
		if meta then 
			
			if node.editor  then
				peditor.luabase:SetTitle("Lua BaseType: ".. (meta.editor.name or "Entity"))
				self:ConstructParams(node,meta,peditor.luabase.contents,node)
			end
			self:ConstructParams(node,self.ent_meta_base,peditor.entbase.contents,node)

			local proc_params = {}
			hook.Call("node_properties",node,proc_params)
			PrintTable(proc_params)
			self:ConstructParams(node,{editor = {properties = proc_params}},peditor.entbase.contents,node)
		end
		 
		local contents = peditor.tags.contents 
		contents.populateTags = function()
			contents:Clear()
			local cTags = node:GetTags()
			for k,v in SortedPairs(cTags) do
				contents:Add(gui.FromTable({
					size = {20,textsize},
					dock = DOCK_TOP,
					text = '['..tostring(v)..'] '..(taginfo[v] or 'unknown tag'),
					margin = {5,2,0,0},
					color = {0.1,0.1,0.1},
					textcolor = {1,1,1},
					subs = {
						{ class = "btitle", text = "x", 
							node = node, tag = v,
							OnClick =  function(s) s.node:RemoveTag(v) contents.populateTags() self:UpdateLayout()  end
						}
					}
				},nil,global_editor_style))  
			end 
			contents:Add(gui.FromTable({ type = "enum_selector",
				dock=DOCK_TOP,
				size = {20,textsize},
				margin = {1,1,1,1}, 
				Options = taginfo2,
				OnSelect = function(s,val) 
					if val then
						MsgInfo("addtag:"..val) 
						node:AddTag(val)
						contents.populateTags()
						self:UpdateLayout()
					end
				end 
			},nil,global_editor_style))
		end
		contents.populateTags()


		-- -- -- --
		local con_contents = peditor.com.contents
		for k,v in pairs(node:GetComponents()) do
		
			local type = ""
			if v.GetTypename then type = v:GetTypename() end  

			local con_grp = gui.FromTable({class="cgroup",  Title=type,
				buttons = {
					{class = "btitle",text="x",OnClick=function() node:RemoveComponent(v) self:RefreshPanel() end}
				}  
			},nil,global_editor_style)
			con_contents:Add(con_grp)  
			   
			
			local meta = components:GetType(type)
			if meta then
				local totalY = self:ConstructParams(node,meta,con_grp.contents,v)  
			end
			 
		end 
		con_contents:Add(gui.FromTable({ type = "enum_selector",
			dock=DOCK_TOP,
			size = {20,textsize},
			margin = {1,1,1,1}, 
			Options = comtypeinfo,
			OnSelect = function(s,val) 
				if val then
					MsgInfo("addcom:"..val)
					node:AddComponent(val)
					self:RefreshPanel()
				end
			end 
		},nil,global_editor_style))
		 
		
			
		self:UpdateLayout()
		self.propcontainer:ScrollToTop()
	end
end

function PANEL:ConstructParams(node,meta,parent,com)  
	local totalY = 0
	if meta.editor and meta.editor.properties then
		for k,v in SortedPairs(meta.editor.properties) do 
			local pva = panel.Create("button") 
			pva:SetColorAuto(Vector(0.6,0.6,0.6)/5,0)
			pva:SetTextColor(Vector(1,1,1))
			pva:SetSize(20,textsize)
			pva:Dock(DOCK_TOP)
			pva:SetMargin(5,2,0,0)
			pva:SetTextAlignment(ALIGN_LEFT)
			pva:SetText(v.text..":")
			pva:SetTextOnly(true)
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
						_sub_header = { color = {0.1,0.1,0.1} } 
					},nil,global_editor_style) 

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
							mgr:AddItem(gui.FromTable(arg_template,nil,global_editor_style,it))
							it.val:SetText(v)
						end
					end
					
					mgr:AddButton(gui.FromTable({ class = 'btitle',
						text = 'add', ColorAuto = Vector(0.2,1,0.2)/10, textcolor = {0.2,1,0.2}, OnClick = function()
							mgr:AddItem(gui.FromTable(arg_template,nil,global_editor_style))
							self:UpdateLayout()
						end
					},nil,global_editor_style))
					mgr:AddButton(gui.FromTable({ class = 'btitle',
						text = 'sel', ColorAuto = Vector(0.5,0.9,0.9)/10, textcolor = {0.5,0.9,0.9}, OnClick = function()
							local lp = file.GetDirectory(inp:GetText())
							OpenFileDialog(lp,nil,function(path) 
								inp:SetText(path)
								fApply(inp)
							end)
						end
					},nil,global_editor_style))
					mgr:AddButton(gui.FromTable({ class = 'btitle',
						text = 'clr', ColorAuto = Vector(0.5,0.9,0.9)/10, textcolor = {0.5,0.9,0.9}, OnClick = function()
							inp:SetText('')
							fApply(inp)
						end
					},nil,global_editor_style))

					--mgr:Add(gui.FromTable({ type = "button",
					--	dock=DOCK_TOP,
					--	size = {20,textsize/2},
					--	margin = {1,1,1,1},
					--	ColorAuto = Vector(0.6,0.6,0.6),--0.2,1,0.2),
					--	textalignment = ALIGN_CENTER,
					--	text = "+", 
					--	OnClick = function() 
					--		mgr:AddItem(gui.FromTable(arg_template,nil,global_editor_style))
					--		self:UpdateLayout()
					--	end
					--},nil,global_editor_style))

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
				pva.OnClick = function(b) 
					if v.action(node,b) then
						self:SelectNode(self.cnode)
					end
				end 
			elseif v.type == "indicator" then 
				pva:SetColorAuto(Vector(0.6,0.6,0.8))
				pva:SetText(v.text)   
				inp = panel.Create('checkbox') 
				inp.active = false
				inp:SetValue(v.value(node))
				inp:Dock(DOCK_RIGHT)
				pva:Add(inp)
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
