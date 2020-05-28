
local layout = {
    color = {0,0,0},
    size = {200,200},
    autosize = {false,true},
    subs = {
        { name = 'itemname',
            size = {20,20},
            dock = DOCK_TOP,
            text = "ITEM NAME",
            textonly = true,
            textcolor = {1,1,1},
        },
        {
            size = {2,2},
            dock = DOCK_TOP,
            color = {1,0,0},
        },
        { name = 'itemdesc',
            size = {20,0},
            autosize = {false,true},
            dock = DOCK_TOP,
            text = "ITEM\nDESCRIPTION",
            textonly = true,
            textcolor = {1,1,1},
            multiline = true,
            margin = {2,2,2,2},
            textalignment =  ALIGN_LEFT,
            linespacing = 4,
            lineheight = 20,
            autowrap = true,
        },
        {
            size = {2,2},
            dock = DOCK_TOP,
            color = {0.1,0,0},
        },
        { name = 'features',
            dock = DOCK_TOP,
            textonly = true,
            size = {20,0},
            autosize = {false,true},
        }
    }
}
function PANEL:Init()
    gui.FromTable(layout,self,{},self)    
end
function PANEL:SetForm(formid)
    local formdata = forms.GetData2(formid)
    if formdata then
        local name = forms.GetName(formid) or formid
        self.itemname:SetText(name)
        self.itemdesc:SetText(formdata:Read('description') or '  ')
        --for k,v in pairs(formdata:Read('tags') or {}) do
        --    self:AddFeature(v,{1,1,1},"textures/gui/pointer.png")
        --end
        hook.Call('item_features',formid,formdata,function(t,c,i) self:AddFeature(t,c,i) end)

        for k,v in pairs(formdata:Read('features') or {}) do
            local v1 = tostring(v[1]) 
            self:AddFeature(k..': '..v1,v[2],"textures/gui/pointer.png")
        end
       -- self:AddFeature("Color: RED",{1,0,0},"textures/gui/pointer.png")
       -- self:AddFeature("Color: GREEN",{0,1,0},"textures/gui/pointer.png")
       -- self:AddFeature("Color: BLUE",{0,0,1},"textures/gui/pointer.png")
    else
        self.itemname:SetText("~unknown~")
        self.itemdesc:SetText("~unknown~")
    end
end
function PANEL:SetItem(itemdata)

end

function PANEL:AddFeature(text,color,image)
    self.features:Add(gui.FromTable({
        textonly = true,
        size = {20,20},
        dock = DOCK_TOP,
        subs = {
            {
                size = {20,20},
                dock = DOCK_LEFT,
                color = color,
                texture = image,
            },
            {
                textonly = true,
                text = text,
                size = {20,20},
                dock = DOCK_FILL, 
                textcolor = {1,1,1}
            }
        }
    }))
end