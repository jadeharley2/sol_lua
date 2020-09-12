PANEL.basetype = "menu_dialog"

 

function PANEL:Init()  
	
	self.base.Init(self,"Load",600,600)
	local sub = self.sub
	local list = panel.Create("list")  
	list:Dock(DOCK_LEFT)
	list:SetSize(300,300)
	
	list.hasback = true
	
	self.list = list
	sub:Add(list)
	
	local sp_img = panel.Create()
	--sp_img:SetText("S") 
	sp_img:SetPos(300,300)
	sp_img:SetSize(250,250) 
	self:Add(sp_img)
	
	local sp_text = panel.Create()
	sp_text:SetText("-----") 
	sp_text:SetPos(300,50)
	sp_text:SetSize(250,20)  
	self:Add(sp_text)
	self.sp_text= sp_text
	
	local sp_load = panel.Create("button")
	sp_load:SetText("Load") 
	sp_load:SetPos(150,-450)
	sp_load:SetSize(50,20)
	sp_load.OnClick = function()   
		--LoadSingleplayer("testmap",sp_text:GetText())
		self:Load()
	end
	self:SetupStyle(sp_load)
	self:Add(sp_load)
	
	local sp_back = panel.Create("button")
	sp_back:SetText("Back") 
	sp_back:SetPos(450,-450)
	sp_back:SetSize(50,20)
	sp_back.OnClick = function() hook.Call("menu","sp") end
	self:SetupStyle(sp_back)
	self:Add(sp_back)
	
	
	list.OnSelect = function(list, line)
		local savename = line:GetText()
		sp_text:SetText(savename) 
		sp_img:SetTexture(engine.GetStateImage(savename))
	end
	
	self:RefreshList()
	self:UpdateLayout()
end
function PANEL:Load()
	LoadSingleplayerSave(self.sp_text:GetText())
end
function PANEL:RefreshList()
	self.list.lines = engine.GetStateList() 
	self.list:Refresh()
end

function PANEL:OnShow()
	self:RefreshList()
	self:UpdateLayout()
end