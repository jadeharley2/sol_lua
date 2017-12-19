-- spawn lobby

LOBBY = ents.Create()
LOBBY:SetSizepower(1000)
LOBBY:SetSeed(1000003)
LOBBY:Spawn()
--network.AddNode(LOBBY)

 
GLOBAL_SPAWN_node = LOBBY
GLOBAL_SPAWN_pos = Vector(0,0,0)--Vector(0.003537618,0.01925059,0.2446546)
 
if SERVER then

	player = player or {}
	
	local player_list  = player_list or {}
 

	local onClientConnected = function(client, id)  
		local actor = ents.Create("base_actor")
	
		actor:AddFlag(FLAG_PLAYER)
		actor:SetSizepower(1000)
		actor:SetParent(GLOBAL_SPAWN_node)
		actor:SetSeed(120000+id)
		actor:SetPos(GLOBAL_SPAWN_pos)
		actor.player = client
		hook.Call("player.prespawn", actor)
		actor:Create()  
		network.AddNodeImmediate(actor)
		
		player_list[id] = { 
			["client"] = client,
			["actor"] = actor
		}
		--network.BroadcastLua("local l =  ents.GetById("..tostring(120000+id)..") if l then l:Load() end")
		client:SendLua("local p = ents.GetById("..tostring(120000+id)..") SetLocalPlayer(p) p:SetGlobalName('player') SetController('actorcontroller') p:SetPos(GLOBAL_SPAWN_pos)")
		 
		hook.Call("player.firstspawn", actor)
	end
	local onClientDisconnected = function(client, id)
		local v = player_list[id] 
		if v and v.actor then
			v.actor:Destroy()
		end
		player_list[id] = nil 
	end

	hook.Add("server.client.connected", "playerspawn",onClientConnected)
	hook.Add("server.client.disconnected", "playerspawn",onClientDisconnected)

	function player.GetAll()
		local pl = {}
		for k,v in pairs(player_list) do
			pl[k] = v.actor
		end
		return pl
	end
	function player.GetAllClients()
		local pl = {}
		for k,v in pairs(player_list) do
			pl[k] = v.client
		end
		return pl
	end
	function player.GetList() 
		return player_list
	end
	function Player(id)
		local v = player_list[id]
		if v then return v.actor end
		return nil
	end
	function Client(id)
		local v = player_list[id]
		if v then return v.client end
		return nil
	end
end
if CLIENT then
	local TACTOR = false
	function LocalPlayer()
		return TACTOR
	end
	function SetLocalPlayer(actor)
		TACTOR = actor 
	end
end