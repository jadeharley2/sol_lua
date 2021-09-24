local font_d16 = "fonts/d12.json"
local togglehandler = function (s)
    s.refnode:Toggle()
end
PANEL.SelectedColor = "#303060"
PANEL.HoverColor = "#101030"
PANEL.IdleColor ="#000000"
function PANEL:Init()  
    gui.FromTable({
        autosize = {false,true},
        size = {16,16},
        dock = DOCK_TOP,
        collapsed = false,
        textonly = true,
        childrencount = 0,
        margin = {0,2,0,2},
        subs = {
            { name = "header",
                size = {16,16},
                dock = DOCK_TOP,
                textonly = true,
                color = "#000000", 
                subs = {
                    {type = "button",name = "toggler",
                        OnClick = togglehandler,
                        refnode = self,
                        size = {16,16},
                        dock = DOCK_LEFT,
                        rotation = -90,
                        texture = "textures/gui/expand.png",
                        textonly = true,
                        mousenabled = false,
                        ColorAuto = Vector(1,1,1), 
                    },
                    { name = "icon", 
                        size = {16,16},
                        dock = DOCK_LEFT, 
                        visible = false,
                    },
                    { type = "button", name = "title", 
                        size = {16,16},
                        dock = DOCK_FILL,
                        textonly = true,
						font = font_d16,
                        text = "TreeNode",
                        textcolor = {1,1,1},
                    }
                },
            },
            { name = "padding",
                size = {16,16},
                dock = DOCK_LEFT, 
                textonly = true,
                mousenabled = false
            },
            { name = "subcon",
                size = {16,0},
                dock = DOCK_TOP,
                autosize = {false,true},
                textonly = true,
                interactive = false,
            }
        },
    },self,{},self)
     
end
function PANEL:MouseEnter()
    if not self:IsSelected() then
        self.header:SetColor(self.HoverColor)
        self.header:SetTextOnly(false)
    end
end

function PANEL:MouseLeave()
    if not self:IsSelected() then
        self.header:SetColor(self.IdleColor)
        self.header:SetTextOnly(true)
    end
end
 
function PANEL:SetOnClick(callback)
    self.title.OnClick = function(s)
        callback(self)
    end
end
function PANEL:SetOnDoubleClick(callback)
    self.title.OnDoubleClick = function(s)
        callback(self)
    end
end

function PANEL:SetText(text)
    self.title:SetText(text)
end
function PANEL:SetTextColor(text)
    self.title:SetTextColor(text)
end
function PANEL:SetIcon(v)
    local i = self.icon
    i:SetTexture(v)
    i:SetVisible(v~=nil)
end
function PANEL:AddNode(node) 
    
    node.tree = self.tree

    self.subcon:Add(node)
    if self.childrencount == 0 then
        local t = self.toggler
        t:SetTextOnly(false)
        t:SetCanRaiseMouseEvents(true) 
    end
    self.childrencount = self.childrencount + 1
    self:UpdateLayout()
end
function PANEL:RemoveNode(node) 
    node.tree = nil

    self.subcon:Remove(node)
    self.childrencount = self.childrencount - 1
    if self.childrencount == 0 then
        local t = self.toggler
        t:SetTextOnly(true)
        t:SetCanRaiseMouseEvents(false)
    end
    self:UpdateLayout()
end
PANEL.nodes_info = {type ="children_array",add = PANEL.AddNode}

function PANEL:Expand(recursive)  
    CALL(self.OnExpand,self)
    self.subcon:SetVisible(true) 
    if recursive then
        for k,v in pairs(self.subcon:GetChildren()) do
            v:Expand(recursive)
        end
    end
    self.collapsed = false
    self.toggler:RotateTo(-90,0.2,easing.linear)
    self:GetTree():UpdateLayout()
end
function PANEL:Collapse(recursive)  
    self.subcon:SetVisible(false) 
    if recursive then
        for k,v in pairs(self.subcon:GetChildren()) do
            v:Collapse(recursive)
        end
    end
    CALL(self.OnCollapse,self)
    self.collapsed = true
    self.toggler:RotateTo(0,0.2,easing.linear)
    local t = self:GetTree()
    if t then t:UpdateLayout() end
end
function  PANEL:Setcollapsed()
   --ASSERT(self.subcon==nil,"???")
   --self:Collapse()
end
function PANEL:Toggle()  
    if self.collapsed then
        self:Expand()
    else
        self:Collapse()
    end
end
function PANEL:IsExpanded()
    return not self.collapsed  
end
function PANEL:IsCollapsed()
    return self.collapsed  
end
function PANEL:GetTree()
    local tree = self.tree
    if tree then return tree end
    local parent = self:GetParent()
    while parent do
        tree = parent.tree
        if tree then return tree end
        parent = parent:GetParent()
    end 
end
ST_SELECTED_NODE = false
function PANEL:OnSelect()
    self.header:SetColor(self.SelectedColor) 
    self.header:SetTextOnly(false)
end
function PANEL:OnDeselect()
    self.header:SetColor(self.IdleColor) 
    self.header:SetTextOnly(true)
end 
PANEL.Select = nil
PANEL.Deselect = nil
PANEL.IsSelected = nil
PANEL.DoubleClick = nil