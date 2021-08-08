if SERVER then return nil end

gui = gui or {}
--gui.style = gui.style 
gui.stylemeta = gui.stylemeta or {}

function gui.stylemeta:GetColor(name)
	local c = self.Color[name]
	if c then 
		return Vector(c[1],c[2],c[3])
	end
end
function gui.stylemeta:GetAlpha(name)
	local c = self.Color[name]
	if c then 
		return c[4]
	end
end
function gui.stylemeta:ApplyStyle(panel,name)
	local c = self.Color[name]
	if c then
		panel:SetColor(Vector(c[1],c[2],c[3]))
		panel:SetAlpha(c[4])
	end
end
gui.stylemeta.__index = gui.stylemeta 

function gui.SetStyle(name)
	local fname = "env.global/gui/styles/"..name..".lua"
	local ps = STYLE
	STYLE = {}
	include(fname)
	gui.style = setmetatable(STYLE,gui.stylemeta)
	STYLE = ps
end

function gui.ApplyStyle(node,styletable,stylekey)
	if styletable and styletable[stylekey] then
		gui.FromTable(styletable[stylekey],node)
	end
end


function LockMouse(lock_events)
	MOUSE_LOCKED = true 
	if lock_events then input.SetMouseBusy(true) end
end

function UnlockMouse()
	MOUSE_LOCKED = false 
	input.SetMouseBusy(false)
end
function MouseLocked()
	return MOUSE_LOCKED
end

function FSTR_Dock(v)
	if isnumber(v) then return v else
		if v=='bottom' then return 3 
		elseif v=='top' then return 2 
		elseif v=='fill' then return 4
		elseif v=='left' then return 1
		elseif v=='right' then return 0 
		end
		return -1
	end
end
function FSTR_Alignment(v)
	if isnumber(v) then return v else
		if v=='bottom' then return 3
		elseif v=='bottomleft' then return 7
		elseif v=='bottomright' then return 8
		elseif v=='top' then return 2
		elseif v=='topleft' then return 5
		elseif v=='topright' then return 6
		elseif v=='center' then return 4
		elseif v=='left' then return 0
		elseif v=='right' then return 1 
		end
	end
end

function gui.ApplyParameters(node,t,style,namedtable,tablekey)
	local delayed = {}
	for k,v in pairs(t) do
		if     k == 'size' then node:SetSize(v[1],v[2])  
		elseif k == 'pvsize' then 
			local vsize = GetViewportSize()  
			node:SetSize(v[1]*vsize.x,v[2]*vsize.y) 
		elseif k == 'pos' then node:SetPos(v[1],v[2])
		elseif k == 'origin' then node:SetOrigin(FSTR_Alignment(v))
		elseif k == 'rotation' then node:SetRotation(v)
		elseif k == 'dock' then node:Dock(FSTR_Dock(v))
		elseif k == 'padding' then node:SetPadding(v[1],v[2],v[3],v[4])
		elseif k == 'margin' then node:SetMargin(v[1],v[2],v[3],v[4])
		elseif k == 'anchors' then node:SetAnchors(v)
		elseif k == 'alpha' then node:SetAlpha(v)
		
		elseif k == 'color' then 
			if isjson(v) then
				if v[0] then
					node:SetColor(Vector(v[0],v[1],v[2]))
				elseif v[1] then
					node:SetColor(Vector(v[1],v[2],v[3]))
				end 
			elseif isuserdata(v) then
				node:SetColor(v)
			elseif isstring(v) then
				node:SetColor(v)--"#009432"
			else
				node:SetColor(Vector(v[1],v[2],v[3]))
				if v[4] then
					node:SetAlpha(v[4])
				end 
			end
		elseif k == 'gradient' then 
			local c1 = v[1]
			local c2 = v[2]
			local a = v[3] or 0
			node:SetColor(JVector(c1))
			node:SetColor2(JVector(c2))
			node:SetGradAngle(a)  
		elseif k == 'visible' then node:SetVisible(v)
		elseif k == 'texture' then node:SetTexture(v)--LoadTexture(v))

		elseif k == 'mouseenabled' then node:SetCanRaiseMouseEvents(v)
		elseif k == 'interactive' then node:SetInteractive(v)
		
		elseif k == 'clip' then node:SetClipEnabled(v)

		elseif k == 'text' then node:SetText(v)
		elseif k == 'textonly' then node:SetTextOnly(v)
		elseif k == 'textcut' then node:SetTextCutMode(v)
		elseif k == 'textcolor' then 
			if isstring(v) then
				node:SetTextColor(v)--"#009432"
			else
				node:SetTextColor(Vector(v[1],v[2],v[3])) 
			end 
		elseif k == 'textalignment' then node:SetTextAlignment(v)
		elseif k == 'multiline' then node:SetMultiline(v)
		elseif k == 'lineheight' or k == 'fontsize' then node:SetLineHeight(v)
		elseif k == 'linespacing' then node:SetLineSpacing(v)
		elseif k == 'autowrap' then node:SetAutowrap(v)
		
		elseif k == 'font' then node:SetFont(LoadFont(v))
		
		elseif k == 'autosize' then node:SetAutoSize(v[1],v[2])
		elseif k == 'value' and node.SetValue then node:SetValue(v)
		elseif k == 'align' then --skip
		elseif k == 'states' then  
			for kk,vv in pairs(v) do 
				node:AddState(kk,vv)
			end 
		elseif k == 'state' or  k == 'type' then --skip
		elseif string.starts( k,'_sub_') then
			local subkey = string.sub(k,6)
			local subnode = node[subkey]
			--MsgN(subkey,subnode)
			if subnode and isuserdata(subnode) then
				gui.ApplyParameters(subnode,v,style,namedtable,tablekey)
			end
			--[[
				sub example 
				_sub_title = {
					...
				}
			]]
		else 
			local customfunction = node['Set'..k]
			if customfunction and isfunction(customfunction) then
				customfunction(node,v)
			else 
				local info = node[k..'_info']
				if(info) then
					delayed[k] = {v,info}
				else
					node[k] = v
				end
			end
		end
	end
	--delays subpanel creation to post parameter init stage
	for k,vinf in pairs(delayed) do 
		local v = vinf[1]
		local info = vinf[2]
		if info.type == "children_array" then
			for k2,v2 in ipairs(v) do 
				if istable(v2) then
					info.add(node,gui.FromTable(v2,nil,style,namedtable,tablekey)) 
				elseif isuserdata(v2) then
					info.add(node,v2)
				end
			end 
		elseif info.type == "children_dict" then
			for k2,v2 in pairs(v) do 
				MsgN("CHD",k2,v2)
				if istable(v2) then
					info.add(node,k2,gui.FromTable(v2,nil,style,namedtable,tablekey)) 
				elseif isuserdata(v2) then
					info.add(node,k2,v2)
				end
			end 
		elseif info.type == "children_single" then 
			info.add(node,gui.FromTable(v,nil,style,namedtable,tablekey)) 
		end
	end
	
	if t.state then 
		node:SetState(t.state) 
	end 
end

function gui.FromTable(t,node,style,namedtable,tablekey)
	local ptype = t.type 
	if not ptype and style and t.class then
		for k,styleclass in pairs(string.split(t.class,' ')) do
			local pstyle = style[styleclass] 
			if pstyle and pstyle.type then
				ptype = pstyle.type 
			end 
		end
	end 
	node = node or panel.Create(ptype or "panel")
	ASSERT(node==nil,"Can't create panel of type "..tostring(ptype))

	if style and t.class then
		for k,styleclass in pairs(string.split(t.class,' ')) do
			local v = style[styleclass]
			--print(styleclass,v)
			if v then
				gui.ApplyParameters(node,v)
			end
		end
		node.class = t.class
	end


	
	gui.ApplyParameters(node,t,style,namedtable,tablekey)
	
--	local FromTable = node.FromTable  -- conflict with tree.FromTable
--	if FromTable then FromTable(node,t) end
	
	
	if t.subs then
		for k,v in ipairs(t.subs) do 
			if istable(v) then
				local x = gui.FromTable(v,nil,style,namedtable,tablekey)
				if x then
					node:Add(x) 
					if v.align then 
						if istable(v.align) then
							local alignment =FSTR_Alignment(v.align[1])
							
							local offsetx = v.align[2]
							local offsety = v.align[3] 
							x:AlignTo(node,alignment,alignment,offsetx,offsety)
						else
							local alignment =FSTR_Alignment(v.align) 
							x:AlignTo(node,alignment,alignment,0,0)
						end
					elseif v.pvpos then
						local ps = node:GetSize()
						
						if v.pvpos == 'center' then 
							local xs = x:GetSize()
							x:SetPos(math.floor((ps.x-xs.x)/2),math.floor((ps.y-xs.y)/2))
						elseif istable(v.pvpos) then
							if v.pvpos[3] == 'size' then
								local xs = x:GetSize()
								x:SetPos(math.floor(ps.x*v.pvpos[1]-xs.x/2),math.floor(ps.y*v.pvpos[2]-xs.y/2))
							else
								x:SetPos(math.floor(ps.x*v.pvpos[1]+(v.pvpos[3] or 0)),math.floor(ps.y*v.pvpos[2]+(v.pvpos[4] or 0)))
							end 
						end
					end 
				end
			elseif isuserdata(v) then
				node:Add(v)
			end
		end
	end
	
	if namedtable then
		if t.name then
			namedtable[t.name] = node
		end
		if tablekey then 
			node[tablekey] = namedtable
		end 
	end
	return node
end
 
function gui.Border(parent,style)
	local xsize = style.size or 16
	local color = style.color or "#009432"
	local texture_corner = style.corner or "textures/gui/menu/corner.png"
	local texture_hedge = style.hedge or "textures/gui/menu/edge.png"
	local texture_vedge = style.vedge or "textures/gui/menu/edge2.png"
	gui.FromTable({ 
		textonly = true,
		subs={
			{class="border",dock = DOCK_TOP, textonly = true,subs ={
					{class="border corner",dock=DOCK_LEFT},
					{class="border corner",dock=DOCK_RIGHT, rotation = -90},
					{class="border vedge",dock=DOCK_FILL}
			}},
			{class="border",dock = DOCK_BOTTOM, textonly = true,subs ={
					{class="border corner",dock=DOCK_LEFT, rotation = 90},
					{class="border corner",dock=DOCK_RIGHT, rotation = 180},
					{class="border vedge",dock=DOCK_FILL}
			}},
			{class="border hedge",dock=DOCK_LEFT},
			{class="border hedge",dock=DOCK_RIGHT},
		},
	},
	parent,
	{
		border = { 
			size = {xsize,xsize},
			color = color,
			mouseenabled = false, 
		},
		corner = {texture = texture_corner},
		hedge = {texture = texture_hedge},
		vedge = {texture = texture_vedge}
	}) 
end

local registry = debug.getregistry()
local PANEL = registry.Panel
function PANEL:MoveTo(target,time,easingfunc)
	local pos = pos or self:GetPos()
	time = time or 1
	easingfunc = easingfunc or easing.linear
	local t = 0
	local iters = time*50
	debug.DelayedTimer(0,20,iters, function()  
		t = t + 1
		if t==iters then
			self:SetPos(target) 
		else
			self:SetPos(LerpVector(pos,target,easingfunc(t/iters))) 
		end
	end)
end 
function PANEL:RotateTo(target,time,easingfunc)
	local ang = self:GetRotation()
	time = time or 1
	easingfunc = easingfunc or easing.linear
	local t = 0
	local iters = time*50
	debug.DelayedTimer(0,20,iters, function()  
		t = t + 1
		if t==iters then
			self:SetRotation(target) 
		else
			self:SetRotation(math.lerp(ang,target,easingfunc(t/iters))) 
		end
	end)
end 
function PANEL:AnimateColor(var,target,time,easingfunc)
	local getfunc = self['Get'..var]
	local setfunc = self['Set'..var]
	if getfunc and setfunc then
		time = time or 1
		easingfunc = easingfunc or easing.linear
		local startcolor = getfunc(self)
			
		local t = 0
		local iters = time*50
		debug.DelayedTimer(0,20,iters, function()  
			t = t + 1
			if t==iters then
				setfunc(self,target) 
			else
				setfunc(self,LerpVector(startcolor,target,easingfunc(t/iters))) 
			end
		end) 
	end
end

easing = {
	linear = function (x)
		return x
	end,
	bezier = function (t, x0, x1,x2,x3)
		return	x0 * (1 - t) ^3 +
		x1 * 3 * t * ((1 - t) ^ 2) +
		x2 * 3 * (t ^ 2) * (1 - t) +
		x3 * (t ^ 3)
	end,
	easein = function (x)
		return x*x
	end,
	easeout = function (x)
		return 1-(x-1)^2
	end, 
}
easing.ease = function (x)
	return easing.bezier(x,0,0,1,1)
end
easing.easeinoutback = function (x)
	return easing.bezier(x,0,-0.2,1.2,1)
end
easing.easeinout = easing.ease 

--function gui.FromLayout(root,layout,style)
--	local nodetable = {}
--	for k,v in pairs(layout) do
--		local n = gui.FromTable(v,nil,style)
--		v.node = n
--		if v.name then
--			nodetable[v.name] = n
--		end
--		root:Add(n)
--	end
--	return nodetable
--end
hook.Add("script.reload","panel", function(filename)
	if string.starts(filename,"env.global/gui/panels/") then 
		panel.LoadType(filename)
		return true
	end
end)

console.AddCmd("gui_closetop",function ()
	local top = panel.GetTopElement()
	if top then
		local ntop = top:GetParent()
		while ntop do
			top = ntop
			ntop = top:GetParent()
		end
		MsgN("closing:",top)
		top:Close()
	end
end)
console.AddCmd("gui_printtop", function()
	local top = panel.GetTopElement() 
	local i = 1
	while top do
		MsgN('\a[#cbacff]',"["..tostring(i).."]",'\a[clear]',top,'\a[#bcffac]',top.name)
		i = i + 1  
		top = top:GetParent()
	end  
end)



local sWVal = input.MouseWheel() 
hook.Add("input.mousewheel", "gui.scroll",function() 
	local mWVal = input.MouseWheel() 
	local delta = mWVal - sWVal
	sWVal = mWVal
	local toppanel = panel.GetTopElement()
	while toppanel do
		local OnMouseWheel = toppanel.OnMouseWheel
		if isfunction(OnMouseWheel) then
			OnMouseWheel(toppanel,delta)
			break
		end
		toppanel = toppanel:GetParent()
	end 
end)


function gui.EditText(text_panel,callback)
	 
	local tedit = gui.FromTable({
		type = "input_text",
		dock = DOCK_FILL,
		size = {100,16},
		Font2 = "fonts/d12.json",
		color = "#000020",
		textcolor = "#AFAFAF",
		text = text_panel:GetText(),
		OnKeyDown = function(s,key)
			if key == KEYS_ENTER then
				local txt = s:GetText()
				if CALL(callback,text_panel,txt) ~= false then
					text_panel:SetText(txt)
				end
				text_panel:Remove(s)
			elseif key == KEYS_ESCAPE then
				text_panel:Remove(s)
			end
		end,
		OnDeselect = function(s)
			local txt = s:GetText()
			if CALL(callback,text_panel,txt) ~= false then
				text_panel:SetText(txt)
			end
			text_panel:Remove(s)
		end
	})
	text_panel:Add(tedit)
	tedit:Select()
	text_panel:UpdateLayout()
end