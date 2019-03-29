PANEL.basetype = "window"

function PANEL:Init()
	--PrintTable(self)
	self.base.Init(self)
	self:SetSize(500,200)
	self:SetColor(Vector(0.6,0.6,0.6))
	self:OnResize() 
end

function PANEL:Setup(form_type,spawn_function)


	local ff_grid_floater = panel.Create()  
	ff_grid_floater:SetSize(400,1000)
	
	local bcol = Vector(60,60,60)/255
	  
	local flist = forms.GetList(form_type)
	local totals = 0
	local givefunc = function(s)  
		local LP = LocalPlayer()
		if LP and s.item then  
			spawn_function(LP,s.item)
		end
	end
	for k,v in SortedPairs(flist) do    
		
		local sp_new = panel.Create("button")
		sp_new:SetText(v) 
		sp_new:Dock(DOCK_TOP)
		sp_new:SetTextColorAuto(bcol) 
		sp_new:SetTextAlignment(ALIGN_LEFT)
		sp_new:SetSize(150,20)
		sp_new.item = k
		sp_new.OnClick = givefunc
		ff_grid_floater:Add(sp_new)
		
		totals = totals + 20
			
	end
	ff_grid_floater:SetSize(400,math.max(totals,100))
	ff_grid_floater:SetColor(bcol) 
	
	local ff_grid = panel.Create("floatcontainer") 
	ff_grid:SetSize(400,120)  
	if totals > 120 then
		ff_grid:SetScrollbars(1)
	end
	ff_grid:SetFloater(ff_grid_floater) 
	ff_grid:SetColor(bcol)
	ff_grid:Dock(DOCK_FILL)
	self.inner:Add(ff_grid)
	
	self.grid = ff_grid
	self.floater = ff_grid_floater
	
end

function PANEL:OnResize()  
end

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end

local current_itemv = false
console.AddCmd("apparel",function()
	if current_itemv then
		current_itemv:Close()
		current_itemv=false
	else
		current_itemv = panel.Create("window_itemviewer")
		current_itemv:Show()
	end
	
end)