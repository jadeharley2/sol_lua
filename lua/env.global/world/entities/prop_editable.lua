local NO_COLLISION = NO_COLLISION or 2
local COLLISION_ONLY = COLLISION_ONLY or 1 
 


function SpawnPE(ent,pos)
	local e = ents.Create("prop_editable")  
	e:SetSizepower(1)
	e:SetParent(ent)
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
		self:SetModel()
	end
	--MsgN("dfa")
end  
function ENT:SetModelPath(path)
	self[VARTYPE_FORM] = path
	self.model:Load(path)
end
function ENT:GetModelPath()
	return self[VARTYPE_FORM] 
end
function ENT:Spawn() 
	--MsgN("spawning static object at ",self:GetPos())
	local modelcom = self.modelcom
	if not modelcom then
		self:SetModel()
	end
end

function ENT:SetModel(mdl,scale,norotation)  
	local model = self.model  
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	local path = self[VARTYPE_FORM]
	if path then
		model:Load(path)
	else
		model:CreateBase() 
	end
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

hook.Add('formspawn.dynmeshprop','spawn',function(form,parent,arguments)
	return SpawnPE(form,parent,arguments.pos or Vector(0,0,0) ) 
end) 
