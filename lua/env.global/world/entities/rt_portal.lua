 
function ENT:Init()  
	self:SetSpaceEnabled(false) 
	self:SetSizepower(1000)
	if CLIENT then
		self.enabled = settings.GetBool("engine.mirrorsenabled",true)  
	end
end

if CLIENT then
	glob_portal_tex_a = glob_portal_tex_a or false
	glob_portal_tex_b = glob_portal_tex_b or false

end

function ENT:Spawn()  
	local world = 
		matrix.Scaling(Vector(1,1,1)) 
		 * matrix.Scaling(0.75*0.001)
		 * matrix.Rotation(-90,0,0)
	
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel("lift/lift_mirror.stmd")   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,0.1,0)  
	model:SetMatrix(world)
	
	self:SetScale(Vector(1,1,1))
	if CLIENT then
	
		local cc = ents.CreateCamera()
		cc:SetParent(self) 
		cc:Spawn()

		local rparam = render.RenderParameters()
		rparam:SetCullMode(CULLMODE_FRONT)
		rparam:SetDrawSurfaces(false)
		--rparam:SetDrawSprites(false)
		
		local rcamera = self:AddComponent(CTYPE_CAMERA) 
		rcamera:SetCamera(cc) 
		rcamera:SetParameters(rparam)
		rcamera:AddForceDisabled(model)

		self.rparam = rparam 
		self.rcamera = rcamera 

		self.cc = cc 
		
		local vsize = GetViewportSize()  
		local rtid = "@portalrt".. tostring(self:GetSeed())
		local rt = CreateTexture(vsize.x,vsize.y,10,rtid)--, "@portalrt" --CreateRenderTarget(vsize.x,vsize.y,"@portalrt")
		self.rt = rt
		self.rtid = rtid 
		local basemat = LoadMaterial("textures/target/portalrt.json")
		self.mat =CopyMaterial(basemat)
		ModMaterial(self.mat,{  
			g_MeshTexture_e =  rtid, 
		})
		MsgN("new portal texture: ",rtid)
		self:Hook("window.resize","portalupdate"..rtid,function() 
			local cm = GetCamera()
			local vsize = GetViewportSize()  
			ResizeRenderTarget(rt, vsize.x,vsize.y) 
			self.cc:SetAspectRatio(cm:GetAspectRatio()) 
			self.cc:SetFOV(cm:GetFOV()) 
		end)
		
		self:Hook("settings.changed","portal.update"..rtid,function() 
			self:_UpdateEnabled()  
		end) 
		self:Hook("camera.update","portal.update"..rtid,function() 
			self:_UpdateEnabled()  
		end) 

		local cm2 = GetCamera()
		self.cc:SetAspectRatio(cm2:GetAspectRatio()) 
		
		 
		
		
		
		rcamera:SetPreDrawCallback(function()
			self:PreDraw(GetCamera(),cc,rparam) 
		end) 
		
		rcamera:SetScreenSpace(true)
		rcamera:SetScreenSpaceTarget(self.rt)
		
		
		--rcamera:SetRenderTarget(0,self.rt)
		rcamera:RequestDraw()
		
		--model:SetMaterial("textures/target/mirrorrt.json")
		--self:SetUpdating(true,15)
		self:_UpdateEnabled()
	end
	if self.mirrorlight~=nil then
		local light = self:AddComponent(CTYPE_LIGHT)  
		light:SetColor(Vector(1,1,1))
		light:SetBrightness(0.1) 
		self.light = light
	end
	--self:AddTag(TAG_USEABLE)
end
function ENT:Despawn() 
	self:DDFreeAll() 
end
function ENT:_UpdateEnabled()
	local model = self.model
	if model then
		local enabled = settings.GetBool("engine.mirrorsenabled",true)  
		if enabled then
			model:SetMaterial(self.mat)
			local cam = GetCamera()
			self.cc:SetFOV(cam:GetFOV())  
			self.cc:SetAspectRatio(cam:GetAspectRatio())  
			self:Hook("main.postcontroller","portalupdate", function() self:UpdatePos() end)
		else
			model:SetMaterial("textures/debug/black.json")
			self:UnHook("main.postcontroller","portalupdate")
		end
	end
end
function ENT:PreDraw(camera,scamera,rparam) 
	local target = self.target  
	if target then
		local ll = (camera:GetMatrixAng()*target:GetLocalSpace(camera:GetParent())*matrix.Rotation(Vector(0,180,0))):Mirrored(Vector(1,0,0),0) 
		local lw = (self:GetLocalSpace(camera) * self:GetLocalSpace(target) )
		scamera:SetPos( lw:Position() )--+Vector(0,0,-6*1*0.001)
		scamera:SetAng(camera:GetMatrixAng() * self:GetMatrixAng() * self:GetLocalSpace(target) )   --*self:GetLocalSpace(camera:GetParent())
		local n = Vector(0,0,1)
		local d = n:Dot(scamera:GetPos())
		rparam:SetClipPlane(false,n,d)
	end
end
function ENT:UpdatePos()  
	--self:SetUpdating(true,15)
	local c = GetCamera()  
	---local cc = self.cc
	local rc = self.rcamera
	if not rc then return nil end
	
	local target = self.target
	local model = self.model
	if target then
		model:SetMaterial(self.mat)

	
		local player = LocalPlayer()
		if player and player.model then 
			rc:AddForceEnabled(player.model) 
			local spparts = player.spparts
			local equipment = player.equipment 
		end
		if LocalPlayer()==c:GetParent() then
			self:SetScale(LocalPlayer():GetScale()*Vector(-1,1,1))
		else
			self:SetScale(Vector(-1,1,1))
		end 
		rc:RequestDraw(self.model) 

	else 
		model:SetMaterial("textures/debug/black.json")
	end
	
	  
end
