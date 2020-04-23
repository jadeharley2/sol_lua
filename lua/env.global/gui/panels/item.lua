PANEL.basetype = "button"
CURRENT_DRAG = false
CURRENT_AB_ITEMS = {}

local unknowntex = LoadTexture("textures/gui/icons/unknown.png")
local equippedtex = LoadTexture("textures/gui/equipped.png")
 
local function abupdate() 
	local ct = CurTime()
	for k,v in pairs(CURRENT_AB_ITEMS) do
		local ab = v.item
		if ab then
			local nextcast = ab.nextcast or 0
			if ct < nextcast then
				local cdd = ab.cooldownDelay
				local sz = (nextcast-CurTime())/cdd
				local ss = v:GetSize()
				v.cooldownpanel:SetSize(sz*ss.x,ss.y) 
				v.cooldownpanel:SetPos(sz*ss.x+-ss.x,0)
			else
				v.cooldownpanel:SetSize(10,0) 
			end
			v:UpdateLayout()
		end
	end
end
hook.Add(EVENT_GLOBAL_PREDRAW, "gui.item.abupdate", abupdate)
--hook.Add("ability.cast","item.update",function() 
--end)

function Item(storage,slot,data,node)
	local item =  panel.Create("item")
	item.storage = storage
	item.node = node
	item:Dock(DOCK_FILL)
	item:Set(slot,data,node)
	return item
end
function PANEL:MakeCopy()
	local cpy = panel.Create("item")
	cpy.original = self
	cpy:Set(self.storeslot,self.item,self.node) 
	return cpy
end

function PANEL:Init() 
	self.base.Init(self) 
	self.base.SetColorAuto(self,Vector(0.1,0.3,0.1),0.1) 
	local title = panel.Create()
	title:Dock(DOCK_BOTTOM)
	title:SetSize(10,10) 
	title:SetColor(Vector(0,0,0))
	title:SetTextColor(Vector(4,4,4))
	title:SetCanRaiseMouseEvents(false)
	title:SetAlpha(0.5)
	
	local amount = panel.Create()
	amount:Dock(DOCK_TOP)
	amount:SetSize(15,15)
	amount:SetTextOnly(true)
	amount:SetCanRaiseMouseEvents(false)
	amount:SetTextAlignment(ALIGN_RIGHT)
	amount:SetTextColor(Vector(1,1,1))
	amount:SetText("1")
	
	local selector = panel.Create() 
	selector:SetSize(15,15) 
	selector:SetTexture(equippedtex)
	selector:SetAlpha(0)
	selector:SetCanRaiseMouseEvents(false) 
	
	local cooldown = panel.Create()
	--cooldown:Dock(DOCK_BOTTOM)
	cooldown:SetSize(0,0) 
	cooldown:SetCanRaiseMouseEvents(false) 
	cooldown:SetColor(Vector(0,0,0))
	cooldown:SetAlpha(0.5)
	 
	self:Add(cooldown)
	self:Add(title)
	self.title = title
	self:Add(amount)
	self.amount = amount
	self.cooldownpanel = cooldown
	self:Add(selector)
	self.selector = selector
	--self.OnClick = function(s) 
	--end
end

function PANEL:MouseDown(fid)
	if self.lock then return end
	if not panel.current_drag and fid == 1 then
	
		if self.original == nil then 
			panel.start_drag_on_shift(self,1,function(s) 		
				local p = s:GetParent()
				if p then p:Remove(s) end
				s:Show()
				s:SetPos(input.getInterfaceMousePos()*GetViewportSize()+Point(50,-50))
				s.lastSlot = p
				--s:SetCanRaiseMouseEvents(true)
				return true 
			end,true) 
		else
			local p = self:GetParent() 
			if p then p:Remove(self) p.item = nil  end
			if p.OnUnset then p:OnUnset(self) end
		end
		
		 
	end  
end
function PANEL:MouseClick(fid) 
	if not panel.current_drag and fid==1 then
		if self.lock then return end
		if input.KeyPressed(KEYS_SHIFTKEY) then
			local source = self.storage
			local node = source:GetNode()
			local ply = LocalPlayer()
			local target = false
			if(node==ply) then
				for k,v in pairs(actor_panels.panels) do
					if v and v.storage and v.storage~=source then
						target = v.storage
						break
					end
				end
			else
				target = ply.storage
			end

			if target then
				local fs = target:GetFreeSlot()
				if fs then
					local count = nil
					if input.KeyPressed(KEYS_CONTROLKEY) then count = 1 end

					source:TransferItem(self.storeslot,target,nil,count) 
				--	self:GetParent().parenteq:RefreshINV()
					MsgN("sclick!")  
				--	InvRefreshAll()
					debug.Delayed(100,function()
						hook.Call("storage.update",target,target:GetNode()) 
						hook.Call("storage.update",source,source:GetNode()) 
					end)
				end
			elseif GLOBAL_CEQPANEL then
				local data = self.item.data
				if data.parameters.luaenttype == "item_apparel" then
					--MsgN("uu", self.slot,self.item) 
					if GLOBAL_CEQPANEL:EquipItem(self) then 
					end
					debug.Delayed(100,function()
						hook.Call("storage.update",nil,LocalPlayer())  
						GLOBAL_CEQPANEL:RefreshINV()
					end)
				end 
			end
		end
	end
	if not panel.current_drag and fid==2 then 
		local itemi = self.item
		--local ACT_USE = function(item) if item.item then item.item:SendEvent(EVENT_USE,LocalPlayer()) end return false end
		local context = {}
		if itemi then
			hook.Call("item_properties",itemi,context,self.storage,self)
		end
			--{text = ""..self.title:GetText()},
			--{text = "use",action = ACT_USE},
		context[#context+1] =	{text = "drop",action = function(item) 
				item.storage:GetNode():SendEvent(EVENT_ITEM_DROP,item.storeslot,1) 
				--self:GetParent():Remove(self)  

			end}--hook.Call("event.item.droprequest",item) return false end},
		context[#context+1] =	{text = "destroy",action = function(item) 
				item.storage:GetNode():SendEvent(EVENT_ITEM_DESTROY,item.storeslot) 
				self:GetParent():Remove(self)  
			end}--hook.Call("event.item.droprequest",item) return false end},
		context[#context+1] = {
			text = "debug",
			sub = {
				{text = "info", action = function(item)  PrintTable(json.FromJson(item.storage.list[item.storeslot].data),5)  end},
				{text = "forminfo",action = function(item)  PrintTable(forms.ReadForm(item.storage.list[item.storeslot].formid),5)  end},
				{text = "edit", action = function(item)  EIT = json.FromJson(item.storage.list[item.storeslot].data) end},
				{text = "save", action = function(item)  item.storage.list[item.storeslot].data = json.ToJson(EIT) end}
			}
		}
			--{text = "B",action = function(item,context) MsgN("ho!") end},
			--{text = "CCC",sub={
			--	{text = "lel"},
			--	{text = "1"},
			--	{text = "2"},
			--	{text = "3",action = function(item,context) MsgN("JA!") end},
			--}},
		 
		--if itemi and itemi.IsEquipped then
		--	if itemi:IsEquipped() then
		--		context[#context+1] = {text = "unequip",action = function(i) ACT_USE(i) i:Refresh() end}
		--	else
		--		context[#context+1] = {text = "equip",action = function(i) ACT_USE(i) i:Refresh() end}
		--	end
		--end
		if self.customactions then
			local node = self.storage:GetNode()
			local fenf = setmetatable({
				storage = self.storage, 
				node = node,
				item = json.FromJson(self.item.data)
			},{__index = _G})
			for k,v in pairs(self.customactions) do
				local condvalue = true
				if v.condition then
					for k,v in pairs(v.condition) do
						if v[1]=='if' then
							condvalue = condvalue and node[v[2]]
						elseif v[1]=='ifnot' then
							condvalue = condvalue and (not node[v[2]]) 
						end 
					end
				end
				if condvalue then
					local act = v.action 
					if istable(act) then
						act = ''
						for kk,vv in ipairs(v.action) do
							act = act ..' '.. vv
						end
					end
					local f,e1,e2,e3 = load(act,nil,nil,fenf)
					if f and isfunction(f) then 
						context[#context+1] = {text = v.text, action = function(item) 
							local rez = pcall(f)
							
							if rez == 'inv' then self:GetParent().parenteq:RefreshINV() 
							elseif rez then self:Refresh() end
						end}
					else
						MsgN(f,e1,e2,e3)
					end
				end
			end
		end
		
		ContextMenu(self,context)
	end 
end

function PANEL:TrySetTexture(name)
	if not name then return false end
	if not isstring(name) then return false end
	local basedir = "textures/gui/icons/"
	local tfn = basedir..name..".png"
	--MsgN("iconsearch: ",tfn)       
	if file.Exists(tfn) then
		local tex = LoadTexture(tfn)
		self:SetTexture(tex)
		return true
	else
		return false
	end
end

function PANEL:Set(slot,item,node)
	--hook.Remove("ability.cast","item."..tostring(3))
	 
	if not item then return false end
	
	self.base.SetColorAuto(self,Vector(0.9,0.9,0.9),0.1)
	self.storeslot = slot

	
	self.item = item
	self.lock = item.lock

	if item.reference and item.table then
		--local actor = self.storage:GetNode() 
		item = node[item.table][item.reference]-- item.table[item.reference] or item
		 
	end
	
	
	local data = item.data
	

	if data then --item
		local title =  data:Read("/parameters/name")
		local luatype = data:Read("/parameters/luaenttype") 
		local class =   data:Read("/parameters/form") or data:Read("/parameters/character")
		local amount =  data:Read("/parameters/amount")
		local icon =   data:Read("/parameters/icon")
		--MsgN(icon)
		self.title:SetText(title or class or luatype or "???")
		self.contextinfo = title or class or luatype or "???"
		self.contextinfo = function(ci)
			ci:Clear()
			ci:SetSize(200,200)
			ci:SetAutoSize(false,true)

			local cc = panel.Create('iteminfo')
			cc:SetForm(class)
			cc:Dock(DOCK_TOP)
			ci:Add(cc)
		end
		--MsgN(title,luatype,class,amount,icon)
		--PrintTable(class)   
 
		if not ( self:TrySetTexture(icon) 
			or self:TrySetTexture(class) 
			or self:TrySetTexture(luatype) ) then 

				FormThumbnailRender(self,class)
			--local tfname = 'textures/thumb/'..class..'.png' 
			--if file.Exists(tfname) then
			--	self:SetTexture(tfname)
			--else
			--	self:SetTexture(unknowntex)
			--end
		end
		
		--PrintTable(item)
		if item.count>1 then
			self.amount:SetText(tostring(item.count)) 
		else
			self.amount:SetText("")
		end 
		self.customactions = data:Read("/parameters/actions")

		local tint = data:Read("/parameters/tint")
		if tint then
			self:SetColorAuto(JVector(tint))
		end

	else -- ability 
		local title =  item.name 
		local icon =  item.icon
		self.title:SetText(title or "???")
		if not (self:TrySetTexture(icon)) then
			self:SetTexture(unknowntex)
		end
		self.amount:SetText("")
	end
	
	if true then return nil end
	 
	if item.GetParameter then
		local char = item:GetParameter(VARTYPE_CHARACTER) 
		if char then 
			self:TrySetTexture(char)
		end
		local amount = item:GetParameter(VARTYPE_AMOUNT)
		if(amount) then
			self.amount:SetText(tostring(amount))
		else
			self.amount:SetText("")
		end
	end
	if item.GetName then
		local name = item:GetName()
		if name and name~="" then
			self.title:SetText(name)
		else 
			local char = item:GetParameter(VARTYPE_CHARACTER) 
			if char then
				self.title:SetText(char)
			end
		end
		if name then
			self:TrySetTexture(name)
		end
	else
		self.title:SetText(tostring(item))
	end
	
	if item.icon then
		self:TrySetTexture(item.icon)
	end
	if item.name and item.name~="" then
		self.title:SetText(item.name)
	end
	
	if isability(item) then
		CURRENT_AB_ITEMS[#CURRENT_AB_ITEMS+1] = self
	end
	
	if item.IsEquipped then 
		local sel = self.selector
		sel:SetSize(self:GetSize())
		if item:IsEquipped() then  
			sel:SetAlpha(1)
		else 
			sel:SetAlpha(0)
		end
	end
	if self.lock then  
		self.base.SetColorAuto(self,Vector(0.1,0.1,0.1),0.1) 
	end
	self.item = item
	
end
 
function PANEL:OnDrop()
	if CURRENT_DRAG == self then
		CURRENT_DRAG = false
		input.SetKeyboardBusy(false)
	end
	self:Close()
	hook.Remove(EVENT_GLOBAL_PREDRAW, "gui.item.drag")
	
	--MsgN("Dropped !")
	--MsgN(debug.traceback())
	LAST_DROP = self
	LAST_DROP_TIME = CurTime()
end

function PANEL:OnDropped(onto)
	--MsgN(onto) 
	local parent = self:GetParent()
	if not parent then
		self:Close() 
		local ls = self.lastSlot 
		if ls then
			ls:Add(self)
			ls:UpdateLayout()
		end
	end
end
function PANEL:Select(actor)
	local ent = self.item  
	if ent then
		if istable(ent) then  
			actor:SetActiveAbility(ent.reference)
			--local rit = actor[ent.table][ent.reference]
			--if rit then
			--	if rit.Activate then
			--		rit:Activate(actor)
			--	elseif rit.Cast then 
			--		actor:SetActiveAbility(rit._name)
			--	end
			--end
		end
		--if ent.HasTag then
		--	if ent:HasTag(TAG_USEABLE) then
		--		USE_ITEM(actor,ent)
		--	end
		--else
		--end
	else
		actor:SetActiveWeapon()
		actor:SetActiveAbility()
	end
end
function PANEL:Refresh()
	self:Set(self.item)
end