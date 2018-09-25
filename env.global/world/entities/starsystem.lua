 
local rdtex = LoadTexture("space/star_sprites.png")

function ENT:Init() 
	self:SetLoadMode(1)
end

function ENT:Enter()  
	TSYSTEM = self
	if not self.loaded then 
		self:SetParameter(VARTYPE_TYPE,NTYPE_STARSYSTEM) 
		--self:SetParameter(VARTYPE_TYPENAME,"star")
	
		
		
		local generator = self:AddComponent(CTYPE_PROCEDURAL) 
		
		generator:AddEvent(EVENT_GENERATOR_SETUP)
		local ss = self:GetParameter(VARTYPE_GENERATOR)
		if not ss or ss == "none" then ss = "com.system.default" end
		MsgN("gen: ",ss)
		generator:SetGenerator(ss)
		
		if CLIENT then
			local skybox = self:AddComponent(CTYPE_SKYBOX) 
			local cubemap = self:AddComponent(CTYPE_CUBEMAP) 
			self.skybox = skybox
			self.cubemap = cubemap
			skybox:SetRenderGroup(RENDERGROUP_STARSYSTEM) 
			skybox:SetBrightness(1)
			cubemap:SetTarget(skybox)
			--cubemap:RequestDraw(skybox,function() render.SetGroupMode(RENDERGROUP_DEEPSPACE,RENDERMODE_DISABLED) end)
			--skybox:SetTexture("data/textures/test/sky_day02.png")
			--render.DisableGroup(RENDERGROUP_DEEPSPACE)
			 self:ReloadSkybox()
			 
			 
			
			--if self.stars then  
			--	for k1,star in pairs(self.stars) do  
			--		local particlesys = star:AddComponent(CTYPE_PARTICLESYSTEM) 
			--	  
			--		particlesys:SetRenderGroup(RENDERGROUP_STARSYSTEM)
			--		particlesys:SetBrightness(0.5)--0.3
			--		star.particlesys = particlesys
			--		
			--		particlesys:SetNodeMode(false)
			--		particlesys:AddNode(1) 
			--		particlesys:SetNodeStates(1,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_READ) 
			--		particlesys:SetTexture(1,rdtex)
			--		particlesys:SetMaxRenderDistance(1000)
			--		
			--		for k2,planet in pairs(star.planets) do  
			--			particlesys:AddParticle(1,planet:GetPos(),star.color*0.2,0.00001,0) 
			--		end
			--	end
			--end
			
		end
		
		
		self.loaded = true
		--[[
		MsgN("stars")
		if self.stars then 
			PrintTable(self.stars)
			for k1,star in pairs(self.stars) do 
				MsgN("planets")
				PrintTable(star.planets)
				for k2,planet in pairs(star.planets) do 
					local orbit = planet.orbit
					local tbl = {}
					for k=1,37 do
						local val = orbit:GetPosition(k*10) 
						tbl[k] = val
					end
					--tbl[#tbl+1] = Vector(0,0,0) 
					debug.ShapeCreate(k2,star,Vector(1,1,1),3,tbl)
				end
			end
		end
		]]
		if CLIENT then
			--if GetCamera():GetParent()~=LocalPlayer() then
			--	--self:ReloadSkybox()
			--end
		end
	end
end 
function ENT:Leave()  
	
	if  TSYSTEM == self then TSYSTEM = nil end
	
	render.SetGroupMode(RENDERGROUP_DEEPSPACE,RENDERMODE_ENABLED)
	self:RemoveComponents(CTYPE_PROCEDURAL) 
	if CLIENT then
		self:RemoveComponents(CTYPE_SKYBOX) 
		self:RemoveComponents(CTYPE_CUBEMAP) 
		self:RemoveComponents(CTYPE_PARTICLESYSTEM) 
	end
	self:UnloadSubs()
	self.loaded = nil
	
	if CLIENT then
		 render.SetGroupMode(RENDERGROUP_DEEPSPACE,RENDERMODE_ENABLED) 
	end
end
function ENT:Regenerate()
	local rebaseCam = false
	if CLIENT then
		local cam = GetCamera()
		if self:IsParentOf(cam) then
			rebaseCam = true
			for k,v in ipairs(cam:GetHierarchy()) do
				MsgN(k,v,v==self)
				if v == self then
					break
				end
				if v ~= cam then
					cam:Eject()
				end
			end
			--cam:SetParent(self)
			MsgN("camrebase")
		end
	end
	self:Leave()
	self:Enter()
	if rebaseCam then
		local cam = GetCamera()
		--cam:SetParent(self)
	end
end
function ENT:MapMode()
	for	k,v in pairs(self.stars[1].planets) do
		v.orbit = nil
		v:RemoveComponents(CTYPE_ORBIT)
		v:SetPos(Vector(0.0001+k*0.00001,0,k*-0.000001))
		local spt = v.sptext or v:AddComponent(CTYPE_SPRITETEXT)
		if spt then
			spt:SetText(v:GetName() 
			.."\nClass: "..(v:GetParameter(VARTYPE_ARCHETYPE) or "default")
			.."\nRadius: "..((v:GetParameter(VARTYPE_RADIUS) or 0)/1000).."km"
			)
			spt:SetRenderGroup(RENDERGROUP_STARSYSTEM)
			spt:SetMatrix(matrix.Translation(Vector(0,-0.03,0)))
			--spt:SetColor(Vector(0.1,0.1,0.1))
			spt:SetBrightness(0.1)
			v.sptext = spt
		end
	end
	self.stars[1]:SetBrightness(1e18)
end
if CLIENT then
	function ENT:ReloadSkybox()
		MsgN("reload star sky")
		render.SetGroupMode(RENDERGROUP_DEEPSPACE,RENDERMODE_ENABLED)
		render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_DISABLED)
		--self.skybox
		self.cubemap:RequestDraw(nil,function() 
			render.SetGroupMode(RENDERGROUP_DEEPSPACE,RENDERMODE_DISABLED) 
			render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_BACKGROUND)
			render.SetGroupBounds(RENDERGROUP_STARSYSTEM,1e8,0.5*UNIT_LY)
		end)
	end
end

