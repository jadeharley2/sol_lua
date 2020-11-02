 
	
function PANEL:Init()
	--PrintTable(self) 
	 
	
	self:SetSize(300,30)
	self:SetColor(Vector(0.6,0.6,0.6))
	self:SetTextOnly(true)
	self:SetCanRaiseMouseEvents(false)
	self:SetText("TEST CONTEXT TEXT")
	self:SetAutoSize(true,false)
	self:UpdateLayout()

	hook.Add(EVENT_GLOBAL_PREDRAW,"gui.contextinfo",function() self:UpdateContext() end)
end
 
function PANEL:UpdateContext()  
	local topel = panel.GetTopElement() 
	if topel and topel.contextinfo then

		local vsize = GetViewportSize()
		local impos = input.getInterfaceMousePos()
		local mpos =  impos*vsize

		if self.tel ~= topel then
			self.tel = topel
			local ci = topel.contextinfo
			--MsgN("udp",type(ci))

			self:Clear() 
			self:SetAutoSize(false,false)

			if isstring(ci) then
				self:SetAutoSize(true,false)
				self:SetText(ci)
				self:SetTextColor(Vector(1,1,1))
				self:SetTexture()
				self:SetColor(Vector(0,0,0)) 
				self:SetTextOnly(false)
				self:SetSize(300,30)   
			elseif istable(ci) then
				if(ci[1]=='image') then
					self:SetAutoSize(false,false)
					self:SetText("")
					self:SetTexture(ci[2])
					self:SetSize(300,300)
					self:SetColor(Vector(1,1,1))
					self:SetTextOnly(false)   
				end
			elseif isfunction(ci) then
				ci(self,topel)  
			end 
			self:Show() 
			self:UpdateLayout()
		end
 
		local directiony = -1
		if impos.y<-0.3 then
			directiony = 1
		end
		if impos.x<0.3 then 
			self:SetPos(mpos+self:GetSize()*Point(1,directiony)+Point(30,-10)) 
		else
			self:SetPos(mpos+self:GetSize()*Point(-1.2,directiony)+Point(30,-10)) 
		end
	else
		self:Close()
		self.tel = nil
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