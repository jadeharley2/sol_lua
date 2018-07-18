if SERVER then return nil end

nodeeditor = nodeeditor or {}

function nodeeditor.Enable()
	local list_view = panel.Create("window_nodetree")
	nodeeditor._lv = list_view
	list_view:Show()
end
function nodeeditor.Disable()
	nodeeditor._lv:Close()
end

console.AddCmd("ed_node", nodeeditor.Enable)
---test

--render.SetRenderBounds(100,100,1000,1000)

function nodeeditor.OpenFlow()
	local list_view = panel.Create("graph_editor")
	nodeeditor._fe = list_view
	list_view:Show()
	hook.Add("main.predraw","editor_flow",nodeeditor.Update)
end
function nodeeditor.CloseFlow()
	nodeeditor._fe:Close()
	nodeeditor._fe = nil 
	hook.Remove("main.predraw","editor_flow")
end
function nodeeditor.Update()
	nodeeditor._fe:Update()
end

function nodeeditor.ToggleFlow()
	if nodeeditor._fe then
		nodeeditor.CloseFlow()
	else
		nodeeditor.OpenFlow()
	end
end

console.AddCmd("ed_flow",nodeeditor.ToggleFlow)