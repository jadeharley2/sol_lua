
--CLIENT ONLY

function ENT:Init()  
	self:SetSpaceEnabled(false) 
	self:SetDonotsave(true) 
	self:SetSizepower(1000)
	self:SetSelfContained(true)
end

function ENT:Spawn()   
	local seed = self:GetSeed()
	hook.Add("settings.changed","shadowmap.update."..tostring(seed),function()
		self:UpdateShadowMap()
	end)
	self:UpdateShadowMap()
	
end
function ENT:UpdateShadowMap()

	local shadows_enabled = settings.GetBool("engine.shadowsenabled",true)  
	if shadows_enabled then
		local shadow_size = settings.GetNumber("engine.shadowssize",1024) 
		
		local cc = self.cc or ents.CreateCamera()
		cc:SetParent(self) 
		cc:Spawn()
		self.cc = cc  
		
		local shadowrp = render.RenderParameters()
		shadowrp:SetRenderGroups({
			{RENDERGROUP_CURRENTPLANET,RENDERMODE_ENABLED,0.01,1e10},
			{RENDERGROUP_LOCAL,RENDERMODE_ENABLED,0.01,1e10}
		})
		self.rp = shadowrp
		 
		local camera = self.camera or self:AddComponent(CTYPE_SHADOW) 
		camera:SetCamera(cc)
		camera:SetParameters(shadowrp)
		camera:RequestDraw()
		self.camera = camera 
		
		local seed = self:GetSeed()
		self.seed = seed 
		
		--self:SetUpdating(true)
		--hook.Remove("main.predraw", "shadowmapupdate"..tostring(seed))
		hook.Add(EVENT_GLOBAL_PREDRAW, "shadowmapupdate"..tostring(seed), function() self:UpdatePos() end)
	else
		local cc = self.cc 
		local target = self.target
		local camera = self.camera
		
		if cc then cc:Despawn() self.cc = nil end
		if target then target:Unload() self.target = nil end
		if camera then camera:UnsetShadowMap() self:RemoveComponent(camera) self.camera = nil end
		
		--self:SetUpdating(false)
		hook.Remove(EVENT_GLOBAL_PREDRAW, "shadowmapupdate"..tostring(seed))
	end 
end
function ENT:UpdatePos() 
	local c = GetCamera()
	if not IsValidEnt(self) or not self.camera then 
		hook.Remove(EVENT_GLOBAL_PREDRAW, "shadowmapupdate"..tostring(self.seed))
	else
		--self:SetPos(Vector(0,0,0)) 
		--self:SetAng(Vector(0,0,0))
		self:SetParent(c:GetParent()) 
		 
		
		local light = self.light
		if light then 
			self.camera:SetLight(light) 
		end
		
		
		self.camera:RequestDraw() 
	end
end















































--[[
--CLIENT ONLY

function ENT:Init()  
	self:SetSpaceEnabled(false) 
	self:SetDonotsave(true) 
	self:SetSizepower(1000)
end

function ENT:Spawn()   
	local seed = self:GetSeed()
	hook.Add("settings.changed","shadowmap.update."..tostring(seed),function()
		self:UpdateShadowMap()
	end)
	self:UpdateShadowMap()
end
function ENT:UpdateShadowMap()

	local shadows_enabled = settings.GetBool("engine.shadowsenabled",true)  
	if shadows_enabled then
		local shadow_size = settings.GetNumber("engine.shadowssize",1024) 
		
		local cc = self.cc or ents.CreateCamera()
		cc:SetParent(self) 
		cc:Spawn()
		self.cc = cc  
		
		local seed = self:GetSeed()
		self.seed = seed
		--self.target or 
		local target = CreateRenderTarget(shadow_size,shadow_size,"@shadow"..tostring(seed)..":Texture2D",1)
		self.target = target
		 
		local camera = self.camera or self:AddComponent(CTYPE_CAMERA) 
		camera:SetCamera(cc)
		camera:SetRenderTarget(0,target)
		camera:SetTargetTech("shadow")
		camera:RequestDraw()
		self.camera = camera 
		
		
		--self:SetUpdating(true)
		hook.Add("main.predraw", "shadowmapupdate"..tostring(seed), function() self:UpdatePos() end)
	else
		local cc = self.cc 
		local target = self.target
		local camera = self.camera
		
		if cc then cc:Despawn() self.cc = nil end
		if target then target:Unload() self.target = nil end
		if camera then camera:UnsetShadowMap() self:RemoveComponent(camera) self.camera = nil end
		
		--self:SetUpdating(false)
		hook.Remove("main.predraw", "shadowmapupdate"..tostring(seed))
	end 
end
function ENT:UpdatePos() 
	local c = GetCamera()
	if not IsValidEnt(self) then 
		hook.Remove("main.predraw", "shadowmapupdate"..tostring(self.seed))
	else
		local p = self:GetParent()
		local cp = c:GetParent()
		if cp~=nil then
			while cp:HasFlag(FLAG_ACTOR) do
				cp = cp:GetParent()
			end
			if(cp~=p)then
				self:SetParent(cp)
				p = cp
				--MsgN("cp ",self, " to ",cp)
			end
			
			
			
			
			local light = self.light
			if light then
				local dir = p:GetLocalCoordinates(light):Normalized()
				local cpos = p:GetLocalCoordinates(c)--p:GetLocalCoordinates(c) 
				self:SetPos(cpos +dir/p:GetSizepower()*1000)--*10
				self:LookAt(-dir)
				local sc = self.camera
				
				
				if sc then
					
					local player = LocalPlayer()
					if player and player.model then 
						sc:AddForceEnabled(player.model) 
						local spparts = player.spparts
						local equipment = player.equipment
						if spparts then
							for k,v in pairs(spparts) do
								sc:AddForceEnabled(v.model)
							end
						end
						if equipment then
							for k,v in pairs(equipment) do
								if v.ent then 
									sc:AddForceEnabled(v.ent.model)
								end
							end
						end
					end
					
					sc:RequestDraw()
				end
			end
			
		end
	end
end
]]

