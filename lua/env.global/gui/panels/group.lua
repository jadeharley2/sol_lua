  
function PANEL:Init()  
	gui.FromTable({
		autosize = {false,true},
		subs ={ 
			{ name = "header",
				size = {20,20},
				text = "Title",
				color = {0.2,0.2,0.7},
				textcolor = {1,1,1},
				textalignment = ALIGN_CENTER,
				dock = DOCK_TOP,
				subs = {
					{ type = "button", name = "rez",
						text = "-",
						size = {20,20},
						dock = DOCK_RIGHT,
						margin = {1,1,1,1},
						textalignment = ALIGN_CENTER,
						ColorAuto = Vector(0.2,0.6,0.8)/50,
						textcolor = {1,1,1}, 
						OnClick = function(s) self:ToggleCollapse() end
					}
				}
			},
			{ name = "contents",
				size = {30,0}, 
				color = {0.2,0.2,0.2}, 
				dock = DOCK_TOP,
				autosize = {false,true}
			},
		}
	},self,{},self)  
end
  
function PANEL:AddItem(node)
	self.contents:Add(node)
end  
function PANEL:RemoveItem(node)
	self.contents:Remove(node)
end  
function PANEL:GetItems()
	return self.contents:GetChildren()
end
PANEL.items_info = {type="children_array",add = PANEL.AddItem}

function PANEL:AddButton(node)
	self.header:Add(node)
end 
PANEL.buttons_info = {type="children_array",add = PANEL.AddButton}

function PANEL:SetTitle(text) 
	self.header:SetText(text)
--	baseSetText(header,text)
end
function PANEL:ToggleCollapse()
	if self.contents:GetVisible() then
		self:Collapse()
	else
		self:Expand()
	end
end
function PANEL:Expand()
	self.contents:SetVisible(true)
	self.rez:SetText("-")
	self:GetTop():UpdateLayout()
end
function PANEL:Collapse()
	self.contents:SetVisible(false)
	self.rez:SetText("+")
	self:GetTop():UpdateLayout()
end