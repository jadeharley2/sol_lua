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
				{ type = "slot", name = "itemA",
					size={48,48},
					color = {0.1,0.1,0.1},
					dock = DOCK_LEFT,
					slottype = "reference",
					id = 1
				},
				{ type = "slot", name = "itemB", 
					size={48,48},
					color = {0.1,0.1,0.1},
					dock = DOCK_RIGHT,
					slottype = "reference",
					id = 2
				}
			}
			
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
	local ondrp = function(p,item)
		self.items[p.id] = item
		self:CheckCombo()
	end
	local onunset = function(p)
		self.items[p.id] = nil
		self:Clean()
	end
	self.itemA.OnDrop = ondrp
	self.itemB.OnDrop = ondrp
	self.itemA.OnUnset = onunset
	self.itemB.OnUnset = onunset
end  
function PANEL:Refresh() 
end 
function PANEL:Clean()
	self.combolist:Clear()
end
function PANEL:CheckCombo()
	self.combolist:Clear()
	local itms = self.items
	local itemPA = itms[1]
	local itemPB = itms[2]
	--MsgN("CheckCombo2",itemPA,"|",itemPB)
	if itemPA and itemPB then
		local cl = self.combolist
		local itemA = itemPA.item
		local itemB = itemPB.item 
		MsgN("STAGE2",itemA.data,"|",itemB.data)
		FFX = itemA.data
		--local formidA = itemA.data:Read("/parameters/form")
		--local formidB = itemB.data:Read("/parameters/form")
		--cl:Add(gui.FromTable({text = forms.GetName(formidA),size = {22,22},dock=DOCK_TOP}))
		--cl:Add(gui.FromTable({text = forms.GetName(formidB),size = {22,22},dock=DOCK_TOP}))
		
		for k,v in pairs(crafting.GetCombineOptions(itemA.data,itemB.data)) do
			cl:Add(gui.FromTable({type="button",
				text = v,
				size = {22,22},
				dock=DOCK_TOP,
				ctype = v,
				OnClick = function(s)
					self:Combine(itemA.data,itemB.data,s.ctype)
				end})) 
		end
		cl:UpdateLayout()

	end
end 
function PANEL:Combine(A,B,T)
	--crafting.CanCraft(formid,storage)
	--MsgN(crafting.Craft(s.formid,s.recipeid,LocalPlayer().storage)) 
	if crafting.Combine(A,B,T,LocalPlayer().storage) then
		--self.itemA:Remove(self.itemA.item)
		--self.itemB:Remove(self.itemB.item)
		--self.itemA.item = nil
		--self.itemB.item = nil
		--self.items = {}
		--self.combolist:Clear()
	end
	hook.Call("inventory_update",LocalPlayer())
end