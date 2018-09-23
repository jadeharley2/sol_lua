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
	end
	local char_b = SpawnButton(space,"primitives/box.stmd",dpos,nil,dfunc,23521234,0.8)
	char_b.usetype = "character morpher"
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
		 
		local cbm = SpawnCubemap(space,Vector(0,0.0013627,0),512)
		self.cubemap = cbm
		
		space:AddNativeEventListener(EVENT_ENTER,"cubmapset",function() 
			GlobalSetCubemap(cbm,true) 
			ambient:Start()
		end)
		space:AddNativeEventListener(EVENT_LEAVE,"dt",function()   
			ambient:Stop()
		end)
		self.cubemap:RequestDraw()
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
	d1.target = {"models/dyntest/sdm/interior_main.dnmd","foyer.flatgrass.door"}--d2
	--d2.target = d1
	
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
end
  
function ENT:CreateTestPM()
	if self.testme then
		self.testme:Despawn()
		self.testme = nil
	end
	if self.testmewf then
		self.testmewf:Despawn()
		self.testmewf = nil
	end
	
	module.Require("procedural")
	local b = procedural.Builder()
	b:BuildModel("@testmodel",json.ToJson(
	{    
		variables = {
			["$roof_height"] = 0.1
		},
		operations = { 
			 
			--[[--test rope
			{ type = "line",out = "test1",  
				points = {{-15,0,10},{-15,4,14},{-10,0,16},{-15,-5,16},{-15,-5,13}},
				loop = true
			},    
			{ type = "tesselate",["in"] = "test1",out = "test2", 
				interpolation = "cubic",
				times=5,
			},       
			{ type = "column",["in"] = "test2",out = "test3", 
				r = "@((sin($p/4)+15)*0.02)",
				sides = 10,   
			},
			]]       

			--buildings
			{ type = "surface",out = "building_base",  
				points = {{-15,0,-1.3}, {-15,8,-1.3},{-10,8,-1.3},{-10,0,-1.3}}
			},  
			
			{ type = "surface",out = "building_base",  
				points = {{-35,0,-1.3}, {-35,8,-1.3},{-30,8,-1.3},{-30,4,-1.3},
				{-25,4,-1.3}, {-25,8,-1.3},{-20,8,-1.3},{-20,0,-1.3}}
			},  
			{ type = "surface",out = "building_base",  
				points = {{-5,0,-1.3},{-7,4,-1.3}, {-5,8,-1.3},{0,8,-1.3},{2,4,-1.3},{0,0,-1.3}}
			},  
			
			--[[
			{ type = "ngon",out = "building_base", 
				pos = {40,20,0},
				r = 5,
				sides = 10,      
			}, 
			{ type = "ngon",out = "building_base", 
				pos = {20,20,0},
				r = 3,
				sides = 5,      
			}, 
			{ type = "ngon",out = "building_base", 
				pos = {10,20,0},
				r = 4,
				sides = 3,      
			}, 
			]]
			--{ type = "surface",out = "roof_base", 
			--	points = {{-10,0,0},{-10,10,0},{0,10,0},{0,0,0}}
			--},  
			
			--base
			
			{ type = "extrude",from = "building_base",out = "walls_a", outtop = "floor_base",
				mode = "normal",  
				shift = 0.2 ,   
			},  
			{ type = "extrude",["in"] = "floor_base",out = "walls_b", outtop = "ceil_base",
				mode = "normal",  
				shift = 2 ,   
			}, 
			{ type = "extrude",["in"] = "ceil_base",out = "walls_c", outtop = "roof_base",
				mode = "normal",  
				shift = 0.7 ,   
			}, 
			{ type = "split",["in"] = "walls_b",out = "wall_panels", 
				steps ="@(floor($l*0.7))",        
				stype="constant",      
			},     
			{ type = "flip",from = "ceil_base",out = "ceiling", },     
			{ type = "inset",from = "ceiling",out = {face = "c_inner",edge="c_outer"}, 
				amount = 0.1,   
			},  
			{ type = "extrude",from = "c_inner",out = "t333", 
				mode = "normal",   
				shift = -0.5,     
			},  
			--{ type = "inset",["in"] = "wall_panels",out = {face = "wp_inner",edge="wp_outer"}, 
			--	amount = 0.1,   
			--},     
			--{ type = "extrude",["in"] = "wp_inner",out = "t333", 
			--	mode = "normal",   
			--	shift = -0.1,     
			--},      
			
			
			--walls
			{ type = "split",["in"] = "wall_panels",out = "wall_subpanels", 
				steps =2,        
				stype="constant",      
			},     
			 
			{ type = "select", ["in"] = "wall_panels", out = "column_base",
				mode = "dotnormalsegments", normal = {0,0,1},
			},     
			{ type = "random",["in"] = "wall_subpanels", var = "i",
				variants = {
					{ 
						{ type = "extrude",["in"] = "i",out = "final", 
							mode = "normal",   
							shift = 0.05,     
						},  
						{ type = "flip",from = "i",out = "final", }, 
					}, 
					{
						{ type = "remove",["in"] = {"i"}}
					},
				}   
			}, 
			--{ type = "select", ["in"] = "wall_panels", out = "column_base",
			--	mode = "dotnormalsegments", normal = {1,0,0},
			--},       
			{ type = "column",["in"] = "column_base",out = "column_main",outcap = "ccap",
				angle = 45,  
				r =  0.15 ,
				sides = 8,       
			}, 
			{ type = "extrude",from = "ccap",out = "column_extend", 
				mode = "normal",   
				shift = 0.8,     
			},   
			
			{ type = "material",["in"] = {"column_main","column_extend"},
				material = "black.json"
			},   
			
			
			{ type = "remove",["in"] = {"wp_inner","wall_panels","walls_b"}  },
			
			---floor 
			
			{ type = "inset",from = "floor_base",out = {face = "floor_inner",edge="floor_outer"}, 
				amount = 0.5,   
			},  
			{ type = "extrude",from = "floor_inner",out = "t333", 
				mode = "normal",   
				shift = -0.1,     
			},   
			--{ type = "remove",["in"] = {"floor_base", "floor_inner"}  },
			    
			--pad floor
			
			{ type = "extrude",from = "walls_a",outtop = "floor_abase", out = "dump",
				mode = "normal",  
				shift = 0.2 ,    
				merge = true   
			},  
			{ type = "extrude",from = "floor_abase",out = "floor_around",
				mode = "normal",  
				shift = 0.8 ,   
				merge = true
			},  
			
			
			{ type = "material",["in"] = {"floor_around","t333"},
				material = "black.json"
			},   
			{ type = "material",["in"] = {"floor_base","dump"},
				material = "darkgray.json"
			},   
			--[[]]
			---roof
			
			
			--[[
			{ type = "ngon",out = "roof_base", 
				pos = {20,0,0},
				r = 3,
				sides = 5,      
			}, 
			{ type = "ngon",out = "roof_base", 
				pos = {10,0,0},
				r = 4,
				sides = 3,      
			}, 
			]]
			{ type = "inset",from = "roof_base",out = {face = "roof_f",edge="roof_f"}, 
				amount = 1, extrude =0.5,
			}, 
			{ type = "extrude",["in"] = "roof_f",out = "t3top", outtop = "roof",
				mode = "normal",  
				shift = 0.2 ,  
				merge = true,
			},   
			{ type = "extrude",from = "t3top",out = "t33", outtop = "t33",
				mode = "normal",  
				shift = 2  ,  
				merge = true,
			},   
			            
			
			--{ type = "inset",["in"] = "roof_base",out = {face = "roof_f",edge="roof_f"}, 
			--	amount = 1, extrude =1,
			--},
			--{ type = "extrude",["in"] = "roof_f",out = "t3", outtop = "roof",
			--	mode = "normal",  
			--	shift = 0.3  ,  
			--},   
			          
			   
			{ type = "select",["in"]="roof",out = "second_roof_base",
				mode = "dotnormal",
				normal = {0,0,-1}, 
				maxangle = 10,  
			}, 
			{ type = "select",["in"]="t33",out = "roof_bottom", remove = true, 
				mode = "dotnormal",
				normal = {0,0,1}, 
				maxangle = 30,  
			}, 
			   
			--{ type = "extrude",["in"] = "roof_bottom",out = "t3", 
			--	mode = "normal",  
			--	merge = true,
			--	shift = 0.1  ,    
			--},      
			{ type = "split",from = "roof_bottom",out = "re", 
				steps ="@($l*4)",--20,       
				stype="constant",     
			},      
			 
			--{ type = "inset",["in"] = "re",out = {face = "roof_f",edge="roof_f"}, 
			--	amount = 0.1, 
			--},  
			
			{ type = "inset",from = "second_roof_base",out = {face = "roof2_f",edge="roof2_c"}, 
				amount = 0.4, extrude =0.5, 
			},        
			{ type = "inset",from = "roof2_f",out = {face = "roof2_f",edge="roof2_c"}, 
				amount = 0.4, extrude =-0.2 , 
			},      
			
			{ type = "extrude",["in"] = "re",out = "roof_grate", 
				mode = "normal",   
				shift = "@($i % 2 * 0.1)",    
			},      
			     
			{ type = "select",["in"] = "t33", out = "testdef2", 
				mode = "points",--{{-16,9,3}},--,{1.5,20,-3}
			},  

			{ type = "select",["in"]="roof",out = "*", remove = true,
				mode = "dotnormal",
				normal = {0,0,-1}, 
				maxangle = 4,  
			}, 
			
			{ type = "split",from = "t33",out = "roof_tesselated", 
				steps =30,       
				stype="constant",     
			},    
			{ type = "split",from = "roof",out = "roof_tesselated", 
				steps =30,       
				stype="constant",     
			},     
			--{ type = "tesselate", from = "t33", out = "roof_tesselated", 
			--	interpolation = "linear",
			--	times = 2,
			--},  
			--{ type = "tesselate", from = "roof", out = "roof_tesselated", 
			--	interpolation = "linear",
			--	times = 2,
			--},  
			{ type =  "pointdeform", ["in"] = {"roof_tesselated","roof_grate"},inpoints = "testdef2",
				r = 1,pow = 0.05,dir = {0,0,1},
				func = "sin",
			},        
			
			{ type = "material",["in"] = {"roof_grate","roof2_c"},
				material = "black.json"
			},   
			{ type = "material",["in"] = {"roof_tesselated","roof2_f"},
				material = "teal.json"
			}, 
			 
			 
			{ type = "remove",["in"] = {"roof_f"}  },
			 
			 
			 
			 
			 
			 
			 
			--test ark
			
			{ type = "point", out = "gate_base", 
				points = {{-1.5,20,-3},{1.5,20,-3}},
			},   
			{ type = "line", out = "gate_middle_base", 
				points = {{-2,20,1},{2,20,1}},
			},           
			{ type = "line", out = "gate_top_base", 
				points = {{-3,20,2},{3,20,2}},
			},                          
			{ type = "line", out = "gate_top_base2", 
				points = {{-3.2,20,2.2},{3.2,20,2.2}},
			},    
			
			{ type = "extrude",["in"] = "gate_base",out = "gate_column_base",   
				shift = {0,0,2},
				times = 1,
			},         
			{ type = "column",["in"] = "gate_column_base",out = "gate_columns",outcap="gate_column_cap", 
				angle = 45,  
				r =  0.2 , 
				sides = 8,       
			},      
			{ type = "select",["in"]="gate_column_cap",out = "gate_column_top", remove = true, 
				mode = "dotnormal",
				normal = {0,0,-1}, 
				maxangle = 30,  
			}, 
			{ type = "inset",from = "gate_column_top",out = {face = "gate_column_top",edge="gate_columns_edges"}, 
				amount = 0.04, extrude =0 , 
			},  
			{ type = "inset",from = "gate_column_top",out = "gate_column_top",  
				extrude = 3,
				amount = 0.02,
			},            
			{ type = "tesselate", from = "gate_top_base", out = "gate_top_base", 
				interpolation = "linear",
				times = 3,
			},                  
			{ type = "tesselate", from = "gate_top_base2", out = "gate_top_base2", 
				interpolation = "linear",
				times = 3,
			},              
			{ type = "deform", ["in"] = "gate_top_base", out = "gate_top_base2", 
				mode = "bend",  
				amountx = {0,0,-0.2},       
				mul = {0.5,1,1},
			},            
			{ type = "deform", ["in"] = "gate_top_base2", out = "gate_top_base2", 
				mode = "bend",  

				amountx = {0,0,-0.2},      
				mul = {0.5,1,1}, 
			},            
			{ type = "column",["in"] = "gate_middle_base",out = "gate_top",outcap="gate_top", 
				angle = 45,   
				r =  0.15 ,  
				sides = 4,     
				normal = {0,0,1},
			},  
			{ type = "column",["in"] = "gate_top_base",out = "gate_top",outcap="gate_top", 
				angle = 45,  
				r =  0.2 , 
				sides = 4,     
				normal = {0,0,1},
			},  
			{ type = "column",["in"] = "gate_top_base2",out = "gate_topb",outcap="gate_topb", 
				angle = 0,  
				r =  0.22 , 
				sides = 4,     
				normal = {0,0,1},
			},  
			    
			{ type = "material",["in"] = {"gate_columns","gate_columns_edges","gate_topb"},
				material = "black.json"
			},  
			{ type = "material",["in"] = {"gate_column_top","gate_column_base","gate_top"},
				material = "med_red.json"
			},  
			 
			--{ type = "point", out = "testdef", 
			--	points = {{-1.5,20,3}},--,{1.5,20,-3}
			--},    
			--{ type =  "pointdeform", ["in"] = {"gate_top","gate_top_cap"},inpoints = "testdef",
			--	r = 3,pow = 1,dir = {0,0,1},
			--},   
			
		}       
	}       
	))           
	local testme = SpawnSO("@testmodel",self.space,Vector(0,0.01,0),1) 
	local testmewf = SpawnSO("@testmodel",self.space,Vector(0,0.01,0),1) 
	self.testme = testme
	self.testmewf = testmewf  
	local mat = LoadMaterial("debug/white.json")
	local matwf = CopyMaterial(mat)
	--ModMaterial(matwf,{wireframe = 1,FullbrightMode = true}) 
	--testme.model:SetMaterial(mat)  
	--testmewf.model:SetMaterial(matwf)        
end 
function ENT:CTO(user,ss)
	user:SetParent(ss)
	user:SetAbsPos(Vector(0,1,0))
	--if user.model then user.model:SetUpdateRate(10) end
	--ModNodeMaterials(user,{FullbrightMode=true},false,true)
	ModNodeMaterials(user,{
		ssao_mul=0, 
		LightwarpEnabled =1,
		g_LightwarpTexture="textures/warp/lw_soft.dds"
	},false,true)--,g_LightwarpTexture="models/renamon/tex/lw.dds",LightwarpEnabled=1},false,true)
end 
function ENT:CFR(user,ss)
	user:SetParent(ss:GetParent())
	user:SetAbsPos(ss:GetAbsPos()+Vector(0,1,0))
	if user.model then user.model:SetUpdateRate(60) end
	ModNodeMaterials(user,{
		ssao_mul=1,
		g_LightwarpTexture="",
		LightwarpEnabled =0,
		FullbrightMode=false,
	
	},true,true)
end 
function ENT:GetSpawn() 
	local space = self.space
 
	--local space2 = ents.Create()
	--space2:SetLoadMode(1)
	--space2:SetSeed(9900033)
	--space2:SetPos(Vector(0.00748269, 0.0012758673, 0.003352003))
	--space2:SetParent(space) 
	--space2:SetSizepower(1000)
	--space2:SetGlobalName("u1_room.space2")
	--space2:SetScale(Vector(0.0005, 0.1, 0.1))
	--space2:SetSpaceEnabled(false)
	--space2:Spawn()  
	--local sspace = space2:AddComponent(CTYPE_PHYSSPACE)  
	--sspace:SetGravity(Vector(0,-2,0))
	--space2.space = sspace
	--self.space2 = space2
	--
	--local instr = SpawnSO("test/r_room.stmd",space2,Vector(0,0,0),0.75) 
	--
	--instr:AddEventListener(EVENT_USE,"use_event",function(s,user) 
	--	self:CFR(user,space2)
	--end)
	--instr:AddFlag(FLAG_USEABLE) 
	--
	--space2:AddEventListener(EVENT_USE,"use_event",function(s,user)
	--	self:CTO(user,space2)
	--end)
	--space2:AddFlag(FLAG_USEABLE) 

	SpawnCONT("active/container.stmd",space,Vector(0,0.01,0.001)) 
	
	--local chair = SpawnSPCH("shiptest/chair1.json",space,Vector(0,0,0.0002),0.75)  
	--chair:SetSeed(space:GetSeed()+38012)
	--chair.usetype = "sit"
	 
	return self.space, Vector(0,0.0013627,0)
end 
    
debug.Delayed(100,function()
	hook.Call("aat","fst")
end)  