
local rdtex = LoadTexture("space/star_sprites.png")

function ENT:Init()   
end

function ENT:Spawn(c) 
	local scolor = self.color or self:GetParameter(VARTYPE_COLOR) or Vector(1,1,1)
	local brightness = self:GetParameter(VARTYPE_BRIGHTNESS) or 1
	self.color = scolor

	local light = self:AddComponent(CTYPE_LIGHT)  
	light:SetColor(scolor)
	light:SetBrightness(10) 
	self.light = light
	
	
	local model = self:AddComponent(CTYPE_MODEL)  
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetRenderOrder(RORDER_EFFECT)
	model:SetModel("engine/csphere_36.json") 
	model:SetMaterial("textures/debug/white.json") 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED) 
	model:SetMatrix(matrix.Scaling(2))
	model:SetFullbright(true)
	model:SetBrightness(brightness)
	model:SetFadeBounds(0,99999,0)  
	if self.hasflare then 
		model:SetFlare(true)
		model:SetColor(scolor)
	else
		model:SetColor(Vector(1,1,1))
	end
	self.model =  model

	local particlesys = self:AddComponent(CTYPE_PARTICLESYSTEM) 
	particlesys:SetRenderGroup(RENDERGROUP_LOCAL)
	particlesys:SetNodeMode(false)
	particlesys:AddNode(1) 
	particlesys:SetNodeStates(1,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_READ) 
	particlesys:SetTexture(1,rdtex)
	particlesys:AddParticle(1,Vector(0,0,0),scolor,10,0) 
	
	self.particlesys = particlesys 
	self:SetSpaceEnabled(false) 
	
	--self:AddEventListener(EVENT_USE,"use_event",function(a,b,c,d,e)
	--	MsgN(self," is used by: ",a,b,c,d,e)
	--end)
	--self:AddFlag(FLAG_USEABLE)
end


function ENT:SetColor(c) 
	self:SetParameter(VARTYPE_COLOR,c)
	self.light:SetColor(c) 
	self.particlesys:AddParticle(1,Vector(0,0,0),c,10,0) 
end
function ENT:SetBrightness(c) 
	self:SetParameter(VARTYPE_BRIGHTNESS,c)
	self.light:SetBrightness(c) 
end 
function ENT:TurnOff()
	self.Fstate = false
	self.particlesys:Enable(false)
	self.light:Enable(false)
	self.model:Enable(false) 
end
function ENT:TurnOn()
	self.Fstate = true
	self.particlesys:Enable(true)
	self.light:Enable(true)
	self.model:Enable(true) 
end
function ENT:Toggle()
	local astate = self.Fstate  
	if astate then 
		astate = false
		self.Fstate = false 
	else 
		astate = true 
		self.Fstate = true
	end 
	--MsgN("TOGGLE! ",self.Fstate,"-",astate)  
	self.particlesys:Enable(astate)
	self.light:Enable(astate) 
	self.model:Enable(astate) 
end
 