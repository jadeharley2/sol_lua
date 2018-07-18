PANEL.basetype = "graph_node" 
function PANEL:Init() 
	PANEL.base.Init(self) 
end 
function PANEL:Load()   
	self:SetTitle("Join") 
	
	
	
	self:AddAnchor(-1,">>","signal") 
	self:AddAnchor(-2,">>","signal") 
	self:AddAnchor(-3,">>","signal") 
	self:AddAnchor(-4,">>","signal") 
	self:AddAnchor(-5,">>","signal")  
	self:AddAnchor(-6,">>","signal") 
	self:AddAnchor(-7,">>","signal") 
	self:AddAnchor(-8,">>","signal") 
	self:AddAnchor(-9,">>","signal")
	
	self:AddAnchor(1,">>","signal")
	
	self:Deselect()
end
function PANEL:ToData()  
	local pos = self:GetPos() 
	local j = {id = self.id, type = "join",pos = {pos.x,pos.y}} 
	
	local out = self.outputs[1]
	local to = out.to:First()
	if to then
		j.next = to.node.id 
	end
	
	return j
end 
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset)  
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
 
 