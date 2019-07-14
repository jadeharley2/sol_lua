
DeclareEnumValue("event","ITEM_TRANSFER",	8266) 
DeclareEnumValue("event","ITEM_ADDED",		8267) 
DeclareEnumValue("event","ITEM_TAKEN",		8268) 
DeclareEnumValue("event","ITEM_DROP",		8269) 
DeclareEnumValue("event","ITEM_DESTROY",    8270) 

DeclareEnumValue("event","CONTAINER_SYNC",		8271) 
DeclareEnumValue("event","CONTAINER_SYNC_DATA",	8272) 

DeclareEnumValue("vartype","STORAGE",		88010)

component.uid = DeclareEnumValue("CTYPE","STORAGE", 1314)
component.editor = {
	name = "Storage",
	properties = {
		size = {text="size",type="scripted",valtype="number",reload=false,key="storage.size"},
		items = {text="Item count",type="scripted",valtype="array",reload=false,
			getvalue=function(n,c) return c:ItemCount() end},
		
	}, 
	
} 
component._typeevents = { 
	[EVENT_ITEM_TRANSFER]={networked=true,f = function(self,from_id,ent_to,to_id,count)  
		if ent_to then
			local to = ent_to:GetComponent(CTYPE_STORAGE)
			if self and to and to.list and self.list then
				MsgN(self:GetNode(),"item transfer ",self:GetNode(),from_id,ent_to,to_id,count)

				local data = nil

				if to:SlotIsFree(to_id) then
					local item = self.list[from_id]
					if item then 
						item.count = item.count - 1
						if item.count <=0 then self.list[from_id] = nil end 
						local data = item.data
						
						to.list[to_id] = {data = data, count = 1}  
						self:GetNode()[VARTYPE_STORAGE] = self:ToData() 
						MsgN("item transfer: valid")
					else 
						MsgN("item transfer: invalid - item nonexistent")
					end 
				else 
					MsgN("item transfer: invalid - target slot occupied")
				end 
			end
		end
	end},
	[EVENT_ITEM_ADDED]={networked=true,f = function(self,id,data,count)  
		MsgN(self:GetNode(),"item added at",id) 
		self.list[id] = {data = data,count = 1}   
		self:GetNode()[VARTYPE_STORAGE] = self:ToData()
	end},
	[EVENT_ITEM_TAKEN]={networked=true,f = function(self,id)
		MsgN(self:GetNode(),"item taken at",id)
		self.list[id] = nil
		self:GetNode()[VARTYPE_STORAGE] = self:ToData()
	end},
	[EVENT_ITEM_DROP] = {networked = true, f = function(self,id) 
		local e = self:TakeItem(id)
		if e then
			--e:Spawn()
			if SERVER then
				MsgN(self:GetNode(),"item dropped at",id)
				network.AddNodeImmediate(e)
			end
		end
		self:GetNode()[VARTYPE_STORAGE] = self:ToData()
	end}, 
	[EVENT_ITEM_DESTROY] = {networked = true, f = function(self,id) 
		MsgN(self:GetNode(),"item destroyed at",id)
		self:DestroyItem(id) 
		self:GetNode()[VARTYPE_STORAGE] = self:ToData()
	end},  
	--client->server - request
	--server->client - data
	[EVENT_CONTAINER_SYNC]={networked=true,f = function(self)
		if SERVER then 
			self:GetNode():SendEvent(EVENT_CONTAINER_SYNC_DATA,self:ToData())  
		end
	end},
	[EVENT_CONTAINER_SYNC_DATA]={networked=true,f = function(self,data)
		if CLIENT then
			--PrintTable(data)
			self:FromData(data)
			if self.pending_event then
				self:pending_event()
				self.pending_event = nil
			end
			self:GetNode()[VARTYPE_STORAGE] = self:ToData()
		end
	end} 
}
 
function component:OnLoad()
	local itms = self:GetNode()[VARTYPE_STORAGE]
	if itms then
		self:FromData(itms)
	end
end

function component:Init()
	self.list = {}
end
   
function component:OnAttach(node)
	node._comevents = node._comevents or {}
	node._comevents[self.uid] = self
	MsgN('new storage at: ',node,self:GetNode())
	
	node:AddNativeEventListener(EVENT_LOAD,"storage",function(s) component.OnLoad(self) end)
end
function component:OnDetach(node)
	node._comevents = node._comevents or {}
	node._comevents[self.uid] = nil
	MsgN('ded storage at: ',node)

	node:RemoveNativeEventListener(EVENT_LOAD,"storage")
end
      
function component:SetSynchroEvent(func)
	self.pending_event = func
end  
function component:Synchronize(onCompleted)
	if CLIENT and network.IsConnected() then
		self.pending_event = onCompleted
		local node = self:GetNode()
		if node then
			node:SendEvent(EVENT_CONTAINER_SYNC)
		end
	else
		onCompleted(self)
	end
end


--[[

				hook.Call("event.pickup",actor,item)
				hook.Call("event.inventory.update",self,actor)
]]

function component:AddFormItem(ftype,fname) -- local function
	local index = self:GetFreeSlot();
	if not self.list[index] then
		local p = false
		if fname then
			p = forms.GetForm(ftype,fname)
		else
			p = forms.GetForm(ftype)
		end 
		if p then
			local data = false
			if(string.starts(ftype,"apparel"))then
				data = ItemIA(p,GetFreeUID())--apparel
			else
				data = ItemPV(p,GetFreeUID())--prop
			end
			if data then
				self.list[index] = {data = data, count = 1} 
				return true 
			end
		end
	end
	return false
end
function component:PutItem(index,item) -- local function
	if not self.list[index] then
		if item and IsValidEnt(item) then
			local data = item:ToData()  
			self.list[index] = {data = data, count = 1} 
			--self:GetNode():SendEvent(EVENT_ITEM_ADDED,index,data,count) 
			return true 
		end
	end
	return false
end
function component:PutItemAsData(index,data)  -- local function
	if not self.list[index] then
		if data then 
			self.list[index] = {data = data, count = 1} 
			--self:GetNode():SendEvent(EVENT_ITEM_ADDED,index,data,count) 
			return true 
		end
	end
	return false
end
function component:SlotIsFree(index)
	return not self.list[index]
end
function component:TransferItem(from_id,to,to_id,count)
	if from_id and to and to_id and count then
		self:GetNode():SendEvent(EVENT_ITEM_TRANSFER,from_id,to:GetNode(),to_id,count) 
	end
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
			e:CopyAng(n)
			return e
		end 
	end
	return false
end
function component:DestroyItem(index)
	local n = self:GetNode()
	if n then
		local item = self:TakeItemAsData(index) 
		return true
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
function component:GetItemData(index) 
	local item = self.list[index]
	if item then  
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
function component:HasItem(formid)
	for k,v in pairs(self.list) do
		if v and v.data then
			if isstring(v.data) then
				if v.data == formid then
					return true
				end
			else
				if v.data.parameters then
					local fid = v.data.parameters.form or v.data.parameters.character
					if fid and fid == formid then
						return true
					end
				end
			end 
		end
	end
	return false
end
function component:FormIdCounts()
	local fids = {}
	for k,v in pairs(self.list) do
		if v and v.data then
			if isstring(v.data) then
				local fidl = fids[v.data] or {}
				fidl[k] = v.count or 1
				fids[v.data] = fidl
				--fids[v.data] = (fids[v.data] or 0) + (v.count or 1)
			else
				if v.data.parameters then
					local fid = v.data.parameters.form or v.data.parameters.character
					if fid then 
						local fidl = fids[fid] or {}
						fidl[k] = v.count or 1
						fids[fid] = fidl
						--fids[fid] = (fids[fid] or 0) + (v.count or 1)
					end
				end
			end 
		end
	end
	return fids
end
function component:GetFreeSlot() 
	for k=1,100 do 
		if not self:HasItemAt(k) then
			return k
		end
	end
	return nil
end
function component:HasFreeSlot(count)
	return true
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

function component:ToData()
	local list = self.list

	local datar = {}
	for k,v in pairs(list) do
		datar[#datar+1] = {slot = k, count = v.count, data = json.FromJson(v.data)}
	end  
	return json.ToJson(datar)
end
function component:FromData(data)
	local list= {}
	if data then
		local datar = json.FromJson(data) 
		for k,v in pairs(datar) do
			if(v.data) then
				list[v.slot] = {count = v.count, data = json.ToJson(v.data)}
			end
		end
	end
	self.list = list
	return list
end
