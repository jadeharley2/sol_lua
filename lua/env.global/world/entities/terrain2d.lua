
local rdtex = LoadTexture("space/star_sprites.png")
function ENT:CreateStaticLight( pos, color,power,glname,seed)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2) 
	lighttest:SetParent(self)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn() 
	if power then lighttest:SetBrightness(power) end
	lighttest:SetPos(pos) 
	if glname then lighttest:SetGlobalName(glname) end
	if seed then lighttest:SetSeed(seed) end
	

	local particlesys = lighttest:AddComponent(CTYPE_PARTICLESYSTEM) 
	particlesys:SetRenderGroup(RENDERGROUP_LOCAL)
	particlesys:SetNodeMode(false)
	particlesys:AddNode(8)
	particlesys:SetNodeStates(8,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_READ) 
	particlesys:SetTexture(8,rdtex)
	particlesys:AddParticle(8,Vector(0,0,0), Vector(1, 244 / 255, 232 / 255)*1,100000*8,0) 
	particlesys:SetMaxRenderDistance(10000000000)
	lighttest.psys = particlesys

	return lighttest
end

function ENT:Init()

	self:SetSizepower(1000) 
	self:SetUpdating(true,16)
	  
	local ctime = self:AddComponent(CTYPE_TIME)
	ctime:SetDeltaTime(1)
	self.ctime = ctime
end
function ENT:SetupData(data)
	if data.world then 
		self.worldname = data.world 
	end 
end
function ENT:LoadWorld(name)
	local data = json.Read('chunkdata/'..name..'/info.json')
	if(not data) then return end

	if IsValidEnt(self.skybox) then
		self.skybox:Despawn()
		self.skybox = nil
	end  
	if IsValidEnt(self.dynsky) then
		self.dynsky:Despawn()
		self.dynsky = nil
	end  
	if data.sky and data.sky.texture then
		self.skybox = SpawnSkybox(self.space,data.sky.texture or "textures/cubemap/bluespace.dds")
		if data.sky.rotation then self.skybox:SetWorld(matrix.Rotation(JVector(data.sky.rotation))) end--Vector(180,0,0)))
	end
	if data.atmosphere then
		self.dynsky = SpawnDynsky(self.space)
	end
	self.grid:SetWorldName(name)
	if CLIENT then 
		self:Delayed("cubemapdraw",1000,function()
			if IsValidEnt(self) then
				self.cubemap:RequestDraw()
			end
			
		end)
	end

end
function ENT:Spawn()

	MsgN("worlfa")
	local space = self
	self.space = space
	space:SetLoadMode(1)
	
	local sspace = space:RequireComponent(CTYPE_PHYSSPACE)  
	sspace:SetGravity(Vector(0,-4,0))
	space.pspace = sspace

	
	--def:1900000000
	local light = self:CreateStaticLight(Vector(-85.6,106.2,124.6)/10/2*10,
		Vector(255,255,255)/255,5050000000,"dgl_star0",33244285) 
	light.light:SetShadow(true)  
	SpawnPV('prop.furniture.space.spawn',space,Vector(0,-1,0)*0.001,Vector(0,0,0),0)
	 
	local grid = space:RequireComponent(CTYPE_CHUNKTERRAIN)
	self.grid = grid
	grid:SetRenderGroup(RENDERGROUP_LOCAL)

	local name = self.worldname or 'testworld01'--'unnamedworld_131'
	self.worldname = name
	self:LoadWorld(name)

	if CLIENT then

		local eshadow = ents.Create("test_shadowmap2")  
		eshadow.light = light
		eshadow:SetParent(ent) 
		eshadow:Spawn() 
		self.shadow = eshadow

		
		 
		local root_skyb =  ents.Create()
		root_skyb:SetSizepower(2000)
		root_skyb:SetParent(space)
		root_skyb:SetPos(Vector(0,0.5,0))
		root_skyb:SetSpaceEnabled(false)
		root_skyb:Spawn()

		local cubemap = root_skyb:RequireComponent(CTYPE_CUBEMAP)  
		self.cubemap = cubemap 
		cubemap:SetTarget(nil,self)  
		cubemap:RequestDraw()

		GlobalSetCubemap(cubemap)
		
	end 
	CreateSpawnpoint(space,Vector(0,0.0013627,0) )
end
function ENT:Think()
	local time = CurTime()
	self:SetTime(time)
	return true
end
function ENT:SetTime(time)
	local dt = time - (self.time or 0)
	self.time = time
	local dgl_star0 = ents.GetByName("dgl_star0")
	if dgl_star0 then
		local lpos = dgl_star0:GetPos()
		local dbase = Vector(0,70,0)
		-- 0 = -180
		-- 6 = -90
		-- 12= 0 
		-- 16= 90
		local angle = dt/100--(time/10/12-1)*180

		dgl_star0:SetPos(lpos:Rotate(Vector(angle,0,0)))
		local alpos =  dgl_star0:GetPos():Normalized().y
		local mulb = math.min(math.max(alpos*20,0),1)
		--MsgN(alpos,mulb)
		dgl_star0:SetBrightness(5050000000*mulb,1)--
		if lpos.y<0 then
			dgl_star0.light:SetShadow(false) 
		else 
			dgl_star0.light:SetShadow(true)  
		end
	end
end


