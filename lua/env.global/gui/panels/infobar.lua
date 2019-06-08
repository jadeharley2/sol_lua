 local testtexture = LoadTexture("gui/blacktr.dds")
	
function PANEL:Init()
	--PrintTable(self) 
	 
	
	self:SetSize(300,30)
	self:SetColor(Vector(0.6,0.6,0.6))
	self:SetTextOnly(true)
	self:SetCanRaiseMouseEvents(false)
	
	local back = panel.Create()  
    back:SetTexture(testtexture) 
	back:SetPos(0,0)
	back:SetSize(299,25)
	back:SetColor(Vector(0,0,0)) 
	back:SetText("TEXT")
	back:SetTextColor(Vector(1,1,1))
	back:SetTextAlignment(ALIGN_CENTER)
	
	back:SetAlpha(0)
	
	local hp = panel.Create()  
	hp:SetColor(Vector(0.6,0.3,0.1))
	hp:SetSize(297,2)
	hp:SetPos(0,-20)
	hp:SetAlpha(0)
	
	self:Add(back)  
	self:Add(hp)
	
	self.fixedsize = true 
	self.back = back
	self.hp = hp
	self:UpdateLayout()
end
 
function PANEL:UpdateBar(ent)  
	if ent and IsValidEnt(ent) then
		local back = self.back
		local hp = self.hp
		back:SetAlpha(1)
		hp:SetAlpha(0)
		if ent.info then
			if isstring(ent.info) then
				back:SetTextColor(Vector(255,255,255)/255)
				back:SetText(ent.info) 
			else
				back:SetTextColor(ent.info.color/255)
				back:SetText(ent.info.text) 
			end
		elseif ent:HasFlag(FLAG_PLAYER) then
			back:SetTextColor(Vector(115,13,201)/255)
			back:SetText("player "..ent:GetName())
			
			local percentage = ent:GetHealthPercentage()
			hp:SetAlpha(1)
			hp:SetSize(297*percentage,2)
		elseif ent:HasFlag(FLAG_NPC) then
			back:SetTextColor(Vector(255,255,255)/255)
			if ent.usetype then
				back:SetText( ent:GetName()..": "..(ent.usetype or "unknown"))
			else
				back:SetText( ent:GetName())
			end
			local percentage = ent:GetHealthPercentage()
			hp:SetAlpha(1)
			hp:SetSize(297*percentage,2)
		elseif ent:HasFlag(FLAG_WEAPON) then
			back:SetTextColor(Vector(201,133,13)/255)
			back:SetText( "weapon "..ent:GetName())
		elseif ent:HasFlag(FLAG_USEABLE) then
			back:SetTextColor(Vector(13,201,115)/255)
			back:SetText( "use: "..(ent.usetype or "unknown"))
		
		else
			back:SetTextColor(Vector(255,255,255)/255)
			back:SetText("")
			back:SetAlpha(0)
		end
		--self.back:SetText(tostring(ent))
	else
		self.back:SetText("")
		self.back:SetAlpha(0)
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