TOOL.nextfiretime = 0.5
TOOL.holdtype = ""

function TOOL:OnSet(data) 
	self.state = "idle"
	self.damage = data.projectile.damage[1].amount
	MsgN("dam: ",self.damage)
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
			local aid = self.aid or 0
			aid = (aid + 1)%3
			self.aid = aid
			if user.model then
				user.model:SetAnimation("attack"..tostring(aid+1))
			end
			local world = user:GetParentWithComponent(CTYPE_PHYSSPACE)
			if world then
				local lw = world:GetLocalSpace(user) 
				local sz = world:GetSizepower()
				local forw = dir
				local lwp = user:GetPos()+Vector(0,1/sz,0) 
				local projectile = SpawnProjectile(world,lwp+forw*(1),forw*50000,0.1,Vector(1,1,1),false,"tools/projectiles/arrow.stmd")
				debug.Delayed(6000,function() if projectile and IsValidEnt(projectile) then projectile:Despawn() end end)
				--projectile:SetAng(user:GetAng())
				projectile.damage = self.damage
				projectile.OnHit = self.OnHit
			end
		end
	elseif state == "hold" then
	end
end
function TOOL:OnHit(target) 
	if target:HasFlag(FLAG_ACTOR) then
		target:Hurt(self.damage or 1)
	end
	return true
end

function TOOL:AltFire() 
end

function TOOL:Reload()

end

function TOOL:Equip(actor)
	local actor_model = actor.model
	if actor_model then
		self.model:SetCopyTransforms(actor_model)
		--self.model:SetMatrix(actor_model:GetMatrix())
		self:SetPos(actor.phys:GetFootOffset()*0.75*-0.001)
	end
	self:SetAng(Vector(-90,0,0))
end
function TOOL:Unequip(actor)
	local actor_model = actor.model 
	if actor_model then
		self.model:SetCopyTransforms()
	end 
end
