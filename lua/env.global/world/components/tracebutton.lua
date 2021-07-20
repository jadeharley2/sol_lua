
local static = component.static or {}
component.static = static

static.comlist = static.comlist or {}

component.uid = DeclareEnumValue("CTYPE","TRACEBUTTON", 3352)
component.editor = {
	name = "Trace Button",
	properties = { 
        
	}, 
	
}

 

function component:Init()
	self.list = {}
end

function component:OnAttach(node)
    static.comlist[node] = self
end
function component:OnDetach(node)
    static.comlist[node] = nil
end
function component:OnClick(node)
    MsgN("CLICK! " ,self," - ",node)
    MsgN("Unclick! " ,self," - ",node)
end

if CLIENT then
    hook.Add("input.mousedown","tracebutton",function()
        --if true then return end
        if not input.GetKeyboardBusy() 
            and input.leftMouseButton() 
            and (not worldeditor or not worldeditor:IsOpen())
            and table.Count(static.comlist)>0 then
            
            local vsz = GetViewportSize()
            local vmp = input.getInterfaceMousePos()
            local vsr = vmp-- (vmp/vsz)--*Point(0.5,-0.5)+Point(0.5,0.5)

            render.DCISetEnabled(true)
            render.DCIRequestRedraw()
            debug.Delayed(50,function()
                local drw = render.DCIGetDrawable(vsr)  
                render.DCISetEnabled(false)
                if drw then
                    local node = drw:GetNode()
                    local button = static.comlist[node] 
                    if button then 
                        CALL(button.OnClick,button,node)
                    end
                end 
            end)
        end
    end)
end