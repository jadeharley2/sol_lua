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
function ServerStartup(wmap,mode,callback)
	--U = ents.Create("world_testmap")--"world_solverse")--"world_flatcity")--"world_testmap") 
	--network.AddNodeImmediate(U)
	--U:Create() 
	--SPAWNORIGIN,SPAWNPOS = U:GetSpawn()
	world.UnloadWorld()
	world.LoadWorld(wmap,mode,function()
		AddOrigin(SPAWNORIGIN)
		MsgN("loaded world at: ",SPAWNORIGIN)
		if callback then callback(wmap,mode) end
	end,function()
		MsgN("error")
	end)


end


-- player spawn 
local function OnPlayerSetModel(ply)  
	local tagmodel = ply.player:GetTag(VARTYPE_MODEL)
	MsgN("ply",ply," => ",tagmodel)
	if tagmodel then
		ply:SetCharacter(tagmodel)  
	end
end

lfiles = {}
function AddCSLuaFile(filename)
	lfiles[#lfiles+1] = filename
	MsgN("AddCSLuaFile: ",filename)
end
function AddFile(filename)
	lfiles[#lfiles+1] = filename
	MsgN("AddFile: ",filename)
end
function AddDir(dir,recu)
	for k,v in pairs(file.GetFiles(dir,"",recu or false)) do
		AddFile(v)
	end
end

local function OnPlayerLoad(player)
	player:SendFiles(lfiles,true)  
end

local function OnPlayerSpawn(ply)
	local name = ply.player:GetName()
	ply:SetName(name)
	ply.phys:SetGravity(Vector(0,-4,0))
	--ply:SetParent(U)
	--ply.player:LoadAddress(SPAWNORIGIN,ply)
	ply:SetParent(SPAWNORIGIN)
	ply:SetPos(SPAWNPOS)
	hook.Call("player.onspawn",ply)

	AddOrigin(ply)
	
	ply.player:SendCurrentState(ply)
	ply.player:AssignNode(ply)
	network.AddNodeImmediate(ply)
	
	--ply:SetParent(SPAWNORIGIN)
	--if SPAWNPOS then ply:SetPos(SPAWNPOS) end
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
	

	--ply:Give("tool_propspawner")
	--debug.Delayed(1,function()  ply:Recall() end)
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

hook.Add("server.client.connected","startup", OnClientConnect)
hook.Add("server.client.disconnected","startup", OnClientDisconnect)

hook.Add("player.load","startup", OnPlayerLoad)


--AddCSLuaFile("lua/env.global/world/entities/world_flatcity.lua")  
--AddFile("models/map/flatcity.stmd")  
--AddDir("models/map/fc01/tex")   

for k,v in pairs(file.GetFiles("forms/characters")) do 
	AddCSLuaFile(v)  
end

local loadworld =  "testmap"
local loadmode = false
if not U then  
	ServerStartup(loadworld,loadmode) 
end

console.AddCmd("status",function()
	MsgN("world:",U)
	MsgN("spawn:",SPAWNORIGIN,"at",SPAWNPOS)
	MsgN("player count:",player.Count()) 
	for key, value in pairs(player.GetAll()) do
		if IsValidEnt(value) then
			MsgN(key,value)
		end
	end
end) 
console.AddCmd("restart",function()
	ServerStartup(loadworld,loadmode)
end) 
console.AddCmd("changelevel",function(world,mode)
	loadworld = world
	loadmode = mode or false
	ServerStartup(loadworld,loadmode,function()
		player.ReloadAll()
	end)
end)
console.AddCmd("save",function (save)
	engine.SaveState(save)
end)
console.AddCmd("load",function (save)
	
	world.UnloadWorld()
	world.LoadSave(save,function(origin)
		SPAWNORIGIN = origin:GetParent()
		SPAWNPOS = origin:GetPos()
		AddOrigin(SPAWNORIGIN)
		MsgN("loaded world at: ",SPAWNORIGIN)
		player.ReloadAll()
		if callback then callback(wmap,mode) end
	end,function()
		MsgN("error")
	end)

end)