
local SELECTED_BNODE = false
local t_mpanel = LoadTexture("gui/bnode.png")

function PANEL:Init()  
	
	self:SetSize(128,64)
	self:SetTexture(t_mpanel)
	self.links = {}
	
	local atext = panel.Create("input_text")
	atext:SetSize(100,20)
	atext:SetPos(0,0)
	atext:SetText("Node")
	atext:SetTextColor(Vector(0.5,0.8,1)*2)
	--atext:SetTextOnly(true)
	--atext:SetTextAlignment(ALIGN_CENTER) 
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
function PANEL:Select()
	if SELECTED_BNODE then
		SELECTED_BNODE:Deselect()
	end
	self:SetColor(Vector(83,255,164)/255)
	SELECTED_BNODE = self
end
function PANEL:Deselect()
	self:SetColor(Vector(83,164,255)/255)
	SELECTED_BNODE = false
end

function PANEL:SetTitle(text)
	self.name = text
	self.atext:SetText(tostring(text))
end

function PANEL:MouseDown(id)
	if id == 1 then
		if not CURRENT_WINDOW_MOVE then
			if not self.fixedpos then
				CURRENT_WINDOW_MOVE_POS = self:GetPos()
				CURRENT_WINDOW_MOVE_POINTPOS =  input.getMousePosition() 
				CURRENT_WINDOW_MOVE = self
				hook.Add("main.predraw", "gui.window.move", GUI_PANEL_GLOBALS.cwmove)
			end
		end
	elseif id == 2 then
		self:Select()
	end
end