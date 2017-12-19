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

---test

--render.SetRenderBounds(100,100,1000,1000)