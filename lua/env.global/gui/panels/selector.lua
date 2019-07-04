
local layout = {type="button", 
	size = {20,20},
	states = {
		idle    = {color = {0,0,0}},
		hover   = {color = {0.3,0.3,0.3}},
		pressed = {color = {1,1,1}},
	}, 
	stat = "idle",
	color = {0,0,0}, 
	textcolor = {1,1,1},
	text = "picked: default",
	dock = DOCK_TOP,   
	OnClick = function(s) 
		s:SetSize(150,150) 
		debug.Delayed(100,function()
			if s.variants then
				s.indicator:SetVisible(false) 
				s.container:SetVisible(true) 
				s:GetTop():UpdateLayout()
			end
		end)
	end,
	subs = { 
		{	name = "indicator", 
			dock = DOCK_RIGHT,
			color = {0,0,0}, 
			text = "value",
			textcolor = {1,1,1},
			size = {50,20},
			visible=true
		},
		{	name = "container", 
			dock = DOCK_FILL,
			color = {0,0,0}, 
			visible=false
		}
	}
}
PANEL.basetype = "button"
function PANEL:Init() 
	gui.FromTable(layout,self,{},self)
end
-- string=value pairs
function PANEL:SelectVariant(v)
	self.container:SetVisible(false)
	self.indicator:SetVisible(true) 
	self:SetSize(20,20)
	self:GetTop():UpdateLayout()
	self.selected = v
	self.indicator:SetText(key) 
	local val = self.variants[v]
	self:OnSelect(v,val)
end
function PANEL:SetVariants(table)
	self.variants = table
	self.container:Clear()
	for k,v in pairs(table) do
		self.container:Add(gui.FromTable({
			type = "button",
			text = k,
			tag = k,
			size = {20,20},
			dock = DOCK_TOP,
			OnClick = function(s)
				self:SelectVariant(s.tag)
			end
		}))
	end
end
function PANEL:SetValue(val) 
	local key = false
	for k,v in pairs(self.variants) do
		if v == val then
			key = k 
			break
		end
	end
	if key then
		self.selected = key
		self.indicator:SetText(key)
	end
end
function PANEL:GetValue()  
	return self.variants[self.selected]
end

function PANEL:OnSelect(key,val)  
end
 