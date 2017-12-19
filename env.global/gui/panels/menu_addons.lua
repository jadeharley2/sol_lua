PANEL.basetype = "menu_dialog"

function PANEL:Init()  
	 
	self.base.Init(self,"Addons",600)
 
	local addons_list = panel.Create("list")
	addons_list.hasback = true
	
	local laddons = addons.GetLoaded();
	local aaddons = addons.GetAll()
	local _lines = {}
	local _nes = {}
	function lineInit(p,v)
		local b_toggle = panel.Create("button") 
		local psize = p:GetSize()
		b_toggle:SetSize(psize.y,psize.y-2) 
		b_toggle:SetTextAlignment(ALIGN_CENTER)
		b_toggle:SetPos(psize.x-psize.y,0)
		--b_toggle:SetColor(Vector(10,50,10)/255*2)
		b_toggle.OnClick = function()
			v.enabled = not v.enabled
			if v.enabled then
				p:SetColorAuto(Vector(10,50,10)/255)
				addons.Enable(v.text)
				b_toggle:SetText("-") 
			else
				p:SetColorAuto(Vector(50,10,10)/255)
				addons.Disable(v.text)
				b_toggle:SetText("+")
			end
		end
		p:SetSize(psize.x,psize.y-2)
		p:Add(b_toggle) 
		if v.enabled then
			b_toggle:SetText("-")
			p:SetColorAuto(Vector(10,50,10)/255)
		else
			b_toggle:SetText("+")
			p:SetColorAuto(Vector(50,10,10)/255)
		end
	end
	for	k,v in pairs(laddons) do
		_lines[#_lines+1] = {text = v,init =lineInit,enabled = true}
		_nes[v] = true
	end
	for	k,v in pairs(aaddons) do
		if not _nes[v] then
			_lines[#_lines+1] = {text = v,init =lineInit,enabled = false}
		end
	end
	--PrintTable(_lines)
	addons_list.lineheight = 60
	addons_list.lines = _lines
	
	
	addons_list:SetSize(500-50,600-50)  
	addons_list:Refresh() 
	self:Add(addons_list)
	
	local addons_back = panel.Create("button")
	addons_back:SetText("Back")
	addons_back:SetSize(70,20)
	addons_back:SetPos(0,-600+25)
	self:SetupStyle(addons_back)
	addons_back.OnClick = function()
		console.Call("iosystem_restart") 
		hook.Call("menu","settings")
	end
	self:Add(addons_back) 
	 
	
end