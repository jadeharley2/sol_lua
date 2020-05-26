 

effect.icon = "hex"
effect.type = "target"   
effect.name = "Swap"  

function effect:Begin(source,target)   
	--self:CastAnimation(source) 
	if source==target then return false end
	
	MsgN("swap",source,target)
	if IsValidEnt(target) and target.GetClass and target:GetClass()=="base_actor"  then 
		SpawnParticles(source,"explosion_void",Vector(0,0,0),1,0.05)
		SpawnParticles(target,"explosion_void",Vector(0,0,0),1,0.05)
		self:Swap(source,target)
		return true  
	end
	return false 
end
function effect:End(source,target) 
	SpawnParticles(source,"explosion_void",Vector(0,0,0),1,0.05)
	SpawnParticles(target,"explosion_void",Vector(0,0,0),1,0.05)
	self:Swap(source,target) 
end
   
function effect:Swap(caster,target)   
	if not caster or not target then return false end 
	local cai = caster.controller
	local tai = target.controller
	local ctm = caster.tmanager
	local ttm = target.tmanager
	
	caster.controller = tai
	target.controller = cai
	if tai then tai.ent = caster end
	if cai then cai.ent = target end
	
	caster.tmanager = ttm
	target.tmanager = ctm
	if ctm then ctm.ent = target end
	if ttm then ttm.ent = caster end
	
	if CLIENT then
		
		local player = LocalPlayer()
		if caster == player then
			SetLocalPlayer(target)
		elseif target == player then
			SetLocalPlayer(caster) 
		end
		SetController('actor') 
	end
end
