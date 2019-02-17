INV_META = INV_META or {}

--[[
	inventory items types
		- suspended
		- data only
]]

function INV_META:AddItem(actor, item)
	 
	if self.list:Contains(item) then 
		if item.SetParent then
			item:SetParent(self.storage)   
		end
		return false 
	end 
	
	if self.list:Add(item) then
		if self.storage then
			if item.SetParent then
				item:SetParent(self.storage) 
				hook.Call("event.pickup",actor,item)
				hook.Call("event.inventory.update",self,actor)
			end
		end
		return true
	else
		return false
	end
end

function INV_META:ContainsItem(item)
	return self.list:Contains(item)
end
function INV_META:Select(func)  
	return self.list:Select(func)
end

function INV_META:RemoveItem(actor,item)
	if self.list:Remove(item) then
		if self.storage then
			if item.SetParent then
				item:SetParent(actor:GetParent()) 
				item:SetPos(actor:GetPos()) 
				hook.Call("event.drop",actor,item)
				hook.Call("event.inventory.update",self,actor)
			end
		end
		return true
	else
		return false
	end 
end

function INV_META:MoveItem(actor,item,otherinv)
	if self.list:Remove(actor,item) then 
		if otherinv.list:Add(actor,item) then
			return true
		end
	end
	return false
end

function INV_META:Clear()
	local tbl = self.list:ToTable()
	self.list:Clear()
	return tbl
end

function INV_META:FreeSlotCount()
	return self.slotcount - self.list:Count()
end

function INV_META:SlotCount()
	return self.slotcount
end

function INV_META:SetSlotCount(num)
	self.slotcount = num
end


INV_META.__index = INV_META

function Inventory(slotnum,physicalid)
	local inv = {slotcount = slotnum, list = List()}
	if physicalid then
		inv.storage = ents.Create() 
		inv.storage:SetSizepower(1000)
		inv.storage:SetSeed(physicalid)
		inv.storage:Spawn() 
	end
	inv.list:SetMaxCount(slotnum)
	setmetatable(inv,INV_META) 
	return inv
end