PANEL.basetype = "graph_node" 
function PANEL:Init() 
	PANEL.base.Init(self) 
end 
function PANEL:Load()  
	self:SetTitle("Assign") 
	
	self:AddAnchor(-1,">>","signal")
	self:AddAnchor(-2,"variable","variable")
	self:AddAnchor(-3,"value","any")
	
	self:AddAnchor(1,">>","signal") 
	self:Deselect()
end
function PANEL:ToData()   
	local j = PANEL.base.ToData(self)
	j.type = "assign"
	
	local variable = self.inputs[2]
	if variable and variable.node then
		j.variable = (variable.node.id or "")
	end 
	local value = self.inputs[3]
	if value and value.node then
		j.value = (value.node.id or "")
	end 
	
	local out = self.outputs[1] 
	if out then
		local to = out.to:First()
		if to then
			j.next = to.node.id 
		end
	end
	
	return j
end 
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset) 
	
	local e = self.editor.editor 
		
	if data.variable then
		local f = e.named[mapping(data.variable)].anchors[1] 
		local t = self.anchors[-2]
		if f and t then
			f:CreateLink(f,t)
		end
	end
	 
	if data.value then
		local f = e.named[mapping(data.value)].anchors[1] 
		local t = self.anchors[-3]
		if f and t then
			f:CreateLink(f,t)
		end
	end
	
	if data.next then
		local e = self.editor.editor 
		local o = self.outputs[1]
		local t = e.named[mapping(data.next)].anchors[-1] 
		o:CreateLink(o,t)
	end
end
 
function PANEL:Select(selector) 
	self:SetColor(Vector(83,255,164)/255)
	self.selector = selector
	
	---PrintTable(getmetatable(self))
end
function PANEL:Deselect()
	self:SetColor(Vector(255,255,255)/255) 
	self.selector = nil
end
 
 