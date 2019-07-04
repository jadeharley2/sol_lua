
--button "+"
--onpress:hide button, reveal options
--onselect option, hide options, show button
local layout = {
    autosize = {false,true},
    subs = {
        {type = "button", name = "plus", 
            dock=DOCK_TOP, 
            size = {20,20},
            ColorAuto = Vector(0.2,1,0.2)/5, 
            textcolor = {0.2,1,0.2}, 
            textalignment = ALIGN_CENTER,
            text = "+", 
        },
        {type = "button", name = "cancel", 
            dock=DOCK_TOP, 
            size = {20,20},
            ColorAuto = Vector(0.5,0.7,0.5)/5, 
            textcolor = {0.5,0.7,0.5},  
            textalignment = ALIGN_CENTER,
            text = "CANCEL",
            visible=false
        },
        {name = "contents",
            dock=DOCK_TOP,
            autosize = {false,true},
            color = {0,0,0},
            visible=false
        }
    }
}
function PANEL:Init()
    gui.FromTable(layout,self,{},self)
    self.plus.OnClick = function() self:ShowOptions() end
    self.cancel.OnClick = function() self:HideOptions() end
end
local function OnSelectOption(s)
    s.selector:HideOptions()
    s.selector:OnSelect(s.value)
end
function PANEL:SetOptions(list)
    local contents = self.contents
    contents:Clear()
    for k,v in SortedPairs(list) do 
        local b = gui.FromTable({ type = "button",
            dock=DOCK_TOP,
            size = {20,20},
            margin = {1,1,1,1},
            ColorAuto = Vector(0.5,0.7,0.5)/5, 
            textcolor = {0.5,0.7,0.5},
            text = tostring(k), 
            value = v, 
            selector = self,
            OnClick = OnSelectOption
        },nil,style) 
        contents:Add(b)   
    end
end

function PANEL:ShowOptions()
    self.plus:SetVisible(false)
    self.cancel:SetVisible(true)
    self.contents:SetVisible(true)
    self:GetTop():UpdateLayout()
end
function PANEL:HideOptions()
    self.plus:SetVisible(true)
    self.cancel:SetVisible(false)
    self.contents:SetVisible(false)
    self:GetTop():UpdateLayout()
end

function PANEL:OnSelect(option)

end
