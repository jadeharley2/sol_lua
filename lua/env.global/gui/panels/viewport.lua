 
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
function PANEL:Resize()
	local vsize = self:GetSize()
	if self.rt then
		ResizeRenderTarget(self.rt, vsize.x,vsize.y) 
	end
	if self.cameraupdate then self:UpdateCamera() end
end
function PANEL:SetCamera(cam,cameraupdate)
	self.cam = cam 
	self.rcam:SetCamera(cam)
	self.cameraupdate = cameraupdate or self.cameraupdate
	if self.cameraupdate then self:UpdateCamera() end
	self.rcam:RequestDraw()
end
function PANEL:UpdateCamera()
	local cam = self.cam 
	local vsize = self:GetSize()
	local aspect = vsize.x/vsize.y 
	cam:SetAspectRatio(aspect) 
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