 
	
function PANEL:Init()
	--PrintTable(self) 
	 
	
	self:SetSize(300,30)
	self:SetColor(Vector(0.6,0.6,0.6))
	self:SetTextOnly(true)
	self:SetCanRaiseMouseEvents(false)
	self:SetText("TEST CONTEXT TEXT")
	self:UpdateLayout()

	hook.Add(EVENT_GLOBAL_PREDRAW,"gui.contextinfo",function() self:UpdateContext() end)
end
 
function PANEL:UpdateContext()  
	local topel = panel.GetTopElement() 
	if topel and topel.contextinfo then
		self:SetText(topel.contextinfo)
		self:SetTextColor(Vector(1,1,1))
		self:SetColor(Vector(0,0,0))
		self:SetTextOnly(false)
		local mpos = (input.getInterfaceMousePos()*GetViewportSize())+self:GetSize()*Point(1,-1)+Point(10,-10)
		self:SetPos(mpos) 
		self:Show()
	else
		self:Close()
	end
end 

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end