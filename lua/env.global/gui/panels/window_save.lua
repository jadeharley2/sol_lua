PANEL.basetype = "window"

function PANEL:Init()
	--PrintTable(self)
	self.fixedsize = true
	self.base.Init(self)
	self:SetSize(500,200)
	self:SetColor(Vector(0.6,0.6,0.6))
	 
	local label = panel.Create()
	label:SetText("Enter filename")
	label:SetTextAlignment(ALIGN_CENTER)
	label:SetSize(280,20)
	label:SetPos(0,50)
	label:SetTextColor( Vector(1,1,1))
	label:SetColor(Vector(50,150,50)/256/3)
	
	local filename = panel.Create("input_text")
	filename.downcolor = Vector(50,50,50)/256
	filename.upcolor = Vector(0,0,0)/256
	filename.hovercolor = Vector(80,80,80)/256
	filename:SetColor(filename.upcolor)
	filename:SetTextColor( Vector(1,1,1))
	filename:SetSize(280,20)
	
	local save = panel.Create("button")
	save:SetText("Save")
	save:SetSize(70,20)
	save:SetPos(-100,-50)
	save.OnClick = function() if self.OnAccept then self.OnAccept(self,filename:GetText()) end self:Close() end
	
	
	local back = panel.Create("button")
	back:SetText("Back")
	back:SetSize(70,20)
	back:SetPos(100,-50)
	back.OnClick = function() self:Close() end
	
	
	self:Add(label)
	self:Add(filename)
	self:Add(save)
	self:Add(back)
	
	self.save = save
	self.back = back
	
	self:UpdateLayout() 
end

function PANEL:SetButtons(a,b)
	self.save:SetText(a)
	self.back:SetText(b)
end
