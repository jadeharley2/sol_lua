--TODO:UPDATE
--if true then return end

ability.icon = "hex"
ability.type = "target" 
ability.cooldownDelay = 2  
ability.dispelDelay = 1
ability.name = "MindLink"  

function ability:Begin(source,target)  

	if not self.spelltarget then
		local tr = GetCameraPhysTrace() 
		if tr and tr.Hit then 
			local pr = tr.Node
			local sz = pr:GetSizepower() 
			local nearest,dist = GetNearestNode(tr.Node,tr.Position,TAG_ACTOR)
			MsgN("nearest: ",nearest,pr)
			--SpawnExplosion(pr,tr.Position)
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
			SetController('actor') 
		elseif target == player then
			SetLocalPlayer(caster)
			SetController('actor')
		end
	end
end
   
console.AddCmd('mindlink',function()
	local ply = LocalPlayer()
	local par = ply:GetParent()  
	local nearest = false
	local minimum = 99999
	for k,n in pairs(par:GetChildren()) do
		if n~=ply and n:GetClass()=='base_actor' then
			if minimum > ply:GetDistance(n) then
				nearest = n
			end
		end
	end
	if nearest then	
		hook.Add("input.keydown","mindlink",function(key)
			if not input.GetKeyboardBusy() then
				if key == KEYS_Z then
					ability.Swap(nil,nearest,ply)
				end
			end
		end)
	end 
end)