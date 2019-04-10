
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
	
	local floater = panel.Create()
	floater:SetSize(vsize.x - 300,vsize.y)
	floater:Dock(DOCK_LEFT)
	floater:SetColor(Vector(0,0,0))
	floater:SetClipEnabled(true)
	self:Add(floater)
	
	local nodelayer = panel.Create("graph_grid")
	nodelayer.editor = self
	nodelayer:SetSize(20000,20000)
	nodelayer:SetTextureScale(Point(1,1)*(20000/256))
	floater:Add(nodelayer)
	
	self.nodelayer = nodelayer
	
	
	
	local curvelayer = panel.Create()
	nodelayer:Add(curvelayer)
	nodelayer.curvelayer = curvelayer
	
	local ED = self 
	
	function self:GetFreeId()
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
	
	function self:AddNode(n,idoverride) 
		n.editor = nodelayer 
		local ml = nodelayer:GetScaleMul()
		n:SetPos(-nodelayer:GetPos()/ml)
		nodelayer:Add(n)
		
		local id = self:GetFreeId() 
		n.id = id
		self.named[n.id] = n
		MsgN("CreateNode",n.id)
	end 
	 
	local edpanel = panel.Create("list")
	edpanel:SetSize(300,vsize.y/4)
	edpanel:Dock(DOCK_TOP)
	self:Add(edpanel) 
	 
	local edNew = panel.Create("button") 
	edNew:SetSize(50,50)
	edNew:SetText("New")
	function edNew:OnClick() 
		ED:Clear()
	end
	
	
	local edOpen = panel.Create("button") 
	edOpen:SetSize(50,50)
	edOpen:SetText("Open")
	function edOpen:OnClick()  
		ED:Open("output/aaaaout.json")
	end
	
	local edSave = panel.Create("button") 
	edSave:SetSize(50,50)
	edSave:SetText("Save")
	function edSave:OnClick() 
		json.Write("output/aaaaout.json",ED:ToData())
	end
	 
	local edSaveAs = panel.Create("button") 
	edSaveAs:SetSize(50,50)
	edSaveAs:SetText("SaveAs")
	function edSaveAs:OnClick() 
		json.Write("output/aaaaout.json",ED:ToData())
	end
	
	local edCompile = panel.Create("button") 
	edCompile:SetSize(50,50)
	edCompile:SetText("Compile")
	function edCompile:OnClick() 
		if CURRENT_DEBUG_FLOW then
			CURRENT_DEBUG_FLOW:Dispose()
			CURRENT_DEBUG_FLOW = false
		end
		local j = json.ToJson(ED:ToData())
		local result, error = flowbase.CompileJson(j) 
		if result then
			MsgN("Compilation successful")
			MsgInfo("Compilation successful",Vector(0,1,0))
			CURRENT_DEBUG_FLOW = result
			result:SetupHooks()
			result:TryRun("startup")
		else
			MsgN("Compilation failed")
			MsgInfo("Compilation failed")
		end
	end
	
	edpanel.lines = {edNew,edOpen,edSave,edSaveAs,edCompile}
	  
	for	k,v in pairs(edpanel.lines) do
		v:SetSize(280,25)
	end
	edpanel:Refresh() 
	
	
	 
	local trpanel = panel.Create("tree")
	trpanel:SetSize(300,vsize.y*(3.0/4))
	trpanel:Dock(DOCK_TOP)
	self:Add(trpanel)
	
	
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
	
	
	
	local tab = {
		flow = {event = {"startup","input.keydown"},"branch","assign","sequence","join","while","for"},
		constants = {"string","boolean","int","float","vector3","quaternion"},
		variables = {"string","boolean","int","float","vector3","quaternion","scriptednode"},
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
			ED:AddNode(n)
			n:Load(com) 
		elseif epr[1] == "compounds" then
			local com = epr[2]--.."."..epr[3] 
			local n = panel.Create("graph_node_compound")  
			ED:AddNode(n)
			n:Load(com) 
		elseif epr[1] == "constants" and epr[2] then
			local n = panel.Create("graph_node_const")  
			ED:AddNode(n)
			n:Load(epr[2])
		elseif epr[1] == "variables" and epr[2] then
			local n = panel.Create("graph_node_var")  
			ED:AddNode(n)
			n:Load(epr[2])
		elseif epr[1] == "flow" then
			if epr[2] == "event" then
				local n = panel.Create("graph_node_event")  
				ED:AddNode(n)
				n:Load(epr[3])
			elseif epr[2] == "branch" then
				local n = panel.Create("graph_node_branch")  
				ED:AddNode(n)
				n:Load()
			elseif epr[2] == "assign" then
				local n = panel.Create("graph_node_assign")  
				ED:AddNode(n)
				n:Load()
			elseif epr[2] == "sequence" then
				local n = panel.Create("graph_node_sequence")  
				ED:AddNode(n)
				n:Load()
			elseif epr[2] == "join" then
				local n = panel.Create("graph_node_join")  
				ED:AddNode(n)
				n:Load()
			elseif epr[2] == "while" then
				local n = panel.Create("graph_node_while")  
				ED:AddNode(n)
				n:Load()
			elseif epr[2] == "for" then
				local n = panel.Create("graph_node_for")  
				ED:AddNode(n)
				n:Load()
			end
		elseif epr[1] == "group" then
			local n = panel.Create("graph_group")  
			ED:AddNode(n)
			n:Load()
		elseif epr[1] == "map" then
			if epr[2] == "point" then
				local n = panel.Create("editor_point")  
				ED:AddNode(n)
				n:Load(epr[3])
			elseif epr[2] == "line" then
				local n = panel.Create("line") 
				n:SetColor(Vector(83,164,255)/255)
				n:SetUseGlobalScale(true)
				ED:AddNode(n)
				local first = false
				hook.Add("input.mousedown","linebuild",function()
					if input.leftMouseButton() then
						local top = panel.GetTopElement()
						if top then
							local point = false
							if top:__eq(ED.nodelayer) then
								local pn = panel.Create("editor_point")  
								ED:AddNode(pn)
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
	self.trpanel= trpanel
	
	
	
	--local TESTONLY = panel.Create() 
	--TESTONLY:SetSize(vsize.x,vsize.y)
	--TESTONLY:SetPos(100,10000*0) 
	--TESTONLY:SetCanRaiseMouseEvents(false)
	--TESTONLY:SetTexture(LoadTexture("@mirrorrt"))
	--nodelayer:Add(TESTONLY)
	 
	
	---[[
	local TESTONLY = panel.Create("dockslot") 
	TESTONLY:SetSize(vsize.x,vsize.y)
	TESTONLY:SetPos(100,10000*0) 
	nodelayer:Add(TESTONLY)
	
	for k=1,5 do
		local TESTONLY2 = panel.Create("testdragable")  
		TESTONLY2:SetPos(-2200,100*k+10000*0) 
		TESTONLY2:SetSize(300,300)
		nodelayer:Add(TESTONLY2)
		
		local contents = panel.Create("button") 
		contents:SetText("A"..tostring(k))
		contents:Dock(DOCK_FILL)
		TESTONLY2:AddTab("A"..tostring(k),contents)
		TESTONLY2:ShowTab()
	end
	--]]
	
	--do 
	--	local TESTONLY2 = panel.Create("testdragable")  
	--	TESTONLY2:SetPos(-2200,200+10000*0) 
	--	TESTONLY2:SetSize(300,300)
	--	nodelayer:Add(TESTONLY2) 
	--	TESTONLY2:AddTab("actions",edpanel)
	--	TESTONLY2:ShowTab()
	--end
	--do 
	--	local TESTONLY2 = panel.Create("testdragable")  
	--	TESTONLY2:SetPos(-2200,200+10000*0) 
	--	TESTONLY2:SetSize(300,300)
	--	nodelayer:Add(TESTONLY2) 
	--	TESTONLY2:AddTab("nodes",trpanel)
	--	TESTONLY2:ShowTab()
	--end
	
	
	
	
	
	self:UpdateLayout()
	
end
function PANEL:Clear(node)
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
	self:Clear()
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
				--if v.type == "func" then          n = panel.Create("graph_node_function") 
				--elseif v.type == "compound" then  n = panel.Create("graph_node_compound")   
				--elseif v.type == "event" then     n = panel.Create("graph_node_event")   
				--elseif v.type == "const" then     n = panel.Create("graph_node_const")   
				--elseif v.type == "variable" then  n = panel.Create("graph_node_var")   
				--elseif v.type == "assign" then    n = panel.Create("graph_node_assign")  
				--elseif v.type == "branch" then    n = panel.Create("graph_node_branch")   
				--elseif v.type == "sequence" then  n = panel.Create("graph_node_sequence")   
				--elseif v.type == "join" then      n = panel.Create("graph_node_join")  
				--elseif v.type == "while" then     n = panel.Create("graph_node_while")    
				--elseif v.type == "for" then       n = panel.Create("graph_node_for")     
				--end 
				
				if n then
					self:AddNode(n)
					local newId = n.id
					local oldId = v.id
					mapping[oldId] = newId
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








