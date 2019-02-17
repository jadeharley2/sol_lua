
function SpawnRTCAM(target,ent,pos)
	local e = ents.Create("rt_camera")  
	e.target = target
	e:SetParent(ent)
	if pos then e:SetPos(pos) end
	e:Spawn()
	return e
end

function ENT:Init()  
	self:SetSpaceEnabled(false) 
	self:SetSizepower(1000)
end

function ENT:Spawn()  
	local cc = ents.CreateCamera()
	cc:SetParent(self) 
	cc:Spawn()
	
	local camera = self:AddComponent(CTYPE_CAMERA) 
	camera:SetCamera(cc)
	camera:SetRenderTarget(0,self.target)
	camera:RequestDraw()
	self.camera = camera 
	self.cc = cc 
	
	self:SetUpdating(true)
end

function ENT:Think() 
	self.camera:RequestDraw()
end