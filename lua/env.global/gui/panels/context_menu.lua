CONTEXTMENU_ALL = {}
 
function ContextMenu(parent,data,custompos,level,crtbtn)
	level = level or 0
	
	local b = false
	if data then
		b = panel.Create("context_menu")
		b:SetData(parent,data,crtbtn)
		local mpos = (custompos or input.getInterfaceMousePos()*GetViewportSize())+b:GetSize()*Point(0,-1)
		b:SetPos(mpos+Point(0,b:GetSize().y)) 
		b:Show()
		b.level = level
	end
	
	if level==0 then
		for k,v in pairs(CONTEXTMENU_ALL) do
			v:Close()
		end 
		CONTEXTMENU_ALL = {}
		LAST_CONTEXTMENU_CLOSE_TIME = CurTime()
		hook.Remove("input.mousedown","contextmenu.close")
		
		if data then
					
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
	end
	if data then CONTEXTMENU_ALL[#CONTEXTMENU_ALL+1] = b end
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
function PANEL:SetData(base,data,crtbtn)
	self.base = base
	self.data = data 
	local hperrow = 20
	local height = 0 --hperrow*#data
	local width = 200
	--self:SetSize(200,height)
	for k,v in pairs(data) do
		local b = panel.Create("button")
		b:SetSize(200,hperrow)
		b:SetText(v.text)
		self:Add(b)
		b:Dock(DOCK_TOP) 
		if crtbtn then crtbtn(b) end
		local sz = b:GetSize()
		height = height + sz.y
		width = sz.x
		
		--MsgN(v.text,"= ",v.action ) 
		if v.sub then
			b.OnClick = function(s)
				CONTEXTMENU_ISBUTTON_PRESSED = true 
				local sp = b:GetScreenPos()*2+b:GetSize()*Point(1,1)--*GetViewportSize()
				ContextMenu(base,v.sub,sp,self.level+1)
			end
			b:Add(gui.FromTable({ text = ">",textonly=true, mouseenabled=false,size = {hperrow,hperrow},dock = DOCK_RIGHT }))
		else
			if v.action then
				b.action = v.action
				b.OnClick = function(s) CONTEXTMENU_ISBUTTON_PRESSED = s.action(base,self,v) end
			end
		end
	end
	self:SetSize(width,height)
end
 