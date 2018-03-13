
--local testDFont = LoadFont("fonts/alternian.json")
--[[
	table types
	1: 
		key = {key,key={key}}, key
	2:
		1 = key,
		2 = {1 = key,2 = {1=key,2=key}}
]]
PANEL.itemheight = 20

function PANEL:Init()
	--PrintTable(self)  
	self:SetColor(Vector(0.2,0.2,0.2))
	
	local ff_grid_floater = panel.Create() 
	
	ff_grid_floater:SetSize(400,800)   
	ff_grid_floater:SetColor(Vector(0.2,0.2,0.2))
	
	
	local ff_grid = panel.Create("floatcontainer") 
	ff_grid:SetSize(400,120)  
	ff_grid:Dock(DOCK_FILL)  
	ff_grid:SetScrollbars(1) 
	ff_grid:SetFloater(ff_grid_floater) 
	ff_grid:SetColor(Vector(0.2,0.2,0.2))
	self:Add(ff_grid)
	ff_grid_floater.level = 0
	self.root = ff_grid_floater
	self.grid = ff_grid
	--local tbl = file.GetFileTree("forms/characters/")
	--PrintTable(tbl)
	--self:FromTable(tbl,self.root)
end
function PANEL:SetTableType(type) 
	self.tabletype = type
end
--PANEL:Clear() - clear all elements
function PANEL:FromTable(tbl,parent,clickfn) 
	parent = parent or self.root
	local clevel = parent.level + 1
	local tabletype = self.tabletype or 1
	--if parent then self:Clear() end
	local clickfn = clickfn or function(btn) self:ItemClick(btn) end
	
	local subs = {}
	if tabletype==1 then
		for k,v in pairs(tbl) do
			local nod = self:AddItem(k,parent,v,clickfn)
			nod.level = clevel
			subs[#subs+1] = nod 
		end
	else--if tabletype == 2 then
		for k,v in ipairs(tbl) do 
			if k > 1 then
				local nod = self:AddItem(v[1],parent,v,clickfn)
				nod.level = clevel
				subs[#subs+1] = nod 
			end
		end
	end
	parent.subs = subs
	self:UpdateLayout() 
end 
function PANEL:Collapse(node) 
	if node.level and node.level>0 then
		local totalcon = 0
		for k,v in pairs(node.subs) do
			totalcon = totalcon + v:GetSize().y
			node:Remove(v)
		end 
		node:SetSize(200,self.itemheight) 
		local parent = node:GetParent()
		if parent then
			self:RecuExpand(parent,-totalcon)
			self.root:SetPos(self.root:GetPos()+Point(0,totalcon))
		end
		self:UpdateLayout() 
	end
end 
function PANEL:AddItem(text,parent,value,clickfn) 
	local vistbl = istable(value)
	local tabletype = self.tabletype or 1
	--MsgN("add item: ",text," to ",parent)
	local new_item = panel.Create()
	new_item:SetSize(200, self.itemheight)
	--new_item:SetText("-"..tostring(text))
	new_item:SetColor(Vector(0.5,0.5,0.5))
	new_item:Dock(DOCK_TOP)
	if vistbl then new_item.tag = value.tag end
	
	new_text = panel.Create("button")
	---new_text:SetFont(testDFont)
	new_text:SetSize(200,self.itemheight-1) 
	new_text:SetText(tostring(text))
	new_text:SetColorAuto(Vector(0.4,0.4,0.4))
	new_text:Dock(DOCK_TOP)
	
	 
	if parent then
		self:RecuExpand(parent,self.itemheight)
		self.root:SetPos(self.root:GetPos()+Point(0,-self.itemheight))
	end
	
	parent = parent or self.root
	parent:Add(new_item)
	
	if vistbl and value.OnClick then
		new_text.OnClick = value.OnClick
	else
		new_text.OnClick = clickfn
	end
	
	if vistbl and (tabletype==1 or #value>1) then 
		expand = panel.Create("button")
		--
		
		expand:SetSize(20,20) 
		expand:SetText("+")
		expand:SetTextAlignment(ALIGN_CENTER)
		expand:SetColorAuto(Vector(0.1,0.5,0.3))
		expand:Dock(DOCK_LEFT)
		expand.cont = false
		expand.item = new_item
		expand.value = value
		expand.OnClick = function(b)
			if b.cont then
				self:Collapse(b.item)
				b:SetText("+")
				b:SetColorAuto(Vector(0.1,0.5,0.3))
				b.cont = false
			else
				self:FromTable(b.value,b.item,clickfn) 
				b:SetColorAuto(Vector(0.5,0.3,0.1))
				b:SetText("-")
				b.cont = true
			end
		end
		
		new_indent = panel.Create()
		new_indent:SetSize(20,2000) 
		--new_indent:SetText("+")
		new_indent:SetColor(Vector(0.5,0.5,0.5))
		new_indent:Dock(DOCK_LEFT)
		
		new_item:Add(expand)
		new_item:Add(new_text)
		new_item:Add(new_indent)
	else 
		new_item:Add(new_text)
	end
	
	return new_item
end 

function PANEL:RecuExpand(item,amount)
	local csize = item:GetSize()
	item:SetSize(csize.x,csize.y+amount)
	local parent = item:GetParent()
	if parent and parent.level then
		self:RecuExpand(parent,amount)
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
function PANEL:ItemClick(item)
	if self.OnItemClick then
		self:OnItemClick(item:GetParent())
	end
end
