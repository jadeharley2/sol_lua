
TOOL.firedelay = 0.1
TOOL.title = "Energy Gun"

function TOOL:HitEffect(ent, pos,magnpow) 
	local lighttest = ents.Create("env_explosion")
	local world = matrix.Scaling(2) 
	lighttest:SetParent(ent)
	lighttest:SetSizepower(0.1)
	lighttest.magnitude = 100*magnpow*magnpow
	--lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:SetPos(pos) 
	lighttest:Spawn() 
	--debug.Delayed(100,function() lighttest:Despawn() end)
	
end
function TOOL:CreateLight(ship, pos, color, vel,magn)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2)
	local phys = lighttest:AddComponent(CTYPE_PHYSOBJ) 
	phys:SetShape("engine/gsphere_2.SMD",world* matrix.Scaling(0.4))
	phys:SetMass(100) 
	phys:SetGravity(Vector(0,-2,0))
	phys:SetupCallbacks()
	
	lighttest:SetParent(ship)
	lighttest:SetSizepower(0.08)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	
	
	lighttest:AddNativeEventListener(EVENT_PHYSICS_CONTACT_CREATED,"event",function(selfobj,eid,collider) 
		local p = lighttest:GetParent()
		local cp = lighttest:GetPos()
		self:HitEffect(p,cp,magn)
		lighttest:Despawn() 
	end)
	
	lighttest:Spawn()
	
	lighttest.model:SetMatrix(world*matrix.Translation(-phys:GetMassCenter()))
	lighttest.phys = phys
	
	lighttest:SetPos(pos) 
	phys:ApplyImpulse(vel or Vector(0,4,40))
	return lighttest
end

function TOOL:Fire(dir)
	local nft = self.nextfiretime
	local ct = CurTime()
	local fd = self.firedelay
	if ct > nft then 
		self.nextfiretime = ct + fd
		local user = self:GetParent()
		local parentphysnode = user:GetParentWithComponent(CTYPE_PHYSSPACE)
		if parentphysnode then 
		MsgN("PPN: ",parentphysnode)
			local charge = self.charge or 0
			local lw = parentphysnode:GetLocalSpace(user) 
			local sz = parentphysnode:GetSizepower()
			local forw = dir--user:Right()--:TransformC(matrix.AxisRotation(lw:Right(),math.random(-30,30)))
			local lwp = user:GetPos()+Vector(0,1/sz,0)
			local ent = self:CreateLight(parentphysnode,lwp+forw*(1),
			self.fcolor,forw*50000*1,1+charge)--*150)
			--ent.phys:SetGravity(Vector(0,-9,0))
			self.fcolor = Vector(math.random(0,255),math.random(0,255),math.random(0,255))/255*1
			if self.mlight then
				self.mlight:Despawn()
				self.mlight = nil
				--self.mlight:TurnOff() 
			end
			self.charge = 0
			
			self:Lightning(Vector(0,0,0),Vector(0,0,0))
			hook.Remove("main.update", "testgun.effects")
			hook.Remove("main.update", "physgun.dropcheck")
			debug.Delayed(6000,function() ent:Despawn() end)
		else
			MsgN("NO PHYS SPACE FOUND")
		end
		return true
	else
		return false
	end
end

function TOOL:AltFire()


	local nft = self.nextfiretime
	local ct = CurTime()
	local fd = self.firedelay
	if ct > nft then 
		self.nextfiretime = ct + fd/4
		
		local charge = self.charge or 0
		
		charge = charge + 0.1
		
		local mlight = self.mlight
		if not mlight then
			mlight = ents.Create("omnilight")  
			mlight:SetParent(self)
			mlight:SetSizepower(0.1)
			mlight.color = self.fcolor
			mlight:SetSpaceEnabled(false)
			mlight:Spawn() 
			mlight:SetBrightness(1) 
			mlight:SetPos(self.model:GetAttachmentPos("muzzle"))
			self.mlight = mlight
		end 
		local chargesq = math.sqrt( charge)
		mlight:TurnOn() 
		mlight:SetBrightness(charge) 
		mlight:SetSizepower(chargesq/10) 
		--mlight:SetColor(self.fcolor)
		local mpos = self.model:GetAttachmentPos("muzzle")
		local rpos = mpos+Vector(0,-0.5*chargesq,0)
		mlight:SetPos(rpos)
		self.charge = charge
		hook.Add("main.update", "testgun.effects", function()  
			self:Lightning(mpos,rpos)
		end)
	end
end
function TOOL:Lightning(p1,p2)
	local a = Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1))/10
	local b = Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1))/10
	self:CreateLaser(p1,p1+a,p2+b,p2,10,0.1)
end

function TOOL:Reload()

end

function TOOL:OnSet()
	
	self.fcolor = Vector(math.random(0,255),math.random(0,255),math.random(0,255))/255*1
end

function TOOL:OnSelect()
	
end
