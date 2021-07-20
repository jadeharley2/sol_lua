
component.editor = {
	name = "Light",
	properties = {
		color = {text="color",type="parameter",valtype="color",reload=true,key=VARTYPE_COLOR},
		--brightness = {text="brightness",type="parameter",valtype="number",reload=true,key=VARTYPE_BRIGHTNESS},
		
		brightness = {text="Brightness",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) 
				m:SetBrightness(v)  
			end,
			get = function(n,m,k) 
				return m:GetBrightness()
			end
		}, 
		 
		color = {text="Color",type="parameter",valtype="color",reload=false,
			apply = function(n,m,k,v) 
				m:SetColor(v)  
			end,
			get = function(n,m,k) 
				return m:GetColor()
			end
		}, 

		shadow = {text="Shadow",type="parameter",valtype="bool",reload=false,
			apply = function(n,m,k,v) 
				m:SetShadow(v)  
			end,
			get = function(n,m,k) 
				return m:GetShadow()
			end
		}, 
		 
	},
	 
}