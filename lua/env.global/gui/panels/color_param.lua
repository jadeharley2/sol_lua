
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
	--text = "test",
	dock = DOCK_TOP,   
	OnClick = function(s) 
		s:SetSize(150,150)
		debug.Delayed(100,function()
			local c = s:GetChildren()
			c[1]:SetVisible(false)
			c[2]:SetVisible(true)
			chareditor.panel:UpdateLayout()
		end)
	end,
	subs = {
		{ 	name = "indicator",--indicator
			size = {20,20},
			dock = DOCK_RIGHT, 
			margin = {2,2,2,2},   
			color = {1,1,1}, 
		},
		{	name = "colorpicker",
			type = "colorpicker",
			dock = DOCK_FILL,
			visible=false, 
			OnPick = function(s,clr) 
				local ss = s:GetParent()
				local btp = ss.OnPick
				if btp then
					btp(ss,clr)
				end
				local c = ss:GetChildren()
				c[1]:SetColor(clr)
			end
		}
	}
}
PANEL.basetype = "button"
function PANEL:Init() 
	gui.FromTable(layout,self,{},self)
	self.colorpicker:AddButtons(function(s,clr)  
	end,function(s)
		s:SetVisible(false) 
		self:SetSize(20,20)
		local c = self:GetChildren()
		c[1]:SetVisible(true)
		self:GetTop():UpdateLayout()
	end)
end

function PANEL:SetValue(color)
	self.indicator:SetColor(color)
	self.colorpicker:SetValue(color)
end
function PANEL:GetValue() 
	return self.colorpicker:GetValue()
end
 