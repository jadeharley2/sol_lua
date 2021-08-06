hook.Remove("input.mousewheel", "gui.quickpanel.repos")
hook.Remove("input.keydown", "gui.quickpanel.repos")
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
		self:UpdatePos()
	end)
	 
	
	hook.Add( "event.inventory.update","gui.quickpanel.repos",function(inv,actor)
		if actor == LocalPlayer() then 
			self:Refresh()
		end
	end)
--hook.Add("input.mousewheel", "gui.quickpanel.repos",function()
--	self:GMouseWheel()
--end)
	hook.Add("input.keydown", "gui.quickpanel.repos",function()
		if LocalPlayer() then
			self:GKeyDown()
		end
	end)
end
function PANEL:UpdatePos()
	local vsize = GetViewportSize()
	local csize = self:GetSize() 
	self:SetPos(vsize.x/2-csize.x/2,vsize.y-csize.y)
end
function PANEL:Select(actor,index)
	cslot = self.cslot or 0
	--if index ~= cslot then
		self.cslot = index 
		local slot = self.slots[index]
		if slot then 
			slot:Select(actor)
			self.selector:SetPos(slot:GetPos()+Point(0,0.5))
			if slot.item and slot.item.item then
				hook.Call("quickmenu.item_select",slot.item.item,index)
			else
				hook.Call("quickmenu.item_select",nil,index) 
			end
		end
	--end
	self.selector:SetVisible(true)
end
hook.Add("quickmenu.item_select","test",function(item,id)
	local _ctool = LocalPlayer()._ctool
	if _ctool then
		_ctool:Unequip(LocalPlayer())
		_ctool:Despawn()
		LocalPlayer()._ctool = nil
	end

	if item and item.data then
		MsgN(item)
		if(item.data:Read("/parameters/luaenttype") == 'base_tool') then
			MsgN("istool")
			PrintTable(json.FromJson(item.data))
			local tool = ents.FromData(item.data,LocalPlayer())
			if tool then
				LocalPlayer()._ctool = tool
				tool:Equip(LocalPlayer())
			end
		end
	end
end)
function PANEL:SelectNext(actor)
	self:Select(actor,((self.cslot or 1) + 1)%10)
end
function PANEL:SelectPrev(actor)
	local sl = (self.cslot or 1)-1
	if sl<=0 then sl=sl+10 end
	self:Select(actor,sl)
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
	local actor = LocalPlayer()
	
	for k=1,8 do
		slot = self.slots[k]
		data = self.slot_data[k]
		slot:Clear()
		if data then  
			local item = Item(inventory,k,data,actor) 
			item.original = true
			slot:Add(item)
			slot.item = item
			slot:UpdateLayout()
			item:SetPos(0,0)
		end
	end
end

function PANEL:GKeyDown() 
	local actor = LocalPlayer()
	if not input.GetKeyboardBusy() then
		if (input.KeyPressed(KEYS_D1)) then self:Select(actor,1) end
		if (input.KeyPressed(KEYS_D2)) then self:Select(actor,2) end
		if (input.KeyPressed(KEYS_D3)) then self:Select(actor,3) end
		if (input.KeyPressed(KEYS_D4)) then self:Select(actor,4) end
		if (input.KeyPressed(KEYS_D5)) then self:Select(actor,5) end
		if (input.KeyPressed(KEYS_D6)) then self:Select(actor,6) end
		if (input.KeyPressed(KEYS_D7)) then self:Select(actor,7) end
		if (input.KeyPressed(KEYS_D8)) then self:Select(actor,8) end
		if (input.KeyPressed(KEYS_D9)) then self:Select(actor,9) end
		if (input.KeyPressed(KEYS_D0)) then self:Select(actor,10) end 
	end
end
function PANEL:GMouseWheel()
	local wp = self.wheelpos
	local nwp = input.MouseWheel()
	if wp then
		if wp<nwp then
			self:SelectPrev(LocalPlayer())
		elseif wp>nwp then
			self:SelectNext(LocalPlayer())
		end
	end
	self.wheelpos = nwp
end

console.AddCmd("qm_set",function(num,itemtype)

end)