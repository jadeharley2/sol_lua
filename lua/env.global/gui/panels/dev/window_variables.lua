PANEL.basetype = "window"
local layout = {
	color = {0.6,0.6,0.6},
	subs = {
		{type = "list",name = "proplist",
			dock = DOCK_FILL,
			size = {400,400}
		} 
	}
}
function PANEL:Init()
	--PrintTable(self)
	self.base.Init(self)
	self.base.SetTitle(self,"View variables: ")
	self.mv:SetTextColor(Vector(0,0,0))
	gui.FromTable(layout,self.inner,{},self)
	 
end
function PANEL:Setup(target,title)
	self.target = target 
	title = title or tostring(target).." : "..tostring(target.__metaname)
	self.base.SetTitle(self,"View variables: "..tostring(title))	
	local pl = self.proplist
	pl:ClearItems()
	local t = {}
	if istable(target) then
		t = target
	end
	if isuserdata(target) and target.GetTable then
		t = target:GetTable() or {}
	end
	if(isuserdata(target) or istable(target)) then
		local value = getmetatable(target)
		if value then
			local ilayout = {
				size = {700,22},
				margin = {0,2,0,2},
				subs = {
					{
						size = {700/3,20},
						dock = DOCK_LEFT,
						text = tostring("__metatable__")
					},
					{
						size = {700/6,20},
						dock = DOCK_LEFT,
						text = type(value)
					},
					{type = "button",name = "viewnext",
						text = ">",
						size = {20,20},
						dock = DOCK_RIGHT,
						OnClick = function()
							ViewVariables(value)
						end
					},
					{  
						dock = DOCK_FILL,
						text = tostring(value),
						contextinfo = tostring(value),
					}
				}
			} 
			local c = 0
			for k,v in pairs(value) do
				c = c + 1
			end
			ilayout.subs[4].text = "len: "..tostring(c)
			local item = gui.FromTable(ilayout)
			pl:AddItem(item)
		end
	end
	for key, value in SortedPairs(t) do
		local ilayout = {
			size = {700,22},
			margin = {0,2,0,2},
			subs = {
				{
					size = {700/3,20},
					dock = DOCK_LEFT,
					text = tostring(key)
				},
				{
					size = {700/6,20},
					dock = DOCK_LEFT,
					text = type(value)
				},
				{

				},
				{  
					dock = DOCK_FILL,
					text = tostring(value),
					contextinfo = tostring(value),
				}
			}
		}
		local vt = type(value)
		if vt=="table" then
			ilayout.subs[3] = {type = "button",name = "viewnext",
				text = ">",
				size = {20,20},
				dock = DOCK_RIGHT,
				OnClick = function()
					ViewVariables(value)
				end
			}
			local c = 0
			for k,v in pairs(value) do
				c = c + 1
			end
			ilayout.subs[4].text = "len: "..tostring(c)
		elseif vt=="userdata" and getmetatable(value) and getmetatable(value).GetTable then
			ilayout.subs[3] = {type = "button",name = "viewnext",
				text = ">",
				size = {20,20},
				dock = DOCK_RIGHT,
				OnClick = function()
					ViewVariables(value)
				end
			}
			local c = 0
			for k,v in pairs(value:GetTable() or {}) do
				c = c + 1
			end
			ilayout.subs[4].text = "len: "..tostring(c)
		elseif vt=="function" then
		--	ilayout.subs[3] = {type = "button",name = "view",
		--		text = "V",
		--		size = {20,20},
		--		dock = DOCK_RIGHT,
		--		OnClick = function() 
		--			local info = debug.getinfo(value)
		--			if info then
		--				MsgN(info.func)
		--				MsgBox(info.func )
		--			end
		--		end
		--	}
		else
			ilayout.subs[3] = {type = "button",name = "edit",
				text = "E",
				size = {20,20},
				dock = DOCK_RIGHT,
				OnClick = function() 
				end
			}
		end
		local item = gui.FromTable(ilayout)
		pl:AddItem(item)
	end 
end  
function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end
function ViewVariables(target,title)
	local w = panel.Create("window_variables")
	w:SetSize(700,700)
	w:Setup(target,title)
	w:Show()
	return w
end
console.AddCmd("view_vars",function(target)
	if target == "s" then
		target = E_FS
	end
	if not target then
		target = LocalPlayer()
	end
	if target then
		ViewVariables(target)
	end
end)