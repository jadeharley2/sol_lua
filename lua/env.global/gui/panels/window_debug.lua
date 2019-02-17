PANEL.basetype = "window"
 
function PANEL:Init()
	--PrintTable(self)
	self.base.Init(self)
	self:SetSize(200,300)
	self:SetColor(Vector(0.6,0.6,0.6))
	local inner = self.inner
	
	local structure = {
		{"Nodes","cmd_toggle","debug.shownodes"},
		{"Wireframe","cmd_toggle","debug.wireframe"},
		{"REC SET",function() r = Recorder(LocalPlayer()) end},
		{"REC START",function() r:Start() end},
		{"REC STOP",function() r:Stop() end},
		{"REC PLAY",function() r:Play() end},
		{"REC PLAYLOOP",function() r:PlayLooped() end},
	}
	self.clist = {self,inner,self.mv,self.bc}
	for k,v in pairs(structure) do
		local button = panel.Create("button")
		button:SetSize(30,30)
		button:Dock(DOCK_TOP)
		button:SetParent(inner)
		button:SetText(v[1])
		if isfunction(v[2]) then
			button.OnClick = v[2]
		else
			button.OnClick = function()
				local val = 0 -- get con var
				--set convar
				if val == 0 then
					MsgN("CON COMMAND "..v[3].." set ".."1")
				else 
					MsgN("CON COMMAND "..v[3].." set ".."0")
				end
				
			end
		end
	end
	
	local calpha = 0.2
	for k,v in pairs(self.clist) do
		v:SetAlpha(calpha)
	end  
	--self:OnResize() 
	self:UpdateLayout()
end
 
 