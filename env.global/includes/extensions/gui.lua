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

function LockMouse()
	MOUSE_LOCKED = true 
end

function UnlockMouse()
	MOUSE_LOCKED = false 
end


function gui.ApplyParameters(node,t)
	for k,v in pairs(t) do
		if     k == 'size' then node:SetSize(v[1],v[2])  
		elseif k == 'pvsize' then 
			local vsize = GetViewportSize()  
			node:SetSize(v[1]*vsize.x,v[2]*vsize.y) 
		elseif k == 'pos' then node:SetPos(v[1],v[2])
		elseif k == 'dock' then node:Dock(v)
		elseif k == 'padding' then node:SetPadding(v[1],v[2],v[3],v[4])
		elseif k == 'margin' then node:SetMargin(v[1],v[2],v[3],v[4])
		elseif k == 'anchors' then node:SetAnchors(v)
		
		elseif k == 'color' then node:SetColor(Vector(v[1],v[2],v[3]))
			if v[4] then
				node:SetAlpha(v[4])
			end
		elseif k == 'visible' then node:SetVisible(v)
		elseif k == 'texture' then node:SetTexture(LoadTexture(v))
		
		elseif k == 'text' then node:SetText(v)
		elseif k == 'textonly' then node:SetTextOnly(v)
		elseif k == 'textcolor' then node:SetTextColor(Vector(v[1],v[2],v[3]))  
		elseif k == 'textalignment' then node:SetTextAlignment(v)
		
		elseif k == 'font' then node:SetFont(LoadFont(v))
		
		elseif k == 'states' then  
			for kk,vv in pairs(v) do 
				node:AddState(kk,vv)
			end 
		elseif k == 'state' then --skip
		else
			node[k] = v
		end
	end
	
	if t.state then 
		node:SetState(t.state) 
	end 
end

function gui.FromTable(t,node,style,namedtable,tablekey)
	node = node or panel.Create(t.type)
	
	if style and t.class then
		local v = style[t.class]
		if v then
			gui.ApplyParameters(node,v)
		end
		node.class = t.class
	end
	
	gui.ApplyParameters(node,t)
	
	local FromTable = node.FromTable
	if FromTable then FromTable(node,t) end
	
	
	if t.subs then
		for k,v in ipairs(t.subs) do 
			node:Add(gui.FromTable(v,nil,style,namedtable,tablekey)) 
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