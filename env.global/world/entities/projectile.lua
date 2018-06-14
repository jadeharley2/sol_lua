
local rdtex = LoadTexture("space/star_sprites.png")
function SpawnProjectile(parent,pos,vel,radius,color,glow,model)
	local e = ents.Create("projectile") 
	if model then e:SetParameter(VARTYPE_MODEL,model) end
	local ang = matrix.LookAt(Vector(0,0,0),vel:Normalized()*Vector(1,1,1),Vector(0,-1,0))
	e.radius = radius 
	e.color = color
	e.glow = glow
	e:SetSizepower(1)
	e:SetParent(parent)
	e:SetPos(pos) 
	e:SetAng(ang)
	e:Spawn() 
	e:SetAng(ang)
	e:SetPos(pos) 
	e.phys:ApplyImpulse(vel)
	return e
end


function ENT:Init() 
	self:SetSpaceEnabled(false) 
end

function ENT:Spawn() 
	local scolor = self.color or self:GetParameter(VARTYPE_COLOR) or Vector(1,1,1)
	local smodel = self:GetParameter(VARTYPE_MODEL) or "engine/csphere_36.stmd"
	local brightness = 1
	self.color = scolor
	local radius = self.radius or 0.2
	local glow = self.glow 
	
	 
	local model = self:AddComponent(CTYPE_MODEL)  
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetRenderOrder(RORDER_EFFECT)
	model:SetModel(smodel) 
	--model:SetMaterial("textures/debug/white.json") 
	if glow then
		model:SetBlendMode(BLEND_ADD) 
		model:SetFullbright(true)
	else
		model:SetBlendMode(BLEND_OPAQUE) 
	end
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED) 
	model:SetMatrix(matrix.Scaling(radius))
	model:SetBrightness(brightness)
	model:SetFadeBounds(0,99999,0)  
	if self.hasflare then 
		model:SetFlare(true)
		model:SetColor(scolor)
	else
		model:SetColor(Vector(1,1,1))
	end
	self.model =  model

	if glow then
		local particlesys = self:AddComponent(CTYPE_PARTICLESYSTEM) 
		particlesys:SetRenderGroup(RENDERGROUP_LOCAL)
		particlesys:SetNodeMode(false)
		particlesys:AddNode(1) 
		particlesys:SetNodeStates(1,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_READ) 
		particlesys:SetTexture(1,rdtex)
		particlesys:AddParticle(1,Vector(0,0,0),scolor*brightness,radius,0) 
		particlesys:SetMaxRenderDistance(1000)
		
		self.particlesys = particlesys 
		
		local light = self:AddComponent(CTYPE_LIGHT)  
		light:SetColor(scolor)
		light:SetBrightness(radius) 
		self.light = light
	end
	
	local phys = self:AddComponent(CTYPE_PHYSOBJ) 
	phys:SetShape("engine/gsphere_2.SMD", matrix.Scaling(1))
	phys:SetMass(1)  
	phys:SetupCallbacks() 
	 
	
	self.phys = phys
	
	
	self:AddNativeEventListener(EVENT_PHYSICS_CONTACT_CREATED,"event",self.Hit)
	--self:AddEventListener(EVENT_USE,"use_event",function(self,a,b,c,d,e)
	--	MsgN(self," is used by: ",a,b,c,d,e)
	--end)
	--self:AddFlag(FLAG_USEABLE)
end
function ENT:Hit(a,collider,pos,normal,depth)  
	local OnHit = self.OnHit
	if OnHit then 
		if not self:OnHit(collider) then
			self:Despawn()
		else 
			if not self.hitcompleted  then
				local par = self:GetParent()
				if par and collider and collider ~=par then
					local lp = pos;--+self:Forward()*(self.radius*10/par:GetSizepower()) -- normal*depth
					self:SetPos(lp)
					self.phys:Disable()
					self:SetPos(lp)
					--local lp = collider:GetLocalCoordinates(self)
					--self:SetParent(collider)
					--self:SetPos(lp) 
					MsgN("hit! ",collider,pos,normal,depth)
				end
				self:EmitSound("events/hit/"..table.Random({"arrow-01.ogg","arrow-02.ogg","arrow-03.ogg","arrow-04.ogg","arrow-05.ogg","arrow-06.ogg"}),1,1)
				
				self.hitcompleted = true
			end
		end
	else
		self:Despawn()
	end
	
end 

ENT._typeevents = { 
	--[EVENT_PHYSICS_CONTACT_CREATED] = {networked = true, f = ENT.Hit},
} 

 