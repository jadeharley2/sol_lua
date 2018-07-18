PANEL.basetype = "graph_node" 
function PANEL:Init() 
	PANEL.base.Init(self) 
end 
function PANEL:Load()  
	self:SetTitle("Sequence") 
	
	self:AddAnchor(-1,">>","signal")
	
	
	self:AddAnchor(1,"1>>","signal") 
	self:AddAnchor(2,"2>>","signal") 
	self:AddAnchor(3,"3>>","signal") 
	self:AddAnchor(4,"4>>","signal") 
	self:AddAnchor(5,"5>>","signal")  
	self:AddAnchor(6,"6>>","signal") 
	self:AddAnchor(7,"7>>","signal") 
	self:AddAnchor(8,"8>>","signal") 
	self:AddAnchor(9,"9>>","signal")
	
	self:Deselect()
end
function PANEL:ToData()  
	local pos = self:GetPos() 
	local j = {id = self.id, type = "sequence",pos = {pos.x,pos.y}} 
	local next = {}
	for k,v in pairs(self.outputs) do 
		local to = v.to:First()
		if to then
			next[#next+1] = {to.node.id,to.id,to.name}--:GetInputData(to.id)-- to.node.id 
		else
			next[#next+1] = ""
		end 
	end
	j.next = next
	
	return j
end 
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset,true) 
	
	local e = self.editor.editor 
		
	for k,v in pairs(data.next) do 
		if istable(v) then
			local f = self.anchors[k]
			local t = e.named[mapping(v[1])].anchors[v[2]] 
			if f and t then
				f:CreateLink(f,t)
			end
		end
	end
	--if data.condition then
	--end
	 
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
 
 