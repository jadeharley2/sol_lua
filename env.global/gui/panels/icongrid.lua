 
 

function PANEL:Init()
	--PrintTable(self) 
	self.items = {} 
	self.itemsettings = 
	{
		perrow = 10,
		maxcount = 30,
		width = 64+32,
		height = 64+32,
		spacingx = 2,
		spacingy = 2
	}
	self:SetColor(Vector(0,0,0))
	
	--self.items[2] = panel.Create("item")
	--self.items[5] = panel.Create("item")
	
	
	self:Refresh() 
end
function PANEL:LoadInventory(inv)
	
	local set = self.itemsettings
	local lns = self.lns or {}
	for k=1,set.maxcount do 
		local lpanel = lns[k]
		if lpanel then
			lpanel:Clear()
		end
	end
	if inv then
		self.items = {}
		local id = 1
		if getmetatable(inv) then
			for k,v in list(inv.list) do
				local item =  panel.Create("item")
				item.inv = inv
				item:Set(v)
				self.items[#self.items+1] = item
				
				if self.lns then
					local lpanel = self.lns[id]
					if lpanel then
						item:Dock(DOCK_FILL)
						lpanel:Add(item)
					end
				end
				id = id +1
			end
		else 
			for k,v in pairs(inv) do
				local item =  panel.Create("item")
				item.inv = inv
				item:Set(v)
				self.items[#self.items+1] = item
				
				if self.lns then
					local lpanel = self.lns[id]
					if lpanel then
						item:Dock(DOCK_FILL)
						lpanel:Add(item)
					end
				end
				id = id +1
			end
		end
	end
	self.inv = inv
end
 

function PANEL:Refresh()  


	local set = self.itemsettings
	local lns = self.lns or {}
	local ss = self:GetSize()
	
	for k,v in pairs(self.lns or {}) do
		v:SetText("")
		v:SetSize(0,0)
	end
	
	
	
	
	local lineheight = set.height + set.spacingy
	local cellwidth = set.width + set.spacingx
	for k=1,set.maxcount do
		--local item = self.items[k] 
		
		local lpanel = lns[k] or panel.Create("slot") 
		local yid = math.floor((k-1)/set.perrow)
		local xid = (k-1) - yid*set.perrow 
		
		lpanel.tex = xid.." "..yid
		
		lpanel:SetSize(set.width/2,set.height/2) 
		lpanel:SetPos(
			xid*cellwidth - ss.x +cellwidth/2 ,
			-yid*lineheight + ss.y -lineheight/2)--+ss.y/2-(linecount)*32/2 
		
		--if item then
		--	lpanel:SetColor(item.color or Vector(40,40,40)/256)
			--lpanel:SetTextColor(item.textcolor or Vector(1,1,1))
			--item:Dock(DOCK_FILL)
			--lpanel:Add(item)
		--else
		----	lpanel:SetColorAuto(Vector(20,20,20)/256)
		--end
		--------lpanel.OnClick = function()
		--------	local c = CURRENT_DRAG
		--------	if c then
		--------		c:Drop()
		--------		c:Dock(DOCK_FILL)
		--------		lpanel:Add(c)
		--------		if self.inv ~= c.inv then
		--------			c.inv:MoveItem(c.item,self.inv)
		--------			c.inv = self.inv
		--------		end
		--------		--self:UpdateLayout()
		--------		self:Refresh()  
		--------	end
		--------end
		self:Add(lpanel)
		lns[k] = lpanel
	end
	self.lns = lns 
	self:UpdateLayout()
end
 


function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end