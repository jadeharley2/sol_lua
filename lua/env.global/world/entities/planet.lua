 

function ENT:Init()  
	local orbit = self:AddComponent(CTYPE_ORBIT) 
	
	self.orbit = orbit
	
	self.iscelestialbody = true
	self:AddTag(TAG_PLANET)
	self:SetSpaceEnabled(true,1)
end

function ENT:Spawn()  
	local rgroup1 = self.rgroup1 or RENDERGROUP_STARSYSTEM
	local rgroup2 = self.rgroup2 or RENDERGROUP_PLANET

	self:PreLoadData(false) 
	
	local model = self:AddComponent(CTYPE_MODEL) 
	model:SetRenderGroup(rgroup1)
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

	if true then
		local model = self:AddComponent(CTYPE_MODEL) 
		model:SetRenderGroup(rgroup2)
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
		self.model2 = model

	end
	 
	if not self.orbitIsSet then
	
		self.orbit:SetOrbit()
	end
	self:SetUpdating(true,1000)
	--if self.ismoon then
	--	self:Enter()
	--end
	 

	local ringdata = self.ringsdata
	if ringdata then 
		local targetSZ = radius / 0.909090909090909
		local minr = ringdata.minr/targetSZ
		local maxr = ringdata.maxr/targetSZ
		local colr = JVector(ringdata.color or {255,255,255})/255
		local brght = ringdata.brightness or 1

		local ringsEnt = ents.Create() 
		ringsEnt:SetSizepower(targetSZ)
		ringsEnt:SetParent(self)
		ringsEnt:SetSpaceEnabled(false)

		local model2 = ringsEnt:AddComponent(CTYPE_MODEL) 
		model2:SetRenderGroup(rgroup2)
		model2:SetModel("space/dynrings.dnmd?a="..minr..'&b='..maxr)  
		model2:SetBlendMode(BLEND_OPAQUE) 
		model2:SetRasterizerMode(RASTER_DETPHSOLID) 
		model2:SetDepthStencillMode(DEPTH_ENABLED)  
		model2:SetMatrix(matrix.Scaling(1)*matrix.Rotation(90,0,0))
		model2:SetBrightness(brght)
		model2:SetColor(colr)
		model2:SetFadeBounds(0.01,99999,0.05)  
		model2:SetMaxRenderDistance(99999)

		ringsEnt:Spawn()
		ringsEnt.iscelestialbody=true
		self.rings = ringsEnt
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
	
	if self[VARTYPE_ARCHETYPE]=='earth' then
		local svis = self:RequireComponent(CTYPE_SHAPEVIS)
		self.shapevis = svis
		--ssvis:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
		svis:RemoveShape("countries")
		svis:RemoveShape("lakes")
		svis:RemoveShape("rivers")
		svis:RemoveShape("water_natural")
		svis:RemoveShape("water_artificial")
		svis:LoadShape("countries","L:/_root/_f/_projects/_solge/srcv4/_bin/soltest/sources/vectordata/shapes/ne_50m_admin_0_countries.zip",Vector(10,10,10),10,matrix.Scaling(0.10005))
		svis:LoadShape("lakes",    "L:/_root/_f/_projects/_solge/srcv4/_bin/soltest/sources/vectordata/shapes/ne_10m_lakes.zip",Vector(7,6,10),10,matrix.Scaling(0.10005))
		svis:LoadShape("rivers",   "L:/_root/_f/_projects/_solge/srcv4/_bin/soltest/sources/vectordata/shapes/ne_10m_rivers_lake_centerlines_scale_rank.zip",Vector(2,4,10),10,matrix.Scaling(0.10005))
		svis:LoadOSM("water_natural",
		"#L:/_root/_f/_projects/_solge/srcv4/_bin/soltest/sources/vectordata/osm/crimean-fed-district-latest.o5m",
		--"#L:/_root/_f/_projects/_solge//srcv4/_bin/soltest/sources/vectordata/osm/south-fed-district-latest.o5m",
			json.ToJson({
				waterway = "^riverbank$|^river$|^stream$",
				natural = "^water$",
				water = "^river$|^lake$|^oxbow$|^pond$|^lagoon$|^stream_pool$",-- "."
			}),
			Vector(10,24,21),10,matrix.Scaling(0.10005))
		svis:LoadOSM("water_artificial",
		"#L:/_root/_f/_projects/_solge/srcv4/_bin/soltest/sources/vectordata/osm/crimean-fed-district-latest.o5m",
		--"#L:/_root/_f/_projects/_solge/srcv4/_bin/soltest/sources/vectordata/osm/south-fed-district-latest.o5m",
			json.ToJson({
				waterway = "^canal$|^pressurised$|^drain$",
				water = "^basin$|^reservoir$|^canal$|^lock$|^fish_pass$|^reflecting_pool$|^moat$|^ditch$|^wastewater$"
			}),
			Vector(20,4,1),10,matrix.Scaling(0.10005))
	end
end
function ENT:SpawnSurface() 
	if not self.left then
		local radius = self:GetParameter(VARTYPE_RADIUS) 
		local seed = self:GetSeed()
		
		
		local surface = self.surface
		MsgN("surface",surface)
		if not IsValidEnt(surface) then 
			local k = 0
		--	for k=0,4 do 
				local rgroup1 = self.rgroup1 or RENDERGROUP_STARSYSTEM
				local rgroup2 = self.rgroup2 or RENDERGROUP_PLANET
				local rgroup3 = self.rgroup2 or RENDERGROUP_CURRENTPLANET
				surface = ents.Create("planet_surface") 
				surface.rgroup1 = rgroup2
				surface.rgroup2 = rgroup3
				surface:SetParent(self)
				surface:SetSizepower(radius / 0.909090909090909) 
				surface:SetSeed(seed+1000*(k+1)) 
				surface:SetPos(Vector(0,0,0))-- Vector(k/40,0,0))
				local arch = self:GetParameter(VARTYPE_ARCHETYPE)
				if arch then
					surface:SetParameter(VARTYPE_ARCHETYPE,arch)
				end 
				local archdata = self:GetParameter(VARTYPE_ARCHDATA)
				if archdata then
					surface:SetParameter(VARTYPE_ARCHDATA,archdata)
				end
				surface.surfacenodelevel = self.surfacenodelevel
				MsgN("XXXXX",surface)
				surface:Spawn()  
				MsgN("XXXXX2",surface)
			--end
			self.surface = surface
			self.model2:Enable(false)
		end
		
		
		self.partition = surface.partition
		MsgN("BBB",surface.partition,surface:GetComponent(CTYPE_PARTITION2D)) 
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
	self.model2:Enable(true)
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






function ENT:PreLoadData(isLoad)  
	local data = self.data
	if not data then
		local type = self:GetParameter(VARTYPE_FORM)  
		if type then
			data = forms.ReadForm(type)
			self.data = data
		end
		if data then
			local modtable = self.modtable
			if modtable then table.Merge(modtable,data,true) end
	
			self[VARTYPE_RADIUS] = data.radius
			self[VARTYPE_ARCHETYPE] = data.archetype
	
					 
			if isstring(data.name) then
				self:SetName(data.name)
			end
		end	
	end 
end

hook.Add('formspawn.planet','spawn',function(form,parent,arguments) 
	return hook.Call('formcreate.planet',form,parent,arguments)
end) 
hook.Add('formcreate.planet','spawn',function(form,parent,arguments)  

	local PLANET = ents.Create("planet")
	PLANET[VARTYPE_FORM] = form
	PLANET:PreLoadData(false) 
	--PLANET[VARTYPE_RADIUS] = radius
	--PLANET[VARTYPE_ARCHETYPE] = 'default'
	local radius = PLANET[VARTYPE_RADIUS] or 10
	PLANET.szdiff = 10

	PLANET.rgroup1 = RENDERGROUP_LOCAL
	PLANET.rgroup2 = RENDERGROUP_LOCAL
	PLANET.rgroup3 = RENDERGROUP_LOCAL
	PLANET:SetSizepower(10*radius) 

	PLANET:SetParent(parent)
	PLANET:AddTag(TAG_EDITORNODE)
	PLANET:SetSeed(arguments.seed or 0)
	PLANET:SetPos(arguments.pos or Vector(0,0,0)) 
	PLANET:Create()
	return PLANET
end)