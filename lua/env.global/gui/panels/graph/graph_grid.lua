
local t_mgrid = "textures/gui/nodes/grid2.png"

 
function PANEL:Init() 
	self:SetTexture(t_mgrid)
	self.selector = panel.Selector()
end

function PANEL:MouseDown(id)
	if id == 1 then
		self.selector:BeginSelection(self,1)
	elseif id == 2 then  
	elseif id == 3 then 
		panel.start_drag(self,3,nil,nil,true) 
	end
	
end



 
function PANEL:Zoom(delta)
	local zoom = math.min(10,math.max(-10, (self.zoom or 1)-delta/1000))
	local spos = self:GetPos() 
	local oldsm = self:GetScaleMul()
	local newsm = 1+math.sin(CurTime())*2--math.exp(zoom-1)
	self:SetScaleMul(newsm)
	--self:SetPos(spos*(newsm/oldsm))
	local sc = self:GetSize()
	self:SetPos(-sc.x/2,-sc.y/2)
	self.zoom = zoom
end
 
function PANEL:OnMouseWheel(delta)
	self:Zoom(-delta)
end

function PANEL:DragDrop()

end