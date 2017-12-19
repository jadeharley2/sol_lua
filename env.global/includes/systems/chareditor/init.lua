if SERVER then return nil end

chareditor = chareditor or {}

function chareditor.Enable()
	local list_view = nodeeditor._lv or panel.Create("graph_editor")
	nodeeditor._lv = list_view
	list_view:Show()
end
function chareditor.Disable()
	nodeeditor._lv:Close() 
end

console.AddCmd("chareditor", chareditor.Enable)
---test

--render.SetRenderBounds(100,100,1000,1000)