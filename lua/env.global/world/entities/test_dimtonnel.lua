

ovspace = nil
ovtonnel = nil 

function ENT:Init()  
	local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.coll = coll 
	self:SetSpaceEnabled(false) 
	self:SetSizepower(1000)
	
end
function ENT:Load()
	local modelval = self:GetParameter(VARTYPE_MODEL)
	local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	if modelval then 
		self:SetModel(modelval,modelscale)
	else
		MsgN("no model specified for static model at spawn time")
	end
	--MsgN("dfa")
end  
function ENT:Spawn() 

	-- spawn middlespace
	if not ovspace then
		ovspace = ents.Create()
		ovspace:SetSizepower(1000)
		ovspace:Spawn() 
		local sspace = ovspace:AddComponent(CTYPE_PHYSSPACE)  
		sspace:SetGravity(Vector(0,-4,0))
		ovspace.space = sspace
	
		ovtonnel = SpawnSO("forms/levels/city/sst/sst_corridor.dnmd",ovspace,Vector(0,0,0),1)
		ovtonnel:SetAng(Vector(90,0,0))
	end 


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
	local sp = self:GetParent()
	ovspace:SetPos(Vector(10000,0,0))
	ovspace:SetParent(sp)--GetParent()
	ovtonnel:SetPos(Vector(0,0,0))

	-- -> outside|surface|in>transfer>corridor
	-- -> corridor|in>|surface|outside>
	
	local scd = SpawnSO("forms/levels/city/sst/sst_in.dnmd",self,Vector(0,0,0),1) 
	scd:SetAng(Vector(90,0,0))
	scd.coll:SetupNodeTransfer(self)  
	
	local sct = SpawnSO("forms/levels/city/sst/sst_transfer.dnmd",self,Vector(0,0,0),1) 
	sct:SetAng(Vector(90,0,0))
	sct.coll:SetupNodeTransfer(ovspace)  
	if #ovcon==0 then 
		local scd2 = SpawnSO("forms/levels/city/sst/sst_in.dnmd",ovspace,Vector(0,0,0),1) 
		scd2:SetAng(Vector(90,0,0))
		scd2.coll:SetupNodeTransfer(self)  
		
		ents.CreateWorldLink(self,ovspace,matrix.Identity())
		ents.CreateWorldLink(ovspace,self,matrix.Identity()) 
	elseif #ovcon==1 then
		local scd2 = SpawnSO("forms/levels/city/sst/sst_in.dnmd",ovspace,Vector(0,0,0),1) 
		scd2:SetAng(Vector(90,90,0))
		scd2.coll:SetupNodeTransfer(self)  

		local w = matrix.Rotation(Vector(0,-90,0))
		ents.CreateWorldLink(self,ovspace,w)
		ents.CreateWorldLink(ovspace,self,w) 
	end
	ovcon[#ovcon+1] = self
end

if ovcon and istable(ovcon) then
	for k,v in pairs(ovcon) do
		if IsValidEnt(v) then v:Despawn() end
	end
end  
ovcon= {}
if ovspace and IsValidEnt(ovspace) then
	ovspace:Despawn()
end
if ovtonnel and IsValidEnt(ovtonnel) then
	ovtonnel:Despawn()
end
   

function ENT:SetModel(mdl,scale,norotation) 
	scale = (scale or 1)*0.001
	norotation = norotation or false
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
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world)
	  
	local coll =  self.coll 
	if(model:HasCollision()) then
		coll:SetShapeFromModel(world)--matrix.Scaling(scale/0.75 ) * matrix.Rotation(-90,0,0) ) 
	end 
	

	self.modelcom = true

end 
