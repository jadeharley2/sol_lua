CONTEXTMENU_ALL = {}
 
function ContextMenu(parent,data,custompos,level)
	level = level or 0
	
	local b = panel.Create("context_menu")
	b:SetData(parent,data)
	local mpos = (custompos or input.getInterfaceMousePos()*GetViewportSize())+b:GetSize()*Point(1,-1)
	b:SetPos(mpos)
	b:Show()
	b.level = level
	
	if level==0 then
		for k,v in pairs(CONTEXTMENU_ALL) do
			v:Close()
		end 
		CONTEXTMENU_ALL = {}
		LAST_CONTEXTMENU_CLOSE_TIME = CurTime()
		hook.Remove("input.mousedown","contextmenu.close")
					
		hook.Add("input.mousedown","contextmenu.close",function()
			debug.Delayed(100,function()
				if not CONTEXTMENU_ISBUTTON_PRESSED then
					for k,v in pairs(CONTEXTMENU_ALL) do
						v:Close()
					end 
					CONTEXTMENU_ALL = {}
					LAST_CONTEXTMENU_CLOSE_TIME = CurTime()
					hook.Remove("input.mousedown","contextmenu.close")
				end
				CONTEXTMENU_ISBUTTON_PRESSED = false
			end)
		end)
	end
	CONTEXTMENU_ALL[#CONTEXTMENU_ALL+1] = b
	--MsgN(mpos)
end
  
function PANEL:Init()  
	
end
--[[data format:
	{
		{text="name", action=function(panel_from,context_menu) ... end },--button
		{--submenu
			text = "SUBTEST", 
			sub = {name = "test", acton= ...}
		}
	}
]]
function PANEL:SetData(base,data)
	self.base = base
	self.data = data
	local hperrow = 20
	local height = hperrow*#data
	self:SetSize(200,height)
	for k,v in pairs(data) do
		local b = panel.Create("button")
		b:SetSize(200,hperrow)
		b:SetText(v.text)
		self:Add(b)
		b:Dock(DOCK_TOP) 
		--MsgN(v.text,"= ",v.action ) 
		if v.sub then
			b.OnClick = function(s)
				CONTEXTMENU_ISBUTTON_PRESSED = true 
				local sp = b:GetScreenPos()*2+b:GetSize()*Point(1,1)--*GetViewportSize()
				ContextMenu(base,v.sub,sp,self.level+1)
			end
		else
			if v.action then
				b.action = v.action
				b.OnClick = function(s) CONTEXTMENU_ISBUTTON_PRESSED = s.action(base,self) end
			end
		end
	end
end
 