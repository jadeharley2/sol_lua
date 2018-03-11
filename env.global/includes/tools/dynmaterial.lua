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



function ModModelMaterials(model,modtable,nocopy)
	
	local mc = model:GetMaterialCount()
	local mt = {}
	for k=1,mc do
		local mat = model:GetMaterial(k-1)
		if not nocopy then
			mat = CopyMaterial(mat)
			model:SetMaterial(mat,k-1)
		end
		for kk,vv in pairs(modtable) do
			SetMaterialProperty(mat,kk,vv)
		end
	end
	
end
function ModNodeMaterials(node,modtable,nocopy,recursive)
	local comp = node:GetComponent(CTYPE_MODEL)
	if comp then
		ModModelMaterials(comp,modtable)
	end
	if recursive then
		for k,v in pairs(node:GetChildren()) do
			ModNodeMaterials(v,modtable,nocopy,recursive)
		end
	end
end
function ModNodeRenderOrder(node,newOrder) 
	local comp = node:GetComponent(CTYPE_MODEL)
	if comp then
		comp:SetRenderOrder(newOrder)
	end 
	for k,v in pairs(node:GetChildren()) do
		ModNodeRenderOrder(v,newOrder)
	end
end