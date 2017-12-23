
function SpawnMirror(ent,pos)
	local e = ents.Create("rt_mirror")   
	e:SetParent(ent)
	if pos then e:SetPos(pos) end
	e:Spawn()
	return e
end

function ENT:Init()  
	self:SetSpaceEnabled(false) 
	self:SetSizepower(1000)
	if CLIENT then
		self.enabled = settings.GetBool("engine.mirrorsenabled",true)  
		hook.Add("settings.changed","mirror.update."..tostring(seed),function() 
			self:_UpdateEnabled()  
		end) 
	end
end

function ENT:Spawn()  
	local cc = ents.CreateCamera()
	cc:SetParent(self) 
	cc:Spawn()
	local world = matrix.Scaling(Vector(-1,1,1)) * matrix.Scaling(0.75*0.001) * matrix.Rotation(-90,0,0)
	
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel("lift/lift_mirror.smd")   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world)
	
	
	local rparam = render.RenderParameters()
	rparam:SetCullMode(CULLMODE_FRONT)
	rparam:SetDrawSurfaces(false)
	--rparam:SetDrawSprites(false)
	
	local rcamera = self:AddComponent(CTYPE_CAMERA) 
	rcamera:SetCamera(cc)
	rcamera:SetParameters(rparam)
	
	self.rparam = rparam 
	self.rcamera = rcamera 
	self.cc = cc 
	self:SetScale(Vector(-1,1,1))
	
	if CLIENT then
		local vsize = GetViewportSize()  
		local rt = CreateRenderTarget(vsize.x,vsize.y,"@mirrorrt:Texture2D")
		self.rt = rt
		hook.Add("window.resize","updatemirror",function() 
			local cm = GetCamera()
			local vsize = GetViewportSize()  
			ResizeRenderTarget(rt, vsize.x,vsize.y) 
			self.cc:SetAspectRatio(cm:GetAspectRatio()) 
			self.cc:SetFOV(cm:GetFOV()) 
		end)
		local cm2 = GetCamera()
		self.cc:SetAspectRatio(cm2:GetAspectRatio()) 
		
		
		
		
		
		rcamera:SetPreDrawCallback(function()
			local c = GetCamera()  
			local ll = (c:GetMatrixAng()*self:GetLocalSpace(c:GetParent())*matrix.Rotation(Vector(0,180,0))):Mirrored(Vector(1,0,0),0) 
			cc:SetPos( self:GetLocalCoordinates(c)*Vector(1,1,-1))--+Vector(0,0,-6*1*0.001)
			cc:SetAng(ll)  
			local n = Vector(0,0,1)
			local d = n:Dot(cc:GetPos())
			rparam:SetClipPlane(true,n,d)
		end) 
		
		
		
		
		rcamera:SetRenderTarget(0,self.rt)
		rcamera:RequestDraw()
		
		--model:SetMaterial("textures/target/mirrorrt.json")
		--self:SetUpdating(true,15)
		self:_UpdateEnabled()
	end
	
	local light = self:AddComponent(CTYPE_LIGHT)  
	light:SetColor(Vector(1,1,1))
	light:SetBrightness(1) 
	self.light = light
end
function ENT:Despawn() 
	if CLIENT then
		hook.Remove("window.resize","updatemirror")
		hook.Remove("settings.changed","mirror.update."..tostring(seed)) 
		hook.Remove("main.postcontroller","mirrorupdate"..tostring(seed))
	end
end
function ENT:_UpdateEnabled()
	local model = self.model
	if model then
		local enabled = settings.GetBool("engine.mirrorsenabled",true)  
		if enabled then
			model:SetMaterial("textures/target/mirrorrt.json")
			local cam = GetCamera()
			self.cc:SetFOV(cam:GetFOV())  
			hook.Add("main.postcontroller","mirrorupdate"..tostring(seed), function() self:UpdatePos() end)
		else
			model:SetMaterial("textures/debug/black.json")
			hook.Remove("main.postcontroller","mirrorupdate"..tostring(seed))
		end
	end
end
function ENT:UpdatePos()  
	--self:SetUpdating(true,15)
	local c = GetCamera()  
	---local cc = self.cc
	local rc = self.rcamera
	---local rp = self.rparam 
	---c:UpdateWorld()
	---
	---local ll = (c:GetMatrixAng()*self:GetLocalSpace(c:GetParent())*matrix.Rotation(Vector(0,180,0))):Mirrored(Vector(1,0,0),0)
	-----local ll = (c:GetMatrixAng()*matrix.Scaling(Vector(-1,1,-1))*self:GetLocalSpace(c:GetParent())*matrix.Rotation(Vector(0,180,0))):Mirrored(Vector(1,0,0),0)
	---
	---cc:SetPos( self:GetLocalCoordinates(c)*Vector(1,1,-1))--+Vector(0,0,-6*1*0.001)
	---cc:SetAng(ll) 
	---local n = Vector(0,0,1)
	---local d = n:Dot(cc:GetPos())
	---rp:SetClipPlane(true,n,d)
	
	local player = LocalPlayer()
	if player and player.model then 
		rc:AddForceEnabled(player.model) 
		local spparts = player.spparts
		local equipment = player.equipment
		if spparts then
			for k,v in pairs(spparts) do
				rc:AddForceEnabled(v.model)
			end
		end
		if equipment then
			for k,v in pairs(equipment) do
				if v.ent then 
					rc:AddForceEnabled(v.ent.model)
				end
			end
		end
	end
	
	rc:RequestDraw()
	
	 
	MIRROR = self
end
function ENT:SetWorld(m)
	WMIR = m
	
	local grp = render.GlobalRenderParameters() 
	local srp = self.rparam
	--grp:SetCullMode(CULLMODE_FRONT)
	srp:SetCullMode(CULLMODE_FRONT)  
	if m then
		grp:SetCullMode(CULLMODE_FRONT)
		WMUL = -1
	else
		grp:SetCullMode(CULLMODE_BACK)
		WMUL = 1
	end
end 