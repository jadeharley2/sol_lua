
SETTINGS_VALUES = {
	Categories = {
		{
			name = "Player",
			variables = {
				{ type = "string", name = "Name", var = "player.name", default = "New Player"},
				{ type = "string", name = "Character", var = "player.model", default = "kindred"},
				{ type = "string", name = "Skin IDs", var = "player.skinid", default = ""},
				{ type = "bool", name = "Hide in FP", var = "player.fpmode2", default = true},
			}
		},
		{
			name = "Graphics",
			variables = {
				{type = "bool", name = "EnableShadows", var = "engine.shadowsenabled", default = true},
				{type = "bool", name = "EnableMirrors", var = "engine.mirrorsenabled", default = true},
				{type = "number", name = "ShadowSize", var = "engine.shadowssize", default = 2048, proc = function(n)
					return math.Clamp(n,128,8192) end},
				{type = "number", name = "FOV", var = "engine.fov", default = 90, proc = function(n)
					return math.Clamp(n,45,110) end},
				--{type = "separator", name = "PostProcessing"},
				{type = "bool", name = "PostProcess enabled", var = "engine.pp_enabled", default = true, apply = function(v) render.GlobalRenderParameters():SetPostprocessEnabled(v) end},
				{type = "bool", name = "SSAO", var = "engine.pp_ssao", default = true, apply = function(v) render.GlobalRenderParameters():SetPostprocessSSAO(v) end},
				{type = "number", name = "SSAO samples", var = "engine.pp_ssao_samples", default = 128, proc = function(n)
					return math.Clamp(n,16,256) end, apply = function(v) render.GlobalRenderParameters():SetPostprocessSSAOSamples(v) end},
				{type = "bool", name = "SSLR", var = "engine.pp_sslr", default = true, apply = function(v) render.GlobalRenderParameters():SetPostprocessSSLR(v) end},
				{type = "bool", name = "Bloom enabled", var = "engine.pp_bloom", default = true, apply = function(v) render.GlobalRenderParameters():SetPostprocessBloom(v) end},
			}
		},
		{
			name = "Server",
			variables = {
				{type = "string", name = "ServerName", var = "server.name", default = "Sol Server"}, 
				{type = "bool", name = "FPOnly", var = "server.firstperson", default = false}, 
				{type = "bool", name = "NoFreeCam", var = "server.nofreecam", default = true}, 
				{type = "bool", name = "NoConsole", var = "server.noconsole", default = true}, 
			}
		},
	},
	List = {}
}

for k,v in pairs(SETTINGS_VALUES.Categories) do
	for k2,v2 in pairs(v.variables) do
		SETTINGS_VALUES.List[v2.var] = v2
	end
end


settings = settings or {}

function settings.GetBool(name,default)  
	local p = SETTINGS_VALUES.List[name]
	if p then
		return profile.GetBool(name,p.default)
	else 
		return profile.GetBool(name,default)
	end
end
function settings.SetBool(name,value) 
	profile.SetBool(name,value)
end
function settings.GetNumber(name,default)
	local p = SETTINGS_VALUES.List[name]
	if p then
		return profile.GetNumber(name,p.default)
	else 
		return profile.GetNumber(name,default)
	end
end
function settings.SetNumber(name,value) 
	profile.SetNumber(name,value)
end
function settings.GetString(name,default) 
	local p = SETTINGS_VALUES.List[name]
	if p then
		return profile.GetString(name,p.default)
	else 
		return profile.GetString(name,default)
	end
end
function settings.SetString(name,value) 
	profile.SetString(name,value)
end
function settings.Save() 
	profile.Save()
end

function settings.Apply() 
	for k2,v2 in pairs(SETTINGS_VALUES.List) do
		if v2.apply then
			local val = nil 
			if v2.type == "bool" then
				val = settings.GetBool(v2.var,v2.default) 
			elseif v2.type =="number" then
				val = settings.GetNumber(v2.var,v2.default) 
			end
			if val ~= nil then v2.apply(val) Msg("s_apply ",v2.name," to ",val) end 
		end
	end 
end