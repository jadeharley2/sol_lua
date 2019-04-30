
DeclareEnumValue("event","EQUIP",	331011) 
DeclareEnumValue("event","UNEQUIP",	331012) 
DeclareEnumValue("event","UNEQUIPALL",331013) 

DeclareEnumValue("vartype","EQUIPMENT",		88020)


component.uid = DeclareEnumValue("CTYPE","EQUIPMENT", 1324)
component.editor = {
	name = "Equipment",
	properties = { 
		slotcount = {text="Slot count",type="scripted",valtype="array",reload=false,
			getvalue=function(n,c) return #c:GetSlots() end},
	},  
} 


function component:OnLoad()
	local node = self:GetNode()
	local itms = node[VARTYPE_EQUIPMENT]
	if itms then
		node:Delayed("equip",400,function()
			self:FromData(itms) 
		end)
	end
end



function component:Init() 
	self.list = {}
end
  
function component:OnAttach(node)
	node._comevents = node._comevents or {}
	node._comevents[self.uid] = self 
	node:AddNativeEventListener(EVENT_LOAD,"equipment",function(s) component.OnLoad(self) end)
end
function component:OnDetach(node)
	node._comevents = node._comevents or {}
	node._comevents[self.uid] = nil 
	node:RemoveNativeEventListener(EVENT_LOAD,"equipment")
end
 
 

function component:GetEquipped(slot)  
	if slot then
		local pp = self.list[slot]
		if pp.entity then
			return pp
		end
	else
		local lst = {}
		for k,v in SortedPairs(self.list) do
			if v.entity then
				lst[#lst+1] = v
			end 
		end 
		return lst
	end
end

function component:UneqipAll() 
	local node = self:GetNode()
	if node then
		node:SendEvent(EVENT_UNEQUIPALL)
	end
end
 
function component:IsEquipped(data)
	local node = self:GetNode()
	if node then
		local slot = data:Read("/parameters/slot") or 0
		local sltd = self.list[slot]
		if sltd and sltd.entity then
			return true
		end
	end
	return false
end

function component:Equip(data)
	local node = self:GetNode()
	if node and data then 
		local slot = data:Read("/parameters/slot") or 0
		if self:HasSlot(slot) then
			node:SendEvent(EVENT_EQUIP,data)
			return true
		end
	end
	return false
end
function component:AddSlot(slot)
	self.list[slot] = self.list[slot] or {}
	return false
end
function component:HasSlot(slot) 
	return self.list[slot] ~= nil
end
function component:GetSlots()  
	local lst = {}
	for k,v in SortedPairs(self.list) do
		lst[#lst+1] = k
	end
	return lst
end
function component:Clear() 
	self:UneqipAll()
	self.list = {}
end


function component:TransferItem(from_slot,to,to_id,count)
	local node = self:GetNode()
	if from_slot and to and to_id and count then
		local item = self:GetEquipped(from_slot)
		if item then
			to:GetNode():SendEvent(EVENT_ITEM_ADDED,to_id,item.data,count) 
			node:SendEvent(EVENT_UNEQUIP,item.data)  
		end
	end
end
function component:GetParts()
	local el = {}
	for k,v in pairs(self.list) do
		if v and v.entity and IsValidEnt(v.entity) then 
			el[#el+1] = v.entity
		end
	end
	return el
end 

function component:ToData()
	local list = self.list

	local datar = {}
	for k,v in pairs(list) do
		if v.data then
			datar[k] = { data = json.FromJson(v.data)}
		else
			datar[k] = { data = false}
		end
	end  
	return json.ToJson(datar)
end
function component:FromData(data) 
	local node = self:GetNode()
	for k,v in pairs(node:GetChildren()) do
		if v:GetClass() == "body_part" and v.iscloth then
			v:Despawn()
		end
	end

	local list= {}
	if data then
		local datar = json.FromJson(data)  
		for k,v in pairs(datar) do
			self:AddSlot(k)
			if v.data  then
				local data = json.ToJson(v.data)
				--list[k] = {data = data} 
				self:_equip(data,true)
			end
		end
	end 
	--self.list = list
	return list
end

function component:Synchronize()
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

 
function component:_clear() 
	for k,v in pairs(self.list) do
		self:_unequipslot(k)
	end
	self.list = {}
end
function component:_unequipslot(slot)   
	local node = self:GetNode()
	local eqslt = self.list[slot] 
	if eqslt and eqslt.entity and IsValidEnt(eqslt.entity) then 
		local e = eqslt.entity

		local unhideray = e.hideby
		if unhideray then
			local spp = node.spparts
			if spp then
				for k,v in pairs(unhideray) do
					local nn = spp[v]
					if nn then
						nn:UnhideBy(e) 
					end
				end
			end
		end


		eqslt.entity:Despawn()
		eqslt.entity = nil
		eqslt.data = nil
		MsgN(slot,"free")
	end
end
function component:_equip(data,nosave)    
	local node = self:GetNode()
	local form = data:Read("/parameters/form")
	if node and form then 
		local formdata = json.Read(form) 
		if formdata then
			local model = formdata.model--data:Read("/parameters/model")
			local slot = data:Read("/parameters/slot") or 0
			local scale = data:Read("/parameters/modelscale") or 1
			local seed =  data:Read("seed") or data:Read("/parameters/seed") or 0

			--MsgN("slot",model,scale,seed)
			--PrintTable(formdata)
			if model then
				self:_unequipslot(slot)

				local eqslt = self.list[slot]  
				if eqslt then
					local e = SpawnBP(model,node,scale,seed)
					eqslt.data = data 
					eqslt.entity = e
					e:SetName(slot)
					e.iscloth = true
					MsgN(slot,e)
					if not nosave then
						node[VARTYPE_EQUIPMENT] = self:ToData()
					end
					if CLIENT then
						node:EmitSound("physics/cloth/rustle_0"..table.Random({1,2,3,4,5,6})..".ogg",1)
					end 
 

					local hide = formdata.hide
					if hide then
						self.hideray = self.hideray or {}

						local spp = node.spparts
						if spp then
							for k,v in pairs(hide) do 
								local nn = spp[v]
								if nn then
									nn:HideBy(e) 
								end
							end
							e.hideby = hide
						end
					end
				end
			end
		end
	end
end
 
component._typeevents = { 
	[EVENT_EQUIP]={networked=true,f = component._equip}, 
	[EVENT_UNEQUIP]={networked=true,f = function(self,data)   
		local node = self:GetNode()
		if node then
			local slot = data:Read("/parameters/slot") or 0
			self:_unequipslot(slot)
			node[VARTYPE_EQUIPMENT] = self:ToData()
			if CLIENT then
				node:EmitSound("physics/cloth/rustle_0"..table.Random({1,2,3,4,5,6})..".ogg",1)
			end 
		end
	end}, 
	[EVENT_UNEQUIPALL]={networked=true,f = function(self)   
		local node = self:GetNode()
		if node then 
			for k,v in pairs(self.list) do
				self:_unequipslot(k)
			end
			for k,v in pairs(node:GetChildren()) do
				if v:GetClass() == "body_part" and v.iscloth then
					v:Despawn()
				end
			end
			node[VARTYPE_EQUIPMENT] = self:ToData()
			if CLIENT then
				node:EmitSound("physics/cloth/rustle_0"..table.Random({1,2,3,4,5,6})..".ogg",1)
			end 
		end
	end}, 
}
 