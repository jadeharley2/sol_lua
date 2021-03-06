
component.editor = {
	name = "Orbit",
	properties = {
		va = {text="semi-major axis",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) m:SetParam("a",v) end,
			get = function(n,m,k) return m:GetParam("a") end,
		},
		vb = {text="semi-minor axis",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) m:SetParam("b",v) end,
			get = function(n,m,k) return m:GetParam("b") end,
		},
		vc = {text="c",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) m:SetParam("c",v) end,
			get = function(n,m,k) return m:GetParam("c") end,
		},
		ve = {text="eccentricity",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) m:SetParam("e",v) end,
			get = function(n,m,k) return m:GetParam("e") end,
		},
		vp = {text="periargument",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) m:SetParam("p",v) end,
			get = function(n,m,k) return m:GetParam("p") end,
		},
		vi = {text="inclination",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) m:SetParam("i",v) end,
			get = function(n,m,k) return m:GetParam("i") end,
		},
		vma = {text="meananomaly",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) m:SetParam("meananomaly",v) end,
			get = function(n,m,k) return m:GetParam("meananomaly") end,
		},
		val = {text="ascendinglongitude",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) m:SetParam("ascendinglongitude",v) end,
			get = function(n,m,k) return m:GetParam("ascendinglongitude") end,
		},
		vspd = {text="meanspeed",type="parameter",valtype="number",reload=false,
			apply = function(n,m,k,v) m:SetParam("meanspeed",v) end,
			get = function(n,m,k) return m:GetParam("meanspeed") end,
		},
		
	},
	
}