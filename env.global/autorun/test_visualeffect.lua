--TEST

function Transformation(actor)
	
	local parts = actor:GetAllParts()
	local transformation = {parts={}}
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
			sdm:SetMatrix(model:GetMatrix()*matrix.Scaling(1.5))
			if k~=1 then
				sdm:SetCopyTransforms(parts[1].model)
			end
			 
			
			local pmat = {}
			local nmat = {}
			for k=1,matc do 
				local pmt = model:GetMaterial(k-1)
				local cpy = LoadMaterial("tile/mat/ebony.json")
				sdm:SetMaterial(k-1,pmt) 
				model:SetMaterial(k-1,cpy) 
				pmat[k] = pmt
				nmat[k] = cpy
			end 
			part.matc = matc
			part.pstate.model = model
			part.pstate.materials = pmat
			part.nstate.model = sdm
			part.nstate.materials = nmat
			
			
		end
		transformation.parts[k] = part
	end
	transformation.progress = 0
	transformation.End = function()
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
	end 
	debug.DelayedTimer( 0,10,1001,function()
		if transformation.abort then transformation.End() return nil end
		local D = transformation.progress
		transformation.progress = D+0.001
		for k,v in pairs(transformation.parts) do
			for k=1,v.matc do	
				local mat = v.nstate.materials[k] 
				SetMaterialProperty(mat,"g_NoiseTexture","textures/noise/perlinover_n.jpg")--GetMaterialProperty(mat,"g_MeshTexture"))
				SetMaterialProperty(mat,"noiseclip",true)
				--SetMaterialProperty(mat,"noiseclipmul",-1) 
				--SetMaterialProperty(mat,"noiseclipedge",D)
				SetMaterialProperty(mat,"noiseclipmul",-1) 
				SetMaterialProperty(mat,"noiseclipedge",D-0.95)
				local mat = v.pstate.materials[k] 
				SetMaterialProperty(mat,"g_NoiseTexture","textures/noise/perlinover_n.jpg")--GetMaterialProperty(mat,"g_MeshTexture"))
				SetMaterialProperty(mat,"noiseclip",true)
				SetMaterialProperty(mat,"noiseclipmul",-1) 
				SetMaterialProperty(mat,"noiseclipedge",D-0.95)
			end
		end 
		if D+0.001>1 then
			transformation.End() 
			return nil 
		end
	end)
	return transformation
end