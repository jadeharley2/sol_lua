if SERVER then return nil end

chareditor = chareditor or {}

function chareditor.Enable()
	chareditor.enabled = true
	chareditor.character = LocalPlayer()
	if chareditor.character then
		SetController("orbitingcamera")
		global_controller.center = Vector(0,0.001,0)
		global_controller.zoom = 1
		global_controller.mode = "restricted"
		GetCamera():SetParent(chareditor.character)
	end
	--local list_view = nodeeditor._lv or panel.Create("graph_editor")
	--nodeeditor._lv = list_view
	--list_view:Show()
end
function chareditor.Disable()
	chareditor.enabled = false
	GetCamera():Eject()
end
function chareditor.Toggle()
	if chareditor.enabled then
		chareditor.Disable()
	else
		chareditor.Enable()
	end
end 

console.AddCmd("ed_char", chareditor.Toggle)
---test

--render.SetRenderBounds(100,100,1000,1000)