
local SELECTED_BNODE = Set()
local t_mpanel = LoadTexture("gui/nodes/anode.png")

function PANEL:Init()  
	
	self:SetSize(128,64)
	self:SetTexture(t_mpanel)
	self.links = {}
	
	local atext = panel.Create("input_text")
	atext:SetSize(100,20)
	atext:SetPos(0,0)
	atext:SetText("Node")
	atext:SetTextColor(Vector(0.5,0.8,1)*2)
	atext:SetTextOnly(true)
	atext:SetTextAlignment(ALIGN_CENTER) 
	--atext:SetCanRaiseMouseEvents(false)
	self:Add(atext)
	self.atext = atext
	
	self:SetColor(Vector(83,164,255)/255)
	self.name = "Node"
	
end

function PANEL:Load() 
	local a = panel.Create("graph_behavior_anchor")
	a:Attach(self)
	self.anchor = a
end
function PANEL:Select(selector) 
	self:SetColor(Vector(83,255,164)/255)
	self.selector = selector
end
function PANEL:Deselect()
	self:SetColor(Vector(83,164,255)/255) 
	self.selector = nil
end

function PANEL:SetTitle(text)
	self.name = text
	self.atext:SetText(tostring(text))
end

function PANEL:MouseDown(id)
	if id == 1 then
		local sel = self.selector
		if sel then
			panel.start_drag(sel:GetSelected())
		else
			panel.start_drag(self) 
		end
	elseif id == 2 then
		self:Select()
	end
end