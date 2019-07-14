
component.editor = {
	name = "Physics space",
	properties = {  
		mass= {text = "Gravity",type="parameter",valtype="string",reload=false,
			apply = function(n,m,k,v) m:SetGravity(JVector(v)) end,
			get = function(n,m,k) if m.GetGravity then return m:GetGravity(VectorJ(v)) end return 0 end,
		},  
	},
	
}       