
component.editor = {
	name = "Physics object",
	properties = {  
		mass= {text = "Mass",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) m:SetMass(v) end,
			get = function(n,m,k) return m:GetMass() end,
		}, 
	},
	
}       