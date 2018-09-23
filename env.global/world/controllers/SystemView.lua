
local bp_tex = LoadTexture("gui/nodes/banchor.png")
local VEC_FORWARD = Vector(0,0,-1)
local VEC_RIGHT = Vector(1,0,0)
local VEC_UP = Vector(0,1,0)

OBJ.mouse_lastpos = {0,0}
OBJ.zoom = 0.01
 

OBJ.mouseWheelValue = 0
OBJ.mouseWheelDelta = 0
OBJ.mouseFirstDown = true

OBJ.colorray = {
	Vector(1,0,0),
	Vector(0,1,0),
	Vector(0,0,1),
	
	Vector(1,1,0),
	Vector(0,1,1),
	Vector(1,0,1),
	
	Vector(0.1,0.8,0),
	Vector(0,0.1,0.8),
	Vector(0.8,0,1),
	
	Vector(0.8,0.1,0),
	Vector(0,0.8,0.1),
	Vector(1,0,0.8),
}
local savedZoom = 1 
function OBJ:Init() 
	local cam = GetCamera()
	self.mouseWheelValue = input.MouseWheel() 
	self.center = Vector(0,0,0)
	self.zoom = savedZoom or 1
	
	local parentsystem = self:FindSystem()
	self.system = parentsystem
	if parentsystem then
		cam:SetParent(parentsystem)
		cam:SetPos(Vector(0,0,0.1))
	end
	cam:SetUpdateSpace(false) 
	render.SetGroupBounds(RENDERGROUP_PLANET,10,1e8)
	render.SetGroupBounds(RENDERGROUP_CURRENTPLANET,10,1e8) 
	render.SetGroupBounds(RENDERGROUP_LOCAL,10,1e8) 
	render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_BACKGROUND)
	render.SetGroupMode(RENDERGROUP_CURRENTPLANET,RENDERMODE_BACKGROUND)
	render.SetGroupMode(RENDERGROUP_LOCAL,RENDERMODE_BACKGROUND)
	
	self:PanelsClear()
	self:PanelsCreate()
	
end
function OBJ:UnInit()  
	self:PanelsClear()
	savedZoom = self.zoom
end

function OBJ:FindSystem()   
	local cam = GetCamera()
	local parentsystem = cam:GetParentWithFlag(FLAG_PLANET)
	if parentsystem and parentsystem.moons and #parentsystem.moons>0 then
		return parentsystem
	else
		return cam:GetParentWithFlag(FLAG_STAR)
	end
end

function OBJ:MouseWheel()
	local mWVal = input.MouseWheel()  
	
	self.zoom = math.Clamp( self.zoom + (mWVal-self.mouseWheelValue)/10000,0,10)
	
	self.mouseWheelValue = mWVal 
end

function OBJ:KeyDown(key)  
	if input.GetKeyboardBusy() then return nil end
	if input.KeyPressed(KEYS_B) then
		local cam = GetCamera()
		local cparent = cam:GetParent()
		local star = cam:GetParentWithFlag(FLAG_STAR)
		if cparent~=star then
			self:PanelsClear()
			self.system = cparent:GetParent()
			cam:SetParent(self.system)
			cam:SetPos(Vector(0,0,0.1))
			self:PanelsCreate()
			cparent:Leave()
		end
	end
end
function OBJ:PanelsCreate()
	local system = self.system
	
	local panels = {}
	if system then
		local subs = table.Copy(system.planets or system.moons)
		if system.moons then
			subs[#subs+1] = system
		end
		for k,v in pairs(subs) do
			local col = self.colorray[k%(#self.colorray)]/2+Vector(0.1,0.1,0.1)
		
			local btn = panel.Create("button")
			btn:SetSize(15,15)
			btn.node = v
			btn:SetTexture(bp_tex)
			btn:SetColorAuto(col)
			
			local s = self
			function btn:OnClick() 
				s:ZoomIn(self.node)
			end
			
			btn:Show()
			
			MsgN(v)
			panels[#panels+1] = btn
			
			
			local orbit = v.orbit
			if orbit and v ~= system then
				 
				local pts = {}
				for k=1,36*2+1 do
					local val = orbit:GetPosition(k*5) 
					pts[k] = val 
				end
				debug.ShapeCreate(100+k,system,col,3,pts)
			
			end
			
		end
	end
	self.panels = panels
end  
function OBJ:PanelsClear()  
	if self.panels then
		for k,v in pairs(self.panels) do
			v:Close()
		end
	end
	self.panels = {}
	local system = self.system
	if system then
		local subs = system.planets or system.moons
		for k,v in pairs(subs) do
			debug.ShapeDestroy(100+k)
		end
	end
end

function OBJ:ZoomIn(node) 
	local cam = GetCamera()
	if node.moons and node~=self.system then
		self:PanelsClear()
		self.system = node
		cam:SetParent(node)
		cam:SetPos(Vector(0,0,0.1))
		node:Enter()
		self:PanelsCreate()
	else
		SetController("freecamera")
		cam:SetParent(node)
		node:Enter()
		debug.Delayed(1000,function()
			SetController("planetview")
		end)
	end
end

function OBJ:Update() 
	
	if self.panels then
		local camera = GetCamera()
		local cparent = camera:GetParent()
		local cpos = camera:GetPos()
		local vsize = GetViewportSize()  
	 
		for k,v in pairs(self.panels) do
			local wpos = cparent:GetLocalCoordinates( v.node)-cpos
			local spos = camera:Project(wpos)*Vector(vsize.x,vsize.y,1)
			if spos.z>1 then
				v:SetPos(Point(-10000,0))
			else
				v:SetPos(spos)
			end  
		end
	end
	if input.GetKeyboardBusy() then return nil end
		
		
	local dt = 1
	
	local cam = GetCamera()
	local cam_parent = cam:GetParent()
	local parent_sz = cam_parent:GetSizepower()
	local Forward = cam:Forward():Normalized()
	local Right = cam:Right():Normalized()
	local Up = cam:Up():Normalized()
	local Center = self.center or Vector(0,0,0)
	local zoom = self.zoom
		
		
	local mhag = false -- input.MouseIsHoveringAboveGui()
	local rmb = input.rightMouseButton()
	if not mhag and rmb then
		if not self.lms_active then
			input.SetCursorHidden(true)
			self.lms_active = true
		end 
		
		local mousePos = input.getMousePosition()
		local size = GetViewportSize() 
		local center = size / 2
		center = Point(math.floor( center.x),math.floor(center.y))
		local offset = (mousePos - center);
		self.mouse_lastpos = mousePos
		input.setMousePosition(center)
		if not self.mouseFirstDown then
			cam:RotateAroundAxis(VEC_RIGHT, (offset.y / -1000))
			cam:RotateAroundAxis(VEC_UP, (offset.x / -1000))
		end
		self.mouseFirstDown = false
	else 
		self.mouseFirstDown = true
	end 
	if self.lms_active and (not rmb or mhag) then
		input.SetCursorHidden(false)
		self.lms_active = false
	end 
	 
	local Forward = cam:Forward():Normalized()
	cam:SetPos( Center - Forward * (zoom*zoom) )
		
end