TOOL.firedelay = 0.1
TOOL.title = "Spawner"
TOOL.selector = {"primitives/box.json","primitives/chbox.json","primitives/sphere.json","primitives/cylinder.json","primitives/cone.json"}
function TOOL:Fire(dir)
	local curmodel  = self.curmodel 
	
	local nft = self.nextfiretime
	local ct = CurTime()
	local fd = self.firedelay
	if ct > nft then 
		self.nextfiretime = ct + fd
		
		local parentphysnode = cam:GetParentWithComponent(CTYPE_PHYSSPACE)
		if parentphysnode then 
		local lw = parentphysnode:GetLocalSpace(cam) 
			local sz = parentphysnode:GetSizepower()
			local forw = lw:Forward()--:TransformC(matrix.AxisRotation(lw:Right(),math.random(-30,30)))
			 
			local tr = GetCameraPhysTrace()
			if tr and tr.Hit then 
				self:SpawnProp(parentphysnode,tr.Position+tr.Normal*(0.2/sz),
					curmodel ,1)
			end
		end
	end
	
end
function TOOL:AltFire(dir)
	local nft = self.nextfiretime
	local ct = CurTime()
	local fd = 0.5
	if ct > nft then 
		self.nextfiretime = ct + fd
		local curid = self.curid or 0
		curid = (curid + 1) % #self.selector
		local curmodel = self.selector[curid+1]
		MsgN("selected: ",tostring(curmodel))
		hook.Call("chat.msg.received", self, "selected: "..tostring(curmodel))
		self.curid = curid
		self.curmodel = curmodel
	end
end

function TOOL:SpawnProp(ent, pos, model, scale) 
	local nseed = (self.pseed or 1100) + 1
	self.pseed = nseed
	local prop = ents.Create("prop_physics") 
	prop:SetModel(model)
	prop:SetModelScale(scale)
	prop:SetSizepower(1) 
	prop:SetSpaceEnabled(false)
	prop:SetSeed(nseed)
	prop:SetParent(ent)
	prop:SetPos(pos) 
	prop:Create()  
	prop.phys:SetMass(100)
	
	
	local particlesys2 = prop:AddComponent(CTYPE_PARTICLESYSTEM2) 
	particlesys2:SetSpeed(1)
	particlesys2:SetRenderGroup(RENDERGROUP_LOCAL)
	particlesys2:SetBlendMode(BLEND_ADD) 
	particlesys2:SetRasterizerMode(RASTER_DETPHSOLID) 
	particlesys2:SetDepthStencillMode(DEPTH_READ)  
	 
	particlesys2:Set("particles/magic_model_aura_test.json")
	prop.particlesys2 = particlesys2 
	
	
end