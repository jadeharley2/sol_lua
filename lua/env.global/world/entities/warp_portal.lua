
local rdtex = LoadTexture("space/star_sprites.png")
function ENT:Spawn()
	 
	--self:AddEventListener(EVENT_TOUCH,"trigger",self.Touch)
	
	local scolor = Vector(0.02,0.3,1)
	
	local light = self:AddComponent(CTYPE_LIGHT)  
	light:SetColor(scolor)
	light:SetBrightness(1000000) 
	self.light = light
	
	local particlesys = self:AddComponent(CTYPE_PARTICLESYSTEM) 
	particlesys:SetRenderGroup(RENDERGROUP_PLANET)
	particlesys:SetNodeMode(false)
	particlesys:AddNode(1)
	particlesys:SetNodeStates(1,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_ENABLED) 
	particlesys:SetTexture(1,rdtex)
	particlesys:AddParticle(1,Vector(0,0,0),scolor,0.5,0) 
	
	self.particlesys = particlesys
	
end

function ENT:Touch(eid,ent) 
	MsgN("TOUCH EVENT    ",self," - ", ent)
	local target = self.target
	if target and self:GetParent()~=target then
		--ent:SetPos(Vector(0,0,0))
		self:SetParent(target)
		self:SetPos(Vector(0,0,0))
	end
	if self.OnTouch then
		self.OnTouch(self,ent)
	end
end