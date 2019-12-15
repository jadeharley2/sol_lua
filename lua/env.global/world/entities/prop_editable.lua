local NO_COLLISION = NO_COLLISION or 2
local COLLISION_ONLY = COLLISION_ONLY or 1 
 


function SpawnPE(model,ent,pos,scale,collonly,norotation)
	local e = ents.Create("prop_editable") 
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
	local model = self:AddComponent(CTYPE_EDITABLEMESH)
	  
	self.model = model
	self.coll = coll 
	self:SetSpaceEnabled(false) 
	
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
	model:CreateBase() 
end 
function ENT:UpdateCollision()
	self.coll:SetShapeFromModel(matrix.Identity())  
end

local static = ENT.static or {}
ENT.static = static

ENT.editor = {
	name = "Dynamic mesh prop",
	properties = {
        editMode = {text = "toggle Edit Mode",type="action",action = function(ent)  
		   ent.editMode = not (ent.editMode or false)
		   if static.curedit == ent then
			static.curedit = false
			ent:UpdateCollision()
		   else
			static.curedit = ent
		   end
		   return true
        end}, 
		editMode_display = {text = "In edit mode",type="indicator",value = function(ent)   
			return static.curedit == ent
		end},
	}  
}


function CBASE()
	x = E_FS
	x:RemoveComponents(CTYPE_EDITABLEMESH)
	c = x:AddComponent(CTYPE_EDITABLEMESH)
	c:SetRenderGroup(RENDERGROUP_LOCAL)
	c:CreateBase() 
end

local rmode = false
hook.Add("input.mousedown","testaselect",function()
	rmode = false
	if not static.curedit then return  end
	local c = static.curedit.model
	MsgN(c,"C")
	if c then
		local cam = GetCamera()

		if input.KeyPressed(KEYS_G) then
			c:StartVNPDrag(cam,Vector(1,0,0))
			rmode = 'extrude' 
		elseif input.KeyPressed(KEYS_V) then
			c:StartVNPDrag(cam,Vector(1,0,0))
			rmode = 'inset' 
		elseif input.KeyPressed(KEYS_B) then
			--c:StartVNPDrag(cam,Vector(1,0,0))
			rmode = 'tesselate' 
		else
			c:Cancel() 
			c:SelectFace(cam,Vector(1,0,0),input.rightMouseButton())
		end
	end

end)
hook.Add("input.mouseup","testaselect",function()
	if not static.curedit then return  end
	local c = static.curedit.model
	if c then
		if rmode == 'extrude' then 
			--c:Apply()
		end
		rmode = false
	end
end)
hook.Add("input.keydown","testaselcet",function(key)
	if not static.curedit then return  end
	local c = static.curedit.model
	if c then
		if key == KEYS_ENTER then
			c:Apply()
		end
	end
end)
hook.Add(EVENT_GLOBAL_UPDATE,"testaselcet",function()
	if not static.curedit then return  end
	local c = static.curedit.model
	if c then
		if rmode == 'extrude' then
			local cam = GetCamera()
			local dv = c:GetVNPDrag(cam,Vector(1,0,0))
			c:Cancel()
			--c:ExtrudeFace(dv)
			c:Operate('extrude',json.ToJson({shift = dv, mode = 'normal' }))
			--c:Operate('inset',json.ToJson({amount = dv }))
		end
		if rmode == 'inset' then
			local cam = GetCamera()
			local dv = c:GetVNPDrag(cam,Vector(1,0,0))
			c:Cancel()
			--c:Operate('ngon',json.ToJson({r =dv,sides = 5 }))
			c:Operate('inset',json.ToJson({amount = dv }))--,chamfer = 0.2
			--c:Operate('tesselate',json.ToJson({times = 1 }))
			--c:Operate('stairs',json.ToJson({height = dv })) 
			--c:Operate('cut',json.ToJson({shift = dv })) 
		end
		if rmode == 'tesselate' then 
			local cam = GetCamera()
			local dv = c:GetVNPDrag(cam,Vector(1,0,0))
			c:Cancel() 
			c:Operate('tesselate',json.ToJson({times =math.Clamp(dv,1,3) }))
		end
	end
end)
 
hook.Add('formspawn.dynmeshprop','spawn',function(form,parent,arguments)
	return SpawnPE(form,parent,arguments.pos or Vector(0,0,0) ) 
end) 
