TOOL.firedelay = 0.3
TOOL.title = "Weld"
 
TOOL.tools = {
	weld={"weld",constraint.Weld}, 
	ballsocket={"ballsocket",constraint.Ballsocket}, 
	distance={"distance",constraint.DistanceLimit}
}


function TOOL:OnSet()
	self.state = "select1"
	self.currenttool = self.tools.weld
end

function TOOL:Fire(dir)
	local state = self.state
	MsgN("state: ",state)
 
	
	local nft = self.nextfiretime
	local ct = CurTime()
	local fd = self.firedelay
	if ct > nft then 
		self.nextfiretime = ct + fd
		
		local parentphysnode = cam:GetParentWithComponent(CTYPE_PHYSSPACE)
		if parentphysnode then  
			
			local lw = parentphysnode:GetLocalSpace(cam) 
			local sz = parentphysnode:GetSizepower()
			local forw = lw:Forward()--:TransformC(matrix.AxisRotation(lw:Right(),math.random(-30,30)))
			 
			local tr = GetCameraPhysTrace()
			--if tr and tr.Hit and tr.Entity and tr.Entity:HasFlag(FLAG_PHYSSIMULATED) then  
			--	local user = self:GetParent()
			--	if tr.Entity == user then return nil end
			--	if self.state == "select1" then
			--		self.Target1 = tr.Entity
			--		self.state = "select2"
			--	else
			--		self.Target2 = tr.Entity
			--		self.state = "select1"
			--		self:WeldProps(self.Target1,self.Target2)
			--	end
			--end
			if self.state == "select1" then
				if tr and tr.Hit and tr.Entity and tr.Entity:HasFlag(FLAG_ACTOR) then  
					local user = self:GetParent()
					if tr.Entity == user then return nil end
					if self.state == "select1" then
						self.Target1 = tr.Entity
						self.state = "select2" 
						hook.Call("chat.msg.received", self, "ent copied")
					end
				end
			else
				if tr and tr.Hit then  
			
					self.Target2 = tr.Entity
					self.state = "select1"
					self:Copy(self.Target1,tr.Node,tr.Position)
					hook.Call("chat.msg.received", self, "ent pasted")
				end
			end
		end
	end
	
end
function TOOL:AltFire(dir)
	local nft = self.nextfiretime
	local ct = CurTime()
	local fd = 0.5
	if ct > nft then 
		self.nextfiretime = ct + fd
		
		local parentphysnode = cam:GetParentWithComponent(CTYPE_PHYSSPACE)
		if parentphysnode then 
			
			local lw = parentphysnode:GetLocalSpace(cam) 
			local sz = parentphysnode:GetSizepower()
			local forw = lw:Forward()--:TransformC(matrix.AxisRotation(lw:Right(),math.random(-30,30)))
			 
			local tr = GetCameraPhysTrace()
			if tr and tr.Hit and tr.Entity and tr.Entity:HasFlag(FLAG_PHYSSIMULATED) then  
				local user = self:GetParent()
				if tr.Entity == user then return nil end
				if self.state == "select1" then
					self.Target1 = tr.Entity
					self.state = "select2"
				else
					self.Target2 = tr.Entity
					self.state = "select1"
					self:UnWeldProps(self.Target1,self.Target2)
				end
			end
		end
		
	end
end
function TOOL:OnF()
	self:OpenMenu(self:GetParent()) 
end

function TOOL:Copy(ent,parent,pos)
	local class = ent:GetClass()
	local ne = ents.Create(class)
	ne:SetParent(parent)
	ne:SetSizepower(1000)
	ne:SetSeed(252326+math.random(0,100000)) 
	local vars = {VARTYPE_NAME,VARTYPE_CHARACTER,VARTYPE_HEALTH,VARTYPE_MAXHEALTH}
	for k,v in pairs(vars) do
		local p = ent:GetParameter(v)
		if p then
			ne:SetParameter(v,p)
		end
	end
	local flags = {FLAG_NPC,FLAG_PLAYER,FLAG_ACTOR,FLAG_USEABLE,FLAG_STOREABLE}
	for k,v in pairs(flags) do 
		if ent:HasFlag(v) then
			ne:AddFlag(v)
		else
			ne:RemoveFlag(v)
		end
	end
	ne:SetCharacter(ent:GetParameter(VARTYPE_CHARACTER))
	ne:Create()
	ne:SetName(ent:GetName())
	ne:SetPos(pos) 
	
	local vars = {VARTYPE_NAME,VARTYPE_CHARACTER,VARTYPE_HEALTH,VARTYPE_MAXHEALTH}
	for k,v in pairs(vars) do
		local p = ent:GetParameter(v)
		if p then
			ne:SetParameter(v,p)
		end
	end
	local flags = {FLAG_NPC,FLAG_PLAYER,FLAG_ACTOR,FLAG_USEABLE,FLAG_STOREABLE}
	for k,v in pairs(flags) do 
		if ent:HasFlag(v) then
			ne:AddFlag(v)
		else
			ne:RemoveFlag(v)
		end
	end
	return ne
end
function TOOL:WeldProps(ent,ent2)
	if ent and ent2 then
		local ctool = self.currenttool 
		if ctool[1] == "distance" then
			local psz = ent:GetParent():GetSizepower()
			local p1 = ent:GetPos()
			local p2 = ent2:GetPos()
			ctool[2](ent,ent2,p1,p2,0,p1:Distance(p2)*psz)
		else
			local anchor = (ent:GetPos() + ent2:GetPos())/2
			ctool[2](ent,ent2,anchor)
		end
		--constraint.Weld(ent,ent2,anchor)
		hook.Call("chat.msg.received", self, "props "..ctool[1].."ed")
	end
	self.Target1 = nil
	self.Target2 = nil
end
function TOOL:UnWeldProps(ent,ent2)
	if ent and ent2 then 
		local ctool = self.currenttool 
		if constraint.Break(ent,ent2,ctool[1]) then
			hook.Call("chat.msg.received", self, "props un"..ctool[1].."ed")
		end
	end
	self.Target1 = nil
	self.Target2 = nil
end

function TOOL:OpenMenu(user)
	if not self.menuUser then
		self.menuUser = user 
			MsgN("self.menuUser ",self.menuUser)
		 
		local wn = self.wn
		wn = nil
		--if not wn then
			local totalh = 0
			local prev = false
			local prevc =0
			local btns = {}
			for k,v in pairs(self.tools) do
				 
				local btn = panel.Create("button") 
				btn:SetText(v[1])
				btn:SetSize(70,20) 
				btn:SetPos(prevc*140-300,25)  
				btn.OnClick = function()
					self.currenttool = v 
					local w = self.wn
					if w then
						w:SetVisible(false) 
						w:Close()
						self.menuUser = nil
					end
				end
				prevc = prevc + 1
				prev = btn
				totalh = totalh + 25
				btns[#btns+1] = btn 
			end
			wn = NewDialogPanel("Select tool",totalh+20)
			for k,v in pairs(btns) do
				wn:Add(v)
			end
			MsgN("sdaf ",wn)
			local ebtn = panel.Create("button") 
			ebtn:SetText("X")
			ebtn:SetSize(25,25) 
			ebtn:SetTextAlignment(ALIGN_CENTER)
			ebtn:AlignTo(wn,6,6)   
			ebtn.OnClick = function() 
				local w = self.wn
				if w then
					w:SetVisible(false) 
					w:Close()
					self.menuUser = nil
				end
			end
			wn:Add(ebtn)
			self.wn = wn
		--end
		wn:SetPos(0,0) 
		wn:SetVisible(true) 
		wn:Show()
		MsgN("ddd")
	end
	
end