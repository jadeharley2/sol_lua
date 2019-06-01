 
	
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
		local ci = topel.contextinfo

		local vsize = GetViewportSize()
		local impos = input.getInterfaceMousePos()
		local mpos =  impos*vsize

		if isstring(ci) then
			self:SetText(topel.contextinfo)
			self:SetTextColor(Vector(1,1,1))
			self:SetTexture()
			self:SetColor(Vector(0,0,0))
			self:SetTextOnly(false)
			self:SetSize(300,30) 
			self:SetPos(mpos+self:GetSize()*Point(1,-1)+Point(10,-10)) 
			self:Show()
		elseif istable(ci) then
			if(ci[1]=='image') then
				self:SetText("")
				self:SetTexture(ci[2])
				self:SetSize(300,300)
				self:SetColor(Vector(1,1,1))
				self:SetTextOnly(false) 
				local direction = -1
				if impos.y<-0.3 then
					direction = 1
				end

				self:SetPos(mpos+self:GetSize()*Point(1,direction)+Point(10,-10)) 
				self:Show()
			end
		end
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