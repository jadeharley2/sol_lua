ENT.name = "Flat grass"


function ENT:CreateStaticLight( pos, color,power)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2) 
	lighttest:SetParent(self)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn() 
	if power then lighttest:SetBrightness(power) end
	lighttest:SetPos(pos)  
	return lighttest
end

function ENT:Init()

	self:SetSizepower(10000)
	self:SetSeed(9900001)
	self:SetGlobalName("u1_room") 

end
function ENT:Spawn()

	-- all worlds must have minimum 1 subspace 
	-- 
	local space = ents.Create()
	space:SetLoadMode(1)
	space:SetSeed(9900002)
	space:SetParent(self) 
	space:SetSizepower(1000)
	space:SetGlobalName("u1_room.space")
	space:Spawn()  
	local sspace = space:AddComponent(CTYPE_PHYSSPACE)  
	sspace:SetGravity(Vector(0,-4,0))
	space.space = sspace

	local map = SpawnSO("map/map_01.stmd",space,Vector(0,0,0),0.75) 
	--def:190000000
	--local light = self:CreateStaticLight(Vector(-1.3,1.2,-2.5)/2*10,Vector(140,161,178)/255,190000000)
	local light = self:CreateStaticLight(Vector(-1.3,1.2,-2.5)/2*10,Vector(200,200,200)/255,190000000 * 100)
	 
	light.light:SetShadow(true)
	self.space = space
	 
	
	-- apparel dispenser
	local dpos = Vector(0.007491949, 0.000883143, -0.006987628)
	local current_itemv = false
	local dfunc = function(button,user) 
		if CLIENT and user == LocalPlayer() then
			if current_itemv then
				current_itemv:Close()
				current_itemv=false
				SHOWINV = false
			else
				current_itemv = panel.Create("window_formviewer") 
				local givefunc = function(LP,itemname)
					--LP:Give(itemname) 
					if CLIENT and not network.IsConnected() then
						local app = SpawnIA(itemname,LP:GetParent(),LP:GetPos()) 
						if app then 
							app:SendEvent(EVENT_PICKUP,LP)
							LP.inventory:AddItem(LP, app)
						end
					else
						LP:SendEvent(EVENT_GIVE_ITEM,itemname)
					end
				end
				current_itemv:Setup("apparel",givefunc)
				current_itemv.OnClose = function()
					current_itemv=false
					SHOWINV = false
				end
				current_itemv:Show()
				SHOWINV = true
			end
		end
	end
	local app_b = SpawnButton(space,"primitives/box.stmd",dpos,nil,dfunc,32542389,0.8)
	app_b.usetype = "apparel spawner"
	------
	 
	-- tool dispenser
	local dpos = Vector(0.007491949, 0.000883143, -0.004687628)
	local current_wepv = false
	local dfunc = function(button,user) 
		if CLIENT and user == LocalPlayer() then
			if current_wepv then
				current_wepv:Close()
				current_wepv=false
				SHOWINV = false
			else
				current_wepv = panel.Create("window_formviewer") 
				local givefunc = function(LP,itemname)
					--LP:Give(itemname) 
					LP:SendEvent(EVENT_GIVE_ITEM,itemname)
					MsgN("Give ",LP," <= ",itemname)
				end
				current_wepv:Setup("tool",givefunc)
				current_wepv.OnClose = function()
					current_wepv=false
					SHOWINV = false
				end
				current_wepv:Show()
				SHOWINV = true
			end
		end
	end
	local wep_b = SpawnButton(space,"primitives/box.stmd",dpos,nil,dfunc,231632412,0.8)
	wep_b.usetype = "weapon spawner"
	------
	
	-- character changer
	local dpos = Vector(0.007491949, 0.000883143, -0.002687628)
	local current_charv = false
	local dfunc = function(button,user) 
		if CLIENT and user == LocalPlayer() then
			if current_charv then
				current_charv:Close()
				current_charv=false
				SHOWINV = false
			else
				current_charv = panel.Create("window_formviewer") 
				local givefunc = function(LP,itemname)
					LP:SendEvent(EVENT_CHANGE_CHARACTER,itemname) 
					current_charv:Close()
					current_charv=false
					SHOWINV = false
				end
				current_charv:Setup("character",givefunc)
				current_charv.OnClose = function()
					current_charv=false
					SHOWINV = false
				end
				current_charv:Show()
				SHOWINV = true
			end
		end
		button.velocity:ApplyAngVelocity(Vector(1,0,0),1)
	end
	local char_b = SpawnButton(space,"primitives/box.stmd",dpos,nil,dfunc,23521234,0.8)
	char_b.usetype = "character morpher"
	char_b.velocity = char_b:AddComponent(CTYPE_VELOCITY)
	char_b.velocity:SetAngularDamping(0.1)
	char_b:SetUpdating(true)

	------
	-- ability dispenser
	local dpos = Vector(0.007491949, 0.000883143, -0.000687628)
	local current_abv = false
	local dfunc = function(button,user) 
		if CLIENT and user == LocalPlayer() then
			if current_abv then
				current_abv:Close()
				current_abv=false
				SHOWINV = false
			else
				current_abv = panel.Create("window_formviewer") 
				local givefunc = function(LP,itemname) 
					LP:SendEvent(EVENT_GIVE_ABILITY,itemname)
					--MsgN("add ab: ",ab)
					--PrintTable(LP.abilities)
				end
				current_abv:Setup("ability",givefunc)
				current_abv.OnClose = function()
					current_abv=false
					SHOWINV = false
				end
				current_abv:Show()
				SHOWINV = true
			end
		end
	end
	local wep_b = SpawnButton(space,"primitives/box.stmd",dpos,nil,dfunc,4352342623,0.8)
	wep_b.usetype = "ability teacher"
	------
	
	local ambient = ents.Create("ambient_sound")
	ambient:SetParent(space)
	ambient:Spawn()
	self.ambient = ambient
	
	SpawnMirror(space,Vector(0.0005589276, 0.001217313, -0.01491671))

	--local terrain = map:AddComponent(CTYPE_CHUNKTERRAIN)  
	--	
	--terrain:SetRenderGroup(RENDERGROUP_LOCAL) 
	--terrain:SetBlendMode(BLEND_OPAQUE) 
	--terrain:SetRasterizerMode(RASTER_DETPHSOLID) 
	--terrain:SetDepthStencillMode(DEPTH_ENABLED)  
	--terrain:SetBrightness(1) 
	--self.terrain = terrain
	
	
	--local body = ents.Create("planet")  
	--body:RemoveComponents(CTYPE_ORBIT)
	--body.radius = 1000000
	--body:SetName( "omgplanet") 
	--body:SetSeed(seed or 0)
	--body.mass = 0.33E24  
	--body.radius = 10000  
	--body:SetParameter( VARTYPE_RADIUS,body.radius) 
	--body:SetParameter(NTYPE_TYPENAME,"planet")
	--body:SetParent(space)
	--body:SetSizepower(body.radius*1.1)
	--body:SetScale(Vector(1,1,1)*(1/body.radius/10))
	--body:Spawn() 
	--body:SetPos(Vector(0.006709641, 0.001117634, 0.005824335)) 
	--body:Enter() 
	--body.surface.surface:SetRenderGroup(RENDERGROUP_LOCAL)
	 
	
	
	
	
	
	
	if CLIENT then
		local eshadow = ents.Create("test_shadowmap2")  
		eshadow.light = light
		eshadow:SetParent(space) 
		eshadow:Spawn() 
		self.shadow = eshadow
		 
		 
		 
	--	local cbm =  space:AddComponent(CTYPE_CUBEMAP)
	--	cbm:SetSize(512)
	--	cbm:SetTarget() 
	--	self.cubemap = cbm
		
		 
		local root_skyb =  ents.Create()
		root_skyb:SetSizepower(2000)
		root_skyb:SetParent(space)
		root_skyb:SetPos(Vector(0,0.5,0))
		root_skyb:SetSpaceEnabled(false)
		root_skyb:Spawn()

		local cubemap = root_skyb:AddComponent(CTYPE_CUBEMAP)  
		self.cubemap = cubemap 
		cubemap:SetTarget(nil,space) 
		local cbm =cubemap
		
		--local cbm = SpawnCubemap(space,Vector(0,0.0013627,0),512)
		--self.cubemap = cbm
		
		space:AddNativeEventListener(EVENT_ENTER,"cubmapset",function() 
			--GlobalSetCubemap(cbm,true) 
			ambient:Start()
		end)
		space:AddNativeEventListener(EVENT_LEAVE,"dt",function()   
			ambient:Stop()
		end)
		--debug.Delayed(3000,function()
		--MsgN("RENDER!")
		cbm:RequestDraw()
		--end) 
	end
	
	--local aatest = ents.Create() 
	--aatest:SetSpaceEnabled(false) 
	--aatest:SetSizepower(1000) 
	if CLIENT then
	local nav = space:AddComponent(CTYPE_NAVIGATION)   
	nav:AddStaticMesh(map)
	self.nav = nav
	end
		
	--SpawnDC(space,Vector(0.001,0.1,0))
	
	
	
	
	--local othermap = SpawnSO("dyntest/th_sdm_building.dnmd",space,Vector(-0.1,0.007786129,0),0.5) 
	
	
	
	
	--[[
	local otherspace = ents.Create()
	otherspace:SetLoadMode(1)
	otherspace:SetSeed(9900013)
	otherspace:SetParent(self) 
	otherspace:SetPos(Vector(10,0,0))
	otherspace:SetSizepower(1000)
	otherspace:SetGlobalName("u1_room.space2")
	otherspace:Spawn()  
	local sspaceo = otherspace:AddComponent(CTYPE_PHYSSPACE)  
	sspaceo:SetGravity(Vector(0,-4,0))
	otherspace.space = sspaceo  

	 
	local othermap = SpawnSO("dyntest/th_sdm_foyer.dnmd",otherspace,Vector(0,0,0),1) 
	
	
	if CLIENT then 
		local cbm  = SpawnCubemap(otherspace,Vector(0,0.002,0),512)
		otherspace.cubemap = cbm
		--otherspace.cubemap:RequestDraw()
		
		otherspace:AddNativeEventListener(EVENT_ENTER,"cubmapset",function() 
			GlobalSetCubemap(cbm,true) 
			ambient:Stop()
		
		end)
		
	
	end 
	
	local lam_p = Vector(0.006782898, 0.004328228, 0.002894839)
	]]
	--local otherspace = ents.Create() 
	--otherspace:SetSeed(9901342)
	--otherspace:SetParent(space) 
	--otherspace:SetPos(Vector(0.3,0,0))
	--otherspace:SetSizepower(100) 
	--otherspace:SetSpaceEnabled(false)
	--otherspace:Spawn()  
	 
	local d1 = SpawnDT("door/door2.stmd",space,Vector(0.004689594, 1.789255E-06, -0.01484391),Vector(0,180,0),0.05)
	--local d2 = SpawnDT("door/door2.stmd",otherspace,Vector(4.656322E-10, 0, 0.007867295),Vector(0,0,0),0.1)
	d1:SetSeed(334001)
	d1:SetGlobalName("flatgrass.door")
	d1.target = {"forms/levels/sdm/interior_main.dnlv","foyer.flatgrass.door"}--d2
	--d2.target = d1
	
	
	--local dynamicmodel = ents.Create()
	--dynamicmodel:SetSeed(45312341)
	--local model = dynamicmodel:AddComponent(CTYPE_MODEL)  
	--dynamicmodel.model = model 
	--dynamicmodel:SetSpaceEnabled(false) 
	--dynamicmodel:SetSizepower(1)
	--
	--dynamicmodel:SetPos(Vector(0,0.008022659,0)) 
	--dynamicmodel:SetAng(Vector(-90,0,0))
	--dynamicmodel:SetParent(space)
	--
	--model:SetRenderGroup(RENDERGROUP_LOCAL) 
	--model:SetBlendMode(BLEND_OPAQUE) 
	--model:SetRasterizerMode(RASTER_DETPHSOLID) 
	--model:SetDepthStencillMode(DEPTH_ENABLED)  
	--model:SetBrightness(1)
	--model:SetFadeBounds(0,9e20,0)   
	--
	--model:SetModel("dyntest/maptest.dnmd")
	



	----local dynamicmodel = ents.Create()
	----dynamicmodel:SetSeed(45312341)
	----local model = dynamicmodel:AddComponent(CTYPE_MODEL)  
	----dynamicmodel.model = model 
	----dynamicmodel:SetSpaceEnabled(false) 
	----dynamicmodel:SetSizepower(1)
	----dynamicmodel:SetParent(space)
	----
	----model:SetRenderGroup(RENDERGROUP_LOCAL) 
	----model:SetBlendMode(BLEND_OPAQUE) 
	----model:SetRasterizerMode(RASTER_DETPHSOLID) 
	----model:SetDepthStencillMode(DEPTH_ENABLED)  
	----model:SetBrightness(1)
	----model:SetFadeBounds(0,9e20,0)   
	---- 
	----local procgen = dynamicmodel:AddComponent(CTYPE_PROCGEN) 
	----dynamicmodel.procgen = procgen
	----procgen:SetModel("models/dyntest/test_dynamic.dnmd")
	----
	----
	----dynamicmodel:Spawn()
	----dynamicmodel:SetPos(-0.02885208, 0.007299021, 0)
	
	
	
	
	
	
	--local light = self:CreateStaticLight(Vector(-1.3,1.2,-2.5)/2*10,Vector(200,200,200)/255,190000000 * 100)
	
	
	--local test13 = engine.Create("objects/yukari.gap")
	--test13:SetSizepower(1)
	--test13:SetParent(space)
	--test13:SetPos(Vector(0.05, 0.01, 0.002))
	--test13:SetAng(Vector(0,0,90))
	--test13:SetSeed(333333)
	--test13:Spawn()
	--testA = test13
	--
	--local test14 = engine.Create("objects/yukari.gap")
	--test14:SetSizepower(1)
	--test14:SetParent(space)
	--test14:SetPos(Vector(0.05, 0.01, 0.004))
	--test14:SetAng(Vector(0,0,90))
	--test14:SetSeed(333333)
	--test14:Spawn()
	--testB = test14
	--
	--test13:SetTarget(test14)
	--test13:Open()
	--test14:Open()
	 
	--self:CreateTestPM() 
	--hook.Add("aat","fst",function() 
	--	self:CreateTestPM()
	--end)


	-- BSP SPAWN TESTS
	if false then
		local test13 = ents.Create("bspmap")
		test13[VARTYPE_FORM] ="gm_flatgrass"-- "gm_construct"--"rp_evocity_dbg"--
		
		test13:SetSizepower(1000)
		test13:SetParent(space)
		test13:SetPos(Vector(0, 2, 0)) 
		test13:SetSeed(333333)
		test13:SetSpaceEnabled(false)
		test13:Spawn()
		testA = test13
	end
	-- END


	
	local pn = {}
	-- x, z, -y
	pn[1] = {p = Vector(-0.01907886, 0, 0.01137811),n ="eeew",s=true,c=1,d={b=true}}
	pn[2] = {p = Vector(-0.01907886,0,53.011*0.001)}
	pn[3] = {p = Vector(0,0,53.011)*0.001,n ="u?",s=true,c=1,d={b=true}}
	pn[4] = {p = Vector(0,100,53.011)*0.001,n ="unyu?",s=true,c=1}
	
	pn.links = {{1,2,3,4}}
	pn.currentid = 1
	
	self.lift = SpawnLift(space,325402,pn)--'forms/levels/train/carriage.dnmd')
 
end 
function ENT:CTO(user,ss)
	user:SetParent(ss)
	user:SetAbsPos(Vector(0,0.1,0))
	--if user.model then user.model:SetUpdateRate(10) end
	--ModNodeMaterials(user,{FullbrightMode=true},false,true)
	ModNodeMaterials(user,{
		FullbrightMode=true,
		outline=1,
		brightness=0.2
		--ssao_mul=0, 
		--LightwarpEnabled =1,
		--g_LightwarpTexture="textures/warp/lw_soft.dds"
	},false,true)--,g_LightwarpTexture="models/renamon/tex/lw.dds",LightwarpEnabled=1},false,true)
end 
function ENT:CFR(user,ss)
	user:SetParent(ss:GetParent())
	user:SetAbsPos(ss:GetAbsPos()+Vector(0,0.1,0))
	--if user.model then user.model:SetUpdateRate(60) end
	ModNodeMaterials(user,{
		ssao_mul=1, 
		FullbrightMode=false,
		outline=0,
		brightness=1
	
	},true,true)
end 
function ENT:GetSpawn() 
	local space = self.space
 
	
	local space2 = ents.Create()
	space2:SetLoadMode(1)
	space2:SetSeed(9900033)
	space2:SetPos(Vector(0.00748269, 0.0012758673, 0.003352003))
	space2:SetParent(space) 
	space2:SetSizepower(1000)
	space2:SetGlobalName("u1_room.space2")
	space2:SetScale(Vector(0.0005, 0.4, 0.4))
	space2:SetSpaceEnabled(false)
	space2:Spawn()  
	local sspace = space2:AddComponent(CTYPE_PHYSSPACE)  
	sspace:SetGravity(Vector(0,-2,0))
	space2.space = sspace
	self.space2 = space2
	
	local instr = SpawnSO("test/r_room.stmd",space2,Vector(0,0,0),0.75/4) 
	instr.model:SetMaterial("textures/gui/test.json")
	
	instr:AddEventListener(EVENT_USE,"use_event",function(s,user) 
		self:CFR(user,space2)
	end)
	instr:AddFlag(FLAG_USEABLE) 
	
	space2:AddEventListener(EVENT_USE,"use_event",function(s,user)
		self:CTO(user,space2)
	end)
	space2:AddFlag(FLAG_USEABLE) 




	local c = SpawnCONT("active/container.stmd",space,Vector(0,0.01,0.001)) 
	local cc = c:GetComponent(CTYPE_STORAGE)
	if cc then
		cc:PutItemAsData(1, ItemPV("forms/props/clutter/clut_lab_book.json",24879,{ 
			parameters = { name = "The Book",  },
		}))
		cc:PutItemAsData(2, ItemPV("forms/props/clutter/clut_lab_book.json",4352,{ 
			parameters = { name = "The Book",  },
		}))
		cc:PutItemAsData(3, ItemPV("forms/props/clutter/clut_lab_book.json",4452,{ 
			parameters = { name = "The Book",  },
		})) 
		cc:PutItemAsData(4, ItemPV("forms/props/clutter/clut_lab_book.json",2542,{ 
			parameters = { name = "The Book",  },
		}))
		cc:PutItemAsData(5,ItemPV("forms/props/furniture/futur/chair_a.json",346334,{
			parameters = {name = "Egg chair"},
			flags = {"storeable"},
		}))
		cc:PutItemAsData(6,ItemPV("forms/props/furniture/space/chair.json",349820,{
			parameters = {name = "O chair"},
			flags = {"storeable"},
		})) 
		cc:PutItemAsData(7,ItemIA("forms/apparel/uniform_0.json",3498224)) 
		cc:PutItemAsData(8,ItemIA("forms/apparel/cape_0.json",3498225)) 
		cc:PutItemAsData(9,ItemIA("forms/apparel/scarf_0.json",3498226)) 
		--cc:PutItemAsData(10,ItemIA("forms/apparel/socks_0.json",3498227)) 
		cc:PutItemAsData(11,ItemIA("forms/apparel/uniform_1.json",3498228)) 
		cc:PutItemAsData(12,ItemIA("forms/apparel/armw.json",3498229)) 
		cc:PutItemAsData(13,ItemIA("forms/apparel/legw.json",3498230)) 
		cc:PutItemAsData(14,ItemIA("forms/apparel/collar.json",3498231)) 
	end 
	
	--[[
	{
		"sizepower" : 1,
		"seed" : 1000002,
		"updatespace" : 0,
		"parameters" : 
		{
			"type" : 0,
			"typename" : "none",
			"seed" : 1000002,
			"abssize" : 1,
			"name" : null,
			"position" : [-0.0232629049569368, 0.00792624987661839, -0.00735787861049175, "vec3"],
			"rotation" : [0, 0, 0, 1, "quat"],
			"scale" : [1, 1, 1, "vec3"],
			"mass" : 0,
			"model" : "dyntest/test_road.dnmd",
			"modelscale" : 0.75,
			"gravity" : [0, 0, 0, "vec3"],
			"velocity" : [0, 0, 0, "vec3"],
			"angvelocity" : [0, 0, 0, "vec3"],
			"luaenttype" : "prop_variable",
			"character" : "forms/props/architecture/test_rails.json"
		},
		"flags" : ["editornode"]
	},
	]]
	--local chair = SpawnSPCH("shiptest/chair1.json",space,Vector(0,0,0.0002),0.75)  
	--chair:SetSeed(space:GetSeed()+38012)
	--chair.usetype = "sit"
	 
	local c = SpawnPlayerChar( Vector(0,0.0013627,0),self.space)

	return c, Vector(0,0,0)
end 
	
