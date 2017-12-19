 
function PANEL:Init()
	--PrintTable(self) 
	self.lines = {}
	self.reverse = false
	self:SetColor(Vector(0,0,0))
	self:Refresh() 
end

function PANEL:Refresh() 
	local lns = self.lns or {}
	local ss = self:GetSize()
	local lineheight = self.lineheight or 50
	local linecount = math.floor(ss.y/(lineheight/2))
	local lines = self.lines
	local alpha = self.alpha or 1
	local textonly = not (self.hasback or false)
	for k,v in pairs(self.lns or {}) do
		v:SetText("")
		v:SetSize(0,0)
		v:SetAlpha(alpha)
	end 
	for k=1,linecount do
		local v = ""
		if self.reverse then
			 v = lines[#lines - k + 1] or ""
		else
			 v = lines[k] or ""
		end
		
		local location = 0
		if self.reverse then
			location =  (k-linecount/2-0.5)*lineheight--+ss.y/2-(linecount)*32/2 
			--lpanel:AlignTo(lpanel
		else
			location =  (-k+linecount/2+0.5)*lineheight
		end
		
		local pp = false
		if ispanel(v) then
			
			v:SetPos(0, location)
			v:SetAlpha(alpha)
			self:Add(v)
			
		else
		
			
			local lpanel = lns[k] or panel.Create("button") 
			lpanel:SetSize(ss.x-20,lineheight/2)
			lpanel:SetPos(0, location)
			lpanel:SetTextOnly(textonly)
			lpanel:SetAlpha(alpha)
			
			if pp then
				if self.reverse then
					lpanel:AlignTo(pp,ALIGN_TOPLEFT,ALIGN_BOTTOMLEFT)
				else
					lpanel:AlignTo(pp,ALIGN_BOTTOMLEFT,ALIGN_TOPLEFT)
				end
			end
			
			pp = lpanel
			
			
			if isstring(v) then
				lpanel:SetText(v)
				lpanel:SetColorAuto(Vector(20,20,20)/256)
				lpanel:SetTextColor(Vector(1,1,1))
			else
				lpanel:SetText(v.text)
				lpanel:SetColorAuto(v.color or Vector(20,20,20)/256)
				lpanel:SetTextColor(v.textcolor or Vector(1,1,1))
				if v.init then
					v.init(lpanel,v)
				end
				lpanel.tag = v
			end
		 
			lpanel.OnClick = function()
				if self.OnSelect then
					self:OnSelect(lpanel)
				end
			end
			self:Add(lpanel)
			lns[k] = lpanel
		end
	end
	self.lns = lns
end 
function PANEL:SetAlpha2(a) 
	self.alpha = a
	if self.lns then
		for k,v in pairs(self.lns) do
			v:SetAlpha(a)
		end
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