

function SpawnDT(model,parent,pos,ang,sca)
	local e = ents.Create("use_door_teleport")
	--MsgN("lol"..model) 
	e:SetSizepower(1)
	e:SetParent(parent)
	e:SetModel(model) 
	if sca then e:SetModelScale(sca) end
	e:SetPos(pos) 
	e:SetAng(ang) 
	e:Spawn()
	e:SetAng(ang) 
	return e
end

--ENT.usetype = "enter"
ENT.info = "Door"
ENT._interact = {
	open={text="enter",action= function (self,user)
		self:Press(user)
	end},
}

function ENT:Init()  
	local phys = self:AddComponent(CTYPE_STATICCOLLISION)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.phys = phys
	self:SetSpaceEnabled(false)
	self:AddTag(TAG_PHYSSIMULATED)
	self:AddTag(TAG_USEABLE) 
	

	--phys:SetMass(10)  
	
end
function ENT:LoadModel() 
	local model_scale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	
	local model = self.model
	local world = matrix.Scaling(model_scale)-- * matrix.Rotation(-90,0,0)
	 
	local phys =  self.phys
	local amul = 80
	
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(self:GetParameter(VARTYPE_MODEL)) 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	model:SetMatrix(world)
	
	if(model:HasCollision()) then
		phys:SetShapeFromModel( world* matrix.Rotation(-90,0,0) ) 
	else
		phys:SetShape(mdl, world ) 
	end
	--phys:SetShape(phymodel,world * matrix.Scaling(1/amul) )
	--phys:SetMass(-1) 
	
	--model:SetMatrix( world* matrix.Translation(-phys:GetMassCenter()   ))
	
	--MsgN("model    "..tostring(phys:GetMassCenter()) )
end
function ENT:Load()
	self:LoadModel() 
	self:SetPos(self:GetPos())
end 
function ENT:Spawn()  
	self:LoadModel() 
	--self.phys:SoundCallbacks()
	--self.phys:SetMaterial("wood")
	
	local target = self:GetParameter(VARTYPE_CHARACTER)
	if target then
		local parts = string.split(target,":")
		if #parts > 1 then
			self.target = parts
			
			self.usetype = parts[2]
		else
			self.target = parts[1]
			
			self.usetype = parts[1] 
		end
		
	end
	
end
function ENT:SetModel(mdl)
	self:SetParameter(VARTYPE_MODEL,mdl) 
end
function ENT:SetModelScale(scale) 
	self:SetParameter(VARTYPE_MODELSCALE,scale)
end
--function ENT:Think()
--	--MsgN(self.phys:OnGround())
--	--if input.KeyPressed(KEYS_K) then
--		--self.phys:SetStance(STANCE_STANDING)
--		--self.phys:SetMovementDirection(Vector(100,0,100))
--		--self.phys:SetStandingSpeed(1000) 
--		--self.phys:SetAirSpeed(1000) 
--	--else
--	--	self.phys:SetMovementDirection(Vector(0,0,0))
--	--end
--end

--target variants
--entity - just teleport
--string - get by global name and if exists - teleport
--table {interior,name} - get interior - get entity by name - teleport
function GetAnchor(user,anchorname,ont,onf)
	engine.PausePhysics()
	local loader =user-- GetCamera()--
	--ents.Create() 
	--SetController("freecamera")
	local lpp = loader:GetPos()
	local lpa = loader:GetParent()
	--loader:SetSizepower(1)
	--loader:SetParent(LOBBY) 
	--loader:SetName("world_loader")
	--loader:Spawn()
	--AddOrigin(loader)
	local one = function()
		--RemoveOrigin(loader)
		--loader:Despawn()
		--MsgN("loader despawned")
		loader:SetParent(lpa)
		loader:SetPos(lpp)
		engine.ResumePhysics()
	end
	local ont2 = function()
		if ont then ont() end
		--one()
	end
	local onf2 = function()
		if onf then onf() end 
		one()
	end
	if (engine.SendToAnchor(loader,anchorname,ont2,onf2)) then 
		return true
	else
		one()
		return false
	end
	
end 


function ENT:SetTarget(t)
	self.target = t
	local ttype = type(target)
	if ttype=="string" then
		self.usetype = t
	elseif ttype =="table" then
		self.usetype = t
	else
		self.usetype = target:GetParent():GetName()
	end
end
function ENT:Press(user) 
	local target = self.target
	if target then
		local ttype = type(target)
		if ttype=="string" then
			local targetEnt = ents.GetByName(target)
			if targetEnt then
				self:DoEnter(user,targetEnt)
			else
				MsgInfo("door is locked!!")
			end
		elseif ttype =="table" then
		
			local targetEnt = ents.GetByName(target[2])
			if targetEnt then
				self:DoEnter(user,targetEnt)
			else
		
				local interior = GetInterior(target[1])
				if interior then
					local targetEnt = ents.GetByName(target[2])
					if targetEnt then
						self:DoEnter(user,targetEnt)
					else
						--MsgInfo("door is locked!"..tostring(interior))
						local anchor = GetAnchor(user,target[1],function(a)  
							local targetEnt = ents.GetByName(target[2])
							if targetEnt then 
								self:DoEnter(user,targetEnt)
								engine.ResumePhysics()
							else
								MsgInfo("unable to open door!")
							end 
						end,function()
							MsgInfo("door is damaged!")
						end)
						if not anchor then 
							MsgInfo("door got stuck!")
						end
					end
				else
					MsgInfo("idk..!")
				end
			end
		else
			self:DoEnter(user,target)
		end
	else
		MsgInfo("door has nothing behind it!") 
	end
end

function ENT:DoEnter(user,target)
	
	local ct = CurTime()
	local slastuse = self.lastuse or 0
	local tlastuse = target.lastuse or 0
	if slastuse+4<ct and tlastuse+4<ct then 
		local upar = user:GetParent()
		local tpar = target:GetParent()
		local sz = tpar:GetSizepower()
		MsgN("door open from ",upar," to ",tpar)
		user:SetParent(tpar)
		user:SetPos(target:GetPos()+Vector(0,1/sz,0)+target:Forward()/sz)
		--upar:Leave(user)
		tpar:Enter(user)
		MsgN("door transfer of ",user," to ",tpar)
		
		self.lastuse = ct
		target.lastuse = ct
		
		if target and IsValidEnt(target) then
			target:EmitSound("door/door_wood_close.ogg",1)
		end
		if self and IsValidEnt(self) then
			self:EmitSound("door/door_wood_close.ogg",1)
		end
		MsgN("door closed from ",upar," to ",tpar)
	end
end

ENT._typeevents = {
	[EVENT_USE] = {networked = true, f = ENT.Press},
}