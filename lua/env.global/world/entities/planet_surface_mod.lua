
DeclareVartype("MINLEVEL",1210001,"int","minimal visible level")
DeclareVartype("MAXLEVEL",1210002,"int","maximal visible level")
DeclareVartype("SURFADD" ,1210003,"float","value add mod")
DeclareVartype("SURFMUL" ,1210004,"float","value mul mod")
DeclareVartype("SURFMODE",1210005,"string","modifier mode")
DeclareVartype("SURFMAP" ,1210006,"string","data reference") 
  
function ENT:Init() 
	self:SetSpaceEnabled(false)
end
function ENT:Spawn()  
	
	
	self:LoadData()
end
function ENT:Load()
	self:LoadData()
end
function ENT:LoadData()
	self:RemoveComponents(CTYPE_SURFACEMOD)
	 
	local type = self:GetParameter(VARTYPE_CHARACTER) 
	
		MsgN("type!",type) 
	if type then  
		local data = json.Read("forms/surfacemods/"..type..".json") 
		PrintTable(data)
		self.data =  data
		local mod =self:AddComponent(CTYPE_SURFACEMOD,data)
		
		self.mod = mod
	else 
		local datafile = self:GetParameter(VARTYPE_SURFMAP) or "crater_hm1.sdb"
		local minlevel = self:GetParameter(VARTYPE_MINLEVEL) or 6
		local sadd = self:GetParameter(VARTYPE_SURFADD) or 0
		local smul = self:GetParameter(VARTYPE_SURFMUL) or 1
		local smode = self:GetParameter(VARTYPE_SURFMODE) or "add"
		local mod = self:AddComponent(CTYPE_SURFACEMOD,{
			layer = {
				layertype = 1,--height
				dir = "forms/surfacedata/default/",
				
				minpower = minlevel, 
				
				mode = smode, 
				
				data = datafile, 
				width= 1024,--2216,
				height = 1024,--2445, 
				op_add = sadd,
				op_mul = smul,  
			}
		})
		
		self.mod = mod
	end
end
 
ENT.editor = {
	name = "Surface Modifier",
	properties = {
		data = {text = "datafile",type="parameter",valtype="string",key=VARTYPE_SURFMAP,reload=true}, 
		minlevel = {text = "minlevel",type="parameter",valtype="number",key=VARTYPE_MINLEVEL,reload=true},
		
		surfmode = {text = "mode",type="parameter",valtype="string",key=VARTYPE_SURFMODE,reload=true},
		surfadd = {text = "add",type="parameter",valtype="number",key=VARTYPE_SURFADD,reload=true},
		surfmul = {text = "mul",type="parameter",valtype="number",key=VARTYPE_SURFMUL,reload=true},  
	},  
	
}
