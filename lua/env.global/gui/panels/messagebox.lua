PANEL.basetype = "window"
PANEL.fixedsize = true

function PANEL:Init()
	self.base.Init(self)
end
function PANEL:Click(bt)
    
end

local onerror = function(err)
	MsgN(err)  
	MsgN(debug.traceback())
end
function MsgTextBox(text,title, buttons, callback, size)
    MsgBox({
        textonly = true,
        dock = DOCK_FILL,
        subs = {
            {
                textonly = true,
                text = text,
                textcolor = {1,1,1},
                size = {30,30},
                dock = DOCK_TOP,
            },
            { type = "input_text", name = "field",
                size = {30,30},
                dock = DOCK_TOP,
            },
        }
    },title,buttons,function(rez,x)
        callback(rez,x.field:GetText(),x)
    end, size)
end
function MsgBox(text, title, buttons, callback, size)
    buttons = buttons or {"Ok"}
    local x = {}
    local layout = {
        type = "messagebox", 
        size = size or {250,150},
        Title = title or "Message",
        contents = {
            { name = "buttonpanel",
                textonly = true,
                size = {20,20},
                dock = DOCK_BOTTOM  
            }
        }
    } 
    if(isstring(text))then
        layout.contents[2] =
        {
            textonly = true,
            textcolor = {1,1,1},
            textalignment = ALIGN_CENTER,
            autowrap = true, 
            multiline = true,
            lineheight = 20,
            linespacing = 4,
            dock = DOCK_FILL,
            text =  text or "text\n...." 
        }
    elseif istable(text) then 
        layout.contents[2] = text
    end

    local p = gui.FromTable(layout,nil,{},x)
    local b = x.buttonpanel 
    for k,v in pairs(buttons) do
        if isfunction(v) then
            local btk = k
            local f = v
            b:Add(gui.FromTable({
                type = "button",
                size = {50,20},
                dock = DOCK_LEFT,
                text = btk,
                OnClick = function(s)
                    p:Close()
                    if f then xpcall(f,onerror,btk,x) end
                end
            }))
        elseif istable(v) then
            local btk = v[1]
            local f = v[2]
            b:Add(gui.FromTable({
                type = "button",
                size = {50,20},
                dock = DOCK_LEFT,
                text = btk,
                OnClick = function(s)
                    p:Close()
                    if f then xpcall(f,onerror,btk,x) end
                end
            }))
        elseif isstring(v) then
            local btk = v
            b:Add(gui.FromTable({
                type = "button",
                size = {50,20},
                dock = DOCK_LEFT,
                text = btk,
                OnClick = function(s)
                    p:Close()
                    if callback then xpcall(callback,onerror,btk,x) end
                end
            }))
            
        end
    end
    p:UpdateLayout()
    p:Show()
end

console.AddCmd("test_msg",function(text, title, btn)
    btn = btn or "OK"
    MsgBox(text,title,{{btn,function()
        MsgInfo(btn)
    end}})
end)