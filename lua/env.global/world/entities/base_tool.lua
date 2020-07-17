 
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
function ItemTOOL(type,seed,modtable)
	local j = forms.ReadForm(type)--json.Read(type) 
	MsgN("tool item",j)
	if not j then return nil end 
	local t = {
		sizepower=1, 
		seed= seed, 
		updatespace= 0,
		parameters =  {
			luaenttype = "base_tool",
			name = j.name,
			form = type,
			icon = j.icon,
		},  
	}
	if modtable then table.Merge(modtable,t,true) end
	return json.ToJson(t)
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

	self:SetType(self[VARTYPE_FORM])
	local data =  forms.ReadForm(self[VARTYPE_FORM])
	self.data = data
	if data then
		self:SetParameter(VARTYPE_MODEL,data.appearance.model)
		self:SetParameter(VARTYPE_MODELSCALE,data.appearance.scale or 1)
		MsgN("read ok")
		if data.firedelay then
			self.firedelay = data.firedelay
		end
	end
	self:LoadGraph()
--	self:SpawnWorldModel(0.03)
	self:SpawnWorldModel2(self[VARTYPE_MODELSCALE] or 1)--0.03)
	--self.model:SetMaterial("textures/debug/white.json") 
	--self:SpawnWorldModel(self.dmodel,self.phymodel,self.mscale)
	
	 
	
	self:AddTag(TAG_USEABLE) 
	self:AddTag(TAG_STOREABLE)
	self:AddTag(TAG_WEAPON)
	self:AddTag(TAG_PHYSSIMULATED)
	
--	self.phys:Enable()

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
		local data = forms.ReadForm(type)
		self.data = data 
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
		local parphys = self:GetParent().phys  
		local hit, hpos, hnorm, dist, ent = space:RayCast(pos,dir,parphys)
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
function ENT:IsReady(iscontinuous)
	if iscontinuous and not self.continuous then
		return false
	end
	local ct = CurTime()
	local nft = self.nextfiretime or ct
	return ct >= nft   
end
function ENT:LoadGraph()

	local graph = BehaviorGraph(self,tab) 
	self.graph = graph

	
	local data = self.data 

	local hdt = data.appearance.holdtype  
	graph:NewState("idle",function(s,e) 
		if hdt then e:GetParent().model:PlayLayeredSequence(1,hdt.idle,hdt.model) end
	end)
	graph:NewState("fire",function(s,e) 
		local owner = e:GetParent()
		if hdt then owner.model:PlayLayeredSequence(1,hdt.fire,hdt.model) end
		owner.nomovement = true
		owner.norotation = true
		return hdt.fire_duration or 1
	end)
	graph:NewState("fireend",function(s,e) 
		local owner = e:GetParent() 
		owner.nomovement = false
		owner.norotation = false
		return 0
	end)
	graph:NewTransition("idle","fire",BEH_CND_ONCALL,"fire")
	graph:NewTransition("fire","fireend",BEH_CND_ONEND)
	graph:NewTransition("fireend","idle",BEH_CND_ONEND)

	graph:SetState("idle")
	graph.debug = true
end
function ENT:Think()
	local graph = self.graph
	if graph then 
		graph:Run() 
	end
end
function ENT:Fire() 
	local nft = self.nextfiretime
	local ct = CurTime()
	local fd = self.firedelay
	--MsgN("fired")
	if ct > nft then 
		self.nextfiretime = ct + fd
		
		 
		self.graph:Call("fire")
	--local data = self.data 
	--if data then
	--	local actor = self:GetParent()
	--	local actor_model = actor.model 
	--	if data.appearance then 
	--		if  data.appearance.holdtype then
	--			local hdt = data.appearance.holdtype  
	--			actor_model:PlayLayeredSequence(1,hdt.fire,hdt.model,1)
	--		end
	--	end
	--end

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
	model:SetMatrix(world)-- matrix.Rotation(90,0,0)*(self.mworld or matrix.Identity())* world)--*matrix.Translation(-phys:GetMassCenter()*100)) 
	
end 

function ENT:Equip(actor)
	actor.activeweapon = self 

	local actor_model = actor.model
	--if actor_model and self.attachname then
	--	actor_model:Attach(self,self.attachname or "weapon1",true,self.attachworld or matrix.Identity())
	--	actor_model:PlayLayeredSequence(1,"weapon_hold_test")
	--	actor_model:PlayLayeredSequence(2,"weapon_aim")
	--end
	local data = self.data 
	if data then
		if data.appearance then
			if data.appearance.attach then
				local at = data.appearance.attach
				-- at.world  
				actor_model:Attach(self,at.name,true,matrix.Rotation(JMatrix(at.world)) or matrix.Identity())
			end
			--if  data.appearance.holdtype then
			--	local hdt = data.appearance.holdtype  
			--	actor_model:PlayLayeredSequence(1,hdt.idle,hdt.model,1)
			--end
		end
	end
	if self.graph then self.graph:SetState("idle") end
	self:SetUpdating(true,20)
	CALL(self.Draw,self,actor)
end
function ENT:Unequip(actor)
	CALL(self.Holster,self,actor)
	self:SetUpdating(false)
	actor.activeweapon = nil
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
 

hook.Add('newitem.tool',"new",function(formid,seed)
	return ItemTOOL(formid)
end)
