
function PANEL:Init() 
	self:SetColor(Vector(0,0,0))
	
end 

function PANEL:Set(actor)
	self.actor = actor

	local bcol = Vector(20,20,20)/100

	if not self.inner then
		local xfloater = panel.Create()  
		xfloater:SetSize(150,1000)
		xfloater:SetColor(bcol) 
		xfloater:SetAutoSize(false,true)

		local xgrid = panel.Create("floatcontainer") 
		xgrid:Dock(DOCK_FILL)   
		xgrid:SetScrollbars(1)
		xgrid:SetFloater(xfloater) 
		xgrid:SetColor(bcol)
		self:Add(xgrid)
		self.inner = xfloater
		self.xgrid = xgrid
	end
	local xfloater = self.inner
	local xgrid = self.xgrid

	xfloater:Clear()
	self.slots = {}

	--local asp = actor.species 
	self:AddGroup("ALL")
	if actor.equipment then
		for k,v in pairs(actor.equipment:GetSlots()) do
			self:AddSlot(v..":",v) 
		end 
		
		temp_allinvwindows[-10] = self
	end
	self:UpdateLayout()
	xgrid:Scroll(0)
end
function PANEL:RefreshINV()
	self:Set(self.actor)
end
 
function PANEL:AddGroup(text)
	local r = panel.Create()
	r:SetSize(10,20)
	r:Dock(DOCK_TOP)
	r:SetColor(Vector(20,50,20)/100)
	r:SetText(text)
	r:SetTextAlignment(ALIGN_CENTER)
	self.inner:Add(r)
end

function PANEL:EquipItem(itempanel) 
	local item = itempanel.item
	local sourceslot = itempanel.storeslot
	local node = self.actor  
	local data = item.data 
	--local self_slot = self.slotkey 
	local item_slot = data:Read("/parameters/slot") or 0
	local slotpanel = self.slots[item_slot]
	if slotpanel then
		MsgN("ee")
		node:SendEvent(EVENT_EQUIP,data) 
		if sourceslot then
			MsgN("UUUUU",sourceslot)
			node:SendEvent(EVENT_ITEM_TAKEN,sourceslot) 
		end
		if itempanel then
			local iprt = itempanel:GetParent()
			if iprt then
				iprt:Remove(itempanel)
			end
			itempanel:Close() 
			if slotpanel.item then
				local II = slotpanel.item
				local ls = itempanel.lastSlot
				ls.item = II 
				II.currentSlot = ls
				ls:Add(II)
				II:Dock(DOCK_FILL)
				ls:UpdateLayout()
				II:SetPos(0,0)
			end
			slotpanel.item = item 
			itempanel.currentSlot = slotpanel
			itempanel.storeslot = slotpanel
			slotpanel:Add(itempanel)
			itempanel:Dock(DOCK_FILL)
			slotpanel:UpdateLayout()
			itempanel:SetPos(0,0) 

	
			itempanel.storage = node.equipment
			itempanel.storeslot = item_slot 

			return true
		end 
	end
end

local slotOnDrop = function(self,item)
	local equipment = self.parenteq 
	local storage = item.storage
	local slot = item.storeslot
	local data = storage:GetItemData(slot)
	if data then
		equipment:EquipItem(item)
	end 
	--if item then
	--	item:Close() 
	--	local ls = item.lastSlot
	--	ls:Add(item)
	--	ls:UpdateLayout()
	--end
	return false
end

function PANEL:AddSlot(text,slotkey) 
	
	local node = self.actor
	local equipment = node.equipment

	local equipped = equipment:GetEquipped(slotkey)
 
	local r = panel.Create()
	r:SetSize(10,48)
	r:Dock(DOCK_TOP)
	r:SetColor(Vector(20,20,20)/100)
	self.inner:Add(r)
	
	local slot = panel.Create("slot",{size={48,48},color = {0.1,0.1,0.1}}) 
	slot:Dock(DOCK_RIGHT)  
	slot.OnDrop = slotOnDrop
	slot.parenteq = self
	slot.slotkey = slotkey
	r:Add(slot)
	self.slots[slotkey] = slot

	if equipped then
		--MsgN(slotkey,equipped)
		--PrintTable(equipped)
		slot:Add(Item(equipment,slotkey,{data =  equipped.data, count = 1} )) 
	end

	local rt = panel.Create()
	rt:SetSize(150,20)
	rt:Dock(DOCK_FILL)
	rt:SetText(text)
	rt:SetMargin(0,20,0,0)
	rt:SetColor(Vector(30,30,30)/100)
	r:Add(rt)
	
	
	local rd = panel.Create()
	rd:SetSize(10,1)
	rd:Dock(DOCK_TOP)
	rd:SetColor(Vector(0,0,1))
	self.inner:Add(rd) 
end