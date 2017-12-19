
TOOL.firedelay = 0.1

function TOOL:CreateLight(ship, pos, color, vel)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2)
	local phys = lighttest:AddComponent(CTYPE_PHYSOBJ) 
	phys:SetShape("engine/gsphere_2.SMD",world* matrix.Scaling(0.4))
	phys:SetMass(100) 
	lighttest:SetParent(ship)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn()
	
	lighttest.model:SetMatrix(world*matrix.Translation(-phys:GetMassCenter()))
	lighttest.phys = phys
	
	lighttest:SetPos(pos) 
	phys:ApplyImpulse(vel or Vector(0,4,40))
	return lighttest
end
function TOOL:Fire()
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
			if tr and tr.Hit then 
				self:HitEffect(parentphysnode,tr.Position+tr.Normal*(0.2/sz))
			end
			local ent = self:CreateLight(parentphysnode,lw:Position()+forw*(1.4/sz),
			Vector(math.random(0,255),math.random(0,255),math.random(0,255))/255*1,forw*50000*1)--*150)
			--ent.phys:SetGravity(Vector(0,-9,0))
 
			debug.Delayed(6000,function() ent:Despawn() end)
		end
		return true
	else
		return false
	end
end

function TOOL:AltFire()

end

function TOOL:Reload()

end

function TOOL:OnSet()
	
end

function TOOL:OnSelect()
	
end
