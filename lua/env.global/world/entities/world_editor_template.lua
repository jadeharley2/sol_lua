ENT.name = "Editor empty template world"
ENT.hidden = true

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
	self:SetGlobalName("editor_world") 

end

function ENT:Spawn()

	-- all worlds must have minimum 1 subspace 
	-- 
	local space = ents.Create()
	--space:SetLoadMode(1)
	space:SetSeed(9900002)
	space:SetParent(self) 
	space:SetSizepower(1000)
	space:SetGlobalName("editor_world.space")
	space:Spawn()  
	local sspace = space:AddComponent(CTYPE_PHYSSPACE)  
	--sspace:SetGravity(Vector(0,-0.0000001,0))
	sspace:SetGravity(Vector(0,-0.1,0))
	space.space = sspace
	self.space = space
 
	local light = self:CreateStaticLight(Vector(-1.3,1.2,-2.5)/2*10,Vector(200,200,200)/255,190000000 * 100)
	light.light:SetShadow(true)
	light:SetDonotsave(true) 
	self.light = light
	  
		
	if CLIENT then
	
		--self.skybox = SpawnSkybox(space,"textures/cubemap/sample.dds")
		--self.skybox = SpawnSkybox(space,"data/textures/skybox/spacedefault/space.png")
		--self.skybox = SpawnSkybox(space,"data/textures/skybox/test_horison/daylight.png")
		--self.skybox:SetDonotsave(true)
		
		local eshadow = ents.Create("test_shadowmap2")  
		eshadow.light = light
		eshadow:SetParent(ent) 
		eshadow:Spawn() 
		self.shadow = eshadow
		 
		self.cubemap = SpawnCubemap(space,Vector(0,0.0013627,0),512)
		self.cubemap:SetDonotsave(true)
		self.cubemap:RequestDraw()
		
	end
	
	debug.Delayed(1000,function()
		for k,v in pairs(space:GetChildren()) do
			if v.Load then
				v:Load()
			end
		end
	end)
end

function ENT:GetSpawn() 
	local space = self.space 
	return self.space, Vector(0,0,0)
end 
ENT.options = { 
	editor = {
		text = "Editor", 
		location = "@editor_world.space;0,0,0",
		position = Vector(0,0,0),
		controller = "freecamera",
		onload = function(self,origin) 
			WorldeditorOpen()
		end
	},
}