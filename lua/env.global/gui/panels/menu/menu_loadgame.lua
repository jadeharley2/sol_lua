PANEL.basetype = "menu_dialog"

 

function PANEL:Init()  
	
	self.base.Init(self,"Load",600,600)
	
	gui.FromTable({
		subs = {
			{ type = 'list', name = 'list',
				size = {300,300},
				dock = DOCK_LEFT
			},
			{ type = 'panel', name = 'sp_text', 
				size = {250,20},
				text = "-----",
				dock = DOCK_TOP,
				margin = {10,10,10,10},
			},
			{ type = 'panel', name = 'sp_img', 
				size = {250,250},
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
						text = "Load",
						OnClick = function()    
							self:Load()
						end 
					},
					{ type = 'button', name = 'sp_back',
						pos = {450,-450},
						size = {50,20},
						text = "Back",
						OnClick = function()    
							 hook.Call("menu","sp")
						end 
					},
				}
			},
		}
	},self.sub,{},self) 
	
	self:RefreshList()
	self:UpdateLayout()
end
function PANEL:Load()
	LoadSingleplayerSave(self.sp_text:GetText())
end
function PANEL:SelectSave(savename)  
	self.sp_text:SetText(savename) 
	self.sp_img:SetTexture(engine.GetStateImage(savename))
end
function PANEL:RefreshList()
	self.list:ClearItems()
	for k,v in ipairs(engine.GetStateList() ) do
		self.list:AddItem(gui.FromTable({
			type = "button",
			text = v,
			size ={20,20},
			OnClick = function(s)
				self:SelectSave(v)
			end
		}))
	end
	--self.list.lines = engine.GetStateList() 
	--self.list:Refresh()
end

function PANEL:OnShow()
	self:RefreshList()
	self:UpdateLayout()
end