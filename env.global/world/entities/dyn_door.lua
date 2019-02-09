

function SpawnDoor(model,ent,pos,ang,scale,seedd)
	model = model or "door/door.stmd"
	local e = ents.Create("dyn_door")
	e:SetSeed(seedd)
	e:SetSizepower(1)
	e:SetParameter(VARTYPE_MODEL,model)
	e:SetParameter(VARTYPE_MODELSCALE,scale)
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
	local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	self:SetModel(m,modelscale)
	
end
function ENT:Despawn() 
	if self.sloop then self.sloop:Dispose() self.slopp = nil end
end
function ENT:PlayLoopSound(snd,vol)
	if self.sloop then self.sloop:Dispose() self.slopp = nil end
	self.sloop = self:EmitSoundLoop(snd,vol)
end
function ENT:LoadGraph()
	local graph = BehaviorGraph(self) 
	
	local w = Component("wireio",self)
	w:AddInput("toggle",self.Toggle)
	w:AddInput("open",self.Open)
	w:AddInput("close",self.Close)
	w:AddInput("lock",self.Lock)
	w:AddInput("unlock",self.Unlock)
	
	w:AddOutput("open")
	w:AddOutput("close")
	
	w:AddOutput("opened")
	w:AddOutput("closed")
	
	--graph.debug = true
	graph:NewState("idle_open",function(s,e)  
		e:SetUpdating(false)  
		return 99 end)
	graph:NewState("idle_closed",function(s,e)  
		e:SetUpdating(false) 
		return 99 end)
	graph:NewState("open",function(s,e) 
		e:EmitSound(table.Random({"door/door_electric_start-01.ogg","door/door_electric_start-02.ogg"}),1)
		e:PlayLoopSound("door/door_electric_move.ogg",1)
		w:SetOutput("open")
		return e.model:SetAnimation("open") 
		end)
	graph:NewState("close",function(s,e) 
		e:EmitSound(table.Random({"door/door_electric_start-01.ogg","door/door_electric_start-02.ogg"}),1)
		e:PlayLoopSound("door/door_electric_move.ogg",1)
		w:SetOutput("close")
		return e.model:SetAnimation("close")
		end)
	graph:NewState("preidle_open",function(s,e)  
		e:EmitSound("door/door_electric_stop.ogg",1)
		if e.sloop then e.sloop:Stop() e.slopp = nil end
		w:SetOutput("opened")
		return e.model:SetAnimation("idle_open") 
		end)
	graph:NewState("preidle_closed",function(s,e)  
		e:EmitSound("door/door_electric_stop.ogg",1)
		if e.sloop then e.sloop:Stop() e.slopp = nil end 
		w:SetOutput("closed")
		return e.model:SetAnimation("idle_closed") 
		end)
	graph:NewTransition("open","preidle_open",BEH_CND_ONEND)
	graph:NewTransition("close","preidle_closed",BEH_CND_ONEND)
	graph:NewTransition("preidle_open","idle_open",BEH_CND_ONEND)
	graph:NewTransition("preidle_closed","idle_closed",BEH_CND_ONEND)
	graph:NewTransition("idle_open","close",BEH_CND_ONCALL,"close")
	graph:NewTransition("idle_closed","open",BEH_CND_ONCALL,"open")
	
	self.graph = graph 
	graph:LoadState("preidle_closed")
	--graph:SetState("idle_closed",false)
	
end
function ENT:SetModel(mdl,scale) 
	local model = self.model
	local world = matrix.Scaling(scale)
	 
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
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
	phys:SetMass(-1)--static  
	
	self:LoadGraph()
	 
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
		if(self.graph:Call("open"))then
			self:SetUpdating(true)
			return true
		elseif(self.graph:Call("close"))then
			self:SetUpdating(true) 
			return true
		end
	end
	return false
end

function ENT:Open() 
	if(not self.locked and self.graph:Call("open"))then
		self:SetUpdating(true) 
		return true
	end
	return false
end
function ENT:Close()
	if(not self.locked and self.graph:Call("close"))then
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

ENT._typeevents = { 
	[EVENT_USE] = {networked = true, f = function(self,user)  
		local onuse = self.OnUse
		if onuse then
			onuse(self,user)
		else
			self:Toggle()
		end
	end},
}  