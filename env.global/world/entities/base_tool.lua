 
DeclareEnumValue("event","TOOL_FIRE",					90901) 

local linear_ray = LoadTexture("textures/tile/linear/ray.png")
function SpawnWeapon(type,parent,pos,seed)

	local e = ents.Create("base_tool")
	e:SetType(type)
	e:SetParent(parent)
	e:SetPos(pos) 
	e:SetSeed(seed or 234923)
	e:Spawn()
	return e
end
function CreateWeapon(type,parent,pos,seed)

	local e = ents.Create("base_tool")
	e:SetType(type)
	e:SetParent(parent)
	e:SetPos(pos) 
	e:SetSeed(seed or 234923)
	e:Create()
	return e
end

ENT.holdtype = "th_low"

function ENT:Init()  

	local phys = self:AddComponent(CTYPE_PHYSOBJ)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.phys = phys
	
	self.nextfiretime = CurTime()
	self.firedelay = 0.5
	self.attachworld = matrix.Rotation(Vector(-40,0,-90)) 
		* matrix.Translation(Vector(-10, -2, 0))
	self.type = "none"
	self:SetParameter(VARTYPE_MODEL,"test/phtgun/phtgun.json")
	self:SetSpaceEnabled(false)
	self:SetSizepower(1)
end

function ENT:Spawn()
	self:SpawnWorldModel(0.03)
	--self.model:SetMaterial("textures/debug/white.json") 
	--self:SpawnWorldModel(self.dmodel,self.phymodel,self.mscale)
	
	 
	
	self:AddFlag(FLAG_USEABLE) 
	self:AddFlag(FLAG_STOREABLE)
	self:AddFlag(FLAG_WEAPON)
	self:AddFlag(FLAG_PHYSSIMULATED)
	
	self.phys:Enable()

	if SERVER then
		network.AddNodeImmediate(self)
	end
	if self.OnSpawn then self:OnSpawn() end
end
function ENT:Load()
	self:SetPos(self:GetPos())
	self:CopyAng(self)
	local char = self:GetParameter(VARTYPE_CHARACTER) 
	self:SetType(char)
	local parent = self:GetParent()
	if parent.PickupWeapon then
		parent:PickupWeapon(self)
	end
end 


function ENT:SetType(type)
	if type then
		self.type = type
		self:SetParameter(VARTYPE_CHARACTER,type)
		
		local data = json.Read("forms/items/tools/"..type..".json")
		if data then 
			self:SetName(data.name)
			
			if data.appearance then
				self:SetParameter(VARTYPE_MODEL,data.appearance.model)
				self:SetParameter(VARTYPE_MODELSCALE,data.appearance.scale or 1)
			end
			self.basetype = data.type
			local bt = TOOL
			TOOL = self
			include("lua/env.global/world/tools/"..data.type..".lua") 
			TOOL = bt
			if self.OnSet then self:OnSet(data) end
		end
	end
end

function ENT:OnPickup(ent)
	self.phys:Disable()
	self:SetParent(ent)
	self:SetPos(Vector(0,0,0))
	--local em = ent.model
	--if em then
	--	em:Attach(self,"weapon1")
	--end
end 
function ENT:Trace(pos, dir) 
	local parentphysnode = self:GetParentWithComponent(CTYPE_PHYSSPACE)
	if parentphysnode then 
		if not pos then
			local lw = parentphysnode:GetLocalSpace(self) 
			pos = lw:Position()
		end
		local sz = parentphysnode:GetSizepower() 
		local space = parentphysnode:GetComponent(CTYPE_PHYSSPACE) 
		local hit, hpos, hnorm, dist, ent = space:RayCast(pos,dir)
		return {Hit = hit,Position=hpos,Normal=hnorm,Distance = dist, Node = parentphysnode, Space = space,Entity = ent}  
	end
end
function ENT:OnDrop(ent)
	--local em = ent.model
	--if em then
	--	em:Detach(self)
	--end
	--self:SetParent(ent:GetParent())
	if (SERVER or not network.IsConnected()) then
		self:SetPos(Vector(0,1,0))
		self:Eject()
	end
	self.phys:Enable()
	local sp = self:GetPos()
	local pp = ent:GetPos()
	local pss = ent:GetParent():GetSizepower()
	
	if sp:Distance(pp)*pss > 2 then
		self:SetPos(pp+Vector(0,1/pss,0))
	end
end

function ENT:CreateLaser(p1,p2,p3,p4,s,w)
	local dmesh = self.dmesh
	if not dmesh then
		dmesh = self:AddComponent(CTYPE_DYNAMICMESH)  
		dmesh:SetRenderGroup(RENDERGROUP_LOCAL) 
		dmesh:SetBlendMode(BLEND_ADD) 
		dmesh:SetRasterizerMode(RASTER_NODETPHSOLID) 
		dmesh:SetDepthStencillMode(DEPTH_READ) 
		dmesh:SetTexture(linear_ray)		
		self.dmesh = dmesh
	end
	dmesh:SetParam("timeShift",Point(10,0))
	
	dmesh:SetData(p1 or Vector(0,0,0),p2 or Vector(1,0,0),p3 or Vector(2,0,0),p4 or Vector(3,0,0),s or 5,w or 0.1)
end
function ENT:CreateLight(ship, pos, color, vel)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2)
	local phys = lighttest:AddComponent(CTYPE_PHYSOBJ) 
	phys:SetShape("engine/gsphere_2.SMD",world* matrix.Scaling(0.4))
	phys:SetMass(100) 
	lighttest:SetParent(ship)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn()
	
	lighttest.model:SetMatrix(world*matrix.Translation(-phys:GetMassCenter()))
	lighttest.phys = phys
	
	lighttest:SetPos(pos) 
	phys:ApplyImpulse(vel or Vector(0,4,40))
	return lighttest
end
function ENT:HitEffect(ent, pos) 
	local lighttest = ents.Create("env_explosion")
	local world = matrix.Scaling(2) 
	lighttest:SetParent(ent)
	lighttest:SetSizepower(0.1)
	lighttest.magnitude = 1
	--lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:SetPos(pos) 
	lighttest:Spawn() 
	--debug.Delayed(100,function() lighttest:Despawn() end)
end
function ENT:IsReady(id)
	local ct = CurTime()
	local nft = self.nextfiretime or ct
	return ct >= nft  
end
function ENT:Fire() 
	local nft = self.nextfiretime
	local ct = CurTime()
	local fd = self.firedelay
	if ct > nft then 
		self.nextfiretime = ct + fd
		
		local parentphysnode = cam:GetParentWithComponent(CTYPE_PHYSSPACE)
		if parentphysnode then
		--local tr = GetCameraPhysTrace()
		--MsgN(tr.Hit)
		--if tr and tr.Hit then 
		local lw = parentphysnode:GetLocalSpace(cam)
		--local mpos = --self.model:GetAttachmentPos("muzzle")
			local sz = parentphysnode:GetSizepower()
			local forw = lw:Forward()--:TransformC(matrix.AxisRotation(lw:Right(),math.random(-30,30)))
			
			local tr = GetCameraPhysTrace()
			if tr and tr.Hit then 
				self:HitEffect(parentphysnode,tr.Position+tr.Normal*(0.2/sz))
			end
			---local ent = self:CreateLight(parentphysnode,lw:Position()+forw*(1.4/sz),
			---Vector(math.random(0,255),math.random(0,255),math.random(0,255))/255*1,forw*50000*1)--*150)
			-----ent.phys:SetGravity(Vector(0,-9,0))
			-----local ent = ents.Create("base_tool")
			-----ent:SetParent(tr.Node)
			-----ent:SetPos(tr.Position+tr.Normal*(0.2/sz))
			-----ent.type = "testweap"
			-----ent:SetParameter(VARTYPE_MODEL,"test/phtgun/phtgun.json")
			-----ent:SpawnWorldModel(0.03)
			-----ent:SetSizepower(1)
			-----ent:SetParent(parent) 
			-----ent:Spawn()
			-----ent:Set
			---debug.Delayed(6000,function() ent:Despawn() end)
		end
		return true
	else
		return false
	end
end

function ENT:SpawnWorldModel(scale)
	local model = self.model
	local phys = self.phys
	 
	local world = matrix.Scaling(scale) 
	
	local modelfile =self:GetParameter(VARTYPE_MODEL)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(modelfile) 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	
	model:SetDynamic()
	model:SetAnimation("idle")
	
	if model:HasCollision() then
		phys:SetShapeFromModel(world)
		phys:SetMass(10) 
	end 
	
	--lua_run SpawnWeapon("kindred/bow.json",LocalPlayer(),Vector(0,0,0))
	model:SetMatrix( matrix.Rotation(90,0,0)*(self.mworld or matrix.Identity())* world)--*matrix.Translation(-phys:GetMassCenter()*100)) 
	
	self:SetUpdating(true,100)
end 

function ENT:SpawnWorldModel2(scale)
	local model = self.model 
	 
	local world = matrix.Scaling(scale) 
	
	local modelfile =self:GetParameter(VARTYPE_MODEL)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(modelfile) 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	
	model:SetDynamic()
	model:SetAnimation("idle")
	 
	
	--lua_run SpawnWeapon("kindred/bow.json",LocalPlayer(),Vector(0,0,0))
	model:SetMatrix( matrix.Rotation(90,0,0)*(self.mworld or matrix.Identity())* world)--*matrix.Translation(-phys:GetMassCenter()*100)) 
	
	self:SetUpdating(true,100)
end 

function ENT:Equip(actor)
	local actor_model = actor.model
	if actor_model then
		actor_model:Attach(self,self.attachname or "weapon1",true,self.attachworld or matrix.Identity())
		actor_model:PlayLayeredSequence(1,"weapon_hold_test")
		actor_model:PlayLayeredSequence(2,"weapon_aim")
	end
end
function ENT:Unequip(actor)
	local actor_model = actor.model 
	if actor_model then
		actor_model:Detach(self)
		actor_model:StopLayeredSequence(1)
		actor_model:StopLayeredSequence(2)
	end 
end


ENT._typeevents = {
	[EVENT_USE] = {networked = true, f = function(self,user) user:PickupWeapon(self) end},
	[EVENT_TOOL_FIRE] = {networked = true, f = function(self,id,dir) 
		if id == 0 then
			self:Fire(dir)
		elseif id == 1 then
			if self.AltFire then
				self:AltFire(dir)
			end
		end 
	end},
}
 