

local t_mpanel = LoadTexture("gui/mpanel.png")
PANEL.basetype = "moveable_panel"
function PANEL:Init() 
	self.base.Init(self)
	
	self:SetSize(256,128)
	self:SetTexture(t_mpanel)
	self.anchors = {}
	self.outputs = {}
	self.inputs = {}
	
	local atext = panel.Create()
	atext:SetSize(50,20)
	atext:SetPos(0,110)
	atext:SetText("Node")
	atext:SetTextColor(Vector(0.5,0.8,1)*2)
	atext:SetTextOnly(true)
	atext:SetCanRaiseMouseEvents(false)
	self:Add(atext)
	self.atext = atext
	
	self.name = "Node"
	
	local ebtn = panel.Create("button")
	ebtn:SetSize(50,20)
	ebtn:SetPos(100,-100)
	function ebtn.OnClick()
		self:Exec()
	end
	self.ebtn = ebtn
	self:Add(ebtn)
end
function PANEL:AddAnchor(id,name,type)
	local a = panel.Create("graph_anchor")
	a:Attach(self,id,name,type)
	self.anchors[id] = a
	
	
	local atext = panel.Create()
	atext:SetSize(50,10)
	atext:SetParent(self)
	if id<0 then
		atext:AlignTo(a,ALIGN_LEFT,ALIGN_RIGHT) 
	else
		self.outputs[id] = a
		atext:AlignTo(a,ALIGN_RIGHT,ALIGN_LEFT)
		atext:SetTextAlignment(ALIGN_RIGHT) 
	end
	atext:SetCanRaiseMouseEvents(false)
	atext:SetText(name)
	atext:SetTextColor(Vector(0.5,0.8,1)*2)
	atext:SetTextOnly(true)
	
	self:Add(atext)
end
function PANEL:Load() 
	self:AddAnchor(-1,"a","float")
	self:AddAnchor(-2,"b","float")
	self:AddAnchor(1,"c","float") 
end

function PANEL:SetTitle(text)
	self.name = text
	self.atext:SetText(tostring(text))
end

function PANEL:Exec()
	MsgN("EXEC ",self.name)
	local execf = self.OnExec 
	if execf then execf(self) end
	for k,v in pairs(self.outputs) do 
		if v.to and v.to.node~=self then
			v.to.node:Exec()
		end
	end
end