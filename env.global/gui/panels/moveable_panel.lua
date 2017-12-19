 

function PANEL:Init()  
end

function PANEL:MouseDown()

	if not CURRENT_WINDOW_MOVE then
		if not self.fixedpos then
			CURRENT_WINDOW_MOVE_POS = self:GetPos()
			CURRENT_WINDOW_MOVE_POINTPOS =  input.getMousePosition() 
			CURRENT_WINDOW_MOVE = self
			hook.Add("main.predraw", "gui.window.move", GUI_PANEL_GLOBALS.cwmove)
		end
	end
end