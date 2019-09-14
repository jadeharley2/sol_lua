if SERVER then return nil end

RTENT =  RTENT or  false 
RTHUMB =  RTHUMB or  false 
function RenderTexture(width,height,task,callback) 
	local rte = RTENT
	if not IsValidEnt(rte) then 
		rte = ents.Create("util_textureRenderer")
		rte:Spawn()
		RTENT = rte
	end 
	rte:Draw(nil,task,callback) 
end                                     

function RenderThumbnail(form,callback) 
	local rte = RTHUMB
	if not rte or not IsValidEnt(rte) then 
		MsgN("huh",rte)
		rte = ents.Create("util_thumbnailRenderer")
		rte:Spawn()
		RTHUMB = rte
		MsgN("huh2",rte)
	end 
	rte:Draw(form,callback) 
end                                     
 