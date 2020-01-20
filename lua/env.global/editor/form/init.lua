if SERVER then return nil end

formeditor = formeditor or {}

function formeditor.Enable()
	if formeditor.world then
		
	end
	--if not formeditor.world then
		formeditor.SpawnWorld()
	--end
	local list_view = formeditor._lv or panel.Create("panel_formeditor")
	formeditor._lv = list_view
	formeditor._lvp = true
	
	local vsize = GetViewportSize()
	
	local nsi = 400
	 
	list_view:Dock(DOCK_RIGHT)
	list_view:SetSize(nsi-2,vsize.y-2-15)
	list_view:SetPos(vsize.x-nsi,-15)
	list_view:Show() 
	
	SetController("orbitingcamera")
	global_controller.center = Vector(0,0,0)
	global_controller.zoom = 1
	global_controller.mode = "restricted"
	global_controller.zoom_div = 100
	global_controller.zoom_max = 100000
	global_controller.zoom_power = 2
	GetCamera():SetParent(formeditor.space)
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
 
function formeditor.SpawnWorld()
	local oldworld = formeditor.world
	local w = ents.Create("world_void")
	w:SetSeed(2425414)  
	w.subseed = 2425414442
	w:Spawn()
	formeditor.world = w
	formeditor.space = w.space

	formeditor.CreateStaticLight(Vector(1,1,1), Vector(1,1,1),400000)

 
		
	local skybox = w:AddComponent(CTYPE_SKYBOX) 
	skybox:SetRenderGroup(RENDERGROUP_STARSYSTEM) 
	skybox:SetTexture("textures/cubemap/bluespace.dds")
	formeditor.skybox = skybox

	local root_skyb =  ents.Create()
	root_skyb:SetSizepower(2000)
	root_skyb:SetParent(w.space)
	root_skyb:SetPos(Vector(0,100,0))
	root_skyb:Spawn()

	local cbm =  w.space:AddComponent(CTYPE_CUBEMAP)
	cbm:SetSize(512)
	cbm:SetTarget(nil,w.space) 
	cbm:RequestDraw()
	formeditor.cubemap = cbm 
 
	if oldworld then
		oldworld:Despawn()
	end
end
function formeditor.CreateStaticLight( pos, color,power)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2) 
	lighttest:SetParent(formeditor.space)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn() 
	if power then lighttest:SetBrightness(power) end
	lighttest:SetPos(pos)  
	return lighttest
end
console.AddCmd("ed_form", formeditor.Toggle)
---test
 