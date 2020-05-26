
--local t_mpanel = LoadTexture("gui/nodes/varnode.png")  

PANEL.basetype = "graph_node" 
function PANEL:Init() 
	PANEL.base.Init(self) 
end 
function PANEL:Load(valtype) 
	self.valtype = valtype or "float"
	--self:SetSize(128,32)
	--self:SetTexture(t_mpanel)
	self:SetTitle("Constant: "..valtype) 
	
	if valtype=="boolean" then
		local btext = panel.Create("checkbox")
		btext:SetSize(40,40)
		btext:SetPos(-160,-20)    
		self:Add(btext)
		self.btext = btext
	elseif valtype=="vector3" then
		local TX = panel.Create("input_text")
		TX:SetSize(250,20)
		TX:SetPos(0,50)
		TX:SetText("0")
		TX:SetTextColor(Vector(0.5,0.8,1)*2)
		TX:SetTextOnly(true)
		TX:SetTextAlignment(ALIGN_LEFT)  
		self:Add(TX)
		self.TX = TX
		
		local TY = panel.Create("input_text")
		TY:SetSize(250,20)
		TY:SetPos(0,0)
		TY:SetText("0")
		TY:SetTextColor(Vector(0.5,0.8,1)*2)
		TY:SetTextOnly(true)
		TY:SetTextAlignment(ALIGN_LEFT)  
		self:Add(TY)
		self.TY = TY
		
		local TZ = panel.Create("input_text")
		TZ:SetSize(250,20)
		TZ:SetPos(0,-50)
		TZ:SetText("0")
		TZ:SetTextColor(Vector(0.5,0.8,1)*2)
		TZ:SetTextOnly(true)
		TZ:SetTextAlignment(ALIGN_LEFT)  
		self:Add(TZ)
		self.TZ = TZ
	else
		local btext = panel.Create("input_text")
		btext:SetSize(250,20)
		btext:SetPos(0,0)
		btext:SetText("1")
		btext:SetTextColor(Vector(0.5,0.8,1)*2)
		--btext:SetTextOnly(true)
		btext:SetTextAlignment(ALIGN_LEFT)  
		self:Add(btext)
		self.btext = btext
	end
	
	self:AddAnchor(1,"output",valtype)
	self.bcolor = self.anchors[1].bcolor
	self:Deselect()
	self:UpdateLayout()
end
function PANEL:ToData()   
	local j = PANEL.base.ToData(self)
	j.type = "const" 
	j.valtype = self.valtype
	
	if self.valtype=="boolean" then
		j.val = self.btext.value or false 
	elseif self.valtype=="vector3" then
		j.val = {tonumber(self.TX:GetText()),tonumber(self.TY:GetText()),tonumber(self.TZ:GetText())}
	elseif self.valtype=="float" or self.valtype=="int" then
		j.val = tonumber(self.btext:GetText())
	else
		j.val = self.btext:GetText()
	end
	return j
end 
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset) 
	local valtype = data.valtype or "float"
	self.valtype = valtype
	self.anchors[1]:Attach(self,1,"output",valtype,self.anchr)
	if self.btext then
		self.btext:SetText(tostring(data.val))
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
 
 