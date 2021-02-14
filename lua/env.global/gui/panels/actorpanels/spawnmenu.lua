

function PANEL:Init() 
    local vsize = GetViewportSize() 
    gui.FromTable({
        size = {vsize.x/2,400},
        color = Vector(0.2,0.2,0.2),
        alpha = 0.4,
        padding = {40,40,40,40},
        subs = {
            {type="floatcontainer",name = "items",  -- class = "submenu",
                visible = true, 
                size = {vsize.x/2,400},
                dock = DOCK_FILL,
                color = {0,0,0}, 
                textonly=true, 
                Floater = {type="panel",
                    scrollbars = 1,
                    color = {0,0,0}, 
                    size = {vsize.x/2,4000},
                    autosize={false,true}, 
                },
            }, 
        }
    },self,{},self)

    local props = gui.FromTable({
        type = "grid",
        name = "props",
        size = {vsize.x/2,4000},
        dock = DOCK_TOP,
        rowheight = 64,
        columns = 14
    })
    self.items.floater:Add(props)

    local function spawn(b)
        local p = LocalPlayer()
        local pp = p:GetParent()
        
        local tr = GetPlayerEyeTrace()
        if tr and tr.Hit then
            local sz = tr.Node:GetSizepower()

            local e = false
            if b.form:find('/') then
                e = SpawnSO(b.form,tr.Node,Vector(0,0,0),1,NO_COLLISION)
            else
                e = forms.Create(b.form,tr.Node)
            end
            e:SetPos(tr.Position+tr.Normal*(0.1/sz)) 
        end
    end

    local tbl = {
        "prop.clutter.lab.glass_a",
        "prop.clutter.lab.glass_b",
        "gmod/models/props_trainyard/distillery_barrel001.mdl", 
    }
    local fldrs = {
        'gmod/models/combine_room',
        'gmod/models/props_c17'
    }
    for kk,vv in ipairs(fldrs) do
        for k,v in ipairs(file.GetFiles(vv)) do
            if string.ends(v,'.mdl') then 
                tbl[#tbl+1] = v 
            end
        end
    end
    for k,v in ipairs(tbl) do
        local form = v
        local t = {}
        local thumb = gui.FromTable({
            type = 'button',
            size = {64,64},
            form = form,
            ColorAuto = Vector(0.1,0.2,0.3),
            subs = {
                {
                    type = 'thumbnail',
                    name = "thumb",
                    dock = DOCK_FILL,
                    mouseenabled = false
                }
            },
            OnClick = spawn
        },nil,{},t) 
        props:AddPanel(thumb) 

        if form:find('/') then
            t.thumb:SetPath(form,thumb) 
        else
            t.thumb:SetForm(form,thumb)
        end

    end
	self.items:Scroll(-9999999)
end  