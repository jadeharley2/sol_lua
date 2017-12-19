
local t_mgrid = LoadTexture("gui/mgrid.png")
function PANEL:Init() 
	self:SetTexture(t_mgrid)
end

function PANEL:MouseDown(id)
	if id == 1 then
		if not CURRENT_WINDOW_MOVE and not MOUSE_LOCKED then
			if not self.fixedpos then
				CURRENT_WINDOW_MOVE_POS = self:GetPos()
				CURRENT_WINDOW_MOVE_POINTPOS =  input.getMousePosition() 
				CURRENT_WINDOW_MOVE = self
				LockMouse()
				hook.Add("main.predraw", "gui.window.move", GUI_PANEL_GLOBALS.cwmove)
			end
		end
	elseif id == 2 then 
	end
end