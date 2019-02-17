if SERVER then return nil end

mapeditor = mapeditor or {}

function mapeditor.Enable()
	local list_view = panel.Create("graph_editor")
	mapeditor._lv = list_view
	list_view:Show()
end
function mapeditor.Disable()
	mapeditor._lv:Close()
	mapeditor._lv = nil
end
function mapeditor.Toggle()
	if mapeditor._lv then
		mapeditor.Disable()
	else
		mapeditor.Enable()
	end
end

console.AddCmd("ed_map", mapeditor.Toggle)
 