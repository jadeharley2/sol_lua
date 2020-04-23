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

	self.maxid = 1
	self.sid = 1
	self:UpdateLayout()
end
function PANEL:MouseWheel()
	local mWVal = input.MouseWheel() 
	local changed = false
	if self.mWVal then
		local delta = mWVal-self.mWVal
		if delta<0 then
			self.sid = math.min(self.sid + 1, self.maxid)
			changed = true
		elseif delta>0 then
			self.sid = math.max(self.sid - 1,1)
			changed = true
		end
	end
	self.mWVal = mWVal
	return changed
end
function PANEL:UpdateBar(ent)   
	if ent and IsValidEnt(ent) then
		local isUseP = input.KeyPressed(KEYS_E)
		local wchanged = self:MouseWheel() 

		if self.lastent ~= ent or self.isusep ~= isUseP or wchanged then

			self.lastent = ent
			self.isusep = isUseP 
			local back = self.back
			local hp = self.hp
			back:SetAlpha(1)
			hp:SetAlpha(0)
			local noinfo = false
			if ent.info then
				if isstring(ent.info) then
					back:SetTextColor(Vector(255,255,255)/255)
					back:SetText(ent.info) 
				else
					back:SetTextColor(ent.info.color/255)
					back:SetText(ent.info.text) 
				end

			elseif ent:HasTag(TAG_PLAYER) then
				back:SetTextColor(Vector(115,13,201)/255)
				back:SetText("player "..ent:GetName())
				
				local percentage = ent:GetHealthPercentage()
				hp:SetAlpha(1)
				hp:SetSize(297*percentage,2)
			elseif ent:HasTag(TAG_NPC) then
				back:SetTextColor(Vector(255,255,255)/255)
				if ent.usetype then
					back:SetText( ent:GetName()..": "..(ent.usetype or "unknown"))
				else
					back:SetText( ent:GetName())
				end
				local percentage = ent:GetHealthPercentage()
				hp:SetAlpha(1)
				hp:SetSize(297*percentage,2)
			elseif ent:HasTag(TAG_WEAPON) then
				back:SetTextColor(Vector(201,133,13)/255)
				back:SetText( "weapon "..ent:GetName())
			elseif ent:HasTag(TAG_USEABLE) then
				back:SetTextColor(Vector(13,201,115)/255)
				back:SetText( (ent.usetype or "unknown") )
			
			else
				back:SetTextColor(Vector(255,255,255)/255)
				back:SetText("")
				back:SetAlpha(0)
				noinfo = true
				
				if self.lnd then
					for k,v in pairs(self.lnd) do
						v:Close()
					end
					self.lnd = nil
				end
			end

			if not noinfo then
				if self.lnd then
					for k,v in pairs(self.lnd) do
						v:Close()
					end
					self.lnd = nil
				end
				local user = LocalPlayer()
				local dist = ent:GetDistance(user)
				if dist<(user.userange or 2) then

					local selected = self.sid 
					local options = GetInteractOptions(user,ent)--._interact--{test={text='test'},huh={text="huh?"}}--Interact(LocalPlayer(),ent)
					if options and istable(options) then
						local lnd = {}
						self.lnd = lnd
						local cn = 1
						for k,v in pairs(options) do cn= cn + 1 end
						for k,v in pairs(options) do
							local id =  #lnd + 1
							local line = panel.Create()
							line:SetSize(200,20)
							line:SetPos(0,self:GetPos().y + id*40-20-40*cn)
							line:SetCanRaiseMouseEvents(false)
							line:SetTexture(testtexture) 
							line:SetTextColor(Vector(255,255,255)/255) 
							line:SetText(' '..(v.text or k))
							if selected == id then 
								if isUseP then
									line:SetTextColor(Vector(0,0,0)) 
									line:SetTexture(nil) 
								end 
								line:SetText('>'..(v.text or k))
								LocalPlayer().intent = k
							end
							line:Show()
							lnd[id] = line
						end
						self.maxid = #lnd
					else
						self.maxid = 1
						--self.sid = 1
					end
				end
			else
				self.maxid = 1
				--self.sid = 1
			end 
		--self.back:SetText(tostring(ent))
		end
	else
		self.back:SetText("")
		self.back:SetAlpha(0)

		if self.lnd then
			for k,v in pairs(self.lnd) do
				v:Close()
			end
			self.lnd = nil
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

console.AddCmd("interact_options",function()
	local p = LocalPlayer()
	local t = p.viewEntity
	if IsValidEnt(t) then
		local opts = GetInteractOptions(p,t)
		PrintTable(opts)
	end
end)