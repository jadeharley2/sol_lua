 
function PANEL:Init()
	--PrintTable(self) 
	self.lines = {}
	self.reverse = false
	self:SetColor(Vector(0,0,0))
	local floater = panel.Create() 
	floater:SetColor(Vector(0,0.1,0))
	floater:SetColor2(Vector(0,0,0))
	floater:SetTextOnly(true)
    floater:SetAnchors(ALIGN_TOP)
	self.floater = floater
	
	
	
	local ff_grid = panel.Create("floatcontainer") 
	ff_grid:Dock(DOCK_FILL)
	ff_grid:SetScrollbars(1) 
	ff_grid:SetFloater(floater) 
	ff_grid:SetColor(Vector(0.1,0,0))
	ff_grid:SetColor2(Vector(0,0,0))
	ff_grid:SetTextOnly(true)
	ff_grid.inner:SetTextOnly(true)
	self.ff_grid = ff_grid
	self:Add(ff_grid)
	
	self:Refresh() 
	
end

function PANEL:Refresh() 
	local lns = self.lns or {}
	local ss = self:GetSize()
	local lines = self.lines
	local lineheight = self.lineheight or 50
	local linecount = math.min(#lines,self.maxlinecount or 100) --math.floor(ss.y/(lineheight/2))
	local alpha = self.alpha or 1
	local textonly = not (self.hasback or false)
	local floater = self.floater
	
	floater:SetSize(ss.x,lineheight/2*linecount)
	
	
	
	for k,v in pairs(self.lns or {}) do
		v:SetText("")
		v:SetSize(0,0)
		v:SetAlpha(alpha)
	end 
	for k=1,linecount do
		local v = ""
		if self.reverse then
			 v = lines[#lines - k + 1] or ""
		else
			 v = lines[k] or ""
		end
		
		local location = 0
		if self.reverse then
			location =  (k-linecount/2-0.5)*lineheight--+ss.y/2-(linecount)*32/2 
			--lpanel:AlignTo(lpanel
		else
			location =  (-k+linecount/2+0.5)*lineheight
		end
		
		local pp = false
		if ispanel(v) then
			
			v:SetPos(0, location)
			v:SetAlpha(alpha)
			floater:Add(v)
			
		else
		
			
			local lpanel = lns[k] or panel.Create("button") 
			lpanel:SetSize(ss.x-20,lineheight/2)
			lpanel:SetPos(0, location)
			lpanel:SetTextOnly(textonly)
			lpanel:SetAlpha(alpha)
			
			if pp then
				if self.reverse then
					lpanel:AlignTo(pp,ALIGN_TOPLEFT,ALIGN_BOTTOMLEFT)
				else
					lpanel:AlignTo(pp,ALIGN_BOTTOMLEFT,ALIGN_TOPLEFT)
				end
			end
			
			pp = lpanel
			
			
			if isstring(v) then
				lpanel:SetText(v)
				lpanel:SetColorAuto(Vector(20,20,20)/256)
				lpanel:SetTextColor(Vector(1,1,1))
			else
				lpanel:SetText(v.text)
				lpanel:SetColorAuto(v.color or Vector(20,20,20)/256)
				lpanel:SetTextColor(v.textcolor or Vector(1,1,1))
				if v.init then
					v.init(lpanel,v)
				end
				lpanel.tag = v
			end
		 
			lpanel.OnClick = function()
				if self.OnSelect then
					self:OnSelect(lpanel)
				end
			end
			floater:Add(lpanel)
			lns[k] = lpanel
		end
	end
	self.lns = lns
end 
function PANEL:AddItem(a)
	a:Dock(DOCK_TOP)
	self.floater:Add(a)
	self.floater:SetAutoSize(false,true)
	self:UpdateLayout()
end
function PANEL:ClearItems() 
	self.floater:Clear()
end
function PANEL:GetItems()
	return self.floater:GetChildren()
end
PANEL.items_info = {type="children_array",add = PANEL.AddItem}

function PANEL:SetAlpha(a)
	--Msg("asd!")
	self.base.SetAlpha(self,a)
	self.ff_grid:SetAlpha(a)
	self.floater:SetAlpha(a)
	self.alpha = a
	if self.lns then
		for k,v in pairs(self.lns) do
			v:SetAlpha(a)
		end
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
function PANEL:ScrollToBottom()
	self.ff_grid:Scroll(9999999)
end
function PANEL:ScrollToTop()
	self.ff_grid:Scroll(-9999999)
end
function PANEL:Scroll(e)
	self.ff_grid:Scroll(e or 0)
end
function PANEL:Resize()
	self:Refresh()
end