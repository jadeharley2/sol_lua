
function SpawnRlayer(ent,pos)
	local e = ents.Create("rt_layer")   
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
		self:Hook("settings.changed","layer.update",function() 
			self:_UpdateEnabled()  
		end) 
	end
end

function ENT:Spawn()  

	local world = matrix.Scaling(Vector(-1,1,1)) * matrix.Scaling(0.75*0.001) * matrix.Rotation(-90,0,0)
	
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel("lift/lift_mirror.stmd")   
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
	rcamera:SetCamera(GetCamera()) 
	rcamera:SetParameters(rparam)
	
	self.rparam = rparam 
	self.rcamera = rcamera  
	self:SetScale(Vector(-1,1,1))
	
	if CLIENT then
		local vsize = GetViewportSize()  
		local rt = CreateRenderTarget(vsize.x,vsize.y,"@mirrorrt:Texture2D")
		self.rt = rt
		self:Hook("window.resize","updatelayer",function()    
			local vsize = GetViewportSize()  
			ResizeRenderTarget(rt, vsize.x,vsize.y)  
		end) 
		
		
		
		
		
		--rcamera:SetPreDrawCallback(function() 
		--	local n = Vector(0,0,1)
		--	local d = n:Dot(cc:GetPos())
		--	rparam:SetClipPlane(true,n,d)
		--end) 
		
		
		
		
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
	self:DDFreeAll() 
end
function ENT:_UpdateEnabled()
	local model = self.model
	if model then
		local enabled = settings.GetBool("engine.mirrorsenabled",true)  
		if enabled then
			model:SetMaterial("textures/target/mirrorrt.json") 
			self:Hook("main.postcontroller","mirrorupdate", function() self:UpdatePos() end)
		else
			model:SetMaterial("textures/debug/black.json")
			self:UnHook("main.postcontroller","mirrorupdate")
		end
	end
end   
function ENT:UpdatePos()   
	local c = GetCamera()   
	local rc = self.rcamera  
	self.rparam:SetCullMode(CULLMODE_BACK)
	
	local n = self:Forward()-- Vector(0,0,1)
	local d = n:Dot(-self:GetPos()+c:GetPos())-0.000001
	self.rparam:SetClipPlane(true,n,d)
	rc:RequestDraw()  
end