
function PH_RELOAD()
	dofile("data/lua/env.global/autorun/physcam.lua") 
end
 
function PH_TOGGLE()
	self = GetCamera() 
	if self.isphys then
		--self:RemoveComponents(CTYPE_MODEL) 
		self.phys =nil
		self:RemoveComponents(CTYPE_PHYSOBJ) 
		self.isphys = nil
	else 
		--local model = self:AddComponent(CTYPE_MODEL)  
		--model:SetRenderGroup(RENDERGROUP_STARSYSTEM)
		--model:SetModel("engine/csphere_36.SMD") 
		--model:SetTexture("data/textures/debug/white.png") 
		--model:SetBlendMode(BLEND_OPAQUE) 
		--model:SetRasterizerMode(RASTER_DETPHSOLID) 
		--model:SetDepthStencillMode(DEPTH_ENABLED) 
		--model:SetMatrix(matrix.Scaling(2))
		--model:SetFullbright(true)
		--model:SetBrightness(1)
		--model:SetFadeBounds(0,99999,0)  
		--
		--self.model =  model
	 
		local world = matrix.Scaling(2)
		
		 
		local phys = self:AddComponent(CTYPE_PHYSOBJ) 
		phys:SetShape("engine/gsphere_2.SMD",world* matrix.Scaling(0.5))
		phys:SetMass(100) 
		phys:UpdateSpace()
		--model:SetMatrix(world*matrix.Translation(-phys:GetMassCenter()))
		self.phys = phys
		self.isphys = true	
	end
end

function pat()
	self = GetCamera()  
	local prt = self:GetParent()
	local actor = ents.Create("base_actor")
	actor:SetSizepower(1000)
	actor:SetParent(prt)
	actor:Spawn()
	actor:SetPos(self:GetPos())
	return actor
end


function pat2()
	self = GetCamera():GetParent()
	local prt = self:GetParent()
	local actor = ents.Create("base_actor")
	actor:SetSizepower(1)
	actor:SetParent(prt)
	actor:Spawn()
	actor:SetPos(self:GetPos())
	return actor
end

