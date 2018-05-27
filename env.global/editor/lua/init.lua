if SERVER then return nil end

luaeditor = luaeditor or {}

function luaeditor.Enable()
	local list_view = luaeditor._lv or panel.Create("editor_panel_classtree")
	luaeditor._lv = list_view
	luaeditor._lvp = true
	
	local vsize = GetViewportSize()
	
	local nsi = 600
	 
	list_view:Dock(DOCK_RIGHT)
	list_view:SetSize(nsi-2,vsize.y-2-15)
	list_view:SetPos(-vsize.x+nsi,-15)
	list_view:Show() 
end
function luaeditor.Disable()
	luaeditor._lv:Close() 
	luaeditor._lvp = false
end
function luaeditor.Toggle()
	if luaeditor._lvp then
		luaeditor.Disable()
	else
		luaeditor.Enable()
	end
end
 
console.AddCmd("ed_lua", luaeditor.Toggle)
---test
 