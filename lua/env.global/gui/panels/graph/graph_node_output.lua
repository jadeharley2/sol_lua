PANEL.basetype = "graph_node" 
function PANEL:Init() 
	PANEL.base.Init(self) 
end 
function PANEL:Load(valtype,varname) 
	self.vtype = valtype or "float"
	self.vname = varname or "unknown"
	self:SetTitle("Output "..varname..":"..valtype)
	self:SetSize(256,64)
	--local btext = panel.Create("input_text")
	--btext:SetSize(250,20)
	--btext:SetPos(0,0)
	--btext:SetText("var01")
	--btext:SetTextColor(Vector(0.5,0.8,1)*2)
	--btext:SetTextOnly(true)
	--btext:SetTextAlignment(ALIGN_LEFT)  
	--self:Add(btext)
	--self.btext = btext
	
	
	self:AddAnchor(-1,">>","signal")
	self:AddAnchor(1,">>","signal")
	self:AddAnchor(-2,"value",valtype)
	
	self.bcolor = self.anchors[-1].bcolor
	self:Deselect()
	self:UpdateLayout()
end
function PANEL:ToData()  
	local pos = self:GetPos()
	local j = {id = self.id, type = "output", vtype = self.vtype,name = self.vname,pos = {pos.x,pos.y}}  
	 
	local a = self.anchors[-1]
	j.value = self:GetInputData(2) 
	j.next = self:GetOutputData(1)  
	return j
end 
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset) 
	local valtype = data.vtype or "float" 
	self.vtype = valtype
	self:SetTitle("Output "..self.vname..":"..valtype) 
	self.anchors[-2]:Attach(self,-2,"value",valtype,self.anchl)  
	self.bcolor = self.anchors[-2]:GetTypeColor(valtype)
	self:Deselect()
	
	
	local v = data.value
	if v then
		local e = self.editor.editor 
		local f = e.named[mapping(v[1])].anchors[v[2]] 
		local t = self.anchors[-2]
		if f and t then
			f:CreateLink(f,t)
		end
	end
	 
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
 
 