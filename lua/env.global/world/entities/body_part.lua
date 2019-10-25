--lua_run SpawnBP("mlppony/base_l3_wings.json",LocalPlayer(),0.03)
--lua_run l = LocalPlayer() a = SpawnBP("models/apparel/uniform.stmd",l,1,110101) b = SpawnBP("models/apparel/cape.stmd",l,1,110102) c = SpawnBP("models/apparel/scarf.stmd",l,1,110103) d = SpawnBP("models/apparel/skl.stmd",l,1,110104)
function SpawnBP(model,ent,scale,seed)
	local e = ents.Create("body_part")  
	e:SetSizepower(1000)
	e:SetParent(ent) 
	e:SetModel(model,scale)
	if seed then e:SetSeed(tonumber(seed)) end
	e:Create()
	return e 
end

function ENT:Init()   
	local model = self:AddComponent(CTYPE_MODEL)  
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
		MsgN("no model specified for body part at spawn time")
	end 
end  
function ENT:Spawn()  
	local modelcom = self.modelcom
	if not modelcom then
		local modelval = self:GetParameter(VARTYPE_MODEL)
		local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
		if modelval then
			--MsgN("with model: ",modelval," and scale: ", modelscale)
			self:SetModel(modelval,modelscale)
		else
			MsgN("no model specified for body part at spawn time")
		end
	end 
end
function ENT:SetVisible(v)
	self.model:Enable(v or false)
end

function ENT:ForceVisible(v)
	if v then
		self.model:Enable(true)
	else
		self:UpdateVisibility()
	end
end
function ENT:ForceInvisible(v)
	if v then
		self.model:Enable(false)
	else
		self:UpdateVisibility()
	end
end
function ENT:UpdateVisibility()
	local hideray = self.hideray
	if hideray then  
		if hideray:Count()==0 then
			self.model:Enable(true) 
		else
			self.model:Enable(false)
		end 
	else
		self.model:Enable(true)
	end
end

function ENT:HideBy(v)
	local hideray = self.hideray or Set()
	self.hideray = hideray
	hideray:Add(v) 
	self.model:Enable(false)
end
function ENT:UnhideBy(v)
	local hideray = self.hideray
	if hideray then
		hideray:Remove(v) 
		if hideray:Count()==0 then
			self.model:Enable(true)
		end
	else
		hideray = Set()
		self.hideray = hideray
		self.model:Enable(true)
	end
end

function ENT:SetModel(mdl,scale) 
	scale = scale or 1 
	local model = self.model
	local world = matrix.Scaling(scale) 
	local pmd = self:GetParent().model
	
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(mdl)   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	if pmd then
		model:SetMatrix(pmd:GetMatrix()) --world)
		
		model:SetCopyTransforms(pmd)
	end
	self.modelcom = true
end 
ENT.editor = {
	name = "Body part",
	properties = {
		selectParent = {text = "select parent",type="action",action = function(ent) 
			worldeditor:Select(ent:GetParent(),false)
		end}
	}
}