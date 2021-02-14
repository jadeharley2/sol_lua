local lastdimage = false

function DisplayTexture(path)
    path = cstring.trimchars(path,'"\'')
    if lastdimage then
        lastdimage:Close()
        lastdimage = false
    end
    lastdimage = gui.FromTable({
        type = "button",
        size = {1024,1024},
        texture = path,
        OnClick = function (s)
            s:Close()
        end,  
    })
    lastdimage:SetColorAuto(Vector(1,1,1),0)
    lastdimage:Show()
end
function PlaySound(path)
    path = cstring.trimchars(path,'"\'')
    sound.Start(path,1,1)
end
console.AddCmd("display_texture",DisplayTexture)  

local image_formats = {png=true,dds=true,tga=true,jpg=true,bmp=true,vtf=true}
hook.Add("display","texture",function (path)
    local prts = cstring.split(path,'.')
    local ext = string.lower(prts[#prts])
    MsgN(path)
    if image_formats[ext] then
        DisplayTexture(path)
    end
end)

local sound_formats = {wav=true,ogg=true}
hook.Add("display","sound",function (path)
    local prts = cstring.split(path,'.')
    local ext = string.lower(prts[#prts])
    MsgN(path)
    if sound_formats[ext] then
        GetCamera():EmitSound(path,1,1);
    end
end)


function DisplayModel(path)
    path = cstring.trimchars(path,'"\'')
    if lastdimage then
        lastdimage:Close()
        lastdimage = false
    end
    lastdimage = gui.FromTable({
        type = "thumbnail",
        size = {1024,1024},
        MouseDown = function (s)
            s:Close()
        end,  
        Path = path,
    }) 
    --lastdimage:Show()
end

local model_formats = {smd=true,stmd=true,dnmd=true,mdl=true}
hook.Add("display","model",function (path)
    local prts = cstring.split(path,'.')
    local ext = string.lower(prts[#prts])
    MsgN(path)
    if model_formats[ext] then
        DisplayModel(path)
    end
end)
hook.Remove("display","model")