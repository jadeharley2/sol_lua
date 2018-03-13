ability.icon = "hex"
ability.type = "target" 
ability.cooldownDelay = 2  
ability.dispelDelay = 10
ability.name = "Swap"  

function ability:Begin(caster)  
	if not self.spelltarget then
		local tr = GetCameraPhysTrace() 
		if tr and tr.Hit then 
			local pr = tr.Node
			local sz = pr:GetSizepower() 
			local nearest,dist = GetNearestNode(tr.Node,tr.Position,FLAG_ACTOR)
			if nearest and dist*sz<1 and nearest ~= caster then
				self:CastAnimation(caster)
				self.spelltarget = nearest
				SpawnParticles(caster,"explosion_void",Vector(0,0,0),1,0.05)
				SpawnParticles(nearest,"explosion_void",Vector(0,0,0),1,0.05)
				self:Swap(caster,nearest)
				return true
			end
		end
	end
	return false
end
function ability:End(caster) 
	if self.spelltarget then
		SpawnParticles(caster,"explosion_void",Vector(0,0,0),1,0.05)
		SpawnParticles(self.spelltarget,"explosion_void",Vector(0,0,0),1,0.05)
		self:Swap(caster,self.spelltarget)
		self.spelltarget = nil
	end
end
   
function ability:Swap(caster,target)   
	if not caster or not target then return false end 
	local cai = caster.controller
	local tai = target.controller
	caster.controller = tai
	target.controller = cai
	if tai then tai.ent = caster end
	if cai then cai.ent = target end
	
	
	if CLIENT then
		
		local player = LocalPlayer()
		if caster == player then
			SetLocalPlayer(target)
			SetController('actorcontroller') 
		elseif target == player then
			SetLocalPlayer(caster)
			SetController('actorcontroller')
		end
	end
end
