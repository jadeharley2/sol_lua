local layout = {
	color = {0,0,0},
	subs = {
		{
			margin = {10,10,10,10},
			color = {0,0,0},
			size={48,48},
			dock = DOCK_TOP,
			padding = {60,0,60,0},
			subs = {
				{ type = "slot", name = "item",
					size={48,48},
					color = {0.1,0.1,0.1}, 
					slottype = "reference",
					id = 1
				}
			}
			
		},
		{ type = "button",
			name = "bdec", 
			margin = {10,10,10,10},
			dock = DOCK_BOTTOM,
			size={22,22},
			text = "Deconstruct",
			textalignment = ALIGN_CENTER,
			visible = false
		},
		{ name = "combolist",
			dock = DOCK_FILL,
			color = {0.1,0.1,0.1},
			margin = {10,10,10,10},
		}	
	}
}
function PANEL:Init() 
	self.items = {}
	gui.FromTable(layout,self,{},self)   
	self.item.OnDrop = function(p,item)
		self.items[p.id] = item
		self:Check()
	end
	self.item.OnUnset = function(p)
		self.items[p.id] = nil
		self:Clean()
	end
	self.bdec.OnClick = function(p)
		self:Deconstruct()
	end
end  
function PANEL:Refresh() 
end 
function PANEL:Clean()
	self.combolist:Clear()
	self.bdec:SetVisible(false)
	self:UpdateLayout()
end
function PANEL:Check() 
	self.combolist:Clear()
	self.bdec:SetVisible(false)
	local itemP = self.items[1]
	if itemP then
		local itemA = itemP.item
		if itemA then
			local res = crafting.GetDeconstructResult(itemA.data)
			if res then
				for resultid,resultcount in pairs(res) do 
					local btn = gui.FromTable({
						dock = DOCK_TOP,
						size = {42,42},
						color = {0.1,0.1,0.1}, 
						subs = {
							{
								texture = forms.GetIcon(resultid) or "textures/gui/icons/unknown.png",
								color = (forms.GetTint(resultid) or {1,1,1}),
								size = {42,42}, 
								dock = DOCK_LEFT
							},
							{
								size = {20,20},
								dock = DOCK_TOP,
								text = (forms.GetName(resultid) or resultid)..' '..resultcount, 
								textcolor = {1,1,1},
								textonly = true
							} 
						}
					})
					self.combolist:Add(btn)
				end
				self.bdec:SetVisible(true)
				self:UpdateLayout()
			end
		end
	end
end 
function PANEL:Deconstruct() 
	local itemP = self.items[1]
	if itemP then
		local itemA = itemP.item
		if itemA then
			if crafting.Deconstruct(itemA.data,LocalPlayer().storage) then
				
				hook.Call("inventory_update",LocalPlayer())
			end
		end
	end
end