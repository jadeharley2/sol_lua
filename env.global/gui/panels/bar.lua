 
function PANEL:Init()  
	self:SetValue({
		{v=2,text="all"},
		{v=1, text = "none"},
		{v=0.25}
	})
end
function PANEL:SetValue(values) 
	if isnumber(values) then
		values = math.Clamp( values ,0,1)
		self.values = {{v = values},{v = 1-values}}
	elseif istable(values) then
		local total = 0
		self.values = values
		for k,v in pairs(values) do
			total = total+(v.v or 0)
		end
		self.total = total
	end
	self:UpdateValues()
end

function PANEL:UpdateValues()
	local lns = self.lns or {}
	local ss = self:GetSize()
	local total = self.total
	local values = self.values or {}
	for k,v in pairs(lns) do
		v:SetSize(0,0)
	end
	local totalxoff = 0 
	for k,v in pairs(values) do
		local lpanel = lns[k] or panel.Create() 
		local w = ss.x * (v.v/total)
		lpanel:SetPos(-ss.x+totalxoff+w,0)
		lpanel:SetSize(w-4,ss.y-4)
		lpanel:SetText(v.text or "")
		lpanel:SetTextAlignment(ALIGN_RIGHT)
		lpanel:SetColor(Vector(20*k,70,20)/256)
		lpanel:SetTextColor(Vector(1,1,1))
		
		self:Add(lpanel)
		lns[k] = lpanel
		totalxoff = totalxoff + w*2
	end
	self.lns = lns
end

