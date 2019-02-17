TOOL.nextfiretime = 0.01
TOOL.title = "Physgun"

function TOOL:OnSet()
	self.state = "idle"
	
end
function TOOL:PGPick(ent)
	local state = self.state
	if state == "idle" then
		local user = self:GetParent()
		if ent == user then return nil end
		--MsgN("pick: ",ent)
		self.targetEntity = ent
		local trp = ent:GetParent()
		local pos_user = trp:GetLocalCoordinates(user)
		local pos_target = trp:GetLocalCoordinates(ent) 
		self.offsetDir = pos_target-pos_user
		--self.targetDistance = (pos_target-pos_self):Distance()
		self.state = "hold"
		constraint.Break(ent,nil,"weld")
		ent.phys:SetGravity(Vector(0,-0.00001,0))
		ent.phys:SetLinearDamping(0.99)
		
	
		
		if not self.mlight then
			local mlight = ents.Create("omnilight") 
			local world = matrix.Scaling(2) 
			mlight:SetParent(self)
			mlight:SetSizepower(0.1)
			mlight.color = Vector(0.3,0.8,1)
			mlight:SetSpaceEnabled(false)
			mlight:Spawn() 
			mlight:SetBrightness(1)
			
			self.mlight = mlight
		end 
		if not self.flight then
			local flight = ents.Create("omnilight")  
			flight:SetParent(self)
			flight:SetSizepower(0.1)
			flight.color = Vector(0.3,0.8,1)
			flight:SetSpaceEnabled(false)
			flight:Spawn() 
			flight:SetBrightness(1)
			
			self.flight = flight
		end
		--if not self.glight then
		--	local glight = ents.Create("env_emitter")  
		--	glight:SetParent(self)
		--	glight:SetParameter(VARTYPE_CHARACTER,"fire")
		--	glight:SetSizepower(0.1) 
		--	glight:SetSpaceEnabled(false)
		--	glight:Spawn()  
		--	
		--	self.glight = glight
		--end
		
		self.mlight:SetPos(self.model:GetAttachmentPos("muzzle")) 
		self.mlight:TurnOn() 
		self.flight:TurnOn()
		if not self.snd then
			self.snd = self:EmitSoundLoop("energy/loop_01_mono.ogg",1,0.5)
		end
		
		hook.Add("main.update", "physgun.dropcheck", function() 
			
			local ent = self.targetEntity
			if ent then
				local p1 = self.model:GetAttachmentPos("muzzle")
				local forw = Vector(0,-1,0)
				local p2 = self:ToLocal(ent,Vector(0,0,0))
				self:CreateLaser(p1,p1+forw*2,p2+(p1-p2)*0.5,p2,20,0.1)
				
				self.flight:SetPos(p2) 
				--self.glight:SetPos(p2) 
				
				local trp = ent:GetParent()
				local user = self:GetParent()
				local sz = user:GetParent():GetSizepower()
				local pos_user = trp:GetLocalCoordinates(user)+Vector(0,1/sz,0)
				local pos_current = ent:GetPos()
				local self_dir = (self.dir  or Vector(1,0,0)):Normalized()
				local pos_target = pos_user+self_dir * self.offsetDir:Length()
				local vel = pos_target-pos_current
					--MsgN("mt: ",pos_target)
				--ent:SetPos(pos_target)
				ent.phys:ApplyImpulse(vel*10)
			else
				state = "idle"
			end
		
		
			if not input.leftMouseButton() then
				hook.Remove("main.update", "physgun.dropcheck")
				self:PGDrop()
			end
		end)
	end
end
function TOOL:PGDrop()
	local state = self.state
	if state == "hold" then
		local ent = self.targetEntity
		--MsgN("drop: ",self.targetEntity)
		ent.phys:SetGravity() 
		ent.phys:SetLinearDamping(0)
		self.targetEntity = false
		self.offsetDir = false
		self.state = "idle"
		self.mlight:TurnOff()
		self.flight:TurnOff()
		--self.glight:Despawn()
		--self.glight = nil
	end
	local snd = self.snd
	if snd then
		snd:Stop()
		self.snd = nil
	end
	
	local p1 = self.model:GetAttachmentPos("muzzle") 
	self:CreateLaser(p1,p1,p1,p1,10,0.01)
end
function TOOL:ToLocal(node,pos)
	local w = self:GetLocalSpace(node)
	return pos:TransformC(w) 
end
function TOOL:Fire(dir)
	self.dir = dir
	local state = self.state
	--MsgN("state: ",state)
	if state == "idle" then
		local nft = self.nextfiretime
		local ct = CurTime()
		local fd = self.firedelay
		if ct > nft then 
			self.nextfiretime = ct + fd
			
			local user = self:GetParent()
			local parentphysnode = user:GetParentWithComponent(CTYPE_PHYSSPACE)
			local lw = parentphysnode:GetLocalSpace(user) 
			local sz = parentphysnode:GetSizepower()
			local lwp = user:GetPos()+Vector(0,1.4/sz,0)
			
			local tr = self:Trace(lwp,dir)
			if tr and tr.Hit then 
				local p1 = self.model:GetAttachmentPos("muzzle")
				local p2 = self:ToLocal(parentphysnode,tr.Position)
				--self:CreateLaser(p1,p2,10,0.1)
				if tr.Entity and tr.Entity:HasFlag(FLAG_PHYSSIMULATED) then
					self:PGPick(tr.Entity)
				end
			end
		end
	elseif state == "hold" then
	end
end

function TOOL:AltFire()
	local state = self.state
	if state == "hold" then 
		local ent = self.targetEntity
		if ent then 
			constraint.Weld(ent,nil,ent:GetPos())
		end
	end
end

function TOOL:Reload()

end

