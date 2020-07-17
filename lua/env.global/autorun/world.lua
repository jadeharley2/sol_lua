
world = world or {}


function world.LoadWorld(id,mode,onComplete,onFail)
	if not id  then 
		if CLIENT then hook.Call("menu") end 
		return error("world id unspecified") 
	end
	xpcall(function()
		
		local c_origin = ents.Create()
		c_origin:SetSpaceEnabled(false)
		UNIid = id
		
		
		MsgN("[WORLD] load sequence begun")
		
		U = ents.Create("world_"..id)  
		if not U then
			return error("No such world: world_"..id) 
		else
			U:Create() 

			local opttable = false
			if mode and isstring(mode) and U.options then 
				opttable = U.options[mode] 
			else
				opttable = mode
			end

			if opttable then
				--load location string or anchor 
				local anchor =  opttable.anchor or opttable.location
				if anchor then
					world.LoadLocation(anchor,function(e)
						world.LoadWorld_OnLoaded(e,opttable,U,onComplete)
					end,function()
						if onFail then onFail() end
					end)
				else
					world.LoadWorld_OnLoaded(c_origin,opttable,U,onComplete)
				end

			else
				if U.GetSpawn then
					SPAWNORIGIN,SPAWNPOS = U:GetSpawn()
					c_origin:SetParent(SPAWNORIGIN)
					c_origin:SetPos(SPAWNPOS)
					MsgN("[WORLD] load complete")
					if onComplete then onComplete(U,c_origin,pos) end
					hook.Call("engine.location.loaded", origin,"local")
				else
					if U.LoadSpawnpoint then
						hook.Add("world.loaded","spawner",function(origin, pos) 
							hook.Remove("world.loaded","spawner")
							SPAWNORIGIN = origin
							SPAWNPOS = pos
							origin:SetParent(origin)
							origin:SetPos(pos)
							if CLIENT then
								local cam = GetCamera()
								cam:SetParent(origin)
								cam:SetPos(pos)
							end

							MsgN("[WORLD] load complete")
							if onComplete then onComplete(U,origin,pos) end
							hook.Call("engine.location.loaded", origin,"local")
							
						end) 
						hook.Add("world.load.error","spawner",function() 
							MsgN("[WORLD] load error")
							hook.Remove("world.load.error","spawner") 
							world.UnloadWorld()
							if onFail then onFail() end
						end) 
						U:LoadSpawnpoint()
					end
				end 
			end
		end

		
		if CLIENT then
			local cam = GetCamera()
			cam:SetUpdateSpace(true)
			cam:SetGlobalName("player_cam")
		end

		return U
	end,function(err) 
		MsgN("[WORLD] load error")
		MsgN(err)
		MsgN(debug.traceback())
		hook.Remove("world.load.error","spawner") 
		world.UnloadWorld()
		if onFail then onFail() end
	end)
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

function world.UnloadWorld(nodisconnect)
	if CLIENT then
		SetController()  
		local cam = GetCamera()
		cam:SetParent(LOBBY) 
	end 
	if CLIENT and network.IsConnected() and not nodisconnect then
		network.Disconnect()
	end

	if U then
		hook.Call("world.unload",U)
		if istable(U) then
			for k,v in pairs(U) do v:Despawn() end
		else
			U:Despawn()
		end
		U = nil 
	end
	engine.ClearState()
	if CLIENT and chat and not nodisconnect then chat:Close() end
	engine.SetGameState("menu")
end 

function world.LoadSave(savedgamestate,onComplete,onFail)
	if not savedgamestate then 
		if CLIENT then hook.Call("menu")  end
		return error("save worldstate is empty") 
	end
	local cam = false
	if CLIENT then
		cam = GetCamera()
		cam:SetUpdateSpace(true)
	end

	MsgN("[WORLD] load sequence begun")

	hook.AddOneshot("engine.location.loaded","spawner",function(origin)  
		if onComplete then onComplete(origin) end
	end)
	hook.AddOneshot("engine.location.loadfailed","spawner",function(origin) 
		MsgN("[WORLD] load error") 
		world.UnloadWorld()
		if onFail then onFail() end
	end)
	local result, roottable = engine.LoadState(savedgamestate) 
	if result then
		U = roottable
	else
		
	end
	if CLIENT then
		cam:SetGlobalName("player_cam")
	end
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

	if string.find(target,';') then --anchorname
		engine.SendTo(origin_loader,target, onComplete,onFail)
	else
		engine.SendToAnchor(origin_loader,target,onComplete,onFail)
	end
end

function world.GetList(filter)
	local files = file.GetFiles("lua/env.global/world/entities",".lua")
	local result = {}
	for k,v in pairs(files) do
		if string.match(v,'entities/world.*') then
			if not filter or string.match(v,filter) then
				result[#result+1]= string.sub(v,37,-5) 
			end
		end
	end 
	return result
end
function world.GetModes(world)
	local meta = ents.GetType("world_"..world)
	if meta then
		if meta.GetOptions then
			local opts = meta.GetOptions({})
			if opts then 
				local rez = {}
				for k,v in pairs(opts) do
					rez[#rez+1] = k
				end
				return rez
			end
		else
			local opts = meta.options
			if opts then 
				local rez = {}
				for k,v in pairs(opts) do
					rez[#rez+1] = k
				end
				return rez
			end
		end
	end 
end 

console.AddCmd("maps",function(filter)
	PrintTable( world.GetList(filter))
end)
console.AddCmd("modes",function(w)
	PrintTable( world.GetModes(w))
end)

hook.Add("engine.location.loaded","engine.hook",function() 
	engine.SetGameState("singleplayer")
end)

console.AddCmd("coc",function(w)
	--MsgN(w)
	engine.SendToAnchor(LocalPlayer() or GetCamera(),w)
end)