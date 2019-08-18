
function SpawnTr(parent,model,pos,ang,seed,scale)
	local e = ents.Create("train_carriage")  
	e:SetSizepower(1)
	e:SetParent(parent)
	e:SetModel(model,scale or 1)
	e:SetPos(pos) 
	e:SetAng(ang or Vector(0,0,0))  
	e:SetSeed(seed)
	e:Spawn()
	return e
end
function ENT:Init()   
    local model = self:AddComponent(CTYPE_MODEL) 
    
	local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	self.model = model 
	self.coll = coll 
	self:SetSpaceEnabled(false)  
	
end
function ENT:Load()
	local modelval = self:GetParameter(VARTYPE_MODEL) 
	local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	if modelval then 
		self:SetModel(modelval,modelscale)
	else
		MsgN("no model specified for button model at spawn time")
	end  
end  
function ENT:Spawn()  
	local modelcom = self.modelcom
	if not modelcom then
		local modelval = self:GetParameter(VARTYPE_MODEL)
		local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
		if modelval then 
			self:SetModel(modelval,modelscale)
		else
			error("no model specified for button model at spawn time")
		end
	end  
	
end

 
function ENT:SetModel(mdl,scale) 
	scale = scale or 1
	local model = self.model
	local world = matrix.Scaling(scale) 
		* matrix.Rotation(-90,0,0) 
		--* matrix.Translation(Vector(-10,0,0))
	
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	--model:SetRenderOrder(1)
	model:SetModel(mdl or "forms/levels/train/bogie.dnmd")   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world)
	model:SetMaxRenderDistance(9999999)
	self.coll:SetShapeFromModel(matrix.Scaling(scale) ) 
	
	self.modelcom = true
end 
function ENT:SetBogies(A,B)
	self.bogie_A = A
	self.bogie_B = B
	self:SetPos(A:GetPos())
	self:SetUpdating(true,20)
	self.offset = Vector(0,0.9,0)
	self.motor=0
	self.links = {}
	self:Link('slf',A,B,16)
end
function ENT:Link(name,bga,bgb,dist)
	self.links[name] = {bga,bgb,dist}

end 

function ENT:SetTrack(tracknode,off)
	off = off or 0
	self:SetParent(tracknode.node)
	self:SetPos(tracknode.pos)
	self.tracknode = tracknode
	self.movement = 1
	self.dl = 0
	self:SetPP(40)
	self:SetUpdating(true,20)
	self.offset = Vector(0,0.4,0)
	self.speed = 0 
	
	local from = self.tracknode.pos
	local to =  self.tracknode:GetNext().pos
	local len = (to-from):Length()*1000
	self.dl = self.dl + off/len
end
function ENT:SetTrack2(track,node,nodeb,off)
	node = node or 1
	off = off or 0  
	self.pathfollow = self.pathfollow or self:AddComponent(CTYPE_PATHFOLLOW)

	self.pathfollow:SetPath(track,node,nodeb,off)
	--self.pathfollow:SetSpeed(1)
	self.pathfollow:SetOffsetAng(matrix.Rotation(Vector(0,90,0)))
	self.pathfollow:SetAngSlerp(0.3) 
	self.pathfollow:SetOffsetPos(Vector(0,0.5,0)) 
	--self.pathfollow:SetOnReach(function(id) 
	--	MsgN("reached!",id) 
	--end)
	--self.pathfollow:SetOnReach(function(id) 
	--	MsgN("breached!",id) 
	--end)
	self.pathfollow:SetOnDerail(function(id) 
		--MsgN("derailed!",id)
		--self.pathfollow:SetPath(track,node,nodeb,0)
	end)

	self:SetUpdating(true,20) 
end

function ENT:SetPP(count)
	self.ppl = {}
	self.ppi = 0
	self.ppc = count
end
function ENT:AddPrevPos(pos)
	self.ppi = self.ppi + 1 
	if self.ppi>=self.ppc then
		self.ppi = 0
	end
	self.ppl[self.ppi] = pos
end
function ENT:GetPrevPos(id)
	local rid = self.ppi - id
	if rid<0 then
		rid = rid + self.ppc
	end
	return self.ppl[rid]
end
function ENT:RemAll()
	if IsValidEnt(self.bogie_A) then self.bogie_A:Despawn() end
	if IsValidEnt(self.bogie_B) then self.bogie_B:Despawn() end
	if IsValidEnt(self) then self:Despawn() end
end
function ENT:Think()

	--if true then return  end
	local bga = self.bogie_A
	local bgb = self.bogie_B
	if IsValidEnt(bga) and IsValidEnt(bgb) then
		local psz = self:GetParent():GetSizepower()
		local offset = (self.offset or Vector(0,0.3,0))/psz
		local posa = bga:GetPos()+offset
		local posb = bgb:GetPos()+offset
		local midp = (posa+posb)/2
		self:SetPos(midp)
		self:LookAt((posa-posb), 
			matrix.Rotation(Vector(0,90,0)),0.8) 

	--	for k,v in pairs(self.links) do  
	--		local _ga = v[1]
	--		local _gb = v[2]
	--		local _d = v[3]
	--		local posa = _ga:GetPos()
	--		local posb = _gb:GetPos()
	--		local dlen = ((posa-posb):Length() - (_d/psz))*4
	--		_ga.speed = _ga.speed +dlen*10
	--		_gb.speed = _gb.speed -dlen*10
	--	end
		
		--local dlen = ((posa-posb):Length() - (16/psz))*1
		--bga.speed = bgb.speed +dlen*10
		--bgb.speed = bgb.speed -dlen*10

	--	bga.speed = bga.speed *0.9
	--	bgb.speed = bgb.speed *0.9
	--	bgb.speed = bgb.speed +self.motor
	else 
		local speed = self.speed or 0
		local offset = (self.offset or Vector(0,0.3,0))/self:GetParent():GetSizepower()
		local tracknode = self.tracknode
		if tracknode then
			local nextnode = tracknode:GetNext(self.prevnode)
			if nextnode then
				local from = self.tracknode.pos
				local to = nextnode.pos
				local len = (to-from):Length()*1000

				self.dl = self.dl + speed/len
				if self.dl>1 then
					self.prevnode = self.tracknode
					self.tracknode = nextnode 
					self.dl =  self.dl - 1
					return true 
				elseif self.dl<0 then
					if self.prevnode then
						local newprev = self.tracknode-- self.prevnode:GetNext(self.tracknode)
						self.tracknode = self.prevnode 
						self.prevnode = newprev
						self.dl =  1
						--self.movement = -self.movement
					end
					--self.speed = -self.speed
					return true 
				end
				local dlt =from + (to - from)*self.dl
				
				--local prevpos =-- self:GetPrevPos(2) or
				--self.lastpos or Vector(0,0,0)
				--local newpos = dlt
				--self.lastpos = newpos
				self:SetPos(dlt+ offset)
				self:LookAt((to-from),--*self.movement
					matrix.Rotation(Vector(0,90,0)),0.2) 
				--self:AddPrevPos(newpos)
				--debug.ShapeBoxCreate(333,self:GetParent(),
				--	matrix.Scaling(0.0001)*matrix.Translation(newpos)) 
				--debug.ShapeBoxCreate(334,self:GetParent(),
				--	matrix.Scaling(0.0001)*matrix.Translation(prevpos)) 
			else
				local prevpos = self.lastpos or Vector(0,0,0)
				local newpos =  self.tracknode.pos 
				self.lastpos = newpos
				self:SetPos(newpos+offset)
				self.prevnode = nil
				--self.movement = self.movement * -1
				--self:LookAt(newpos-prevpos,matrix.Rotation(Vector(0,90,0))) 
			end
		end
	end
end