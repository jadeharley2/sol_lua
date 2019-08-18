ENT.active_spawnpoints = ENT.active_spawnpoints or {}
local active_spawnpoints = ENT.active_spawnpoints

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
	if spwn then
		ply:SetParent(spwn:GetParent())
		ply:SetPos(spwn:GetPos())
	end
end)