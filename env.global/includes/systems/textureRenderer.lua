if SERVER then return nil end

 RTENT =    false 
function RenderTexture(width,height,task,callback)
	local rt = CreateRenderTarget(width,height,"")
	local rte = RTENT
	if not rte then 
		rte = ents.Create("util_textureRenderer")
		rte:Spawn()
		RTENT = rte
	end 
	rte:Draw(rt,task,callback)
	return rt
end          