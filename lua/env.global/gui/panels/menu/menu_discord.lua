
local style = {

}
local layout = { 
    size = {256+10,128/2+10},
    color = {0.1,0.1,0.1},
	subs = {  
		{type="panel",name = "avatar",  -- class = "submenu",
			 
            size = {128/2,128/2},
            margin = {5,5,5,5},
            dock = DOCK_LEFT,
            color = {1,1,1}
		},  
	}
}
function PANEL:Init()  

	 
	gui.FromTable(layout,self,{},self) 
    module.Require("discord") 
    hook.Add("discord.user_ready","panel",function (x)  
        self:Update()
    end)
    self:Update()
end 

function PANEL:Update() 
    local vsize = GetViewportSize()
    self:SetPos(vsize.x+300,vsize.y-200) 
    local av = discord.GetUserAvatar()
    if av then
        self.avatar:SetTexture(av)
        self:MoveTo(Point(vsize.x-300,vsize.y-200),1,easing.easeinoutback)
    end
end 