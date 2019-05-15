
function PANEL:Init() 
	self:SetColor(Vector(0,0,0))
	
	local bcol = Vector(20,20,20)/100
	if not self.inner then
		local xfloater = panel.Create()  
		xfloater:SetSize(150,1000)
		xfloater:SetColor(bcol) 
		xfloater:SetAutoSize(false,true)

		local xgrid = panel.Create("floatcontainer") 
		xgrid:Dock(DOCK_FILL)   
		xgrid:SetScrollbars(1)
		xgrid:SetFloater(xfloater) 
		xgrid:SetColor(bcol)
		self:Add(xgrid)
		self.inner = xfloater
		self.xgrid = xgrid
	end
	local xfloater = self.inner
	local xgrid = self.xgrid

	xfloater:Clear()
	self.slots = {}

	self:AddSlot("first","a")
	self:AddSlot("second","b")

	
	local btn = gui.FromTable({
		type="button",
		text = "merge",
		dock = DOCK_TOP,
		size = {32,32},
		OnClick = function(s)
			MsgInfo("a!")
			self:MergeItems()
		end
	}) 
	self.inner:Add(btn)

	self:AddSlot("result","out")
end 

function PANEL:AddSlot(text,slotkey) 
	
	--local node = self.actor
	--local equipment = node.equipment

	--local equipped = equipment:GetEquipped(slotkey)
 
	local r = panel.Create()
	r:SetSize(10,48)
	r:Dock(DOCK_TOP)
	r:SetColor(Vector(20,20,20)/100)
	self.inner:Add(r)
	
	local slot = panel.Create("slot",{size={48,48},color = {0.1,0.1,0.1}}) 
	slot:Dock(DOCK_RIGHT)  
	slot.OnDrop = slotOnDrop
	slot.parenteq = self
	slot.slotkey = slotkey
	r:Add(slot)
	self.slots[slotkey] = slot

	

	local rt = panel.Create()
	rt:SetSize(150,20)
	rt:Dock(DOCK_FILL)
	rt:SetText(text)
	rt:SetMargin(0,20,0,0)
	rt:SetColor(Vector(30,30,30)/100)
	r:Add(rt)
	
	
	local rd = panel.Create()
	rd:SetSize(10,1)
	rd:Dock(DOCK_TOP)
	rd:SetColor(Vector(0,0,1))
	self.inner:Add(rd) 
end
function PANEL:MergeItems()
	local apanel = self.slots.a.item
	local bpanel = self.slots.b.item
	if apanel and bpanel then
		local aitem = apanel.item
		local bitem = bpanel.item

		local ad = json.FromJson(aitem.data)
		local bd = json.FromJson(bitem.data)

		MsgN("A")
		PrintTable(ad)
		MsgN("B")
		PrintTable(bd)

		local seed = ad.seed 
		local name = nil
		if ad.parameters then
			name = ad.parameters.name
			ad.parameters.position = nil
			ad.parameters.rotation = nil
			ad.parameters.scale = nil
			ad.parameters.model = nil
		end

		table.Merge(bd,ad,true)
		ad.seed = seed
		if ad.parameters then
			ad.parameters.seed = seed
			ad.parameters.name = name or ad.parameters.name
		end
		
		MsgN("OUT")
		PrintTable(ad)
		local od = json.ToJson(ad)
		aitem.data = od
		self.slots.a:Clear()
		self.slots.b:Clear()
		apanel:Set(apanel.storeslot,aitem)
		self.slots.out:Add(apanel)
	end

end