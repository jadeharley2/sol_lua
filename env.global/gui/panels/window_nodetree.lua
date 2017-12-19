PANEL.basetype = "window"

function PANEL:Init()
	--PrintTable(self)
	self.base.Init(self)
	self:Resize(Point(500,200))
	self:SetColor(Vector(0.6,0.6,0.6))
	
	local list_view = panel.Create("list")
	self.list_view = list_view
	list_view:SetSize(480,180) 
	list_view.OnSelect = function(list,item)
		self:LoadProps(item.tag.ent)
	end
	self:Add(list_view)
	
	local node_view = panel.Create("list")
	self.node_view = node_view
	node_view:SetSize(480,180)
	self:Add(node_view)
	
	self:LoadNodes()
	
	self:OnResize() 
end

function PANEL:LoadNodes()
	local list_view = self.list_view
	local cam = GetCamera();
	local cp = cam:GetParent();
	local nodes = {}
	for k,v in pairs(cp:GetChildren()) do
		nodes[k] = {text = tostring(v), ent = v}
	end
	list_view.lines = nodes
	list_view:Refresh() 
end
function PANEL:LoadProps(ent)
	local node_view = self.node_view
	local nodes = {}
	nodes[#nodes+1] =  tostring(ent)
	node_view.lines = nodes
	node_view:Refresh() 
end

function PANEL:OnResize() 
	local list_view = self.list_view
	local node_view = self.node_view
	if( list_view) then
		local size = self:GetSize()
		local rw,rh = math.min(300,size.x-20),size.y-40
		list_view:SetPos(-size.x+rw+20,0)
		list_view:SetSize(rw,rh)
		list_view:Refresh()
		
		node_view:SetSize(rw,rh)
		node_view:AlignTo(list_view,ALIGN_RIGHT,ALIGN_LEFT)
		node_view:Refresh()
	end	
end

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end