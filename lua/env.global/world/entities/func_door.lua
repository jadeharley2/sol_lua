

function Spawn_FUNC_DOOR(model,ent,pos,scale,collonly,norotation)
	local e = ents.Create("func_door") 
	e.collonly = collonly 
	e:SetSizepower(1)
	e:SetParent(ent)
	e:SetParameter(VARTYPE_MODEL,model)
	e:SetParameter(VARTYPE_MODELSCALE,scale)
	--e:SetModel(model,scale,norotation)
	e:SetPos(pos) 
	e:Spawn()
	return e
end

function ENT:Init()  
	local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.coll = coll 
    self.state = "closed"
	self:SetSpaceEnabled(false) 
	
	self:AddNativeEventListener(EVENT_PHYSICS_COLLISION_STARTED,"c",self.OnTouch)
end
function ENT:OnTouch(other)
	MsgN("TOUCH BY",other)
	self:Toggle()
end
function ENT:SetData(sourcedata)
	local movedir = vsourcetools.GetNumberTable( sourcedata.movedir or "0 0 1")
	local movev =Vector(1,0,0):TransformN(vsourcetools.FromSourceAngle(movedir))
	local sz = self:GetParent():GetSizepower()
	self.movedir = movev   
	self.speed =  tonumber(sourcedata.speed)*0.0254
	self.closedpos = self:GetPos()
	self.openpos = self:GetPos()+ movev/sz
	self.closedelay = tonumber(sourcedata.wait)
end
function ENT:Load() 
	local modelcom = self.modelcom
	if not modelcom then
		local modelval = self:GetParameter(VARTYPE_MODEL)
		local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
		if modelval then 
			self:SetModel(modelval,modelscale)
		else
			MsgN("no model specified for static model at spawn time")
		end
	end
	--MsgN("dfa")
end  
function ENT:Spawn() 
	--MsgN("spawning static object at ",self:GetPos())
	local modelcom = self.modelcom
	if not modelcom then
		local modelval = self:GetParameter(VARTYPE_MODEL)
		local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
		if modelval then
			--MsgN("with model: ",modelval," and scale: ", modelscale)
			self:SetModel(modelval,modelscale)
		else
			error("no model specified for static model at spawn time")
		end
	end
end

function ENT:SetModel(mdl,scale,norotation) 
	scale = scale or 1
	norotation = norotation or false
	local model = self.model
	local world = matrix.Scaling(scale)
	if not norotation then
		world = world * matrix.Rotation(-90,0,0)
	end
	 
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(mdl)   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world)
	  
    local coll =  self.coll 
    if norotation then
        if(model:HasCollision()) then
			coll:SetShapeFromModel(matrix.Scaling(scale))--matrix.Scaling(scale/0.75 )  ) 
			coll:SetTouch(true)
        else
            --coll:SetShape(mdl,matrix.Scaling(scale))--matrix.Scaling(scale/0.75 ) ) 
        end
    else
        if(model:HasCollision()) then
            coll:SetShapeFromModel(matrix.Scaling(scale)* matrix.Rotation(-90,0,0))--matrix.Scaling(scale/0.75 ) * matrix.Rotation(-90,0,0) ) 
			coll:SetTouch(true)
		else
            --coll:SetShape(mdl,matrix.Scaling(scale)* matrix.Rotation(-90,0,0))--matrix.Scaling(scale/0.75 ) * matrix.Rotation(-90,0,0) ) 
        end
	end
	
    if self.collonly then
        model:Enable(false)
    end 
	self.modelcom = true
end 
function ENT:Think()
	if self.targetpos then
		local sz = self:GetParent():GetSizepower()
		local sp = self:GetPos()*sz
		local ep = self.targetpos*sz
		local dir = ep-sp
		local remlen = dir:Length()
		local ndir = dir/remlen
		local spd = self.speed/50 
		if remlen<spd then
			self:SetPos(self.targetpos)
			self._locked = false
			local onend = self.onend 
			if onend and isfunction(onend) then 
			    onend(self)
			end
			self.onend = nil
			self.targetpos = nil
			return false
		else
			self:SetPos(self:GetPos()+ndir*spd/sz)
			return true
		end
	end
end

function ENT:Move(endpos,time,onend)
	self._locked = true
	self.targetpos = endpos
	self.onend = onend
	self:SetUpdating(true,20)
    --local sz = self:GetParent():GetSizepower()
	--local startpos = self:GetPos()
	-- 
	--local dt = time/100
    --local t = 0
    --self:Timer("move",0,10,100,function ()
    --    t = t + 0.01
    --    self:SetPos(LerpVector(startpos,endpos,t)) 
    --    if(t>=0.9) then
    --        self._locked =false
    --        if onend and isfunction(onend) then
    --            onend(self)
    --        end
    --    end
    --end)
end
function ENT:Open()
    if not self._locked then 
        self:Move(self.openpos,self.movetime,function (s)
			s.state = "open"
			if self.closedelay and self.closedelay>=0 then
				s:Delayed("autoclose",self.closedelay*1000,function()
					MsgN("C2O")
					s:Close()
				end)
			end 
        end)
    end
end
function ENT:Close()
    if not self._locked then 
        self:Move(self.closedpos,self.movetime,function (s)
            s.state = "closed"
        end)
    end
end
function ENT:Toggle() 
    if self.state =="open" then
        self:Close()
    else
        self:Open()
    end
end