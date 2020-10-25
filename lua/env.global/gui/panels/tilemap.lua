
--https://a.tile.opentopomap.org/3/2/1.png

local layout = {
    subs = {
        type = "floatcontainer",
        dock = DOCK_FILL,
        size = {200,200},  
        Floater = {type="panel",
            scrollbars = 1,
            color = {1,1,1}, 
            size = {200,100},  
            texture = "textures/gui/map/none.png"
        },
    }
}
function PANEL:Init()
    MsgN("dasfd2C523f2323fg2g2g24g2g24g24g24")  
    gui.FromTable(layout,self,{},self)
    MsgN("dasfd2C523f2323fg2g2g24g2g24g24g24") 
end