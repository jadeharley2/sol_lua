PANEL.basetype = "button"
PANEL.slottype = "storage"
--types: storage, reference

function PANEL:Init()
	self.base.Init(self)
	self:SetSize(64,64)  
	self.base.SetColorAuto(self,Vector(20,20,20)/256)  
end
function PANEL:OnClick()
	--local c = CURRENT_DRAG
	--if c then
	--	c:OnDrop()
	--	self:Drop(c)
	--	---if self.inv ~= c.inv then
	--	---	c.inv:MoveItem(c.item,self.inv)
	--	---	c.inv = self.inv
	--	---end 
	--	--self:Refresh()  
	--end
end

function PANEL:MouseEnter()
	self.base.SetColorAuto(self,Vector(20,60,20)/256) 
	CURRENT_SLOT = self
end
function PANEL:MouseLeave()
	if CURRENT_DRAG then
		--
	end
	self.base.SetColorAuto(self,Vector(20,20,20)/256)  
	--CURRENT_SLOT = nil
end

function PANEL:CanDrop(item)
	return self.item == nil
end

function PANEL:Drop(item)
	if self.slottype == "reference" then
		local cpy = item:MakeCopy()
		item.lastSlot:Drop(item)
		item = cpy
		--MsgN("CPY! ",cpy)
	end
	
	
	if item then
		--MsgN(self.text," -> ",self.item, " <> ",item) 
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
	end
	if self.OnSet then self:OnSet(item) end
end

function PANEL:Select(actor)
	local item = self.item 
	if item then
		item:Select(actor)
	else
		actor:SetActiveWeapon(nil)
		actor:SetActiveAbility(nil)
	end
end
function PANEL:Refresh()
	if item then
		item:Refresh()
	end
end