ENT.name = "Source world"


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
	 
	
	
	
	
	
	if CLIENT then
		local eshadow = ents.Create("test_shadowmap2")  
		eshadow.light = light
		eshadow:SetParent(space) 
		eshadow:Spawn() 
		self.shadow = eshadow
		 
		 
		 
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

	 

 
end  
function ENT:GetSpawn() 
	local space = self.space

	local c = SpawnPlayerChar( Vector(0,0.0013627,0),self.space)

	return c, Vector(0,0,0)
end 
	
local LoadOption = function(self,camera,option)
	local path = option.path
	if path then
		self.mapname = path 
		local test13 = ents.Create("bspmap")
		test13[VARTYPE_FORM] = option.text --"gm_flatgrass"-- "gm_construct"--"rp_evocity_dbg"--
		
		test13:SetSizepower(1000)
		test13:SetParent(self.space)
		test13:SetPos(Vector(0, 2, 0)) 
		test13:SetSeed(333333)
		test13:SetSpaceEnabled(false)
		test13:Spawn()
		--testA = test13 
		SpawnPlayerChar(Vector(0,0,0),test13)
		SetController('actor') 
	end
end 

function ENT.GetOptions()
	local maps = file.GetFiles('gmod/maps','bsp',true)
	local opts = {}
 
	for k,v in pairs(maps) do
		local mapname = file.GetFileNameWE(v)
		MsgN(k,v,mapname)
		opts[mapname] = {text = mapname, path = v, onload = LoadOption}
	end 
	return opts 
end