
local t_mgrid = LoadTexture("gui/nodes/grid.png")

 
function PANEL:Init() 
	self:SetTexture(t_mgrid)
	self.selector = panel.Selector()
end

function PANEL:MouseDown(id)
	if id == 1 then
		self.selector:BeginSelection(self,1)
	elseif id == 2 then  
	elseif id == 3 then 
		panel.start_drag(self,3) 
	end
end



 
function PANEL:Zoom(delta)
	local zoom = math.min(10,math.max(-10, (self.zoom or 1)-delta/1000))
	local spos = self:GetPos() 
	local oldsm = self:GetScaleMul()
	local newsm = math.exp(zoom-1)
	self:SetScaleMul(newsm)
	self:SetPos(spos*(newsm/oldsm))
	self.zoom = zoom
end

function PANEL:MouseEnter()  
	local sWVal = input.MouseWheel() 
	hook.Add("input.mousewheel", "grid.scroll",function() 
		local mWVal = input.MouseWheel() 
		local delta = mWVal - sWVal
		sWVal = mWVal
		self:Zoom(-delta)
	end)
end
function PANEL:MouseLeave()
	hook.Remove("input.mousewheel", "grid.scroll")
end

function PANEL:DragDrop()

end