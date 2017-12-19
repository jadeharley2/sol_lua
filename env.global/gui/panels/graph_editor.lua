 
CURRENT_SELECTED_ANCHOR = false
cuup = cuup or {}


function GUI_CURVE_UPDATE()
	for k,v in pairs(cuup) do
		local p = v:GetParent()
		local pv = p:GetScreenPos()
		local f1 = v.from:GetScreenPos()-pv
		local f4 = ((v.to:GetScreenPos()-pv)*2-f1) 
		
		local f2 = f1+Point(v.bend,0)
		local f3 = f4-Point(v.bend,0)
		v:SetCurve(f1,f2,f3,f4)
	end
end

hook.Add("main.predraw", "gui.curve.update", GUI_CURVE_UPDATE)


function PANEL:Init() 
	local vsize = GetViewportSize()
	self:SetSize(vsize.x,vsize.y)
	
	local nodelayer = panel.Create("graph_grid")
	nodelayer.editor = self
	nodelayer:SetSize(vsize.x*10,vsize.y*10)
	nodelayer:SetTextureScale(vsize*10/Point(256,256))
	self:Add(nodelayer)
	
	local curvelayer = panel.Create()
	nodelayer:Add(curvelayer)
	nodelayer.curvelayer = curvelayer
	
	function self:AddNode()
		local n = panel.Create("graph_node")
		n.editor = nodelayer
		n:Load()
		nodelayer:Add(n)
	end
	 
	local edpanel = panel.Create()
	edpanel:SetSize(300,vsize.y)
	edpanel:Dock(DOCK_RIGHT)
	self:Add(edpanel) 
	
	
	local edAddConst = panel.Create("button")
	edAddConst:Dock(DOCK_TOP)
	edAddConst:SetSize(50,50)
	edAddConst:SetText("Const")
	function edAddConst:OnClick()
		local n = panel.Create("graph_node")
		n:SetTitle("Const")
		n.editor = nodelayer
		n:AddAnchor(1,"out","float") 
		function n:OnExec()  
			self.outputs[1]:SetValue(1)
		end
		nodelayer:Add(n)
	end
	edpanel:Add(edAddConst) 
	
	
	local edAddAdd = panel.Create("button")
	edAddAdd:Dock(DOCK_TOP)
	edAddAdd:SetSize(50,50)
	edAddAdd:SetText("Add")
	function edAddAdd:OnClick()
		local n = panel.Create("graph_node")
		n:SetTitle("Add")
		n.editor = nodelayer
		n:AddAnchor(-1,"a","float")
		n:AddAnchor(-2,"b","float")
		n:AddAnchor(1,"out","float") 
		function n:OnExec() 
			local r = 0
			for k,v in pairs(self.inputs) do
				r = r + (v:GetValue() or 0)
			end 
			self:SetTitle(r)
			self.outputs[1]:SetValue(r)
		end
		nodelayer:Add(n)
	end
	edpanel:Add(edAddAdd) 
	
	local edAddDisplay = panel.Create("button")
	edAddDisplay:Dock(DOCK_TOP)
	edAddDisplay:SetSize(50,50)
	edAddDisplay:SetText("Display")
	function edAddDisplay:OnClick()
		local n = panel.Create("graph_node")
		n:SetTitle("Display")
		n.editor = nodelayer
		n:AddAnchor(-1,"in","float") 
		function n:OnExec()  
			n:SetTitle(tostring(self.inputs[1]:GetValue()))
		end
		nodelayer:Add(n)
	end
	edpanel:Add(edAddDisplay) 
	
	
	local edNODE = panel.Create("button")
	edNODE:Dock(DOCK_TOP)
	edNODE:SetSize(50,50)
	edNODE:SetText("Display")
	function edNODE:OnClick()
		local n = panel.Create("graph_behavior_node")
		n:SetTitle("TEST")
		n.editor = nodelayer
		n:Load()
		nodelayer:Add(n)
	end
	edpanel:Add(edNODE) 
	
	
	self:UpdateLayout()
	
end

