PANEL.basetype = "window"

function PANEL:Init()
	--PrintTable(self)
	self.base.Init(self)
	self:Resize(Point(500,200))
	self:SetColor(Vector(0.6,0.6,0.6))
	
	local bar = panel.Create("bar")  
	bar:SetSize(800,15)
	bar:SetPos(0,50)
	bar:UpdateValues()
	self:Add(bar)
	
	local bar2 = panel.Create("bar")  
	bar2:SetSize(800,15)
	bar2:SetPos(0,-50)
	bar2:UpdateValues()
	self:Add(bar2)
	
	hook.Add("main.predraw","test1213"..debug.GetHashString(self),function() 
		local perf = render.GetGroupPerfomance()
		local vv = {}
		for k,v in pairs(perf) do
			vv[#vv+1] = {v=v,text =k}
		end
		bar:SetValue(vv)  
		
		
		local perf2 = render.GetTypePerfomance()
		local vv2 = {}
		for k,v in pairs(perf2) do
			vv2[#vv2+1] = {v=v,text =k}
		end
		bar2:SetValue(vv2)  
		
	end)
	  
	self:OnResize() 
end

function PANEL:OnResize()  
end

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end