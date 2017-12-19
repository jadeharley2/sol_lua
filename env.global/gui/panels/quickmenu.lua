
function PANEL:Init()
	local w = (64+32)/2
	self:SetSize(500-2,w)
	
	self.slots = {} 
	self.slot_data = {}
	
	local OnSet = function(slot,item)
		self.slot_data[slot.id] = item.item
	end
	local OnUnset = function(slot,item)
		self.slot_data[slot.id] = nil
	end
	
	for k=1,10 do
		local slot =  panel.Create("slot")
		slot.slottype = "reference"
		slot:SetSize(w,w)
		--slot.inv = inv
		--slot:Set(v)
		slot.id = k
		slot.OnSet = OnSet 
		slot.OnUnset = OnUnset 
		
		self.slots[k] = slot
		
		slot:Dock(DOCK_LEFT)
		self:Add(slot)
		if k < 10 then
			local separator =  panel.Create()
			separator:SetSize(2,2)
			separator:Dock(DOCK_LEFT)
			separator:SetColor(Vector(0,0,0))
			self:Add(separator)
		end
	end 
	
	local selector =  panel.Create()
	selector:SetSize(w,2)
	selector:SetCanRaiseMouseEvents(false)
	selector:SetVisible(false)
	self:Add(selector)
	
	self.selector = selector
	
	hook.Add( "window.resize","gui.quickpanel.repos",function()
		local vsize = GetViewportSize()
		local csize = self:GetSize() 
		self:SetPos(0,-vsize.y+csize.y)
	end)
	 
	
	hook.Add( "event.inventory.update","gui.quickpanel.repos",function(inv,actor)
		if actor == LocalPlayer() then 
			self:Refresh()
		end
	end)
	
end
function PANEL:Select(actor,index)
	cslot = self.cslot or 0
	--if index ~= cslot then
		self.cslot = index 
		local slot = self.slots[index]
		if slot then 
			slot:Select(actor)
			self.selector:SetPos(slot:GetPos()+Point(0,-slot:GetSize().y+0.5))
		end
	--end
	self.selector:SetVisible(true)
end
function PANEL:Refresh()
	for k,v in pairs(self.slots) do
		v:Refresh()
	end
end
function PANEL:GetData()
	return self.slot_data
end
function PANEL:SetData(slotdata,inventory)
	self.slot_data = slotdata or {}
	
	for k=1,8 do
		slot = self.slots[k]
		data = self.slot_data[k]
		slot:Clear()
		if data then
			local item = Item(data,inventory) 
			item.original = true
			slot:Add(item)
			slot:UpdateLayout()
			item:SetPos(0,0)
		end
	end
end

