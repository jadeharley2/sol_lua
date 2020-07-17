
component.editor = {
	name = "Physics space",
	properties = {  
		mass= {text = "Gravity",type="parameter",valtype="string",reload=false,
			apply = function(n,m,k,v) m:SetGravity(JVector(v)) end,
			get = function(n,m,k) if m.GetGravity then return m:GetGravity() end return 0 end,
		},  
	},
	
} 

local physspacemeta = FindMetaTable("PhysSpace")
function physspacemeta:SetupData(data)
	MsgN("DF",self)
	if data.gravity then
		self:SetGravity(JVector(data.gravity))
	end
end