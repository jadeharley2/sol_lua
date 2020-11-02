
CURRENT_DEBUG_FLOW = CURRENT_DEBUG_FLOW or false
CURRENT_SELECTED_ANCHOR = false
cuup = cuup or {}

module.Require("flow")

function GUI_CURVE_UPDATE()
	for k,v in pairs(cuup) do
		local p = v:GetParent()
		local pv = p:GetScreenPos()
		local mul = p:GetTotalScaleMul()
		local f1 = (v.from:GetScreenPos()-pv)/mul
		local f4 = ((v.to:GetScreenPos()-pv)/mul*2-f1)
		
		local bend = math.min(math.abs(f4.x-f1.x)/2, v.bend)
		
		local f2 = f1+Point(bend,0)
		local f3 = f4-Point(bend,0)
		v:SetCurve(f1,f2,f3,f4)
	end
end

hook.Add(EVENT_GLOBAL_PREDRAW, "gui.curve.update", GUI_CURVE_UPDATE)

local layout = { 
	
	color = {0,0,0},
	subs = {
		{
			name = "curfile",
			gradient = {{0,0,0},{0.5,0.5,0.7},90},
			textcolor = {100,1,1},
			size = {30,30},
			text = "untitled",
			dock = DOCK_TOP
		},
		
		{
			name = "floater",
			size = {300,300},
			dock = DOCK_FILL,
			color = {0,0,0},
			clip = true,
			subs = {
				{
					type = "graph_grid",
					name = "nodelayer",
					size ={20000,20000},
					TextureScale = (Point(1,1)*(20000/256)),
					subs = {
						{
							name = "curvelayer",
							textonly = true, 
							dock = DOCK_FILL,
							mouseenabled = false
						}
					}
				}
			}
		}
	}
}
GLOBAL_FLOW_EDITOR = false
function PANEL:Init()  
	if CURRENT_DEBUG_FLOW then
		CURRENT_DEBUG_FLOW:Dispose()
		CURRENT_DEBUG_FLOW = false
	end
		
	self.cnodec = 0
	self.named = {}
	local vsize = GetViewportSize()-Point(0,20)
	self:SetSize(vsize.x,vsize.y)
	self:SetPos(0,-10)
	self:Dock(DOCK_FILL)
	
	gui.FromTable(layout,self,global_editor_style,self)
 

	self.nodelayer.curvelayer = self.curvelayer
	self.nodelayer.editor = self
	
	local ED = self 
	
	GLOBAL_FLOW_EDITOR = self
	
	 --[[
	  
	local lastpath = "forms/flow"
	local curfilepath = false
	self.bnew.OnClick = function(s) 
		self:ClearNodes()
		curfilepath= ""
		self.curfile:SetText("untitled")
	end
	 
	self.bload.OnClick = function(s)  
		OpenFileDialog(lastpath,".json",function(path)
			lastpath = file.GetDirectory(path)
			self:Open(path)
			curfilepath= path
			self.curfile:SetText(path)
		end) 
	end
	self.bloadtarget.OnClick = function(s)   
		local c = E_FS:GetComponent(CTYPE_FLOW)
		if c then
			local path = c:GetScripts()[1]
			if path then
				lastpath = file.GetDirectory(path)
				self:Open(path)
				curfilepath= path
				self.curfile:SetText(path)
			end
		end
	end
	 
	 
	self.bsave.OnClick = function(s)  
		if curfilepath then
			json.Write(curfilepath,self:ToData())
			MsgInfo("Saved! "..curfilepath)
		else
			self.bsaveas.OnClick()
		end
	end
	  
	self.bsaveas.OnClick = function(s)  
		SaveFileDialog(lastpath,".json",function(path)
			json.Write(path,self:ToData())
			MsgInfo("Saved! "..path)
			curfilepath = path
			self.curfile:SetText(path)
		end)
	end
	 
	self.brun.OnClick = function(s) 
		self:Compile()
	end
	self.brun_cam.OnClick = function(s) 
		self:Compile(GetCamera())
	end
	self.brun_ply.OnClick = function(s) 
		self:Compile(LocalPlayer())
	end
	self.brun_selected.OnClick = function(s) 
		self:Compile(E_SELECTION)
	end
	self.bcom_selected.OnClick = function(s) 
		local c = E_FS:GetComponent(CTYPE_FLOW)
		if c then
			c:Recompile()
		end
	end

	local trpanel = self.trpanel  
	local functlist = {}
	local comlist = {}
	
	local flist = flowbase.GetMethodList()
	
	for k,v in pairs(flist) do
		local type,name = unpack(v:split('.'))
		local tl = functlist[type] or {} 
		tl[#tl+1] = name
		table.sort(tl)
		functlist[type] = tl
	end
	
	for k,v in pairs(file.GetFiles("forms/flow/functions",".json",false)) do
		comlist[#comlist+1] = string.lower(file.GetFileNameWE(v))   
	end
	

	local eventlist = {"startup","invoke","interact","input.keydown"}
	for k,v in pairs(debug.GetAPIInfo('EVENT_')) do
		if string.starts(k,'EVENT_') then
			local subname =string.sub(string.lower(k),7)
			eventlist[#eventlist+1] = subname
		end
	end
	table.sort(eventlist)
	
	local tab = {
		event = eventlist, 
		flow = {"branch","assign","sequence","join","while","for"},
		constants = {"string","boolean","int","float","vector2","vector3","vector4","quaternion","Tex2DArray"},
		variables = {"string","boolean","int","float","vector2","vector3","vector4","quaternion","scriptednode"},
		input = {"string","boolean","int","float","vector2","vector3","vector4","quaternion","scriptednode"},
		output = {"string","boolean","int","float","vector2","vector3","vector4","quaternion","scriptednode"},
		functions = functlist,
		compounds = comlist,
		"group",
		map = {"point","line","polygon","group"},
	} 
	trpanel:SetTableType(3) 
	trpanel:FromTable(tab) 
	trpanel.root:SetSize(280,trpanel.root:GetSize().x)
	trpanel.grid:SetColor(Vector(0.1,0.1,0.1))
	
	trpanel.OnItemClick = function(tree,element)
		self:CreateNewNode(element)
	end 
	]]
	
	
	 
	
	
	
	
	
	self:UpdateLayout()

	--trpanel:ScrollToTop()
	
end
function PANEL:CreateNewNode(element)
	local cmd = {}
	local ep = element
	while ep.text do
		cmd[#cmd+1] = ep.text 
		ep = ep:GetParent()
	end
	local epr = {}
	local elen = #cmd
	for k,v in ipairs(cmd) do
		epr[elen-k+1] = v
	end
	PrintTable(epr)
	if epr[1] == "functions" then
		local com = epr[2].."."..epr[3] 
		local n = panel.Create("graph_node_function")  
		self:AddNode(n)
		n:Load(com) 
	elseif epr[1] == "compounds" then
		local com = epr[2]--.."."..epr[3] 
		local n = panel.Create("graph_node_compound")  
		self:AddNode(n)
		n:Load(com) 
	elseif epr[1] == "constants" and epr[2] then
		local n = panel.Create("graph_node_const")  
		self:AddNode(n)
		n:Load(epr[2])
	elseif epr[1] == "variables" and epr[2] then
		local n = panel.Create("graph_node_var")  
		self:AddNode(n)
		n:Load(epr[2])
	elseif (epr[1] == "input" or epr[1] == "output") and epr[2] then 
		MsgBox({
			name = "valinput",
			type = "input_text",
			text = xvalue,
			size = {20,20},
			dock = DOCK_TOP 
		},"Enter "..epr[1].." name: ",{"ok","cancel"},function(val,s)
			if val == "ok" then
				local name =  s.valinput:GetText()
				local n = panel.Create("graph_node_"..epr[1])  
				n.ft = "input"
				self:AddNode(n)
				n:Load(epr[2], name) 
			end
		end)	 
	elseif epr[1] == "event" then
		local n = panel.Create("graph_node_event")  
		self:AddNode(n)
		n:Load(epr[2])
	elseif epr[1] == "flow" then
		if epr[2] == "branch" then
			local n = panel.Create("graph_node_branch")  
			self:AddNode(n)
			n:Load()
		elseif epr[2] == "assign" then
			local n = panel.Create("graph_node_assign")  
			self:AddNode(n)
			n:Load()
		elseif epr[2] == "sequence" then
			local n = panel.Create("graph_node_sequence")  
			self:AddNode(n)
			n:Load()
		elseif epr[2] == "join" then
			local n = panel.Create("graph_node_join")  
			self:AddNode(n)
			n:Load()
		elseif epr[2] == "while" then
			local n = panel.Create("graph_node_while")  
			self:AddNode(n)
			n:Load()
		elseif epr[2] == "for" then
			local n = panel.Create("graph_node_for")  
			self:AddNode(n)
			n:Load()
		end
	elseif epr[1] == "group" then
		local n = panel.Create("graph_group")  
		self:AddNode(n)
		n:Load()
	elseif epr[1] == "map" then
		if epr[2] == "point" then
			local n = panel.Create("editor_point")  
			self:AddNode(n)
			n:Load(epr[3])
		elseif epr[2] == "line" then
			local n = panel.Create("line") 
			n:SetColor(Vector(83,164,255)/255)
			n:SetUseGlobalScale(true)
			self:AddNode(n)
			local first = false
			hook.Add("input.mousedown","linebuild",function()
				if input.leftMouseButton() then
					local top = panel.GetTopElement()
					if top then
						local point = false
						if top:__eq(ED.nodelayer) then
							local pn = panel.Create("editor_point")  
							self:AddNode(pn)
							pn:Load(epr[3])
							pn:SetPos(ED.nodelayer:GetLocalCursorPos()) 
							point = pn
						elseif top.edpt then
							point = top
						end
						if point then
							n:AddPoint(point)
							if point._tempfirst then
								hook.Remove("input.mousedown","linebuild")
								point._tempfirst = nil
							else
								if not first then
									first = point
									first._tempfirst = true
								end
							end
						end
					end 
				elseif input.rightMouseButton() then
					hook.Remove("input.mousedown","linebuild")
					if first then
						first._tempfirst = nil
						first = false
					end
				end
			end)
			--n:Load(epr[3])
		else
		
		end
	end
end
function PANEL:Compile(ents) 
	if CURRENT_DEBUG_FLOW then
		CURRENT_DEBUG_FLOW:Dispose()
		CURRENT_DEBUG_FLOW = false
	end
	for k,v in pairs(self.named) do
		v:SetError()
	end
	local j = json.ToJson(self:ToData())
	local result, error = flowbase.CompileJson(j) 
	if result then
		if result:IsValid() then
			MsgN("Compilation successful")
			MsgInfo("Compilation successful",Vector(0,1,0))
			CURRENT_DEBUG_FLOW = result
			result:SetupHooks()
			result:TryRun("startup")
			if ents then
				if istable(ents) then
					for k,v in pairs(ents) do
						result:SetValue("self",v)
						result:TryRun("invoke") 
					end
				elseif IsValidEnt(ents) then
					result:SetValue("self",ents)
					result:TryRun("invoke") 
				end
			end
		else
			MsgN("Compilation failed")
			MsgInfo("Compilation failed")
			local errors = json.FromJson(result:GetErrors())
			for k,v in pairs(errors) do
				if v and v.nodeid then
					local nid = tonumber(v.nodeid)

					local nod = self.named[nid] 
					if nod then
						nod:SetError(v.message)
						MsgN(v.message)
						MsgN(v.stacktrace)
					end
				end
			end 
		end
	else
		MsgN("Compilation failed")
		MsgInfo("Compilation failed")
	end
end
function PANEL:GetFreeId()
	local notfree = {}
	for k,v in pairs(self.nodelayer:GetChildren()) do
		if v.id then
			notfree[v.id] = true  
			if v.nodegroup then
				for kk,vv in pairs(v:GetChildren()) do 
					if vv.id then
						notfree[vv.id] = true  
					end
				end
			end
		end
	end 
	local id = 1
	while notfree[id] do 
		id = id + 1
	end
	 
	return id
end

function PANEL:AddNode(n,idoverride) 
	local nodelayer = self.nodelayer 
	n.editor = nodelayer
	local ml = nodelayer:GetScaleMul()
	n:SetPos(-nodelayer:GetPos()/ml)
	nodelayer:Add(n)
	
	local id = self:GetFreeId() 
	n.id = id
	self.named[n.id] = n
	MsgN("CreateNode",n.id)
end 
function PANEL:ClearNodes(node)
	node = node or self.nodelayer
	for k,v in pairs(node:GetChildren()) do
		if v and v.ToData then
			if v.nodegroup then
				self:Clear(v)
			end
			self:RemoveNode(v)
		end
	end
end
function PANEL:Open(filename) 
	self:ClearNodes()
	self:FromData(json.Read(filename))
end

function PANEL:KeyDown() 
	if input.KeyPressed(KEYS_DELETE) then
		local nl = self.nodelayer
		local nls = nl.selector
		for k,v in pairs(nls:GetSelected()) do
			self:RemoveNode(v)
		end
		nls:Deselect()
		MsgN("DEL")
		PrintTable(nl.selector:GetSelected())
	elseif input.KeyPressed(KEYS_C) and input.KeyPressed(KEYS_CONTROLKEY) then
		local nl = self.nodelayer
		local lls = nl.selector:GetSelected() 
		local text = json.ToJson(self:ToData(lls)):ToText()
		ClipboardSetText(text)
		MsgN("COPY",text)
		
	elseif input.KeyPressed(KEYS_V) and input.KeyPressed(KEYS_CONTROLKEY) then  
		local data = json.FromJson(json.FromText(ClipboardGetText())) 
		local nodes = self:FromData(data,Point(100,-100)) 
		if nodes then
			self.nodelayer.selector:Select(nodes)
			MsgN("PASTE")
		end
	end
end
function PANEL:Update() 
	
end


function PANEL:MouseEnter() 
	--MsgN("in")
	hook.Add("input.keydown","editor_graph",function() self:KeyDown() end)
end
function PANEL:MouseLeave() 
	--MsgN("out")
	hook.Remove("input.keydown","editor_graph")
end

function PANEL:RemoveNode(n)
	local nl = self.nodelayer
	if n.id then
		self.named[n.id] = nil
	end
	if n.UnlinkAll then
		n:UnlinkAll()
	end
	nl:Remove(n) 
	MsgN("RemoveNode",n.id)
end 

PANEL.typetable = {
	func              = "graph_node_function",
	compound          = "graph_node_compound",
	event             = "graph_node_event",
	const             = "graph_node_const",
	variable          = "graph_node_var",
	assign            = "graph_node_assign",
	branch            = "graph_node_branch",
	sequence          = "graph_node_sequence",
	join              = "graph_node_join",
	["while"]         = "graph_node_while",
	["for"]           = "graph_node_for",
	group             = "graph_group",
}

function PANEL:ToData(selection)
	local nodes = {1}
	local input = {}
	local output = {}
	for k,v in pairs(selection or self.nodelayer:GetChildren()) do
		if v and v.ToData then
			if v.ft then
				if v.ft=="input" then
					input[#input+1] = v:ToData()
				else
					output[#output+1] = v:ToData()
				end
			else  
				nodes[#nodes+1] =v:ToData()
				if v.nodegroup then self:ToDataAdd(v,nodes) end
			end
		end
	end
	local j = {nodes = nodes}
	if #input>0 then j.input = input end
	if #output>0 then j.output = output end
	return j
end

function PANEL:ToDataAdd(snode,nodes) 
	for k,v in pairs(snode:GetChildren()) do
		if v and v.ToData then 
			nodes[#nodes+1] = v:ToData()
			if v.nodegroup then self:ToDataAdd(v,nodes) end
		end
	end
end

function PANEL:FromData(data,posoffset)
	if data.nodes then 
		local mapping = {}
		for k,v in pairs(self.nodelayer:GetChildren()) do
			if v and v.ToData then
				mapping[v.id] = v.id
			end
		end
		local nodelist = {}
		local datalist = {}
		for k,v in pairs(data.nodes) do
			if not isnumber(v) then
				local n = false
				
				local paneltype = PANEL.typetable[v.type]
				n = panel.Create(paneltype)  
				
				if n then
					self:AddNode(n)
					local newId = n.id
					local oldId = v.id
					mapping[oldId] = newId
					if n.datakeys then
						for kk,vv in pairs(n.datakeys) do
							n[kk] = v[vv]
						end  
					end
					n.data = v
					n:Load(v.func or v.valtype, v.signal) 
				end
				v._node = n
				nodelist[#nodelist+1] = v._node
				datalist[#datalist+1] = v
			end
		end
		if data.input then 
			for k,v in pairs(data.input) do
				local n = panel.Create("graph_node_input")  
				n.ft = "input"
				self:AddNode(n)
				local newId = n.id
				local oldId = v.id
				mapping[oldId] = newId
				n:Load(v.func or v.type, v.name) 
				v._node = n 
				nodelist[#nodelist+1] = v._node
				datalist[#datalist+1] = v
			end
		end
		if data.output then 
			for k,v in pairs(data.output) do
				local n = panel.Create("graph_node_output")  
				n.ft = "output"
				self:AddNode(n)
				local newId = n.id
				local oldId = v.id
				mapping[oldId] = newId
				n:Load(v.func or v.type, v.name) 
				v._node = n 
				nodelist[#nodelist+1] = v._node
				datalist[#datalist+1] = v
			end
		end
		
		PrintTable(mapping)
		local fmap = function(id)
			return mapping[id] or id
		end
		
		
		
		
		
		for k,v in pairs(datalist) do 
			if v._node then
				v._node:FromData(v,fmap,posoffset or Point(0,0))
			end
		end
		
		
		
		return nodelist
	end
end








