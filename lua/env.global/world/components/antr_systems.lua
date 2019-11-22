
DeclareEnumValue("event","ANTRSYS_STATE",		332134)  

if CLIENT then
    ANTR_SYS_CBAR = ANTR_SYS_CBAR or gui.FromTable({
        texture = "textures/gui/hurt.dds",
        canraisemouseevents = false
    })
end 

local cvadz = {}

component.uid = DeclareEnumValue("CTYPE","ANTR_SYSTEMS", 3244)
component.editor = {
	name = "ANTR_SYSTEMS", 
	properties = { 
	}, 
	
}  
component._typeevents = {  
	[EVENT_ANTRSYS_STATE]={networked=true,f = function(self,state)   
	end}, 
}
component.statecolors = {
    off = Vector(0,0,0),
    on = Vector(1,1,1),
    standby = Vector(0.01960784,0.227451,0.5607843),
    error = Vector(250,91,255)/255,
    check = Vector(122,252,129)/255,
    combat = Vector(255,255,100)/255,
    block = Vector(254,106,101)/255, 
}

function component:Init() 
end
   
function component:OnAttach(node)
	node._comevents = node._comevents or {}
    node._comevents[self.uid] = self 
    if CLIENT and GetCamera():GetParent()==node then 
        self:SetState("standby") 
    end
end
function component:OnDetach(node)
	node._comevents = node._comevents or {}
    node._comevents[self.uid] = nil 
    if CLIENT and GetCamera():GetParent()==node then
        component.Unviz()  
    end
end
function cvadz.Viz(col,tex) 
    local cam = GetCamera()
    local node = cam:GetParent()
    local antr =  node:GetComponent(CTYPE_ANTR_SYSTEMS)
    if antr then 
        local bar = ANTR_SYS_CBAR  
        local vsize = GetViewportSize()
        bar:SetPos(0,0)
        bar:SetColor(col) 
        bar:SetTexture(tex or "textures/gui/hurt.dds")
        bar:SetSize(vsize.x,vsize.y)
        bar:SetCanRaiseMouseEvents(false)
        bar:Show()
    end
end
function cvadz.Unviz() 
    local bar = ANTR_SYS_CBAR
    if bar then
        bar:Close() 
    end 
end 
if CLIENT then
    hook.Add("controller.changed","antr",function(from,to)
        if component and component.Unviz then
            cvadz.Unviz() 
            local cam = GetCamera()
            local node = cam:GetParent()
            if to=="actor" then
                local antr =  node:GetComponent(CTYPE_ANTR_SYSTEMS)
                if antr and antr._scolor then
                    cvadz.Viz(antr._scolor,antr._stex) 
                end
            end
        end
    end)
    hook.Add("controller.actor.view","antr",function(view)
        if view == "first" then
            local cam = GetCamera()
            local node = cam:GetParent()
            local antr =  node:GetComponent(CTYPE_ANTR_SYSTEMS)
            if antr and antr._scolor then
                cvadz.Viz(antr._scolor,antr._stex) 
            end
        else
            cvadz.Unviz() 
        end
    end)
end
function component:SetState(s,flicker)
    flicker = flicker or 1
    s = s or self._state
    local color = self.statecolors[s]
    if color then
        self._state = s

        local node = self._node or self:GetNode()
        local neck = node:GetByName("apneck")
        local head = node:GetByName("head")
        if neck and neck.model then 
            ModModelMaterials(neck.model,{  
                emissionTint=color*flicker, 
            },false) 
        end
        if head and head.model then 
            ModModelMaterials(head.model,{ 
                --emissionTint={0.01960784,0.227451,0.5607843},
	            g_IrisTexture_e = "models/species/anthro/materials/iris_b_e2.png",   
                emissive_mul=color*flicker,
                --eyeScale = 0.8,
                --tint= Vector(1,1,1),
            },false) 
        end
        self._scolor = color*flicker
        if s=='off' then
            self._stex = ""
            cvadz.Viz(color*flicker,"")
        else
            self._stex = nil
            cvadz.Viz(color*flicker)
        end
    end
end
function component:Shutdown()
    local it = 0
    local node = self:GetNode()
    node.model:PlayLayeredSequence(32,"idle","models/anthroid_anim.stmd")
    node.model:SetLayerFade(32,0.02,0.01)
    node:SetEyeAngles(0,0,true,true) 
    node:SetHeadAngles(0,0)
    self:SetState('check',1)
    node:Delayed("sitw",1000,function()
        node:Timer("antrcheck",0,50,4,function()
            self:SetState(nil,1-it)
            it = it + 0.25
        end)
        node:Delayed("antr",250,function()
            local node = self:GetNode()
            self:SetState('off')
            node.model:SetPlaybackRate(0)
            node:SetUpdating(false) 
        end)
    end)
end
function component:PowerUp()
    local node = self:GetNode()

    self:SetState('on')
    node:Delayed("antr",100,function()
        self:SetState('check')
        node:Timer("antrcheck",0,50,40,function()
            self:SetState('check',math.random()*0.2+0.8)
        end)
        node:Delayed("antr",2100,function()
            node:SetUpdating(true) 
            node.model:SetPlaybackRate(1)
            node.model:StopLayeredSequence(32)
            self:SetState('standby',0.8)
            node:Delayed("antr",50,function() 
                self:SetState('standby')
            end)
        end)
    end)
end
COMRegFunctions(component,{
	Shutdown = function(node) return node:GetComponent(CTYPE_ANTR_SYSTEMS):Shutdown() end, 
	PowerUp = function(node) return node:GetComponent(CTYPE_ANTR_SYSTEMS):PowerUp() end, 
}) 