PANEL.basetype = "graph_node" 
function PANEL:Init() 
	PANEL.base.Init(self) 
end 
function PANEL:Load(ev) 
	ev = ev or "startup"
	self:SetTitle("Event") 
	
	local btext = panel.Create("input_text")
	btext:SetSize(250,20)
	btext:SetPos(0,0)
	btext:SetText(ev)
	btext:SetTextColor(Vector(0.5,0.8,1)*2)
	btext:SetTextOnly(true)
	btext:SetTextAlignment(ALIGN_LEFT)  
	self:Add(btext)
	self.btext = btext
	
	self:AddAnchor(1,">>","signal")
	self:Deselect()
end
function PANEL:ToData()   
	local j = PANEL.base.ToData(self)
	j.type = "event" 
	j.event = self.btext:GetText()
	
	local out = self.outputs[1] 
	if out then
		local to = out.to:First()
		if to then
			j.next = self:GetOutputData(1) 
		end
	end
	return j
end 
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset) 
	self.btext:SetText(data.event)
	 
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
 
 