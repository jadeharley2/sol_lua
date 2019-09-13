--dynamic materials and textures
dynmateial = dynmateial or {}
dynmateial.LoadDynMaterial = function(data, bmatdir) 
	--procedural check
	if isstring(data) then
		return data
	end
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

local METAMAT = DEFINE_METATABLE("MetaMaterial")

function METAMAT:Flatten()
	local r = {}
	self:_appendnodes(self,r)
	return setmetatable(r,METAMAT)
end
function METAMAT:_appendnodes(n,ray)
	if n.nodes then
		for k,v in pairs(n.nodes) do
			self:_appendnodes(v,ray)
		end
	else
		ray[#ray+1] = n
	end
end
function METAMAT:Apply()
	RestoreMaterials(self)
end
function METAMAT:Clear()
	ClearMaterials(self)
end
function METAMAT:MakeUnique() 
end
function METAMAT:Mod(modtable) 
	if self.materials then
		for k,v in pairs(self.materials) do
			for kk,vv in pairs(modtable) do
				SetMaterialProperty(v,kk,vv)
			end 
		end
	end 
	if self.nodes then
		for k,v in pairs(self.nodes) do
			self.Mod(v,modtable)
		end
	end
end

METAMAT.__index = METAMAT
--returns
--[[
	[
		[model_com,[
			[matid,material]
			[matid,material]
			...
		] ]
		[model_com,[
			[matid,material] 
			...
		] ]
		...
	]
]]

function RestoreMaterials(table)  
	if table.materials and table.model then
		for k,v in pairs(table.materials) do
			table.model:SetMaterial(v,k-1)
		end
	end 
	if table.nodes then
		for k,v in pairs(table.nodes) do
			RestoreMaterials(v)
		end
	end
end
function ClearMaterials(table)  
	if table.materials and table.model then
		for k,v in pairs(table.materials) do
			table.model:SetMaterial(v,nil)
		end
	end 
	if table.nodes then
		for k,v in pairs(table.nodes) do
			ClearMaterials(v)
		end
	end
end

function ModModelsMaterials(models,modtable,nocopy)
	local restore_n = {}
	for k,v in pairs(models) do
		restore_n[#restore_n+1] = ModModelMaterials(v,modtable,nocopy)
	end
	return setmetatable({nodes = restore_n},METAMAT)
end
function ModModelMaterials(model,modtable,nocopy) 
	local mc = model:GetMaterialCount()
	local restore = {}
	for k=1,mc do
		local mat = model:GetMaterial(k-1)
		if not nocopy then
			restore[k] = mat 
			mat = CopyMaterial(mat)
			model:SetMaterial(mat,k-1)
		end
		for kk,vv in pairs(modtable) do
			SetMaterialProperty(mat,kk,vv)
		end
	end
	return  setmetatable({materials = restore, model = model},METAMAT)
end
function ModNodeMaterials(node,modtable,nocopy,recursive)
	local comp = node:GetComponent(CTYPE_MODEL)
	local restore_n = {}
	if comp then
		restore_n[#restore_n+1] = ModModelMaterials(comp,modtable)
	end
	if recursive then
		for k,v in pairs(node:GetChildren()) do
			restore_n[#restore_n+1] =  ModNodeMaterials(v,modtable,nocopy,recursive)
		end
	end
	return  setmetatable({nodes = restore_n},METAMAT)
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
function ModMaterial(mat,modtable) 
	for kk,vv in pairs(modtable) do
		SetMaterialProperty(mat,kk,vv)
	end
end

function dynmateial.GetModels(node,recursive,tab)
	tab = tab or {}
	tab[#tab+1] = node:GetComponent(CTYPE_MODEL)
	if recursive then
		for k,v in pairs(node:GetChildren()) do
			dynmateial.GetModels(v,true,tab)
		end
	end
	return tab
end

function dynmateial.GetUniqueMaterials(node,filter)
	tab = tab or {}
	local model = node:GetComponent(CTYPE_MODEL)
	if model then
		for k,v in pairs(model:GetMaterials()) do
			tab[v] = model:GetMaterial(k-1) 
		end
	end 
	for k2,v2 in pairs(node:GetChildren(true)) do
		if not filter or filter(v2) then
			local model = v2:GetComponent(CTYPE_MODEL)
			if model then
				for k,v in pairs(model:GetMaterials()) do
					tab[v] = model:GetMaterial(k-1) 
				end
			end 
		end
	end 

	local nt = {}
	for k,v in pairs(tab) do
		nt[#nt+1] = v
	end

	return  setmetatable({materials = nt, model = model},METAMAT)
end