
component.editor = {
	name = "Model",
	properties = { 
		model_path = {text="path",type="parameter",valtype="path",reload=true,key=VARTYPE_MODEL},
		mat_override= {text = "matoverride",type="parameter",valtype="path",reload=false,apply = function(n,m,k,v) 
			m:SetMaterial(v)
		end},
		render_group= {text = "rendergroup",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) m:SetRenderGroup(v) end,
			get = function(n,m,k) return m:GetRenderGroup() end,
		},
		render_order= {text = "renderorder",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) m:SetRenderOrder(v) end,
			get = function(n,m,k) return m:GetRenderOrder() end,
		}, 
	},
	
}