PANEL.basetype = "graph_node" 
function PANEL:Init() 
	PANEL.base.Init(self) 
end 
function PANEL:Load()  
	self:SetTitle("While") 
	
	self:AddAnchor(-1,">>","signal")
	self:AddAnchor(-2,"condition","boolean")
	
	self:AddAnchor(1,"do>>","signal")
	self:AddAnchor(2,"end>>","signal")
	self:Deselect()
end
function PANEL:ToData()  
	local pos = self:GetPos() 
	local j = {id = self.id, type = "while",pos = {pos.x,pos.y}} 
	local cond = self.inputs[2]
	if cond and cond.node then
		j.condition = (cond.node.id or "")
	end
	
	local out1 = self.outputs[1] 
	local out2 = self.outputs[2] 
	if out1 then
		local to = out1.to:First()
		if to then
			j['do'] = to.node.id 
		end 
	end
	if out2 then
		local to = out2.to:First()
		if to then
			j.next = to.node.id 
		end
	end
	return j
end 
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset) 
	
	local e = self.editor.editor 
		
	if data.condition then
		local f = e.named[mapping(data.condition)].anchors[1] 
		local t = self.anchors[-2]
		if f and t then
			f:CreateLink(f,t)
		end
	end
	
	if data['do'] then 
		local f = self.outputs[1]
		local t = e.named[mapping(data['do'])].anchors[-1] 
		f:CreateLink(f,t)
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
 
 