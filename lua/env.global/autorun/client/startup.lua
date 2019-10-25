if SERVER then return nil end

module.Require('render')

SAVEDGAME = false 
CONSOLE = CONSOLE or false
	-- lua_run  TACTOR:GetParentWith(NTYPE_STARSYSTEM):ReloadSkybox()
function LoadMenu() 
	local t_start = CurTime()
	gui.SetStyle("default")
	
	--
	local vsize = GetViewportSize()
	chat = panel.Create("window_chat") 
	chat:SetSize(500,200)
	
	chat:SetPos(-vsize.x,-vsize.y) --+csize.x +csize.y
	chat:SetTitle("Chat")
	hook.Add("input.keydown","chat",function(key)  
		if not input.GetKeyboardBusy() and chat:IsOpened() then
			if key == KEYS_T then 
				debug.Delayed(1,function()
					chat:Select() 
				end)
			end
		end
	end) 
	  
	--rdb = panel.Create("window_renderdebug") 
	--rdb:SetPos(0,vsize.y*0.8) 
	--rdb:SetTitle("Render")
	--rdb:Show()
	
	
	
	local wn = panel.Create("menu_main") 
	wn:SetPos(0,0)  
	wn:Show()
	
	local console = CONSOLE or panel.Create("panel_console")  
	local wsize = GetViewportSize()
	console:SetPos(0,100000)	
	console:SetSize(800,600)
	console:Dock(DOCK_TOP)
	console:UpdateLayout()  
	CONSOLE = console
	
	hook.Add("input.keydown","console",function(key)   
		if key == KEYS_OEMTILDE then 	 
			if not settings.GetBool("server.noconsole") then
				local console = CONSOLE   
				
				if console.enabled then
					console:Close()
					console.enabled = false 
				else  
					console:Show()
					console.enabled = true
					console:Select()
				end 
			end
		end
	end)
	hook.Add("settings.changed","consolecheck",function()
		local c = settings.GetBool("server.noconsole")
		local console = CONSOLE
		if console and c then
			console:SetVisible(false)
			console.enabled = false  
		end
		--self.console_enabled = not c
	end)
	
	
	if( settings.GetBool("editor",false)) then
		
		debugmenu = panel.Create("debug_panel_menu")   
		debugmenu:Show()
	end

	contextinfo = panel.Create('context_info')
	
	MsgN("Menu Load finished in:",CurTime()-t_start,"seconds. Total load time:",CurTime())
end

-- main menu shortcuts
function ConnectTo(ip)
	hook.Call("network.connect")
	return network.Connect(ip)
end

function CreateTestShadowMapRenderer(ent, pos)
	local e = ents.Create("test_shadowmap")  
	--e.target = ent.rt1
	e:SetParent(ent)
	if pos then e:SetPos(pos) end
	e:Spawn()
	return e
end
function SpawnPlayerChar(posoverride,nodeoverride)  
	local cam = GetCamera()
	local ship = nodeoverride or SPAWNORIGIN or cam:GetParent()
	local targetpos = posoverride or SPAWNPOS -- Vector(0.003537618,0.01925059,0.2446546)
	local targetpos2 = Vector(0.003008218, -0.07939442, -0.02011958)
	local targetpos3 = Vector(0.4954455, -0.002244724, 0.02894697)
	
	local playeractor = false
	
	if not SAVEDGAME then
		--local actorC = ents.Create("base_actor")
		--actorC:SetSizepower(1000)
		--actorC:SetParent(ship)
		--actorC:SetSeed(120002)
		--actorC:SetCharacter("enchantress")
		--actorC:Create() 
		--actorC:SetPos(targetpos+Vector(0.001,0,0.001)) 
		--
		--local actorD = ents.Create("base_actor")
		--actorD:SetSizepower(1000)
		--actorD:SetParent(ship)
		--actorD:SetSeed(120003)
		--actorD:SetCharacter("kindred_galactic")
		--actorD:Create() 
		--actorD:SetPos(targetpos+Vector(0,0,0.001)) 
		--actorD:SetAi("test")
		
		--local actorF = ents.Create("base_actor")
		--actorF:SetSizepower(1000)
		--actorF:SetParent(ship)
		--actorF:SetSeed(120003)
		--actorF:SetCharacter("ying")
		--actorF:Create() 
		--actorF:SetPos(targetpos+Vector(0,0,-0.001))
		--
		--local actorE = ents.Create("base_actor")
		--actorE:SetSizepower(1000)
		--actorE:SetParent(ship)
		--actorE:SetSeed(120003)
		--actorE:SetCharacter("tali")
		--actorE:Create() 
		--actorE:SetPos(targetpos+Vector(0,0,-0.002))
		
		----local actor = ents.Create("base_actor")
		----actor:SetSizepower(1000)
		----actor:SetParent(ship)
		----actor:SetSeed(120000)
		----actor:SetCharacter("nightwing")
		----actor:Create()  
		----actor:SetPos(targetpos+Vector(0.001,0,0))  
		
		local actor2 = ents.Create("base_actor")
		--actor2.firstspawn = true
		actor2:SetSizepower(1000)
		actor2:SetParent(ship)
		actor2:SetSeed(120001)
		actor2:SetCharacter(settings.GetString("player.model"))
		--actor2:SetModel(debug.LoadString("player.model"))-- "kindred/kindred.json")
		actor2:Create()
		--actor2.phys:SetGravity(Vector(0,-4,0)) 
		actor2:SetPos(targetpos)--targetpos3)--+Vector(0.001,0,0)) 
		actor2:SetSkin(settings.GetString("player.skinid"))
		--actorC:SetPos(targetpos+Vector(0.001,0,0.001)) 
		--actor:SetPos(targetpos+Vector(0.001,0,0)) 
		--actor2:SetPos(targetpos)
		--TM2 = actorD
		--TM2:AddTag(TAG_NPC)
		
		--actor2:Give("tool_magic")

		playeractor = actor2 
		playeractor:SetGlobalName('player') 
		local name = settings.GetString("player.name")
		playeractor:SetName(name)
		playeractor:AddTag(TAG_PLAYER)
	
		--local inventory = playeractor:AddComponent(CTYPE_STORAGE)  
		
		
		-- local pp = SpawnWeapon("testgun",ship,targetpos+Vector(-0.001,0.001,0))--0.006
		-- local pp2 = SpawnWeapon("lightgun",ship,targetpos+Vector(-0.002,0.001,0))--0.006
	
		--pp:SetParent(actor2)
		--actor2.model:Attach(pp,"weapon1")
	
	else
		playeractor = ents.GetByName('player') 
	end
	if playeractor then 
		SetLocalPlayer(playeractor)
		SetController('actor')  
		
		local system = playeractor:GetParentWith(NTYPE_STARSYSTEM)
		if system then 
			system:ReloadSkybox()
		end 
		
		--if UNIid == 0 then
			ship = playeractor:GetParent()
			--SHADOW = CreateTestShadowMapRenderer(ship,Vector(0.002456535,0.02487438,0.3199512))
		--end
		hook.Call("player.onspawn",playeractor)
	else
		MsgN("ERROR: PLAYER ACTOR NOT FOUND!")
	end
	return playeractor
end




-- startup function 
function OnStartup()
 
	local cam = GetCamera() or ents.CreateCamera()
	cam:SetSelfContained(true)
	cam:SetParent(LOBBY)
	cam:Spawn()

	AddOrigin(cam)
	SetCamera(cam) 
	
	
	render.SetGroupMode(RENDERGROUP_DEEPSPACE,RENDERMODE_BACKGROUND) 
	render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_BACKGROUND)  
	render.SetGroupBounds(RENDERGROUP_STARSYSTEM,1e8,0.5*UNIT_LY)
	render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_BACKGROUND) 
	render.SetGroupBounds(RENDERGROUP_PLANET,1e4,1000e8)
	render.SetGroupMode(RENDERGROUP_CURRENTPLANET,RENDERMODE_BACKGROUND) 
	render.SetGroupBounds(RENDERGROUP_CURRENTPLANET,10,1e8)
	render.SetGroupMode(RENDERGROUP_LOCAL,RENDERMODE_ENABLED) 
	render.ClearShadowMaps()
	
	
	cam:SetFOV(settings.GetNumber("engine.fov"))
	settings.Apply() 
	
	hook.Add("settings.changed","camera.fov_update",function() 
		cam:SetFOV(settings.GetNumber("engine.fov"))
	end) 
	
	LoadMenu()  
end
function OnLocationLoad(origin,gametype) 
	MsgN("Location loaded")
	if gametype ~= "local" then
		local system = origin:GetParentWith(NTYPE_STARSYSTEM)
		if system then 
			system:ReloadSkybox()
		end 
	end
end
local onSPLoadFail = function(u,err)
	debug.Delayed(1,function() 
		MsgN("WORLD LOAD FAILED",u,err)
		MAIN_MENU:SetWorldLoaded(false) 
		hook.Call("menu","main")  
	end)
end
function LoadSingleplayer(world_id,mode) 
	MsgN("LOAD SINGLEPLAYER WITH:",world_id,mode)

	local load_timer = debug.Timer(true)
	engine.PausePhysics() 
	
	--hook.Call("menu") 
	hook.Call("menu","loadscreen")
	
	debug.Delayed(1,function() 
		local U = world.LoadWorld(world_id,mode,function(u,origin,pos)  
			--GetCamera():SetUpdateSpace(false) 
			--if u then
			--	if u.OnPlayerSpawn then
			--		if u:OnPlayerSpawn() then --return true
			--			SpawnPlayerChar() 
			--		end
			--	else
			--		SpawnPlayerChar()   
			--	end
			--end
			
			load_timer:Stop()
			MsgN("[WORLD] loaded in: "..tostring(load_timer:ElapsedMs()).."ms")
			MsgN("")
			
			debug.Delayed(1,function() 
				MAIN_MENU:SetWorldLoaded(true) 
				debug.Delayed(1,function() 
					engine.ResumePhysics()  
					hook.Call("menu") 
				end)
			end) 
		end, onSPLoadFail)   
	end)
end

function LoadSingleplayerSave(savegame_id) 
 
	local load_timer = debug.Timer(true)
	engine.PausePhysics() 
	 
	hook.Call("menu","loadscreen")
	
	debug.Delayed(1,function() 
		local U = world.LoadSave(savegame_id,function(u,origin,pos)  
			GetCamera():SetUpdateSpace(false)
			
			load_timer:Stop()
			MsgN("[WORLD] loaded in: "..tostring(load_timer:ElapsedMs()).."ms")
			MsgN("")
			
			debug.Delayed(1,function() 
				MAIN_MENU:SetWorldLoaded(true) 
				debug.Delayed(1,function() 
					engine.ResumePhysics() 
					SetController("actor") 
					hook.Call("menu") 
				end)
			end) 
		end, onSPLoadFail)   
	end)
end

--hook.Add("main.startup","main",OnStartup)
hook.Add("main.startup","main",OnStartup)
hook.Add("engine.location.loaded","main",OnLocationLoad)





-- test functions
function SPA() 
	local cc = GetCamera()
	local fpos = cc:GetPos()
	local actor2 = ents.Create("base_actor")
	actor2:SetSizepower(1000)
	actor2:SetParent(cc:GetParent())
	actor2:SetSeed(120000)
	actor2:SetPos(fpos) 
	actor2:SetModel(settings.GetString("player.model"))
	actor2:Spawn()
	actor2.phys:SetGravity(Vector(0,-4,0))
	
	TACTOR = actor2
	TACTOR:SetGlobalName('player') 
	SetController('actor')  
end
function SPT(scale)
	local cc = GetCamera()
	local fpos = cc:GetPos()
	--SpawnSO("engine/unit_box.SMD",cc:GetParent(),fpos,scale or 0.01).model:SetMaterial("textures/debug/white.json") 
	SpawnSO("test/tree2/dtree.json",cc:GetParent(),fpos,scale or 0.01)
end

 
function fff_GoToPos(npc,pos)
	local sz = npc:GetParent():GetSizepower()
	local a1pos = npc:GetPos()*sz
	local a2pos = pos*sz
	local dir = (a2pos-a1pos):Normalized()
	local dist = a1pos:Distance(a2pos)
	npc.phys:SetStandingSpeed(1)
	if npc.targetpos then
		npc:LookAt((a2pos-a1pos):Rotate(Vector(0,90,0)))
		npc.phys:SetViewDirection(dir)
	end
	if(dist>4)then
		npc.targetpos = Vector(0,0,1)
	end
	if(dist<2)then
		npc.targetpos  = nil 
	end
end

