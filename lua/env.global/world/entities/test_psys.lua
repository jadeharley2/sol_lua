 
function SpawnTPS(ent,pos)
	local e = ents.Create("test_psys")   
	e:SetParent(ent)
	if pos then e:SetPos(pos) end
	e:Spawn()
	return e
end

function ENT:Spawn()  

	local particlesys = self:AddComponent(CTYPE_PARTICLESYSTEM) 
	particlesys:SetRenderGroup(RENDERGROUP_LOCAL)
	particlesys:SetBlendMode(BLEND_ADD) 
	particlesys:SetRasterizerMode(RASTER_DETPHSOLID) 
	particlesys:SetDepthStencillMode(DEPTH_ENABLED) 
	particlesys:SetNodeMode(true)
	--particlesys:AddNode(1) 
	--particlesys:SetNodeStates(1,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_ENABLED) 
	--particlesys:SetTexture(1,rdtex)
	--particlesys:AddParticle(1,Vector(0,0,0),scolor,10,0) 
	
	self.particlesys = particlesys
	--self:SetUpdating(true)
	self:SetSpaceEnabled(false) 
	self:SetSizepower(2)
	
	for k=1,20 do
		local planet = ents.Create()
		planet:SetParent(self)
		planet:SetPos(Vector(0.5,0,0))
		planet:SetSizepower(1)
		local orbit = planet:AddComponent(CTYPE_ORBIT)
		orbit:SetOrbit(0.3,
			0.1*math.random(1,100)/40,
			math.random(-180,180)/90,
			math.random(-180,180)/90,
			math.random(-180,180)/90,
			math.random(-180,180)/90,
			10000)
		local par = planet:AddComponent(CTYPE_PARTICLE)
		local rnd = math.random(0,100)
		if rnd<30 then
			par:SetColor(Vector(0.2,1.2,0.6)*0.008) 
			par:SetSize(0.08)
		elseif rnd<80 then
			par:SetColor(Vector(0.2,1.2,0.6)*0.03) 
			par:SetSize(0.02)
		else
			par:SetColor(Vector(0.2,1.2,0.6)*0.2) 
			par:SetSize(0.007)
		end
		 
		planet:Spawn()
	end
end 

--function ENT:Think()  

--end
	