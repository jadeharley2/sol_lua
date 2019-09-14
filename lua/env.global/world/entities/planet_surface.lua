
function ENT:Init()
	self:AddTag(TAG_PLANET_SURFACE)
	local constrot  = self:AddComponent(CTYPE_CONSTROT) 
	constrot:SetParams(0.00001,0,matrix.Rotation(0.1,0,0))
	--constrot:SetParams(0.1,0,matrix.Rotation(0.1,0,0)) 
	--constrot:SetSpeed(0.001)
	self.constrot = constrot
	self:SetSpaceEnabled(true,1)
	self:SetUpdating(true,50)
end
function ENT:Spawn()  
	
	
	local partition = self:AddComponent(CTYPE_PARTITION2D) 
	local surfacecom = self:AddComponent(CTYPE_SURFACE)  
	local space = self:AddComponent(CTYPE_PHYSSPACE) 
	
	local arch = self:GetParameter(VARTYPE_ARCHETYPE)
	if arch then
		surfacecom:SetArchetype(arch)
	end
	if arch == "earth" then--TODO: add set mapdata source
		local mapdata = self:AddComponent(CTYPE_MAPDATA)
		self.mapdata = mapdata
	end
	--local testmod = ents.Create("planet_surface_mod")
	--testmod:SetSizepower(100000) 
	--testmod:SetParameter(VARTYPE_CHARACTER,"test_earth") 
	--testmod:SetParent(self) 
	--testmod:SetPos(Vector(0,0,0))-- Vector(1,-0.15,0)*0.90908)
	----testmod:SetAng(Vector(0,-90,0))
	--testmod:Spawn() 
	
	
	if self.surfacenodelevel then
		surfacecom:LinkToPartition(self.surfacenodelevel)
	else
		surfacecom:LinkToPartition()
	end
	surfacecom:SetRenderGroup(RENDERGROUP_PLANET)
	
	self.partition = partition
	self.surface = surfacecom  
	self.space = space
	
	if(surfacecom:HasAtmosphere() )then
		local atmosphere = self:AddComponent(CTYPE_ATMOSPHERE)  
		atmosphere:SetRenderGroup(RENDERGROUP_PLANET)
		self.atmosphere = atmosphere
	end
	
	--self:SetUpdating(true,20)
	
	
end

function ENT:Enter() 
	--render.SetGroupBounds(RENDERGROUP_CURRENTPLANET,1e8,0.5*UNIT_LY)
	render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_BACKGROUND)  
	render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_BACKGROUND) 
	render.SetGroupBounds(RENDERGROUP_PLANET,1e4,1000e8) 
	render.SetGroupBounds(RENDERGROUP_CURRENTPLANET,10,1e8)
	self.surface:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
	if self.modelA then
		self.modelA:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
		self.model:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
		self.modelB:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
	end
	if self.atmosphere then
		self.atmosphere:SetRenderGroup(RENDERGROUP_LOCAL)
	end
	render.SetGroupMode(RENDERGROUP_RINGS,RENDERMODE_ENABLED) 
	render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_ENABLED)  
	render.SetGroupMode(RENDERGROUP_CURRENTPLANET,RENDERMODE_ENABLED)  
end

function ENT:Leave()   
	self.surface:SetRenderGroup(RENDERGROUP_PLANET)
	if self.modelA then
		self.modelA:SetRenderGroup(RENDERGROUP_PLANET)
		self.model:SetRenderGroup(RENDERGROUP_PLANET)
		self.modelB:SetRenderGroup(RENDERGROUP_PLANET)
	end
	if self.atmosphere then
		self.atmosphere:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
	end
	
	--render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_ENABLED) 
	--render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_ENABLED) 
	--self:UnloadSubs()
	
	if CLIENT then
		local system =  self:GetParentWith(NTYPE_STARSYSTEM) 
		--MsgN("ad",system)
		--if system and system.cubemap then
		--	render.SetCurrentEnvmap(system.cubemap)
		--else
		--	render.SetCurrentEnvmap()
		--end
		render.SetCurrentEnvmap()
		render.ClearShadowMaps()

		render.SetGroupMode(RENDERGROUP_RINGS,RENDERMODE_ENABLED) 
		render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_ENABLED)  
		render.SetGroupMode(RENDERGROUP_CURRENTPLANET,RENDERMODE_ENABLED)  
	end
end
local ttc = 10
function ENT:Think()
--	--MsgN("d") 
	--self.constrot:SetParams(0.001,0,matrix.Rotation(0.1,0,0))
--	--cr:SetPostOffset()
	if CLIENT and false then
		local cam = GetCamera()
		if cam:GetParent()==self then
			render.ClearShadowMaps()
		end

		local r = Random()
		if self.atmosphere and ttc<0 then
			--for k=1,4 do
			local p = ((r:NextVector()-Vector(0.5,0.5,0.5))*Vector(1,0.3,1)):Normalized()
			--p = Vector(1,0,0)
			p = (self:GetLocalCoordinates( cam)
				+(r:NextVector()-Vector(0.5,0.5,0.5)) *0.06 --*0.01
				--+Vector(7,0,-8)*0.01
				):Normalized()
			self:LightninStrike(p*0.917)--0.915
			--end
			ttc =  5+r:NextFloat(0,43)--5


		end
		ttc  = ttc - 1
	 local eee = (self:GetLocalCoordinates( cam)
	 	+(r:NextVector()-Vector(0.5,0.5,0.5))*0.8 ):Normalized()
	 self:Meteor(eee*0.92,0.5)--r:NextFloat(0.1,2)
	end
end

function ENT:Meteor(pos,size)
	local prtcls = SpawnParticles(self,'meteor',pos,6,100*size,1)
	prtcls.particlesys2:SetMaxRenderDistance(100000)
end
function ENT:LightninStrike(pos)
	local omni = ents.Create("omnilight")
	omni:SetParent(self)
	omni:SetPos(pos)
	omni:Spawn()
	omni:SetColor(Vector(0.9,0.8,1))
	omni:SetBrightness(10000000000*1)
	local c = GetCamera()
	local p = c:GetParent()
	if true then 
		if p:GetParent()==self then
			local cdp = p-- self--p
			local cpp = p:GetLocalCoordinates(omni)
			 cpp = Vector(cpp.x,cpp.y-9,cpp.z) --pos*0.994-- 
			omni:SetPos(pos*0.99135)
			omni:SetBrightness(10000000000*4)
			--*0.99135
			---9
			local prtcls = SpawnParticles(cdp,'lightning',cpp,1,20,1) --:LookAt(pos:Normalized(),matrix.Rotation(0,0,-90))--SetAng(Vector(0,0,-90))
			prtcls.particlesys2:SetMaxRenderDistance(100000)
			local distance = c:GetDistance(prtcls)/10
			if distance< 5000 then
				--MsgN(distance,p:GetDistance(prtcls))
				
				debug.Delayed(distance/3,function()
					sound.Start(table.Random({
						'events/thunder_s1.ogg',
						'events/thunder_s2.ogg',
						'events/thunder_s3.ogg',
						'events/thunder_s4.ogg'}),
						math.min(1,2000/distance),false)
				end)
			end
			debug.Delayed(50,function()
				omni:Despawn()
			end)
			--omni:Despawn()
			--MsgN("VARC")
		else
			--omni:SetPos(pos*0.99135)
			debug.Delayed(50,function()
				omni:Despawn()
			end)
		end 
		--debug.Delayed(50,function()
		--	omni:Despawn()
		--end)
		
	else 
		debug.Delayed(50,function()
			omni:Despawn()
		end)
	end
end

FTEST = ENT.LightninStrike