if not CLIENT then return end

physhandle = {}

function  physhandle.GetPos()
    local t = GetMousePhysTrace(GetCamera())
    if t.Hit then
        debug.ShapePrimCreate(2323, t.Node, "sphere",
            matrix.Scaling(1/t.Node:GetSizepower())
            *matrix.Translation(t.Position),Vector(3,3,3))
        return t.Position, t.Node
    end
end   
function  physhandle.Start()
    hook.Add(EVENT_GLOBAL_UPDATE,"physhandle",function()
        physhandle.Update()
    end)
    hook.Add("input.mousedown","physhandle",function (key)
        if(input.leftMouseButton()) then
            physhandle.Click()
        end
    end)
end
function  physhandle.End()
    hook.Remove(EVENT_GLOBAL_UPDATE,"physhandle")
    hook.Remove("input.mousedown","physhandle")
end
function  physhandle.Update()
    local p, n = physhandle.GetPos()
    if p and physhandle.lastpos then
        debug.ShapeLineCreate(2424,n,p,physhandle.lastpos,Vector(3,3,3))
    end
end
function  physhandle.Click()
    local p,n = physhandle.GetPos()
    if p then 
        physhandle.lastpos = p
        debug.ShapePrimCreate(2324, n, "sphere",
            matrix.Scaling(2/n:GetSizepower())
            *matrix.Translation(p),Vector(3,3,3))
        hook.Call("physhandle.click",p,n)
    end
end