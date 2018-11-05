
 
local iconpool = 
{
	material = LoadTexture("textures/debug/icon_material.png"),
	shader = LoadTexture("textures/debug/icon_shader.png")
}

function PANEL:Init() 
	self:SetColor(Vector(0,0,0))
	self:SetSize(700,600) 
	
	
	local infopanel = panel.Create()
	infopanel:SetColor(Vector(0,0,0))
	infopanel:SetTextColor(Vector(1,1,1))
	infopanel:SetSize(600,300)
	infopanel:Dock(DOCK_BOTTOM)
	self:Add(infopanel)
	local infopanel_header = panel.Create()
	infopanel_header:SetColor(Vector(0.1,0.1,0.1))
	infopanel_header:SetTextColor(Vector(1,1,1))
	infopanel_header:SetText("Header")
	infopanel_header:SetSize(600,20) 
	infopanel_header:Dock(DOCK_TOP)
	infopanel:Add(infopanel_header)
	local infopanel_text = panel.Create()
	infopanel_text:SetColor(Vector(0,0,0))
	infopanel_text:SetTextColor(Vector(0.8,0.8,0.8))
	infopanel_text:SetSize(600,20) 
	infopanel_text:Dock(DOCK_FILL)
	infopanel:Add(infopanel_text)
	local grid =  panel.Create("listbox",{color={0,0,0}}) 
	grid:Dock(DOCK_FILL) 
	self:Add(grid)
	grid:SetRowHeight(128)
	grid:SetItemsPerRow(5)
	local makeitem = function(text,f,color)
		local p = panel.Create("button")
		p:SetSize(128,128)
		p:SetMargin(2,2,2,2)
		p:AddState("idle",{color={1,1,1}})
		p:AddState("hover",{color={0.8,0.9,0.3}})
		p:AddState("pressed",{color={1,1,1}})
		p:SetState("idle")
		local sub = panel.Create("button",{text = text,textOnly=true,size={16,16}})
		sub:Dock(DOCK_TOP)
		sub:SetCanRaiseMouseEvents(false)
		p:Add(sub) 
		
		local sup = panel.Create("button",{text = f,textOnly=true,size={12,12}})
		sup:Dock(DOCK_BOTTOM)
		sup:SetTextCutMode(true)
		sup:SetCanRaiseMouseEvents(false)
		p:Add(sup)
		
		if(text=="texture")then
			local t = LoadTexture(f)
			if t then
				p:SetTexture(t)
			end
		else
			local t = iconpool[text]
			if t then
				p:SetTexture(t)
			end
		end
		
		return p
	end
	for k,v in pairs(file.GetLoadedAssets()) do  
		grid:AddItem(makeitem(v[2],v[1],{0,1,0} ))
	end 
	--for k=1,99 do  
	--	grid:AddItem(makeitem(tostring(k),{0,1,0} ))
	--end 
	 
end 

if SERVER then return nil end

loadedassetlist = loadedassetlist or {}

function loadedassetlist.Enable()
	local list_view = panel.Create("debug_loaded_assets")
	loadedassetlist._lv = list_view
	loadedassetlist._lvp = true
	
	local vsize = GetViewportSize()
	
	local nsi = 128*5.25
	 
	list_view:Dock(DOCK_RIGHT)
	list_view:SetSize(nsi-2,vsize.y-2-15)
	list_view:SetPos(-vsize.x+nsi,-15)
	list_view:Show() 
end
function loadedassetlist.Disable()
	if loadedassetlist._lv then loadedassetlist._lv:Close() end
	loadedassetlist._lvp = false
end
function loadedassetlist.Toggle()
	if loadedassetlist._lvp then
		loadedassetlist.Disable()
	else
		loadedassetlist.Enable()
	end
end
 
console.AddCmd("io_loadedassetlist", loadedassetlist.Toggle)
---test
  