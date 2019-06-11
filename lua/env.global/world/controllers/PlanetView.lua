
local VEC_FORWARD = Vector(0,0,-1)
local VEC_RIGHT = Vector(1,0,0)
local VEC_UP = Vector(0,1,0)

OBJ.mouse_lastpos = {0,0}
OBJ.zoom = 0.01
 

OBJ.mouseWheelValue = 0
OBJ.mouseWheelDelta = 0
OBJ.mouseFirstDown = true

function OBJ:Init() 
	local cam = GetCamera()
	self.mouseWheelValue = input.MouseWheel() 
	self.center = Vector(0,0,0)
	self.zoom = 0.2
	
	local parentplanet = cam:GetParentWithFlag(TAG_PLANET)
	self.planet = parentplanet
	if parentplanet then
		cam:SetParent(parentplanet)
		cam:SetPos(Vector(0,0,0.1))
	end
	cam:SetUpdateSpace(false)
	parentplanet.surface.surface:SetRenderGroup(RENDERGROUP_CURRENTPLANET)
	render.SetGroupBounds(RENDERGROUP_PLANET,10,1e8)
	render.SetGroupBounds(RENDERGROUP_CURRENTPLANET,10,1e8) 
	render.SetGroupBounds(RENDERGROUP_LOCAL,10,1e8) 
	render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_BACKGROUND)
	render.SetGroupMode(RENDERGROUP_CURRENTPLANET,RENDERMODE_BACKGROUND)
	render.SetGroupMode(RENDERGROUP_LOCAL,RENDERMODE_BACKGROUND)
end
function OBJ:UnInit()  
end

function OBJ:MouseWheel()
	local mWVal = input.MouseWheel()  
	
	self.zoom = math.Clamp( self.zoom + (mWVal-self.mouseWheelValue)/100000,0,10)
	
	self.mouseWheelValue = mWVal 
end

function OBJ:KeyDown(key)  
	if input.GetKeyboardBusy() then return nil end
	
end

function OBJ:Update() 
	
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
		
		
	local mhag = input.MouseIsHoveringAboveGui()
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
		local offset = (mousePos - center)*zoom*2;
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
	
	local planet = self.planet
	local sealevel_r = planet:GetParameter(VARTYPE_RADIUS)
	local sz = planet:GetSizepower()
	local mindist = sealevel_r/sz
	local Forward = cam:Forward():Normalized()
	cam:SetPos( Center - Forward * (mindist+zoom*zoom/2) )
	
	if input.KeyPressed(KEYS_B) then
		SetController("systemview")
	end
end