local layout = {
    size = {64,64},
    texture = "textures/gui/icons/com/folder.png",
    subs = {
        { name = "title",
            textonly = true,
            text = "filename",
            size = {128,16},
            textcolor = {1,1,1},
            pos = {0,-70},
            mouseenabled = false,
            textalignment = ALIGN_CENTER
        }
    }
}
PANEL.basetype = "button"
function PANEL:Init() 
	self.fixedsize = true
	self.base.Init(self)  
	gui.FromTable(layout,self,{},self)
end  
 