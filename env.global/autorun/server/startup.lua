if CLIENT then return nil end




-- spawn u
--[[
U = ents.Create()
U:SetSizepower(math.pow(2,88))
U:SetSeed(1000001)
U:SetGlobalName("u1")
U:Spawn()
network.AddNode(U)

space = ents.Create("spaceCluster") 
space:SetSeed(1000002)
space:SetParent(U) 
space:SetSizepower(math.pow(2,86))
space:SetGlobalName("u1.mc")
space:Spawn()
network.AddNode(space)


-- load place


local origin_loader = ents.Create()
origin_loader:SetGlobalName("origin")
origin_loader:SetParent(universe)
origin_loader:Spawn()

AddOrigin(origin_loader)
origin_loader:SetUpdateSpace(true)
OL = origin_loader
SendTo(origin_loader,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333;s2397131")--0.02,0,0")--
--SendTo(origin_loader,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333;s2008650333;0.803679,0.07456001,-0.4183209")--

origin_loader:SetPos(Vector(0,0,0))
--OL = ents.Create() OL:SetGlobalName("origin") OL:SetParent(U) OL:Spawn() 
--SendTo(OL,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333;s2008650333;0.8044567, 0.07306096, -0.4171545")--

local ship = origin_loader:GetParent()
local targetpos = Vector(0.003537618,0.01925059,0.2446546)
local targetpos2 = Vector(0.003008218, -0.07939442, -0.02011958)
local targetpos3 = Vector(0.4954455, -0.002244724, 0.02894697)

SPAWNORIGIN = ship
SPAWNPOS = targetpos

]]


U = ents.Create("world_testmap") 
network.AddNodeImmediate(U)
U:Create() 
SPAWNORIGIN,SPAWNPOS = U:GetSpawn()
AddOrigin(SPAWNORIGIN)
MsgN("loaded world at: ",SPAWNORIGIN)


-- player spawn
local pid=true
local function OnPlayerSetModel(ply)  
	local tagmodel = ply.player:GetTag(VARTYPE_MODEL)
	if tagmodel then
		ply:SetCharacter(tagmodel) 
	end
end

local function OnPlayerSpawn(ply)
	local name = ply.player:GetName()
	ply:SetName(name)
	ply.phys:SetGravity(Vector(0,-4,0))
	--ply:SetParent(U)
	--ply.player:LoadAddress(SPAWNORIGIN,ply)
	ply:SetParent(SPAWNORIGIN)
	ply:SetPos(SPAWNPOS)
	AddOrigin(ply)
	
	ply.player:AssignNode(ply)
	ply.player:SendCurrentState(ply)
	
	ply:SetParent(SPAWNORIGIN)
	ply:SetPos(SPAWNPOS)
	ply.Recall = function(e)
		e:SetParent(SPAWNORIGIN)
		e:SetPos(SPAWNPOS)
		e:SetHealth(e:GetMaxHealth())
		e:SetVehicle(nil) 
		MsgN("RECALL: ",e)
		e.phys:SetVelocity(Vector(0,0,0))
		--for k=1,5 do
		--	e.player:SendLua('TACTOR:SetPos(Vector('..tostring(SPAWNPOS.x)..','..tostring(SPAWNPOS.y)..','..tostring(SPAWNPOS.z)..')) TACTOR.phys:SetVelocity(Vector(0,0,0))')
		--end
		e:SendEvent(EVENT_RESPAWN_AT,SPAWNPOS)
	end
	
	ply:Give("tool_propspawner")
	debug.Delayed(1,function()  ply:Recall() end)
	--for k=1,20 do
	--	ply.player:SendLua('TACTOR:SetPos(Vector('..tostring(SPAWNPOS.x)..','..tostring(SPAWNPOS.y)..','..tostring(SPAWNPOS.z)..'))  TACTOR.phys:SetGravity(Vector(0,-4,0))')
	--end
	--AddOrigin(ply)
	
	--ply.player:SendLua(" local system = TACTOR:GetParentWith(NTYPE_STARSYSTEM) if system then  system:ReloadSkybox() end ")
end
local function OnClientConnect(ply)
	local name = ply:GetName()
	network.BroadcastMessage("Player "..name.." connected");
end
local function OnClientDisconnect(ply)
	local name = ply:GetName()
	network.BroadcastMessage("Player "..name.." disconnected");
end

hook.Add("player.prespawn","startup", OnPlayerSetModel)
hook.Add("player.firstspawn","startup", OnPlayerSpawn)

hook.Add("server.client.connected", OnClientConnect)
hook.Add("server.client.disconnected", OnClientDisconnect)
