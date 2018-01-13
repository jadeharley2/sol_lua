--TEST
local embmat =  LoadMaterial("tile/mat/ebony.json")

function Transformation(actor,target_character)
	target_character = target_character or "mlp_rainbow"
	
	local data = json.Read("forms/characters/"..target_character..".json")
	
	if not data then return nil end
	
	local parts = actor:GetAllParts()
	local transformation = {parts={}}
	--parts[#parts+1] = actor
	local cpymat =  CopyMaterial(embmat)
	
	local oldparts = {}
	local newparts = {}
	
	
	
	local spd = data.species:split(':')
	local species = spd[1]
	local variation = spd[2]
	local speciesdata = json.Read("forms/species/"..species..".json")
		
	local bpath = speciesdata.model.basedir
	for k,v in pairs(data.parts) do 
		local part =  SpawnBP(bpath..v..".json",actor,0.03)
		part.mat = {}
		newparts[k] = part
		
	end
	if data.materials then
		local bmatdir = data.basematdir
		for k,v in pairs(data.materials) do
			local keys = k:split(':') 
			local bpart = keys[1]
			local id = tonumber( keys[2])
			
			local part = newparts[bpart]
			if bpart == "root" then part = self end 
			if part then  
				local mat = dynmateial.LoadDynMaterial(v,bmatdir)
				part.model:SetMaterial(mat,id)
				part.mat[#part.mat+1] = mat
			end
		end
	end
	for k,v in pairs(parts) do
		oldparts[k] = v
		
		local model = v.model
		local matc = model:GetMaterialCount()
		local mat = {}
		for k=1,matc do 
			local pmt =CopyMaterial( model:GetMaterial(k-1))  
			model:SetMaterial(pmt,k-1)  
			mat[k] =pmt  -- model:GetMaterial(k-1) --pmt 
		end 
		v.mat = mat
	end
	
	if newparts and newparts.wings and newparts.wings_folded then 
		newparts.wings.model:Enable(false)
		newparts.wings.model:SetMaxRenderDistance(0)
		newparts.wings_folded.model:Enable(true)
		newparts.wings_folded.model:SetMaxRenderDistance(100)
	end
	--[[
	for k,v in pairs(parts) do
		local model = v.model
		local part = {pstate ={},nstate={},p = v}
		if model then
			local matc = model:GetMaterialCount()
			
			local sdm = v:AddComponent(CTYPE_MODEL)   
	 
			local world = matrix.Scaling(0.03) 
			sdm:SetRenderGroup(RENDERGROUP_LOCAL)
			sdm:SetModel(v:GetParameter(VARTYPE_MODEL))  
			sdm:SetBlendMode(BLEND_OPAQUE) 
			sdm:SetRasterizerMode(RASTER_DETPHSOLID) 
			sdm:SetDepthStencillMode(DEPTH_ENABLED)  
			sdm:SetBrightness(1)
			sdm:SetFadeBounds(0,9e20,0)  
			sdm:SetMatrix(model:GetMatrix())--*matrix.Scaling(1.5))
			--if k~=1 then
				sdm:SetCopyTransforms(parts[1].model)
			--end
			 
			
			local pmat = {}
			local nmat = {}
			for k=1,matc do 
				local pmt =CopyMaterial( model:GetMaterial(k-1)) 
				--local pmt2 =CopyMaterial( model:GetMaterial(k-1)) 
				sdm:SetMaterial(pmt,k-1) 
				model:SetMaterial(cpymat,k-1) 
				pmat[k] = pmt
				nmat[k] = cpymat
			end 
			part.matc = matc
			part.pstate.model = model
			part.pstate.materials = pmat
			part.nstate.model = sdm
			part.nstate.materials = nmat
			
			
		end
		transformation.parts[k] = part
	end
	]]
	transformation.progress = 0
	transformation.End = function()
		if transformation.ended then return nil end
		transformation.ended = true
		for k,part in pairs(transformation.parts) do
			for k=1,part.matc do	
				local mat = part.nstate.materials[k] 
				SetMaterialProperty(mat,"noiseclip",false) 
				local mat = part.pstate.materials[k] 
				SetMaterialProperty(mat,"noiseclip",false) 
				--part.pstate.model:SetMaterial(k-1,mat)
			end
			if part.nstate.model then
				part.p:RemoveComponent(part.nstate.model)
			end
		end
		
		--actor:SetSpeedMul(0)
		--actor:SetUpdating(false)
		
		local up = actor.phys
		if up then
		--	up:SetControllerEnabled(false)
		--	up:SetMass(0)
		--	up:SetMass(30)
		end
		--actor:SetParameter(VARTYPE_LUATYPE,"prop_physics")
		if actor.species then
		--	actor:SetName((actor.species.racename or actor:GetName()).." statue") 
		else
		--	actor:SetName(actor:GetName().." statue") 
		end
		--actor:AddFlag(FLAG_STOREABLE)
		--actor:RemoveFlag(FLAG_PLAYER) 
		actor:SendEvent(EVENT_CHANGE_CHARACTER,target_character)
		
		for k,v in pairs(newparts) do
			v:Despawn()
		end 
		
		MsgN("END!")
	end 
	debug.DelayedTimer( 0,10,1001,function()
		if transformation.abort then transformation.End() return nil end
		local D = transformation.progress
		transformation.progress = D+0.001
		for k,v in pairs(transformation.parts) do
			for k=1,v.matc do	
				local mat1 = v.nstate.materials[k] 
				SetMaterialProperty(mat1,"g_NoiseTexture","textures/noise/perlinover_n.jpg")--GetMaterialProperty(mat,"g_MeshTexture"))
				SetMaterialProperty(mat1,"noiseclip",true)
				SetMaterialProperty(mat1,"noiseclipmul",1) 
				SetMaterialProperty(mat1,"noiseclipedge",1-D)
				--SetMaterialProperty(mat,"noiseclipmul",-1) 
				--SetMaterialProperty(mat,"noiseclipedge",D-0.95)
				local mat2 = v.pstate.materials[k] 
				SetMaterialProperty(mat2,"g_NoiseTexture","textures/noise/perlinover_n.jpg")--GetMaterialProperty(mat,"g_MeshTexture"))
				SetMaterialProperty(mat2,"noiseclip",true)
				SetMaterialProperty(mat2,"noiseclipmul",-1) 
				SetMaterialProperty(mat2,"noiseclipedge",D-1)
			end
		end 
		for k,v in pairs(oldparts) do
			for kk,mat in pairs(v.mat) do	  
				SetMaterialProperty(mat,"g_NoiseTexture","textures/noise/perlinover_n.jpg")--GetMaterialProperty(mat,"g_MeshTexture"))
				SetMaterialProperty(mat,"noiseclip",true)
				SetMaterialProperty(mat,"noiseclipmul",-1) 
				SetMaterialProperty(mat,"noiseclipedge",D-1)
			end
		end 
		for k,v in pairs(newparts) do
			for kk,mat in pairs(v.mat) do	  
				SetMaterialProperty(mat,"g_NoiseTexture","textures/noise/perlinover_n.jpg")--GetMaterialProperty(mat,"g_MeshTexture"))
				SetMaterialProperty(mat,"noiseclip",true)
				SetMaterialProperty(mat,"noiseclipmul",1) 
				SetMaterialProperty(mat,"noiseclipedge",1-D)
			end
		end 
		
		--actor:SetSpeedMul(math.max(0,1-D))
		if D+0.001>1 then
			transformation.End() 
			return nil 
		end
	end)
	return transformation
end