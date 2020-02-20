
hook.Add("prop.variable.load","materials",function (self,j,tags)  
    if j.material then
		local rmodel = self.model
		if isstring(j.material) then
			rmodel:SetMaterial(j.material) 
		end  
	end
	if j.replacematerial then
		local rmodel = self.model
		for k,v in pairs(j.replacematerial) do
			if isstring(v) then
				rmodel:SetMaterial(LoadMaterial(v),k-1) 
			end
		end
	end
	if j.modmaterial then
		local rmodel = self.model
		for k,v in pairs(j.modmaterial) do  
			local mat = rmodel:GetMaterial(k-1)
			if not nocopy and mat then
				mat = CopyMaterial(mat)
				rmodel:SetMaterial(mat,k-1)
			end
			for kk,vv in pairs(v) do
				if istable(vv) and #vv == 3 then
					SetMaterialProperty(mat,kk,JVector(vv))
				else
					SetMaterialProperty(mat,kk,vv)
				end
			end
		end
	end
end)