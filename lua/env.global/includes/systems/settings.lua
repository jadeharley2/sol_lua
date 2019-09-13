
SETTINGS_VALUES = {
	Categories = {
		{
			name = "Player",
			variables = {
				{ type = "string", name = "Name", var = "player/name", default = "New Player"},
				{ type = "string", name = "Character", var = "player/model", default = "vikna"},
				{ type = "string", name = "Skin IDs", var = "player/skinid", default = ""},
				{ type = "bool", name = "Hide in FP", var = "player/fpmode2", default = true},
				{ type = "bool", name = "Disable RI in FP", var = "player/fpmode2_rotintertia", default = false},
			}
		},
		{
			name = "Graphics",
			variables = {
				{type = "bool", name = "EnableShadows", var = "engine/shadowsenabled", default = true},
				{type = "bool", name = "EnableMirrors", var = "engine/mirrorsenabled", default = true},
				{type = "number", name = "ShadowSize", var = "engine/shadowssize", default = 2048, proc = function(n)
					return math.Clamp(n,128,8192) end},
				{type = "number", name = "FOV", var = "engine/fov", default = 90, proc = function(n)
					return math.Clamp(n,45,110) end},
				--{type = "separator", name = "PostProcessing"},
				{type = "bool", name = "PostProcess enabled", var = "engine/pp_enabled", default = true, apply = function(v) render.GlobalRenderParameters():SetPostprocessEnabled(v) end},
				{type = "bool", name = "SSAO", var = "engine/pp_ssao", default = true, apply = function(v) render.GlobalRenderParameters():SetPostprocessSSAO(v) end},
				{type = "number", name = "SSAO samples", var = "engine/pp_ssao_samples", default = 128, proc = function(n)
					return math.Clamp(n,16,256) end, apply = function(v) render.GlobalRenderParameters():SetPostprocessSSAOSamples(v) end},
				{type = "bool", name = "SSLR", var = "engine/pp_sslr", default = true, apply = function(v) render.GlobalRenderParameters():SetPostprocessSSLR(v) end},
				{type = "bool", name = "Bloom enabled", var = "engine/pp_bloom", default = true, apply = function(v) render.GlobalRenderParameters():SetPostprocessBloom(v) end},
				{type = "bool", name = "Grass enabled", var = "engine/gsh_grass", default = true, apply = function(v) render.GlobalRenderParameters():SetDrawGSGrass(v) end},
				{type = "bool", name = "Fur enabled", var = "engine/fur", default = true, apply = function(v) render.GlobalRenderParameters():SetDrawGSFur(v) end},
				
				{type = "bool", name = "Volume clouds top", var = "engine/cheapclouds_top", default = true, apply = function(v) render.GlobalRenderParameters():SetVolumeCloudsTop(v) end},
				{type = "bool", name = "Volume clouds bot", var = "engine/cheapclouds_bot", default = true, apply = function(v) render.GlobalRenderParameters():SetVolumeCloudsBot(v) end},

			}
		},
		{
			name = "Controls",
			variables = {
				{type = "key", name = "Move forward", 	var = "input/move/forward", 	default = KEYS_W},
				{type = "key", name = "Move left", 		var = "input/move/left", 		default = KEYS_A},
				{type = "key", name = "Move backward", 	var = "input/move/back", 		default = KEYS_S},
				{type = "key", name = "Move right", 	var = "input/move/right", 		default = KEYS_D},
				{type = "key", name = "Move up", 		var = "input/move/up", 			default = KEYS_SPACE},
				{type = "key", name = "Move down", 		var = "input/move/down", 		default = KEYS_CONTROLKEY},
				 

				{type = "key", name = "Rotate left", 	var = "input/rotate/left", 		default = KEYS_Q},
				{type = "key", name = "Rotate right", 	var = "input/rotate/right", 	default = KEYS_E},
				
				{type = "key", name = "Inventory", 		var = "input/actor/inventory", 		default = KEYS_Q},
				{type = "key", name = "Use", 			var = "input/actor/use", 			default = KEYS_E},
				{type = "key", name = "Pickup", 		var = "input/actor/pickup", 		default = KEYS_F},
				{type = "key", name = "Jump", 			var = "input/actor/jump", 			default = KEYS_SPACE},
				{type = "key", name = "Duck", 			var = "input/actor/duck", 			default = KEYS_CONTROLKEY},
			}
		},
		{
			name = "Server",
			variables = {
				{type = "string", name = "ServerName", var = "server/name", default = "Sol Server"}, 
				{type = "bool", name = "FPOnly", var = "server/firstperson", default = false}, 
				{type = "bool", name = "NoFreeCam", var = "server/nofreecam", default = true}, 
				{type = "bool", name = "NoConsole", var = "server/noconsole", default = true}, 
			}
		},
	},
	List = {},
	Index = {}
}

for k,v in pairs(SETTINGS_VALUES.Categories) do
	for k2,v2 in pairs(v.variables) do
		SETTINGS_VALUES.List[v2.var] = v2

		SETTINGS_VALUES.Index[v2.var] = v2
		SETTINGS_VALUES.Index[string.Replace(v2.var,'/','.')] = v2
	end
end


settings = settings or {}

function settings.GetBool(name,default)  
	name = string.Replace(name,'%.','/')
	local p = SETTINGS_VALUES.Index[name]
	if p then
		return profile.GetBool(name,p.default)
	else 
		return profile.GetBool(name,default)
	end
end
function settings.SetBool(name,value) 
	name = string.Replace(name,'%.','/')
	profile.SetBool(name,value)
end
function settings.GetNumber(name,default)
	name = string.Replace(name,'%.','/')
	local p = SETTINGS_VALUES.Index[name]
	if p then
		return profile.GetNumber(name,p.default)
	else 
		return profile.GetNumber(name,default)
	end
end
function settings.SetNumber(name,value) 
	name = string.Replace(name,'%.','/')
	profile.SetNumber(name,value)
end
function settings.GetString(name,default) 
	name = string.Replace(name,'%.','/')
	local p = SETTINGS_VALUES.Index[name]
	if p then
		return profile.GetString(name,p.default)
	else 
		return profile.GetString(name,default)
	end
end
function settings.SetString(name,value) 
	name = string.Replace(name,'%.','/')
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