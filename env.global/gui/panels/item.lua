PANEL.basetype = "button"
CURRENT_DRAG = false
CURRENT_AB_ITEMS = {}

local unknowntex = LoadTexture("textures/gui/icons/unknown.png")
local equippedtex = LoadTexture("textures/gui/equipped.png")

local function dragupdate() 
	local c = CURRENT_DRAG
	if c then 
		local mousePos = input.getMousePosition() 
		local vsize = GetViewportSize()
		c:SetPos((mousePos-vsize/2)*Point(2,-2)+Point(70,50))
		c:SetCanRaiseMouseEvents(false)
		
		local mhag = input.MouseIsHoveringAboveGui()
		local lmb = input.leftMouseButton() 
		if not lmb then
			if not mhag then
				hook.Call("event.item.droprequest",c)
					--MsgN("Dropped to world")
			else
				c:OnDrop()
				if CURRENT_SLOT then
					CURRENT_SLOT:Drop(c)
					CURRENT_SLOT = nil
					--CURRENT_DRAG = false 
					--MsgN("Dropped on new slot")
				else 
					c.lastSlot:Drop(c)
					--CURRENT_DRAG = false 
					--MsgN("Dropped on last slot")
				end
				c:SetCanRaiseMouseEvents(true)
			end
			hook.Remove("main.predraw", "gui.item.drag")
		end
	end
end
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
hook.Add("main.predraw", "gui.item.abupdate", abupdate)
--hook.Add("ability.cast","item.update",function() 
--end)

function Item(ent,inv)
	local item =  panel.Create("item")
	item.inv = inv
	item:Dock(DOCK_FILL)
	item:Set(ent)
	return item
end

function PANEL:Init() 
	self.base.Init(self) 
	self.base.SetColorAuto(self,Vector(0.1,0.3,0.1),0.1) 
	local title = panel.Create()
	title:Dock(DOCK_TOP)
	title:SetSize(10,10)
	title:SetCanRaiseMouseEvents(false)
	--title:SetAlpha(0.5)
	
	local amount = panel.Create()
	amount:Dock(DOCK_BOTTOM)
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
	if not CURRENT_DRAG then
		--MsgN("CLICK! ",fid)
		if fid==1 then
			local CTD = CurTime()-0.2
			--MsgN(LAST_CONTEXTMENU_CLOSE_TIME)
			if (LAST_DROP~=self or LAST_DROP_TIME < CTD) and (not LAST_CONTEXTMENU_CLOSE_TIME or LAST_CONTEXTMENU_CLOSE_TIME<CTD) then--
				self:Pick() 
			end
			--MsgN("CLICK=> ",CURRENT_DRAG)
		else
		end
	end
end
function PANEL:MouseClick(fid)
	if not CURRENT_DRAG then
		if fid==2 then 
			local itemi = self.item
			local ACT_USE = function(item) if item.item then item.item:SendEvent(EVENT_USE,LocalPlayer()) end return false end
			local context = {
				{text = ""..self.title:GetText()},
				{text = "use",action = ACT_USE},
				{text = "drop",action = function(item) hook.Call("event.item.droprequest",item) return false end},
				--{text = "B",action = function(item,context) MsgN("ho!") end},
				--{text = "CCC",sub={
				--	{text = "lel"},
				--	{text = "1"},
				--	{text = "2"},
				--	{text = "3",action = function(item,context) MsgN("JA!") end},
				--}},
			}
			
			if itemi.IsEquipped then
				if itemi:IsEquipped() then
					context[2] = {text = "unequip",action = function(i) ACT_USE(i) i:Refresh() end}
				else
					context[2] = {text = "equip",action = function(i) ACT_USE(i) i:Refresh() end}
				end
			end
			
			ContextMenu(self,context)
		end
	end
end

function PANEL:TrySetTexture(name)
	if not name then return false end
	local basedir = "textures/gui/icons/"
	local tfn = basedir..name..".png"
	if file.Exists(tfn) then
		local tex = LoadTexture(tfn)
		self:SetTexture(tex)
		return true
	else
		return false
	end
end

function PANEL:Set(item)
	--hook.Remove("ability.cast","item."..tostring(3))
	
	self.base.SetColorAuto(self,Vector(0.9,0.9,0.9),0.1)
	
	if item.GetClass then 
		local class = item:GetClass()
		self.title:SetText(item.title or class)
		if not self:TrySetTexture(class) then  
			self:SetTexture(unknowntex)
		end
	else
		self:SetTexture(unknowntex)
	end
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
	self.item = item
	
end

function PANEL:Pick()
	--if not CURRENT_DRAG then
		if self.original == nil then
			CURRENT_DRAG = self 
			CURRENT_SLOT = nil
			local p = self:GetParent()
			self.lastSlot = p
			if p then p:Remove(self) p.item = nil end
			dragupdate()
			self:Show()
			input.SetKeyboardBusy(true)
			hook.Add("main.predraw", "gui.item.drag", dragupdate)
			--hook.Add("input.mousedown", "gui.item.drag", function()
			--	self:Drop()
			--	hook.Remove("input.mousedown","gui.item.drag") 
			--end)
		else
			local p = self:GetParent() 
			if p then p:Remove(self) p.item = nil  end
			if p.OnUnset then p:OnUnset(self) end
		end
	--else
		--if self.original ~= nil then 
		--	if CURRENT_DRAG ~= self then
		--		local p = self:GetParent() 
		--		if p then p:Remove(self) p.item = nil  end
		--		if p.OnUnset then p:OnUnset(self) end
		--		p:Drop(CURRENT_DRAG)
		--		CURRENT_DRAG = false
		--	end
		--else  
		--	if self.item and self.item.GetClass then
		--		local classself = self.item:GetClass()
		--		local classtarg = CURRENT_DRAG.item:GetClass()
		--		if classself == classtarg then
		--			if self.item.Stack then 
		--				if(self.item:Stack(CURRENT_DRAG.item))then
		--					CURRENT_DRAG:OnDrop() 
		--					self:Set(self.item)
		--				end
		--			end
		--		end
		--	end
		--end
	--end
end
function PANEL:OnDrop()
	if CURRENT_DRAG == self then
		CURRENT_DRAG = false
		input.SetKeyboardBusy(false)
	end
	self:Close()
	hook.Remove("main.predraw", "gui.item.drag")
	
	--MsgN("Dropped !")
	--MsgN(debug.traceback())
	LAST_DROP = self
	LAST_DROP_TIME = CurTime()
end

function PANEL:MakeCopy()
	local cpy = panel.Create("item")
	cpy.original = self
	cpy:Set(self.item)
	return cpy
end

function PANEL:Select(actor)
	local ent = self.item 
	if ent then
		--if ent.HasFlag then
		--	if ent:HasFlag(FLAG_USEABLE) then
		--		USE_ITEM(actor,ent)
		--	end
		--else
			if ent.Activate then
				ent:Activate(actor)
			elseif ent.Cast then
			--	ent:Cast(actor)
				actor:SetActiveAbility(ent.id)
			end
		--end
	else
		actor:SetActiveWeapon()
		actor:SetActiveAbility()
	end
end
function PANEL:Refresh()
	self:Set(self.item)
end