PANEL.basetype = "menu_dialog"

 

function PANEL:Init()  
	
	self.base.Init(self,"Save",600,600)


	gui.FromTable({
		subs = {
			{ type = 'list', name = 'list',
				size = {300,300},
				dock = DOCK_LEFT, 
				OnSelect = function(list, line)
					local savename = line:GetText()
					self.sp_text:SetText(savename) 
					self.sp_img:SetTexture(engine.GetStateImage(savename))
				end
			},
			{ type = 'panel', name = 'sp_img', 
				size = {250,250},
				dock = DOCK_TOP,
				margin = {10,10,10,10},
			},
			{ type = 'input_text', name = 'sp_text', 
				size = {250,20},
				text = "new_save",
				dock = DOCK_TOP,
				margin = {10,10,10,10},
			},
			
			{type = "xsplit",
				margin = {10,10,10,10},
				dock = DOCK_BOTTOM,
				size = {40,40},
				alpha = 0,
				subs = {
					{ type = 'button', name = 'sp_load',
						pos = {150,-450},
						size = {50,20},
						text = "Save",
						OnClick = function()    
							self:Save()
						end 
					},
					{ type = 'button', name = 'sp_back',
						pos = {450,-450},
						size = {50,20},
						text = "Back",
						OnClick = function()    
							 hook.Call("menu","main")
						end 
					},
				}
			},
		}
	},self.sub,{},self) 

	--[[
	local sub = self.sub
	local list = panel.Create("list")  
	list:Dock(DOCK_LEFT)
	list:SetSize(300,300)
	list.OnSelect = function (s, item)
		MsgN(item.tag)
	end
	list.hasback = true 
	self.list = list
	sub:Add(list)
	
	local sp_img = panel.Create()
	--sp_img:SetText("S") 
	sp_img:SetPos(300,300)
	sp_img:SetSize(250,250) 
	self:Add(sp_img)
	
	local sp_text = panel.Create("input_text")
	sp_text:SetText("newsave") 
	sp_text:SetPos(300,50)
	sp_text:SetSize(250,20)  
	self:Add(sp_text)
	
	local sp_save = panel.Create("button")
	sp_save:SetText("Save") 
	sp_save:SetPos(150,-450)
	sp_save:SetSize(50,20)
	sp_save.OnClick = function()  
		engine.SaveState(sp_text.text or sp_text:GetText()) 
		self:RefreshList()
	end
	self:SetupStyle(sp_save)
	self:Add(sp_save)
	
	local sp_back = panel.Create("button")
	sp_back:SetText("Back") 
	sp_back:SetPos(450,-450)
	sp_back:SetSize(50,20)
	sp_back.OnClick = function() hook.Call("menu","main") end
	self:SetupStyle(sp_back)
	self:Add(sp_back)
	
	self:RefreshList()
	
	list.OnSelect = function(list, line)
		local savename = line:GetText()
		--sp_text:SetText(savename) 
		sp_img:SetTexture(engine.GetStateImage(savename))
	end
	]]
	 
	self:UpdateLayout()
end

function PANEL:RefreshList()
	self.list:ClearItems()
	for k,v in ipairs(engine.GetStateList() ) do
		self.list:AddItem(gui.FromTable({
			text = v,
			size ={20,20}
		}))
	end
	--self.list.lines = engine.GetStateList() 
	--self.list:Refresh()
end
function PANEL:OnShow()
	self:RefreshList()
	self:UpdateLayout()
end
function PANEL:Save() 
	engine.SaveState(self.sp_text.text or self.sp_text:GetText()) 
	self:RefreshList()
end