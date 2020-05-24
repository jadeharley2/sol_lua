PANEL.basetype = "graph_node" 
function PANEL:Init() 
	PANEL.base.Init(self) 
end 
function PANEL:Load()  
	self:SetTitle("For loop") 
	self:SetSize(256,3*16+40)
	
	self:AddAnchor(-1,">>","signal")
	self:AddAnchor(-2,"count","int32")
	
	self:AddAnchor(1,"do>>","signal")
	self:AddAnchor(2,"end>>","signal")
	
	self:AddAnchor(3,"loop","int32")
	self:Deselect()
	self:UpdateLayout()
end
function PANEL:ToData()  
	local j = PANEL.base.ToData(self)
	j.type = "for" 
	j.count = self:GetInputData(2)
	MsgN("Inputx2",j.count)
	--local count = self.inputs[2]
	--if count and count.node then
	--	j.count = (count.node.id or "")
	--end
	
	j['do'] = self:GetOutputData(1) 
	j.next = self:GetOutputData(2) 
	return j
end 
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset) 
	 
	local e = self.editor.editor 
		
	if data.count then
		local f = e.named[mapping(data.count)].anchors[1] 
		local t = self.anchors[-2]
		if f and t then
			f:CreateLink(f,t)
		end
	end
	
	if data['do'] then 
		local f = self.outputs[1]
		local t = e.named[mapping(data['do'][1])].anchors[data['do'][2]] 
		f:CreateLink(f,t)
	end
	if data.next then 
		local f = self.outputs[2]
		local t = e.named[mapping(data.next[1])].anchors[data.next[2]] 
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
 
 