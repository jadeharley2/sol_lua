--dynamic materials and textures
dynmateial = dynmateial or {}
dynmateial.LoadDynMaterial = function(data, bmatdir) 
	--procedural check
	local proc = {}
	for kk,vv in pairs(data) do
		if istable(vv) and vv.subs then 
			local root = gui.FromTable(vv) 
			proc[kk] = root
			data[kk] = "textures/ponygen/body.dds"
		end
	end  
	local mat = NewMaterial(bmatdir, json.ToJson(data)) 
	
	for k,v in pairs(proc) do
		RenderTexture(512,512,v,function(rtex)
			SetMaterialProperty(mat,k,rtex) 
		end)  
	end
	return mat 
end