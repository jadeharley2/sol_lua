
local layout = {type = "panel", 
	size = {200,600},
	dock = DOCK_TOP,  
	color = {0,0,0},  
	subs = {{type = "panel", 
		dock = DOCK_TOP,  
		size = {20,20},
		margin = {9,1,9,1}, 
		color = {1,1,1},  
	}}
}

function PANEL:Init()  
	local nt = {}
	local p = gui.FromTable(layout,self,{},nt)  

	self:UpdateLayout()
end 

