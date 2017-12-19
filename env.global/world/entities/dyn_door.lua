

function SpawnDoor(model,ent,pos,ang,scale,seedd)
	model = model or "door/door.json"
	local e = ents.Create("dyn_door")
	e:SetSeed(seedd)
	e:SetSizepower(1)
	e:SetParameter(VARTYPE_MODEL,model)
	e:SetParent(ent)
	e:SetPos(pos) 
	e:SetAng(ang)
	e:Spawn()
	return e
end

ENT.usetype = "toggle door"

function ENT:Init()  
	local phys = self:AddComponent(CTYPE_PHYSCOMPOUND)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.phys = phys
	self:SetSpaceEnabled(false)
	
	--phys:SetMass(10)  
	
	self:SetUpdating(true)
	
end 
function ENT:Spawn()
	local m = self:GetParameter(VARTYPE_MODEL)
	self:SetModel(m,self.scale or 0.75)
	
end
function ENT:LoadGraph()
	local graph = BehaviorGraph(self) 
	
	--graph.debug = true
	graph:NewState("idle_open",function(s,e) e.model:SetAnimation("idle_open") e:SetUpdating(false) end)
	graph:NewState("idle_closed",function(s,e) e.model:SetAnimation("idle_closed") e:SetUpdating(false) end)
	graph:NewState("open",function(s,e) e.model:SetAnimation("open") end)
	graph:NewState("close",function(s,e) e.model:SetAnimation("close") end)
	graph:NewTransition("open","idle_open",CND_ONEND)
	graph:NewTransition("close","idle_closed",CND_ONEND)
	graph:NewTransition("idle_open","close",CND_ONREQ)
	graph:NewTransition("idle_closed","open",CND_ONREQ)
	
	self.graph = graph 
	graph:LoadState("idle_closed")
	--graph:SetState("idle_closed",false)
end
function ENT:SetModel(mdl,scale) 
	local model = self.model
	local world = matrix.Scaling(scale)
	 
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(mdl)  
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	model:SetMatrix( world) 
	 
	model:SetDynamic()
	
	local phys =  self.phys
	phys:SetShapeFromModel(matrix.Scaling(1))
	--phys:SetMass(0)--static  
	
	self:LoadGraph()
	
	self:AddEventListener(EVENT_USE,"use_event",function(user) 
		
		local onuse = self.OnUse
		if onuse then
			onuse(self,user)
		else
			self:Toggle()
		end
	end)
	self:SetNetworkedEvent(EVENT_USE)
	self:AddFlag(FLAG_USEABLE)
	 
	self:CopyAng(self)
	model:ForceUpdate()
	
	--if SERVER then
	--	network.AddNode(self)
	--end
end 
function ENT:Load()
	self:SetUpdating(true)
	self:LoadGraph()
	
	self.model:ForceUpdate()
end

function ENT:Think()
	local g = self.graph
	if g then g:Run() end  
	--for k=0,4 do 
	--	DrawPoint(3333+k,self:GetParent(),self.model:GetBonePos(k)/750+self:GetPos(),1000)
	--end
end

function ENT:Toggle()
	if not self.locked then
		if(self.graph:TrySetState("open"))then
			self:SetUpdating(true)
			return true
		elseif(self.graph:TrySetState("close"))then
			self:SetUpdating(true) 
			return true
		end
	end
	return false
end

function ENT:Open() 
	if(not self.locked and self.graph:TrySetState("open"))then
		self:SetUpdating(true)
		return true
	end
	return false
end
function ENT:Close()
	if(not self.locked and self.graph:TrySetState("close"))then
		self:SetUpdating(true)
		return true
	end 
	return false
end
function ENT:Lock()
	self.locked = true
end
function ENT:Unlock()
	self.locked = false
end
