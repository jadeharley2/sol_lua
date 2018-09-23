-- spawn lobby
if not LOBBY then
	LOBBY = ents.Create()
	LOBBY:SetSizepower(1000)
	LOBBY:SetSeed(1000003)
	LOBBY:SetName("lobby")
	LOBBY:SetGlobalName("lobby")
	local sspace = LOBBY:AddComponent(CTYPE_PHYSSPACE)  
	sspace:SetGravity(Vector(0,-0.0000001,0))
	LOBBY.space = sspace
	LOBBY:Spawn()
	--network.AddNode(LOBBY)

	 
	GLOBAL_SPAWN_node = LOBBY
	GLOBAL_SPAWN_pos = Vector(0,0,0)--Vector(0.003537618,0.01925059,0.2446546)
end

player = player or {}
	
player.player_list  = player.player_list or {}
local player_list  = player.player_list



if CLIENT then
	function player.GetAll()
		local pl = {}
		for k,v in pairs(player_list) do
			pl[#pl+1] = v 
		end
		return pl
	end
	function player.GetList() 
		return player_list
	end

	function Player(id)
		local v = player_list[id] 
		return v
	end


	local TACTOR = false
	function LocalPlayer()
		return TACTOR
	end
	function SetLocalPlayer(actor)
		TACTOR = actor 
		if not network.IsConnected() then
			player_list[1] = actor
		end
	end
	
	
	local function OnPlayerConnected(id,actor)  
		player_list[id] = actor
	end
	local function OnPlayerDisconnected(id)  
		player_list[id] = nil
	end
	local function OnPlayerList(actortbl)
		
		for k,v in pairs(player_list) do
			player_list[k] = nil
		end 
		if actortbl and actortbl ~= 0 then
			for k,v in pairs(actortbl) do  
				player_list[k] = v
			end
		end
	end
	hook.Add("umsg.player.connected", "playerspawn",OnPlayerConnected)
	hook.Add("umsg.player.disconnected", "playerspawn",OnPlayerDisconnected)
	hook.Add("umsg.player.sendlist", "playerspawn",OnPlayerList)
	hook.Add("network.disconnect","player", function() 
		MsgN("PADIS")
		for k,v in pairs(player_list) do
			player_list[k] = nil
		end  
	end)
end

if SERVER then
	function player.GetAll()
		local pl = {}
		for k,v in pairs(player_list) do
			pl[#pl+1] = v.actor
		end
		return pl
	end
	function player.GetAllClients()
		local pl = {}
		for k,v in pairs(player_list) do
			pl[#pl+1] = v.client
		end
		return pl
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
	local onClientConnected = function(client, id)  
		hook.Call("player.load", client)
	end
		
	local onClientFinishedLoad = function(client, id) 
		client:SendLua("console.Call('lua_reloadents')") 
		client:SendStartupNodes()
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
		client:SendLua("local p = ents.GetById("..tostring(120000+id)..") SetLocalPlayer(p) p:SetGlobalName('player') SetController('actor') p:SetPos(GLOBAL_SPAWN_pos)")
		 
		hook.Call("player.firstspawn", actor) 
		network.BroadcastCall("player.connected",id,actor)
		
		client:Call("player.sendlist",0)
		--local llist = {}
		for k,v in pairs(player_list) do
			client:Call("player.connected",k,v.actor)
			--llist[k] = v.actor
		end
		client:SendLua("SetController('actor')")
	end
	local onClientDisconnected = function(client, id)
		local v = player_list[id] 
		if v and v.actor then
			v.actor:Destroy()
		end
		player_list[id] = nil 
		network.BroadcastCall("player.disconnected",id)
	end

	hook.Add("server.client.connected", "playerspawn",onClientConnected)
	hook.Add("server.client.loadfinish", "playerspawn",onClientFinishedLoad)
	hook.Add("server.client.disconnected", "playerspawn",onClientDisconnected)

end