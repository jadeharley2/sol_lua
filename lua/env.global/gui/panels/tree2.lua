
function PANEL:Init()
	--PrintTable(self)  
	self:SetColor(Vector(0.2,0.2,0.2))
	
	local ff_grid_floater = panel.Create() 
	
	ff_grid_floater:SetSize(400,800)  
    ff_grid_floater:SetColor(Vector(0.2,0.2,0.2))
    ff_grid_floater:SetAutoSize(false,true)
    ff_grid_floater:SetAnchors(ALIGN_TOP)
	
	
	local ff_grid = panel.Create("floatcontainer") 
	ff_grid:SetSize(400,120)  
	ff_grid:Dock(DOCK_FILL)  
	ff_grid:SetScrollbars(3) 
	ff_grid:SetFloater(ff_grid_floater) 
	ff_grid:SetColor(Vector(0.2,0.2,0.2))
	self:Add(ff_grid)
	ff_grid_floater.level = 0
	self.root = ff_grid_floater
    self.grid = ff_grid
    
    self.nodes = {}

    --local ltt = {}
    --for k=1,100 do
    --    ltt[k] = {
    --        type = "tree2node",
    --        text = tostring(k), 
    --    }
    --end
    --ff_grid_floater:Add(gui.FromTable({
    --    tree = self,
    --    type = "tree2node",
    --    nodes = {
    --        { type = "tree2node",
    --            text = "lol"
    --        },
    --        { type = "tree2node", 
    --            text = "abc", 
    --            Icon = "textures/gui/features/dyeable.png",
    --            nodes = ltt,
    --        }, 
    --        { type = "tree2node",
    --            text = "123", 
    --            nodes = { 
    --                { type = "tree2node",
    --                    text = "heh", 
    --                }
    --            }
    --        }
    --    }
    --}))
    --ff_grid_floater:UpdateLayout()
end

function PANEL:AddNode(node)
    node.tree = self 
    self.root:Add(node)  
    self:UpdateLayout()
end
function PANEL:RemoveNode(node) 
    node.tree = nil 
    self.root:Remove(node) 
    self:UpdateLayout()
end
function PANEL:ClearNodes() 
    self.root:Clear()
end
PANEL.nodes_info = {type ="children_array",add = PANEL.AddNode}