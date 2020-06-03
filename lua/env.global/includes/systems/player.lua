-- spawn lobby
if not IsValidEnt(LOBBY) then
	LOBBY = ents.Create()
	LOBBY:SetSizepower(1000)
	LOBBY:SetSeed(1000003)
	LOBBY:SetName("lobby")
	LOBBY:SetGlobalName("lobby")
	local sspace = LOBBY:AddComponent(CTYPE_PHYSSPACE)  
	sspace:SetGravity(Vector(0,-0.0000001,0))
	LOBBY.space = sspace
	LOBBY:Spawn("2d9ec595-fa6c-426a-bf1a-511164d71066")
	--network.AddNode(LOBBY)

	 MsgN("KL",LOBBY) 
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

	player._TACTOR = player._TACTOR or false
	player._lastPlayerUid = player._lastPlayerUid or 0
	--local TACTOR = player._TACTOR 
	--local lastPlayerUid = player._lastPlayerUid 
	function LocalPlayer(returncheck)
		if  player._TACTOR and IsValidEnt( player._TACTOR) then
			player._lastPlayerUid =  player._TACTOR:GetSeed()
			return player._TACTOR
		else
			if returncheck and player._lastPlayerUid~=0 then
				local ply = Entity( player._lastPlayerUid)
				if ply and IsValidEnt(ply) then
					player._TACTOR = ply
					return player._TACTOR
				end
			end
			return nil
		end
	end
	function SetLocalPlayer(actor)
		if actor and IsValidEnt(actor) then
			player._TACTOR = actor 
			player._lastPlayerUid =  player._TACTOR:GetSeed()
			if not network.IsConnected() then
				player_list[1] = actor
			end
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
		local model = client:GetModel()
		local actor = ents.Create("base_actor") 
		actor[VARTYPE_CHARACTER] = model
		actor:AddTag(TAG_PLAYER)
		actor:SetSizepower(1000)
		actor:SetParent(GLOBAL_SPAWN_node) 
		actor:SetSeed(120000+id)
		--actor:SetPos(Vector(0,0,0))
		actor.player = client
		hook.Call("player.prespawn", actor)
		actor:Create()   
		
		
		player_list[id] = { 
			["client"] = client,
			["actor"] = actor
		}
		
		client:SendLua("global_player_await_id = "..tostring(120000+id).." SetController('actorwait')") 

		hook.Call("player.firstspawn", actor) 
		network.BroadcastCall("player.connected",id,actor)
		
		client:Call("player.sendlist",0)
		--local llist = {}
		for k,v in pairs(player_list) do
			client:Call("player.connected",k,v.actor)
			--llist[k] = v.actor
		end 
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

	function player.ReloadAll()
		for k,cli in pairs(player.GetAllClients()) do 
			cli:SendLua('world.UnloadWorld(true)')
			onClientFinishedLoad(cli,cli:Id())
		end 
	end
	console.AddCmd("reload_clients",function ()
		player.ReloadAll()
	end)
 
 
end

function player.Count()
	local c = 0
	for k,v in pairs(player.GetAll()) do
		if IsValidEnt(v) then
			c = c + 1
		end
	end
	return c
end
function player.GetByName(name) 
	for k,v in pairs(player.GetAll()) do
		if IsValidEnt(v) and string.match(v:GetName(),name) then
			return v
		end
	end
end
console.AddCmd("respawn_all",function ()
	for k,ply in pairs(player.GetAll()) do 
		if IsValidEnt(ply) then
			network.BroadcastCall("player.onspawn",ply)
			hook.Call("player.onspawn",ply)
		end
	end 
end)
if CLIENT then
	hook.Add("umsg.player.onspawn","-",function (ply)
		MsgN("AX",ply)
		hook.Call("player.onspawn",ply)
	end)
end
console.AddCmd("players",function ()
	for k,ply in pairs(player.GetAll()) do
		if IsValidEnt(ply) then
			MsgN(k,ply) 
		end 
	end 
end)
console.AddCmd("bring",function (who, to) 
	local a = player.GetByName(who)
	local b = player.GetByName(to)
	MsgN("bring",a,"to",b)
	if a and b then
		a:SetParent(b:GetParent())
		a:SetPos(b:GetPos())	
	end
end)
