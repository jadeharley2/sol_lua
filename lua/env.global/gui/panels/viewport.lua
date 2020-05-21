PANEL.isviewport = true

function PANEL:Init()  

	local rendernode = ents.Create()
	self.rendernode = rendernode
	
	local camera = rendernode:AddComponent(CTYPE_CAMERA) 
	self.rcam = camera

	
end
function PANEL:Initialize(id,w,h)
	self.id = tostring(id)
	self:SetSize(w,h) 
	self.rtname = "@viewport."..self.id
	self.rt = CreateRenderTarget(w,h,self.rtname)
	self.rcam:SetRenderTarget(0,self.rt)
	self:SetTexture(self.rt)
end
function PANEL:InitializeFromTexture(id,texname,camera)
	self.cam = camera
	self.cameraupdate = IsValidEnt(camera) 
	self.id = tostring(id)
	self:SetTexture(texname) 
end 
function PANEL:MouseEnter()
	if self.id then
		hook.Add(EVENT_GLOBAL_UPDATE,"viewport."..self.id,function()
			self:Update() 
		end)
	end
end
function PANEL:MouseExit()
	if self.id then
		hook.Remove(EVENT_GLOBAL_UPDATE,"viewport."..self.id)
	end
end

function PANEL:Resize()
	if self.rt then
		local vsize = self:GetSize()
		ResizeRenderTarget(self.rt, vsize.x,vsize.y) 
	end
	self:UpdateCamera()-- if self.cameraupdate then self:UpdateCamera() end
end
function PANEL:SetCamera(cam,cameraupdate)
	self.cam = cam 
	self.rcam:SetCamera(cam)
	self.cameraupdate = cameraupdate or self.cameraupdate
	if self.cameraupdate then self:UpdateCamera() end
	self.rcam:RequestDraw()
end
function PANEL:UpdateCamera()
	local cam = self.cam or GetCamera()
	local vsize = self:GetSize()
	local aspect = vsize.x/vsize.y 
	cam:SetAspectRatio(aspect) 
	hook.Call("camera.update")
end
function PANEL:Update()
	if panel.GetTopElement()==self then
		if input.rightMouseButton() then
			local vsize = self:GetSize()
			local pos = vsize/2
			
			local size = GetViewportSize() 
			local center = size / 2
			center = Point(math.floor( center.x),math.floor(center.y))

			if global_controller.UpdateCamRotation then 
				global_controller:UpdateCamRotation(vsize,center,0,0)
			end
		end
	end
end
function PANEL:EnableRendering(b)
	if b then
		hook.Add(EVENT_GLOBAL_UPDATE,"viewport."..self.id,function()
			self.rcam:RequestDraw() 
		end)
	else
		hook.Remove(EVENT_GLOBAL_UPDATE,"viewport."..self.id)
	end
end
function PANEL:MouseDown(c)
	local onclick = self.OnClick
	if onclick then onclick(c) end
end