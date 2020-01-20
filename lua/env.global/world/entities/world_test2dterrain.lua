ENT.name = "Test 2d terrain"

local rdtex = LoadTexture("space/star_sprites.png")
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


	local particlesys = lighttest:AddComponent(CTYPE_PARTICLESYSTEM) 
	particlesys:SetRenderGroup(RENDERGROUP_DEEPSPACE)
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

	self:SetSizepower(10000)
	self:SetSeed(9900001)
	self:SetGlobalName("u_grid") 

end
function ENT:LoadWorld(name)
	local data = json.Read('chunkdata/'..name..'/info.json')
	if(not data) then return end

	if data.sky and data.sky.texture then
		if self.skybox  then
			self.skybox:Despawn()
		end 
		self.skybox = SpawnSkybox(self.space,data.sky.texture or "textures/cubemap/daysky.dds")
		if data.sky.rotation then self.skybox:SetWorld(matrix.Rotation(JVector(data.sky.rotation))) end--Vector(180,0,0)))
	end
	self.grid:SetWorldName(name)

end
function ENT:Spawn()

	-- all worlds must have minimum 1 subspace 
	-- 
	local space = ents.Create()
	space:SetLoadMode(1)
	space:SetSeed(9900002)
	space:SetParent(self) 
	space:SetSizepower(1000)
	space:SetGlobalName("u_grid.space")
	space:Spawn()  
	local sspace = space:AddComponent(CTYPE_PHYSSPACE)  
	sspace:SetGravity(Vector(0,-4,0))
	space.space = sspace

	
	--def:1900000000
	local light = self:CreateStaticLight(Vector(-85.6,106.2,124.6)/10/2*10,Vector(255,255,255)/255,50500000000*8)
	light.light:SetShadow(true)  
	SpawnPV('prop.other.prim_box',space,Vector(0,0,0),Vector(0,0,0),0)
	self.space = space
	 
	local grid = space:AddComponent(CTYPE_CHUNKTERRAIN)
	self.grid = grid
	grid:SetRenderGroup(RENDERGROUP_LOCAL)

	local name = 'testworld01'--'unnamedworld_131'

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

		local cubemap = root_skyb:AddComponent(CTYPE_CUBEMAP)  
		self.cubemap = cubemap 
		cubemap:SetTarget(nil,self)  
		cubemap:RequestDraw()

		
	end 
end

function ENT:GetSpawn() 
	if CLIENT then
		local c = SpawnPlayerChar( Vector(0,0.0013627,0),self.space) 
		return c, Vector(0,0,0)
	end
	return self.space, Vector(0,0.01,0)
end

console.AddCmd("changedim",function(dim)
	local pl = LocalPlayer()
	if pl then
		local top = pl:GetTop()
		if top and top.LoadWorld then
			top:LoadWorld(dim)
			--debug.Delayed(function()
			--	top.grid:GetHeight()
			--end)
		end
	end
end)

hook.Add("node_properties","chunk_node_params",function(node,params)
	local p = node:GetParent()
	if p:GetComponent(CTYPE_CHUNKTERRAIN) then 
		params.chunknode_display = {text = "is chunk node",type="indicator",value = function(ent)  
			local p = ent:GetParent()
			if p then
				local chtr = p:GetComponent(CTYPE_CHUNKTERRAIN)
				if chtr then
					return chtr:IsChunkNode(ent)
				end
			end
			return false
		end}
		params.chunknode_set = {text = "set chunk node",type="action",action = function(ent)  
			local p = ent:GetParent()
			if p then
				local chtr = p:GetComponent(CTYPE_CHUNKTERRAIN)
				if chtr then
					chtr:AddNode(ent)
					return true
				end
			end
		end}
		params.chunknode_unset = {text = "unset chunk node",type="action",action = function(ent)  
			local p = ent:GetParent()
			if p then
				local chtr = p:GetComponent(CTYPE_CHUNKTERRAIN)
				if chtr then
					chtr:DelNode(ent)
					return true
				end
			end
		end}
	end
end)