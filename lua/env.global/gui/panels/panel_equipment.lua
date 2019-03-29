 

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

local slotOnDrop = function(self,item)
	local equipment = self.parenteq
	local node = equipment.actor
	local equipment = node.equipment
	local storage = item.storage
	local slot = item.storeslot
	local data = storage:GetItemData(slot)
	if data then
		local self_slot = self.slotkey 
		local item_slot = data:Read("/parameters/slot") or 0
		if self_slot==item_slot then
			MsgN("ee")
			node:SendEvent(EVENT_EQUIP,data) 
			node:SendEvent(EVENT_ITEM_TAKEN,slot) 
			if item then
				item:Close() 
				if self.item then
					local II = self.item
					local ls = item.lastSlot
					ls.item = II 
					II.currentSlot = ls
					ls:Add(II)
					II:Dock(DOCK_FILL)
					ls:UpdateLayout()
					II:SetPos(0,0)
				end
				self.item = item 
				item.currentSlot = self
				self:Add(item)
				item:Dock(DOCK_FILL)
				self:UpdateLayout()
				item:SetPos(0,0) 

		
				item.storage = equipment
				item.storeslot = item_slot 

				return true
			end 
		end
	end
	MsgN("nn")
	if item then
		item:Close() 
		local ls = item.lastSlot
		ls:Add(item)
		ls:UpdateLayout()
	end
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