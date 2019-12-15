PANEL.basetype = "window"

temp_allinvwindows = temp_allinvwindows or {}
function InvRefreshAll()
	for k,v in pairs(temp_allinvwindows) do
		v:RefreshINV()
	end
end
hook.Add("inventory_update","refr_all",function(node)
	for k,v in pairs(temp_allinvwindows) do
		if v.node==node then
			v:RefreshINV()
		end
	end
end)

function InventoryWindow(container)
	if container then
		local seed = container:GetSeed()
		local prev = temp_allinvwindows[seed]
		if prev then
			prev:Close()
			temp_allinvwindows[seed] = nil
			hook.Call("player.inventory.close")
		else
			local s =  container:GetComponent(CTYPE_STORAGE)
			if s then
				local ww = panel.Create("window_inventory")
				ww.node = container
				ww.storage = s
				ww:ReloadTabs() 
				ww:Show()
				temp_allinvwindows[seed] = ww
				hook.Call("player.inventory.open")
			end
		end
	end
end
function OpenInventoryWindow(container)
	if container then
		local seed = container:GetSeed()
		local prev = temp_allinvwindows[seed] 
		if not prev then
			local s =  container:GetComponent(CTYPE_STORAGE)
			if s then
				local ww = panel.Create("window_inventory")
				ww.node = container
				ww.storage = s
				ww:ReloadTabs() 
				ww:Show()
				temp_allinvwindows[seed] = ww
				hook.Call("player.inventory.open")
				return ww
			end
		end
	end
end
function CloseInventoryWindow(container)
	if container then
		local seed = container:GetSeed()
		local prev = temp_allinvwindows[seed] 
		if prev then
			prev:Close()
			temp_allinvwindows[seed] = nil
			hook.Call("player.inventory.close")
		end
	end
end
local temp_iwindows = {} 
function AddIWindow(w) 
	temp_iwindows[#temp_iwindows+1] = w
end
function CloseIWindows()
	for k,v in pairs(temp_iwindows) do
		if v and v.Close then
			v:Close()
		end 
	end
	temp_iwindows = {}
	hook.Call("player.inventory.close")
end

function PANEL:Init()
	--PrintTable(self)
	self.fixedsize = true
	self.base.Init(self)
	self:SetSize(500,200)
	self:SetColor(Vector(0.6,0.6,0.6))
	--self:ReloadTabs() 
end
function PANEL:ReloadTabs()
	 
	local seed = (self.node or LocalPlayer()):GetSeed()
	temp_allinvwindows[seed] = self
	 
	self.inner:Clear()

	local statusbar = gui.FromTable({
		color = {0,0,0},
		textcolor = {1,1,1},
		textalignment = ALIGN_RIGHT,
		size = {20,20},
		dock = DOCK_BOTTOM,
		text = "balance"
	})
	self.statusbar = statusbar
	self.inner:Add(statusbar)
	local tabs = panel.Create("tabmenu")
	
	self.tabs = tabs
	tabs:Dock(DOCK_FILL)
	self.inner:Add(tabs) 
	
	--local grid = panel.Create("icongrid") 
	--local inv = Inventory(30)
	--
	--local ab_grid = panel.Create("icongrid") 
	--local ab_inv = Inventory(30)
	--
	--grid:SetSize(40,40)
	--ab_grid:SetSize(40,40)
	--
	--self.inv = inv
	--self.ab_inv = ab_inv
	--
	----lua_run for k,v in list(chat.list.inv.list) do MsgN(v) end
	--grid:Dock(DOCK_FILL)
	--
	--tabs:AddTab("INV",grid)
	--tabs:AddTab("ABL",ab_grid)
	
	
	local ply = self.node or LocalPlayer()
	local storage = self.storage or ply:GetComponent(CTYPE_STORAGE)
	if storage then
		gui.FromTable({type='floatcontainer', name = 'xgrid',
			dock = DOCK_FILL,
			color = {0,0,0},
			Scrollbars = 1,
			size = {150,150}, 
		},nil,{},self) 

		self.xgrid:SetFloater(gui.FromTable({ 
			color = {0,1,0},
			size = {150,1000},
			autosize = {false,true},
			subs = {
				{type = 'grid', name = 'grid2',
					size = {150,1000},
					color = {1,0,0},
					autosize = {false,true},
					dock = DOCK_TOP,
				}
			}
		},nil,{},self))
		tabs:AddTab("INV",self.xgrid)
		--self.grid2 = grid2
		self.storage = storage 
		self:RefreshINV()
	end
	
	local abilities = ply.abilities  
	if abilities then
		local grid2 = panel.Create("grid")  
		for k,v in pairs(abilities) do 
			local slot = panel.Create("slot",{size={48,48},color = {0.1,0.1,0.1}})
			--slot.storage = storage
			--slot.storeslot = k
			local item  = abilities[k]
			if item then 
				slot:Add(Item(storage,k,{reference = k, table = 'abilities' },ply))
			end
			grid2:AddPanel(slot)
		end 
		tabs:AddTab("ABL",grid2) 
	end
	
	--local abilities = ply.gestures  
	--if abilities then
		--local grid2 = panel.Create("grid")  
		--for k,v in pairs(abilities) do 
		--	local slot = panel.Create("slot",{size={48,48},color = {0.1,0.1,0.1}})
		--	--slot.storage = storage
		--	--slot.storeslot = k
		--	local item  = abilities[k]
		--	if item then
		--		slot:Add(Item(storage,k,item))
		--	end
		--	grid2:AddPanel(slot)
		--end    
	local gestures = ply.gestures    
	if gestures then
		local grid3 = panel.Create("panel")
		grid3:SetColor(Vector(0,0,0))   
		tabs:AddTab("GESTURES",grid3) 

		for k,v in pairs(gestures) do
			local testgesture = panel.Create("button")
			testgesture:SetSize(100,20)     
			testgesture:SetText(k)  
			testgesture:Dock(DOCK_TOP)
			local isOn = false
			testgesture.OnClick = function()
				self.node:GestureToggle(1,k)   
			end

			grid3:Add(testgesture)
		end
	end

	--local ff_grid_floater = panel.Create("graph_grid")  
	--ff_grid_floater:SetSize(4000,4000)
	--ff_grid_floater:SetTextureScale(Point(4000/256,4000/256)) 
	--
	--local ff_grid = panel.Create("floatcontainer") 
	--ff_grid:SetSize(200,200)  
	--ff_grid:SetScrollbars(3)
	--ff_grid:SetFloater(ff_grid_floater)
	--tabs:AddTab("TEST",ff_grid)
	--tabs:AddTab("TEST",panel.Create("tree"))
	
	self.grid = grid
	self.ab_grid = ab_grid
	
	--grid:Refresh()
	--ab_grid:Refresh()
	self:UpdateLayout() 
	--tabs:ShowTab(3)
	--tabs:ShowTab(2) 
	tabs:ShowTab(1) 
	--tabs:ShowTab(3)
end
function PANEL:SetInventory(inv)
	self.inv = inv
	self.grid:LoadInventory(inv)
	self:UpdateLayout()
	self.grid:Refresh()
	self:UpdateLayout()
end
function PANEL:SetInventory2(inv)
	self.ab_inv = inv
	self.ab_grid:LoadInventory(inv)
	self:UpdateLayout()
	self.ab_grid:Refresh()
	self:UpdateLayout()
end
function PANEL:Open() 
	--self:UpdateLayout()
	--self.grid:LoadInventory(self.inv)
	--self.grid:Refresh()
	--self.ab_grid:LoadInventory(self.ab_inv)
	--self.ab_grid:Refresh()
	self:ReloadTabs() 
	self:UpdateLayout()
	self:Show() 
	if not self.first then
		self.xgrid:Scroll(-10000)
		self.first = true
	end
end
function PANEL:RefreshINV() 
	local storage = self.storage 
	local grid2 = self.grid2
	if storage and grid2 then
		local ply = self.node or LocalPlayer()

		local plbalance = currency.GetBalance(ply) or 0
		if plbalance>0 then
			self.statusbar:SetText(plbalance.." cr ")
		else
			self.statusbar:SetText("")
		end
		storage:Synchronize(function(s)
			MsgN("sync",storage,storage:GetNode())
			--MsgN(debug.traceback())
			grid2:Clear()
			local items = storage:GetItems() 
			local storagesize = storage:GetSize()
			for k=1,storagesize do
				local slot = panel.Create("slot",{size={48,48},color = {0.1,0.1,0.1}})
				slot.storage = storage
				slot.storeslot = k
				local item  = items[k]
				if item then
					slot:Add(Item(storage,k,item,ply))
				end
				grid2:AddPanel(slot)
			end 
			self:UpdateLayout() 
			debug.Delayed(100,function()
				self.xgrid:Scroll(-2000)
			end)
		end) 
	end
end

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end