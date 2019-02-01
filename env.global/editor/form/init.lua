if SERVER then return nil end

formeditor = formeditor or {}

function formeditor.Enable()
	local list_view = formeditor._lv or panel.Create("editor_forms")
	formeditor._lv = list_view
	formeditor._lvp = true
	
	local vsize = GetViewportSize()
	
	local nsi = 1000
	 
	list_view:Dock(DOCK_RIGHT)
	list_view:SetSize(nsi-2,vsize.y-2-15)
	list_view:SetPos(-vsize.x+nsi,-15)
	list_view:Show() 
end
function formeditor.Disable()
	if formeditor._lv then
		formeditor._lv:Close() 
		formeditor._lv = nil
	end
	formeditor._lvp = false
end
function formeditor.Toggle()
	if formeditor._lvp then
		formeditor.Disable()
	else
		formeditor.Enable()
	end
end
 
console.AddCmd("ed_form", formeditor.Toggle)
---test
 