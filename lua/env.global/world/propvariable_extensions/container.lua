
function ItemsetSpawn(storage,k,v,rnd) 
	local its = forms.ReadForm('itemset.'..k) 
	--MsgN("itemsetspawn",its)
	if its then
		local count = v.count or 1

		if not v.mode or v.mode == "all" then
			for kk,vv in pairs(its.subsets) do -- groups 
				for k3,v3 in pairs(vv) do -- items
					--storage:AddFormItem(v3)
					local item = forms.GetItem(v3,0) 
					if item then
						MsgN("is_item",v3,item)
						storage:PutItemAsData(nil,item,count)
					end
				end
			end
		elseif v.mode == "oneof" then
			local key = table.RandomKey(its.subsets,rnd)
			local group = its.subsets[key]   
			if group then 
				for k3,v3 in pairs(group) do -- items
					--storage:AddFormItem(v3)
					local item = forms.GetItem(v3,0) 
					if item then
						MsgN("is_item2",v3,item)
						storage:PutItemAsData(nil,item,count)
					end
				end
			end
		end
	end
end

local function ContainerUse(self,user)
	if not self.isopened then
		self.user = user
		self:EmitSound("events/storage-open.ogg",1)
		if CLIENT and LocalPlayer() == user then 
			actor_panels.OpenInventory(self,ALIGN_TOP,nil)
			actor_panels.OpenInventory(user,ALIGN_BOTTOM,nil)
			actor_panels.OpenCharacterInfo(user,ALIGN_LEFT,nil) 
			hook.Add("actor_panels.closed","container_closed",function()
				hook.Remove("actor_panels.closed","container_closed")
				self.user = nil
				self.isopened = false
				self:EmitSound("events/storage-close.ogg",1)
			end)
			--OpenInventoryWindow(self)  
		end 
		self.isopened = true
	else
		if self.user == user then
			self.user = nil
			self:EmitSound("events/storage-close.ogg",1)
			if CLIENT and LocalPlayer() == user then 
				actor_panels.CloseAll()
				--CloseInventoryWindow(self) 
			end
			self.isopened = false
		end
	end
end

hook.Add("prop.variable.load","container",function (self,j,tags)   
	if j.container then
		local storage = self:AddComponent(CTYPE_STORAGE)  
		self.storage = storage
		self.isopened = false 
		self.usetype = "open container"
		self:AddTag(TAG_USEABLE)
		self:AddEventListener(EVENT_USE,"a",ContainerUse)
		self:SetNetworkedEvent(EVENT_USE,true)
		if j.container.size then
			storage:SetSize(j.container.size or 30)
		end
		--local itemc = r:NextInt(0,3)
		--local items = table.Keys(forms.GetList("apparel"))
		--for k=1,itemc do
		--	local st = table.Random(items)
		--	storage:AddFormItem("apparel",st)
		--end

		--MsgN("eeeeee",self:GetSeed())
		local its = j.container.itemsets
		if its then
			local r = Random(self:GetSeed()) 
			for k,v in pairs(its) do 
				if v.chance then
					if r:NextInt(0,100)<v.chance then
						ItemsetSpawn(storage,k,v,r)
					end
				else
					ItemsetSpawn(storage,k,v,r)
				end
			end
		end
		local its = j.container.items
		if its then
			for k,v in pairs(its) do
				
			end
		end
	end
end)


hook.Add('item_features','propv.container',function(formid,data,addfeature)
    if data.container then
        addfeature("container size:"..tostring(data.container.size or 30),{1,1,1},'textures/gui/features/container.png')  
    end  
end) 