 

function ENT:Init()  
	local orbit = self:AddComponent(CTYPE_ORBIT) 
	
	self.orbit = orbit
	
	self.iscelestialbody = true
	self:AddTag(TAG_PLANET)
	self:SetSpaceEnabled(true,1)
end

function ENT:Spawn()  
	
	
	local model = self:AddComponent(CTYPE_MODEL) 
	model:SetRenderGroup(RENDERGROUP_STARSYSTEM)
	model:SetModel("engine/csphere_36_cylproj.stmd") 
	model:SetMaterial("textures/space/distanceplanet.json") 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED) 
	local szdiff = self.szdiff or 100
	local sz = self:GetSizepower()
	local radius = self:GetParameter(VARTYPE_RADIUS) 
	--model:SetMatrix(matrix.Scaling( 0.9086/szdiff * 2) * matrix.Rotation(90,0,0))
	model:SetMatrix(matrix.Scaling( 0.09386*2*(radius/sz)) * matrix.Rotation(90,0,0))
	model:SetBrightness(0.8)
	model:SetFadeBounds(0.01,99999,0.005) 
	model:SetMaxRenderDistance(10000) 
	self.model = model
	 
	if not self.orbitIsSet then
	
		self.orbit:SetOrbit()
	end
	self:SetUpdating(true,1000)
	--if self.ismoon then
	--	self:Enter()
	--end
	
	if false then--
		local radius = self:GetParameter(VARTYPE_RADIUS) 
		local seed = self:GetSeed()
		 
		--self:GetSeed()==361001 then --saturn test
		local ringsEnt = ents.Create() 
		ringsEnt:SetSizepower(radius / 0.909090909090909)
		ringsEnt:SetParent(self)
		ringsEnt:SetSpaceEnabled(false)
		ringsEnt:Spawn()
		ringsEnt.iscelestialbody=true
		
		local model2 = ringsEnt:AddComponent(CTYPE_MODEL) 
		model2:SetRenderGroup(RENDERGROUP_PLANET)
		model2:SetModel("space/rings3.SMD") 
		model2:SetMaterial("textures/space/rings_test.json") 
		model2:SetBlendMode(BLEND_OPAQUE) 
		model2:SetRasterizerMode(RASTER_DETPHSOLID) 
		model2:SetDepthStencillMode(DEPTH_ENABLED)  
		model2:SetMatrix(matrix.Scaling(1)*matrix.Rotation(90+10,0,20))
		model2:SetBrightness(4)
		model2:SetFadeBounds(0.01,99999,0.05)  
		model2:SetMaxRenderDistance(99999)
		--self.modelR = model2
	end
end
function ENT:Enter()  
	self.left = false
	self:SetUpdating(true,10)
	-- TEMP!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	if not self.loaded  then
		--for k=1,5 do
		
		
		local hrender = self:AddComponent(CTYPE_HEIGHTMAP) 
		self.hrender = hrender
		
		--self:SpawnSurface() 
		----[[ 
		if CLIENT then 
			hrender:RequestDraw(nil,function()
				self:SpawnSurface() 
			end)
			
		else
			self:SpawnSurface() 
			--self:AddEventListener(EVENT_HEIGHTMAP_DATA_RECEIVED,"event",function(self)  
			--	self:SpawnSurface() 
			--end)
		end--]]
	end
	--self.model:Enable(false)
	if CLIENT then
		 render.SetGroupMode(RENDERGROUP_DEEPSPACE,RENDERMODE_DISABLED) 
		 
		render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_BACKGROUND) 
		render.SetGroupBounds(RENDERGROUP_PLANET,1e4,1000e8)
		render.SetGroupBounds(RENDERGROUP_CURRENTPLANET,10,1e8)
	end
end
function ENT:SpawnSurface() 
	if not self.left then
		local radius = self:GetParameter(VARTYPE_RADIUS) 
		local seed = self:GetSeed()
		
		
		local surface = self.surface
		if not surface or not IsValidEnt(surface) then 
			local k = 0
		--	for k=0,4 do 
				surface = ents.Create("planet_surface") 
				surface:SetParent(self)
				surface:SetSizepower(radius / 0.909090909090909) 
				surface:SetSeed(seed+1000*(k+1)) 
				surface:SetPos(Vector(0,0,0))-- Vector(k/40,0,0))
				local arch = self:GetParameter(VARTYPE_ARCHETYPE)
				if arch then
					surface:SetParameter(VARTYPE_ARCHETYPE,arch)
				end 
				surface.surfacenodelevel = self.surfacenodelevel
				surface:Spawn()  
			--end
			self.surface = surface
		end
		
		
		self.partition = surface.partition
		self.loaded = true  
		self.partition:SetUpdating(true)
		--self.model:Enable(false)
	end
end
--
function ENT:Leave() 
	self.left = true
	self:SetUpdating(true,1000)
	self.model:Enable(true)
	if self.partition then self.partition:SetUpdating(false) end
	 
	--if self.loaded then 
		for k,v in pairs(self:GetChildren()) do
			if not v.iscelestialbody then
				v:Despawn()
			end
		end
		self.loaded = false
	--end
	--self:UnloadSubs()
	
end

