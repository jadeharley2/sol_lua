
viseffect = viseffect or {}
viseffect.list = viseffect.list or {}

function viseffect.Start(node,type,speed,args) 
    
    speed = speed or 1

end
function viseffect.End() 
     

end
function viseffect.Update() 
     

end

local dissolve = dissolve or {}
function dissolve:Start(node,targs)
    self.node = node
    self.targs = targs

    local argsfin = table.Merge(targs,{
        noiseclip=true,
        noiseclipedge=0,
        noiseclipmul=-1,
        g_NoiseTexture="textures/noise/perlin1.jpg"
    }) 
    
    if istable(node) then

    else
        self.models = dynmateial.GetModels(node,true)
    end
    
    self.tmodels  = {}
    for k,v in pairs(self.models) do
        self.tmodels[#self.tmodels+1] = v:Clone()
    end 
 


    self.bmat = ModModelsMaterials(self.models,{
        noiseclip=true,
        noiseclipedge=0,
        noiseclipmul=1,
        g_NoiseTexture="textures/noise/perlin1.jpg"
    },false,true)
    self.cmat = ModModelsMaterials(self.tmodels,argsfin,false,true)

    self.time = 0
    return true
end
function dissolve:Update()
    local time = self.time +0.01
    self.time = time
    if self.ustart then--error in prev loop
        return false
    end
    self.ustart=true
    ModModelsMaterials(self.models,{ 
        noiseclipedge=time 
    },true,true)
    ModModelsMaterials(self.tmodels,{ 
        noiseclipedge=-time
    },true,true)
    self.ustart=false

    return time>1
end
function dissolve:End()
    if self.targs then 
        self.targs.noiseclip=false
        ModModelsMaterials(self.models,self.targs,true,true)
    else
        if self.bmat then RestoreMaterials(self.bmat) end
    end
    if self.tmodels then
        for k,v in pairs(self.tmodels) do
            v:GetNode():RemoveComponent(v)
        end  
    end
end
dissolve.__index = dissolve


disstest = function(n,...) 
    local d = setmetatable({},dissolve)
    if(d:Start(n,...))then 
        hook.Add(EVENT_GLOBAL_UPDATE,"dis",function() 
            if d:Update() then  
                hook.Remove(EVENT_GLOBAL_UPDATE,"dis")
                d:End()
            end 
        end)

    end
    return d
end