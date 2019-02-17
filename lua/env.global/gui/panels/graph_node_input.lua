PANEL.basetype = "graph_node" 
function PANEL:Init() 
	PANEL.base.Init(self) 
end 
function PANEL:Load(valtype,varname) 
	self.vtype = valtype or "float"
	self.vname = varname or "unknown"
	self:SetTitle("Input "..varname..":"..valtype) 
	  
	--local btext = panel.Create("input_text")
	--btext:SetSize(250,20)
	--btext:SetPos(0,0)
	--btext:SetText("var01")
	--btext:SetTextColor(Vector(0.5,0.8,1)*2)
	--btext:SetTextOnly(true)
	--btext:SetTextAlignment(ALIGN_LEFT)  
	--self:Add(btext)
	--self.btext = btext
	
	
	self:AddAnchor(1,"output",valtype)
	self.bcolor = self.anchors[1]:GetTypeColor(valtype)
	self:Deselect()
end
function PANEL:ToData()  
	local pos = self:GetPos()
	local j = {id = self.id, type = "input", vtype = self.vtype,name = self.vname,pos = {pos.x,pos.y}}  
	return j
end 
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset) 
	local valtype = data.vtype or "float" 
	self.vtype = valtype
	self:SetTitle("Input "..self.vname..":"..valtype) 
	self.anchors[1]:Attach(self,1,"output",valtype) 
	self.bcolor = self.anchors[1]:GetTypeColor(valtype)
	self:Deselect()
end
 
function PANEL:Select(selector) 
	self:SetColor(Vector(83,255,164)/255)
	self.selector = selector
	
	---PrintTable(getmetatable(self))
end
function PANEL:Deselect() 
	self:SetColor(self.bcolor) 
	self.selector = nil
end
 
 