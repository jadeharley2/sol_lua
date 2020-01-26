 
function SpawnEHANDLE(model,world,parent,pos,scale,tint)
	local e = ents.Create("editor_handle")  
	e.parent = parent
	e:SetSizepower(1)
	e:SetParent(world)
	e:SetModel(model,scale)
	e:SetPos(pos) 
	if tint then e:SetColor(tint) end
	e:Spawn()
	return e
end

function ENT:Init()   
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model 
	self:SetSpaceEnabled(false)  
end 
function ENT:Spawn()  
	local modelcom = self.modelcom
	if not modelcom then
		local modelval = self:GetParameter(VARTYPE_MODEL)
		local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
		if modelval then 
			self:SetModel(modelval,modelscale) 
		end
	end
end

function ENT:SetModel(mdl,scale) 
	scale = scale or 1
	local model = self.model
	local world = matrix.Scaling(scale) 
	
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(mdl)   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_NODETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_DISABLED)  
	model:SetMaterial("textures/debug/fullbright.json")
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world)
	model:SetMaxRenderDistance(100000000)
	model:SetPOcclusion(true)
	  
	self.modelcom = true
end 
function ENT:SetColor(color)
	self.model:SetColor(color)
end
ENT.editor = {
	name = "Editor handle",
	properties = {
		selectParent = {text = "select parent",type="action",action = function(ent)  
			if worldeditor and ent.parent then
				worldeditor:Select(ent.parent,false)
			end
		end}
	}
}