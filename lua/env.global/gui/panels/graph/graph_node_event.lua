PANEL.basetype = "graph_node" 
function PANEL:Init() 
	PANEL.base.Init(self,'single') 
	self:SetColor(Vector(255,21,21)/255) 
end 
function PANEL:Load(ev) 
	ev = ev or "startup"
	self:SetTitle("Event") 
	self:SetSize(192,32)
	self:AddAnchorPadding((32-18)/2)
	local btext = panel.Create("input_text")
	btext:SetSize(192/2,20)
	btext:SetPos(0,0)
	btext:SetText(ev)
	btext:SetTextColor(Vector(0.5,0.8,1)*2)
	btext:SetTextOnly(true)
	btext:SetTextAlignment(ALIGN_CENTER)  
	self:Add(btext)
	self.btext = btext
	self.anchorpoint = Point(0,0)
	self:AddAnchor(1,">>","signal")
	self:Deselect()
	self:UpdateLayout()
end
function PANEL:ToData()   
	local j = PANEL.base.ToData(self)
	j.type = "event" 
	j.event = self.btext:GetText()
	j.invocation = j.event == 'invoke'
	
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
	self:SetColor(Vector(255,21,21)/255) 
	self.selector = nil
end
 
 