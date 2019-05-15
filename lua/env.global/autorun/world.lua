
world = world or {}


function world.LoadWorld(id,mode,onComplete,onFail)
	if not id  then hook.Call("menu") return error("world id unspecified") end
	local cam = GetCamera()
	cam:SetUpdateSpace(true)
	UNIid = id
	
	
	MsgN("[WORLD] load sequence begun")
	 
	U = ents.Create("world_"..id)  
	U:Create() 

	local opttable = false
	if mode and isstring(mode) then
		--if U.options then
			opttable = U.options[mode]
		--elseif U.GetOption then
		--	opttable = U:GetOption(mode) 
		--end
	else
		opttable = mode
	end

	if opttable then
		--load location string or anchor
		local anchor = opttable.location
		if anchor then
			world.LoadLocation(anchor,function(e)
				world.LoadWorld_OnLoaded(e,opttable,U,onComplete)
			end,function()
				if onFail then onFail() end
			end)
		else
			world.LoadWorld_OnLoaded(cam,opttable,U,onComplete)
		end

	else
		if U.GetSpawn then
			SPAWNORIGIN,SPAWNPOS = U:GetSpawn()
			cam:SetParent(SPAWNORIGIN)
			cam:SetPos(SPAWNPOS)
			MsgN("[WORLD] load complete")
			if onComplete then onComplete(U,origin,pos) end
			hook.Call("engine.location.loaded", cam,"local")
		else
			if U.LoadSpawnpoint then
				hook.Add("world.loaded","spawner",function(origin, pos) 
					hook.Remove("world.loaded","spawner")
					SPAWNORIGIN = origin
					SPAWNPOS = pos
					cam:SetParent(origin)
					cam:SetPos(pos)
					MsgN("[WORLD] load complete")
					if onComplete then onComplete(U,origin,pos) end
					hook.Call("engine.location.loaded", cam,"local")
					
				end) 
				hook.Add("world.load.error","spawner",function() 
					hook.Remove("world.load.error","spawner") 
					UnloadWorld()
					if onFail then onFail() end
				end) 
				U:LoadSpawnpoint()
			end
		end 
	end

	
	 
	cam:SetGlobalName("player_cam")
	
	return U
end 

function world.LoadWorld_OnLoaded(e,opttable,U,onComplete)
	
	if opttable.position then
		e:SetPos(opttable.position) 
	else
		e:SetPos(Vector(0,0,0)) 
	end
	
	if opttable.controller then
		SetController(opttable.controller)
	end

	if opttable.onload then
		opttable.onload(U,e,opttable)
	end

	if onComplete then onComplete(U,e,Vector(0,0,0)) end
	hook.Call("engine.location.loaded", e, "local")
end

function world.UnloadWorld()
	if network.IsConnected() then
		network.Disconnect()
	end
	SetController()   
	local cam = GetCamera()
	cam:SetParent(LOBBY)
	
	if U then
		if istable(U) then
			for k,v in pairs(U) do v:Despawn() end
		else
			U:Despawn()
		end
		U = nil 
	end
	engine.ClearState()
	if chat then chat:Close() end
end 

function world.LoadSave(savedgamestate,onComplete,onFail)
	if not savedgamestate then hook.Call("menu") return error("save worldstate is empty") end
	local cam = GetCamera()
	cam:SetUpdateSpace(true)
	
	MsgN("[WORLD] load sequence begun")

	hook.Add("engine.location.loaded","spawner",function(origin) 
		hook.Remove("engine.location.loaded","spawner")
		if onComplete then onComplete() end
	end)
	hook.Add("engine.location.loadfailed","spawner",function(origin) 
		hook.Remove("engine.location.loadfailed","spawner")
		UnloadWorld()
		if onFail then onFail() end
	end)
	local result, roottable = engine.LoadState(savedgamestate) 
	if result then
		U = roottable
	else
		
	end
	cam:SetGlobalName("player_cam")

end

function world.LoadLocation(target,onComplete,onFail)
	if CLIENT then
		origin_loader = GetCamera()
	else
		origin_loader = ents.Create()
		origin_loader:SetSpaceEnabled(false)
	end

	AddOrigin(origin_loader)
	origin_loader:SetUpdateSpace(true)
	
	MsgN("[WORLD] SENDTO ",target)

	engine.SendTo(origin_loader,target, 
		onComplete,onFail)
end