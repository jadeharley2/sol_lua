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

function gui.FromTable(t)
	local node = panel.Create()
	if t.size then node:SetSize(t.size[1],t.size[2]) end
	if t.pos then node:SetPos(t.pos[1],t.pos[2]) end
	--if t.angle then node:SetPos(t.pos[1],t.pos[2]) end
	if t.color then node:SetColor(Vector(t.color[1],t.color[2],t.color[3]))
		if t.color[4] then
			node:SetAlpha(t.color[4])
		end
	end
	if t.texture then 
		local tex = LoadTexture(t.texture) 
		node:SetTexture(tex) 
	end
	if t.text then node:SetText(t.text) end
	if t.subs then
		for k,v in ipairs(t.subs) do
			node:Add(gui.FromTable(v)) 
		end
	end
	return node
end