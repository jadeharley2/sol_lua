PANEL.basetype = "menu_dialog"

function PANEL:Init()  
	 
	self.base.Init(self,"Addons",600)
 
	local addons_back = panel.Create("button")
	addons_back:SetText("Back")
	addons_back:SetSize(70,20)
	addons_back:SetPos(0,-600+25)
	self:SetupStyle(addons_back)
	addons_back.OnClick = function()
		console.Call("iosystem_restart") 
		hook.Call("menu","settings")
	end
	addons_back:Dock(DOCK_BOTTOM)
	self.sub:Add(addons_back) 

	local addons_list = panel.Create("list")
	addons_list.hasback = true
	addons_list:Dock(DOCK_FILL) 
	addons_list:SetSize(70,90)
	self.sub:Add(addons_list)
	self.addons_list = addons_list 
	
	self:PopulateList()
	
	self:UpdateLayout()
end
function PANEL:PopulateList()
	local addons_list = self.addons_list 
	addons_list:ClearItems()
	local laddons = addons.GetLoaded();
	local aaddons = addons.GetAll() 
	local _nes = {} 
	for	k,v in pairs(laddons) do
		--_lines[#_lines+1] = {text = v,init =lineInit,enabled = true}
		_nes[v] = true
	end
	for	k,addon in pairs(aaddons) do
		local p =  gui.FromTable({
			size = {20,20},
			dock = DOCK_TOP,
			text = addon,
			subs = {
				{ type = "checkbox",
					size = {20,20},
					dock = DOCK_RIGHT,
					Value = _nes[v],
					OnValueChanged = function(s,val)
						if val then
							addons.Enable(addon)
						else
							addons.Disable(addon)
						end
					end
				}
			}
		}) 
		addons_list:AddItem(p)
		MsgN('n3',p)
	end
end