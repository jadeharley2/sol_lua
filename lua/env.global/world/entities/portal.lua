--lua_run TEST_CGM(GetCamera():GetParent())
function PPM_P(parent,pos,target,tpos)

	local m =  ents.Create("portal")
	m:SetParent( parent)
	m:SetSizepower(0.76) 
	m:SetSpaceEnabled(false) 
	m:SetPos(pos)
	m.target = target
	m.target_pos = tpos
	m:Spawn()
	--GetCamera():SetParent(m.system)
	return m
end

function ENT:Init()  
end

function ENT:Spawn()
 
	
	
	
	local holoBack = self:AddComponent(CTYPE_MODEL) 
	holoBack:SetRenderGroup(RENDERGROUP_LOCAL)
	holoBack:SetModel("engine/gsphere_24_inv.SMD") 
	holoBack:SetMaterial("textures/debug/brightrim.json") 
	holoBack:SetBlendMode(BLEND_SUBTRACT) 
	holoBack:SetRasterizerMode(RASTER_DETPHSOLID) 
	holoBack:SetDepthStencillMode(DEPTH_ENABLED)    
	holoBack:SetBrightness(1)
	holoBack:SetMatrix(matrix.Scaling(3.85))
	holoBack:SetFadeBounds(0.000001,99999,0.0000005)    
	
	 
	local holo = self:AddComponent(CTYPE_MODEL) 
	
	local light = self:AddComponent(CTYPE_LIGHT)  
	light:SetColor(Vector(0.1,0.2,0.9))
	light:SetBrightness(10) 
	self.light = light
	
	self:AddEventListener(EVENT_USE,"use_event",function(self,user)
		MsgN(self," is used by aaa: ",user)
		user:SetParent(self.target)
		user:SetPos(self.target_pos)
	end)
	self:AddTag(TAG_USEABLE)
	
	
	if CLIENT then
		local renderer =self:AddComponent(CTYPE_CAMERA) 
		self.renderer = renderer

		 
		local cam =  ents.CreateCamera()
		self.cam = cam
		cam:SetSpaceEnabled(false) 
		cam:SetParent(self.target)
		cam:Spawn()
	
		local vsize = GetViewportSize()  
		local rt = CreateRenderTarget(vsize.x,vsize.y,"@portalrt:Texture2D")
		self.rt = rt
		hook.Add("window.resize","updatert_portal",function() 
			local cm = GetCamera()
			local vsize = GetViewportSize()  
			ResizeRenderTarget(rt, vsize.x,vsize.y) 
			self.cam:SetAspectRatio(cm:GetAspectRatio()) 
		end)
		
		renderer:SetCamera(cam)
		renderer:SetRenderTarget(1,rt)
		renderer:RequestDraw(holo)
		
		self:SetUpdating(true)
	end
	
	
	holo:SetRenderGroup(RENDERGROUP_LOCAL)
	holo:SetModel("engine/gsphere_24_inv.SMD") 
	holo:SetMaterial("textures/target/portalrt.json") 
	holo:SetBlendMode(BLEND_ADD) 
	holo:SetRasterizerMode(RASTER_DETPHSOLID) 
	holo:SetDepthStencillMode(DEPTH_ENABLED)    
	holo:SetBrightness(1)
	holo:SetMatrix(matrix.Scaling(3.8))
	holo:SetFadeBounds(0.000001,99999,0.0000005)   
	self.holo = holo
	
end

function ENT:Think()
	--local td = (self.td or 0) + 1
	--self.td = td
	--if td > 2 then
		local realcam = GetCamera()
		local rcpr = realcam:GetParent()
		local sz = rcpr:GetSizepower()
		local ls =self:GetLocalSpace(realcam)
		local ptc = ls:Position() --realcam:GetPos() - self.holo_center 
		self.cam:SetPos(ptc/750/10+self.target_pos)--*self.holo_scale--/sz
		--self.cam:CopyAng(realcam)
		self.cam:SetAng(ls)
		--self.origin:SetPos(self.holo_center)
		self.renderer:RequestDraw(self.holo)
		--self:SetPos(self:GetPos()+Vector(0,1,0)/1000000)
		self.td = 0
	--end
end
