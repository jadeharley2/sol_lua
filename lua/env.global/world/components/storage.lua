component.uid = DeclareEnumValue("CTYPE","STORAGE", 1314)
component.editor = {
	name = "Storage",
	properties = {
		size = {text="size",type="scripted",valtype="number",reload=false,key="storage.size"},
		items = {text="Item count",type="scripted",valtype="array",reload=false,
			getvalue=function(n,c) return c:ItemCount() end},
		
	}, 
	
}


DeclareEnumValue("event","ITEM_ADDED",		8267) 
DeclareEnumValue("event","ITEM_TAKEN",		8268) 

function component:Init()
	self.list = {}
end

function component:OnAttach(node)
	MsgN('new storage at: ',node,self:GetNode())
end
function component:OnDetach(node)
	MsgN('ded storage at: ',node)
end
 
function component:Test()
	MsgN('232323',self:GetNode())
end  

--[[

				hook.Call("event.pickup",actor,item)
				hook.Call("event.inventory.update",self,actor)
]]

function component:PutItem(index,item) 
	if not self.list[index] then
		if item and IsValidEnt(item) then
			local data = item:ToData()
			self.list[index] = {data = data,count = 1}   
			self:GetNode():SendEvent(EVENT_ITEM_ADDED,index)
			return true 
		end
	end
	return false
end
function component:PutItemAsData(index,data) 
	if not self.list[index] then
		if data then 
			self.list[index] = {data = data,count = 1}   
			self:GetNode():SendEvent(EVENT_ITEM_ADDED,index) 
			return true 
		end
	end
	return false
end
--[[

				hook.Call("event.drop",actor,item)
				hook.Call("event.inventory.update",self,actor)
]]
function component:TakeItem(index)
	local n = self:GetNode()
	if n then
		local item = self:TakeItemAsData(index)
		if item then
			local parent = n:GetParent()
			local pos = n:GetPos()  
			local e = ents.FromData(item,parent,pos)
			e:SetPos(pos)
			return e
		end 
	end
	return false
end
function component:TakeItemAsData(index) 
	local item = self.list[index]
	if item then 
		item.count = item.count - 1
		if item.count <=0 then
			self.list[index] = nil
		end
		self:GetNode():SendEvent(EVENT_ITEM_TAKEN,index) 
		return item.data
	end 
	return false
end
function component:ShowItem(index)
	local item = self.list[index]
	if item then
		return item.data, item.count
	end
end
function component:HasItemAt(index)
	return self.list[index]~=nil 
end
function component:GetFreeSlot() 
	for k=1,100 do 
		if not self:HasItemAt(k) then
			return k
		end
	end
	return nil
end
function component:ContainsItemOfType(itemtype)
	return false--return self.list:Contains(item)
end
function component:Select(func)
	local retk = {}
	for k,v in pairs(self.list) do
		if func(v.data,v.count) then retk[#retk+1] = k end
	end
	return retk
end
function component:GetItems() 
	return self.list
end


function component:MoveItem(index,otherstorage,otheridex,count)
	count = count or 1 --todo add support
	if self:HasItemAt(index) and not otherstorage:HasItemAt(otheridex) then
		local item = self:TakeItemAsData(index)
		if item then  
			return otherstorage:PutItemAsData(otheridex,item)
		end
	end 
	return false
end

function component:Clear()
	self.list = {}
	self:GetNode():SendEvent(EVENT_ITEM_TAKEN,"all") 
end

function component:ItemCount()
	local ttl = 0
	for k,v in pairs(self.list) do
		ttl = ttl + v.count
	end
	return ttl
end

function component:UpdateData()
	local n = self:GetNode()
	if n then
		
	end
end
