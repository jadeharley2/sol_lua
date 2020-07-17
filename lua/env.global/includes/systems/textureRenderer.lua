if SERVER then return nil end

RTENT =  RTENT or  false 
RTHUMB =  RTHUMB or  false 
RSPRITE =  RSPRITE or  false 
function RenderTexture(width,height,task,callback) 
	local rte = RTENT
	if not IsValidEnt(rte) then 
		rte = ents.Create("util_textureRenderer")
		rte:SetName("textureSpace")
		rte:Spawn()
		RTENT = rte
	end 
	rte:Draw(nil,task,callback) 
end

function RenderThumbnail(form,callback) 
	local rte = RTHUMB
	if not rte or not IsValidEnt(rte) then  
		rte = ents.Create("util_thumbnailRenderer")
		rte:SetName("thumbnailSpace")
		rte:Spawn()
		RTHUMB = rte 
	end 
	rte:Draw(form,callback) 
end


function RenderSprite(form,callback,params) 
	local rte = RSPRITE
	if not rte or not IsValidEnt(rte) then  
		rte = ents.Create("util_spriteRenderer")
		rte:SetName("spriteSpace")
		rte:Spawn()
		RSPRITE = rte 
		MsgN("strt")
	end 
	rte:Draw(form,callback,params) 
end

local st_static = {}
st_static.data = {
	fov = 10,
	ang = Vector(0,0,0),
	tech = "normal"
}
st_static.mbox_callback = function (k)
	local data = st_static.data
	if k=="<<" then
		data.ang = Vector(data.ang.x,data.ang.y+90,data.ang.z)
	end
	if k==">>" then
		data.ang = Vector(data.ang.x,data.ang.y-90,data.ang.z)
	end
	if k=="+" then
		data.fov = data.fov - 1
	end
	if k=="-" then
		data.fov = data.fov + 1
	end
	if k=="SAVE" then
		if st_static.texture then
			st_static.texture:Save("output/spriterenderout_d.png")
			st_static.texturen:Save("output/spriterenderout_n.png")
		end
	end
	st_static.data = data
	RenderSprite(st_static.formid,st_static.callback,data)
end
st_static.callback = function (tex,texn)
	st_static.texture = tex
	st_static.texturen = texn
	local panels = {
		textonly = true,
		dock = DOCK_FILL,
		subs = {
			{
				texture = tex,
				size = {500,500},
				dock = DOCK_LEFT,
			},
			{
				texture = texn,
				size = {500,500},
				dock = DOCK_FILL,
			},
		}
	}
	MsgBox(panels, "sprite", {"CLOSE","<<",">>","+","-","SAVE"},st_static.mbox_callback, {1000,500})
end
console.AddCmd("debug_sprite",function (formid,fov,angY,angX)  
	st_static.formid = formid
	st_static.data = {
		fov = tonumber(fov) or 10,
		ang = Vector(tonumber(angX or '0'),tonumber(angY or '0'),0), 
	}
	RenderSprite(formid,st_static.callback,st_static.data)
end)
--RSPRITE = nil    