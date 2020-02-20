ENT.active_spawnpoints = ENT.active_spawnpoints or {}
local active_spawnpoints = ENT.active_spawnpoints

function CreateSpawnpoint(node,pos)
	e = ents.Create("spawnpoint")
	e:SetPos(pos)-- SpawnSO("primitives/sphere.stmd",self,pos,0.75)
	e:AddTag(77723)
	e:SetParent(node)
	e:Spawn()
	e:SetPlayerSpawn()
end

function ENT:Init()  
	self:SetSpaceEnabled(false)
end 

function ENT:Spawn()
end
function ENT:Despawn()  
	active_spawnpoints[self] = nil
end
function ENT:SetPlayerSpawn()
	active_spawnpoints[self] = true
end

function CreatePlayerspawn(ent,pos) 
	e = ents.Create("spawnpoint")
	e:SetPos(pos) 
	--e:AddTag(77723)
	e:SetParent(ent)
	e:Spawn()
	e:SetPlayerSpawn()
	return e
end

hook.Add("player.onspawn","spawnpoint",function(ply)
	local spwn = table.RandomKey(active_spawnpoints)
	MsgN("respawn",ply,"at",spwn)
	if spwn then
		ply:SetParent(spwn:GetParent())
		ply:SetPos(spwn:GetPos())
	end
end)