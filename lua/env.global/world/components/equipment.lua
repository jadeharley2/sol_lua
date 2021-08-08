
DeclareEnumValue("event","EQUIP",	331011) 
DeclareEnumValue("event","UNEQUIP",	331012) 
DeclareEnumValue("event","UNEQUIPALL",331013) 
DeclareEnumValue("event","UNEQUIPSLOT",	331014) 

DeclareVartype("EQUIPMENT",88020,"json","equipped items data")


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
function component:SetLock(slot,lock)
	self.list[slot].lock = lock
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
function component:HasItem(formid) 
	local lst = {}
	for k,v in SortedPairs(self.list) do
		if v.data and v.data.parameters and v.data.parameters.form == formid then
			return v.data
		end
	end 
	return false
end
function component:UnequipId(formid) 
	local p = forms.GetForm("apparel",formid) or forms.GetForm(formid)

	local lst = {}
	for k,v in SortedPairs(self.list) do
		if v.data and v.data.parameters and v.data.parameters.form == p then 
			return true
		end
	end 
	return false
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
	count = count or 1
	to_id = to_id or to:GetFreeSlot()
	if from_slot and to then 
		local item = self:GetEquipped(from_slot)
		--MsgN(self:GetNode(),from_slot,to:GetNode(),to_id,count)
		if item and to:GetNode() then
			to:GetNode():SendEvent(EVENT_ITEM_ADDED,to_id,item.data,count) 
			local eqslt = self.list[from_slot] 
			if eqslt then eqslt.transfered = true end 
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
function component:_unequipslot(slot,remove)   
	local node = self:GetNode()
	local eqslt = self.list[slot] 
	if eqslt and not eqslt.lock and eqslt.entity and IsValidEnt(eqslt.entity) then 
		local e = eqslt.entity


		if e.subitems then 
			for k,v in pairs(e.subitems) do
				self:SetLock(k,false)
				self:_unequipslot(k,true)
			end
		end

		local unhideray = e.hideby
		if unhideray then
			local spp = node.spparts
			if spp then
				for k,v in pairs(unhideray) do
					--local nn = spp[v]
					--if nn then
					--	nn:UnhideBy(e) 
					--end
					for k,v in pairs(SPECIES_GetParts(node,v)) do
						v:UnhideBy(e)
					end
				end
			end
		end

		if not eqslt.transfered then
			if not remove then
				local storage = node.storage
				if storage then
					storage:PutItemAsData(storage:GetFreeSlot(),eqslt.data)
				end
			end
		else
			eqslt.transfered = nil
		end
		eqslt.entity:Despawn()
		eqslt.entity = nil
		eqslt.data = nil
		hook.Call("equipment.unequip",node,slot)
	end
end

function component:_updatevisibility() 
	local node = self:GetNode()
	for k,e in pairs(node:GetChildren(true)) do
		if e.hideby then  
			for k,part in pairs(e.hideby) do
				for k,v in pairs(SPECIES_GetParts(node,part)) do
					if v ~= e and v:GetParent() ~=e and v:GetSeed()==0 then
						v:HideBy(e)
						--MsgN(v,"hidden by",e)
					end
				end
			end
		end
	end 
end
function component:_equip(data,nosave)    
	local node = self:GetNode()
	local form = data:Read("/parameters/form")
	if node and form then 
		local sizepower = node:GetSizepower()
		local formdata = forms.ReadForm(form)--json.Read(form) 
		if formdata then
			local model = formdata.model--data:Read("/parameters/model")
			local slot = data:Read("/parameters/slot") or 0
			local scale = data:Read("/parameters/modelscale") or 1
			local seed =  data:Read("seed") or data:Read("/parameters/seed") or 0

			--MsgN("slot",model,scale,seed)
			--PrintTable(formdata)
			if model then 
				local eqslt = self.list[slot]  
				if eqslt and not eqslt.lock then
					self:_unequipslot(slot)


					local e = SpawnBP(model,node,scale,GetFreeUID(),sizepower)
					if IsValidEnt(e) then
						eqslt.data = data 
						eqslt.formid = data.parameters.form
						eqslt.entity = e
						e:SetName('ap'..slot)
						e:SetPos(Vector(0,0,0))
						e:SetAng(Vector(0,0,0))
						e.iscloth = true 
						  
						 
						--MsgN(slot,e)
						if not nosave then
							node[VARTYPE_EQUIPMENT] = self:ToData()
						end
						if CLIENT then
							node:EmitSound("physics/cloth/rustle_0"..table.Random({1,2,3,4,5,6})..".ogg",1)
						end 
						if formdata.luatype then 
							local meta = ents.GetType(formdata.luatype)
							if meta then  
								e._secondbase = meta  
								if meta.Init then
									meta.Init(e)
								end
								if meta.PreLoadData then
									meta.PreLoadData(e)
								end 
								if isLoad then
									if meta.Load then 
										meta.Load(e)
									end
								else
									if meta._spawn then 
										meta._spawn(e)
									end
								end
								if meta.Think then 
									e:AddNativeEventListener(EVENT_UPDATE,"think",meta.Think)
								end
							end
						end

						local hide = formdata.hide
						if hide then
							self.hideray = self.hideray or {}

							local spp = node.spparts
							if spp then
								for k,v in pairs(hide) do 
									--local nn = spp[v]
									--if nn then
									--	nn:HideBy(e) 
									--end
									for k,v in pairs(node:GetByName(v,true,true)) do
									--	v:HideBy(e)
									end
								end
								e.hideby = hide
							end
						end


						local nametable = {root = e}
						if formdata.subs then
							for k,v in pairs(formdata.subs) do
								local ee = ents.FromData(json.ToJson(v),e)
								local en = ee:GetName()
								if en then
									nametable[en] = ee
								else
									nametable[#nametable+1] = ee
								end
							end
						end
						if formdata.subitems then
							e.subitems = {}
							for k,v in pairs(formdata.subitems) do
								self:GetNode():Give(v,1,true) 
								e.subitems[k] = true
								self:SetLock(k,true)
							end
						end
						--MsgN("names")
						--PrintTable(nametable)

						if formdata.materials then 

							local bmatdir = formdata.basematdir
							for k,v in pairs(formdata.materials) do
								local keys = k:split(':') 
								local bpart = keys[1] 
								local id = tonumber( keys[2])
								if id==nil and bpart == 'mat' then
									local newmat = dynmateial.LoadDynMaterial(v,bmatdir)
									for partname,part in pairs(nametable) do
										for matid,matname in pairs(part.model:GetMaterials()) do
											if string.find(matname,keys[2]) then
												part.model:SetMaterial(newmat,matid-1)
											end
										end
									end  
								else
									local part = nametable[bpart]
									if part then  
										local mat = dynmateial.LoadDynMaterial(v,bmatdir)
										part.model:SetMaterial(mat,id)
									end
								end 
							end
						end 
						if formdata.replacematerial then
							for ee in pairs(nametable) do
								local rmodel = ee.model
								for k,v in pairs(formdata.replacematerial) do
									if isstring(v) then
										rmodel:SetMaterial(LoadMaterial(v),k-1) 
									end
								end
							end
						end
						if formdata.modmaterials then
							e.defmat = ModNodeMaterials(e,formdata.modmaterials,false,true)
						end
						if formdata.modmaterial then 
							local rmodel = e.model
							if rmodel then
								for k,v in pairs(formdata.modmaterial) do  
									local mat = rmodel:GetMaterial(k-1)
									if not nocopy and mat then
										mat = CopyMaterial(mat)
										rmodel:SetMaterial(mat,k-1)
									end
									for kk,vv in pairs(v) do
										if istable(vv) and #vv == 3 then
											SetMaterialProperty(mat,kk,JVector(vv))
										else
											SetMaterialProperty(mat,kk,vv)
										end
									end
								end
							end 
						end
						if formdata.flexes then 
							for k,v in pairs(formdata.flexes) do
								local keys = k:split(':') 
								local bpart = keys[1] 
								local id = tonumber( keys[2]) 
		
								local part = nametable[bpart]
								if bpart == "root" then part = self end 
								if part then   
									part.model:SetFlexValue(id,v)
								end 
							end
						end
						if formdata.effects then
							for k,v in pairs(formdata.effects) do 
								Ability()
							end
						end
						if formdata.viseffects then
							--debug.Delayed(100,function()
								for k,v in pairs(formdata.viseffects) do 
									local targ = false
									if v.target =='self' then targ = e
									elseif v.target =='owner' then targ = node
									end
									if targ then
										disstest(targ,v.args)
									end
								end
							--end)
						end
						self:_updatevisibility()
						hook.Call("equipment.equip",node,slot,formdata)
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
	[EVENT_UNEQUIPSLOT]={networked=true,f = function(self,slot,remove)   
		local node = self:GetNode()
		if node then 
			self:_unequipslot(slot,remove) 
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
 
if CLIENT then
	console.AddCmd("unequipall",function()
		local l = LocalPlayer()
		if l then
			l:SendEvent(EVENT_UNEQUIPALL)
		end
	end)
end