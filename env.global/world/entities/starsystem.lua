 

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
			skybox:SetBrightness(0.5)
			cubemap:SetTarget(skybox)
			--cubemap:RequestDraw(skybox,function() render.SetGroupMode(RENDERGROUP_DEEPSPACE,RENDERMODE_DISABLED) end)
			--skybox:SetTexture("data/textures/test/sky_day02.png")
			--render.DisableGroup(RENDERGROUP_DEEPSPACE)
			--self:ReloadSkybox()
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
			--	self:ReloadSkybox()
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
	end
	self:UnloadSubs()
	self.loaded = nil
end

if CLIENT then
	function ENT:ReloadSkybox()
		render.SetGroupMode(RENDERGROUP_DEEPSPACE,RENDERMODE_ENABLED)
		self.cubemap:RequestDraw(self.skybox,function() render.SetGroupMode(RENDERGROUP_DEEPSPACE,RENDERMODE_DISABLED) end)
	end
end

