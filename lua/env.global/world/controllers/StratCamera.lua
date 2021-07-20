
local VEC_FORWARD = Vector(0,0,-1)
local VEC_RIGHT = Vector(1,0,0)
local VEC_UP = Vector(0,1,0)

OBJ.mouse_lastpos = {0,0}
OBJ.zoom = 0.01
OBJ.zoom_max = 10
OBJ.zoom_min = 0
OBJ.zoom_div =1000
OBJ.zoom_power = 4

OBJ.mouseWheelValue = 0
OBJ.mouseWheelDelta = 0

function OBJ:Init() 
	self.mouseWheelValue = input.MouseWheel() 
	local cam = GetCamera()
	cam:SetAng(Vector(0,0,0))
	self.center = cam:GetPos()  
	self._first = true
	self.firstp = 0 
end
function OBJ:UnInit()  
end

function OBJ:MouseWheel()
	if not input.MouseIsHoveringAboveGui() then
		local mWVal = input.MouseWheel()  
		
		self.zoom = math.Clamp( self.zoom + (mWVal-self.mouseWheelValue)/self.zoom_div,self.zoom_min,self.zoom_max)
		
		self.mouseWheelValue = mWVal 
	end
end

function OBJ:KeyDown(key)  
	if input.GetKeyboardBusy() then return nil end
	
end

function OBJ:MouseUp() 
	self.firstp = 0 
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
		local offset = mousePos - center
		self.mouse_lastpos = mousePos
		if self.firstp>4 then
            cam:TRotateAroundAxis(Right, (offset.y / -1000))
            cam:TRotateAroundAxis(VEC_UP, (offset.x / -1000)) 
		end 
		input.setMousePosition(center)
		self.firstp = self.firstp+1
	end 
	if self.lms_active and (not rmb or mhag) then
		input.SetCursorHidden(false)
		self.lms_active = false
	end
	
	local Forward = cam:Forward():Normalized()
    local zoom_value = math.pow(self.zoom,self.zoom_power)
	cam:SetPos( Center - Forward * zoom_value / parent_sz)
	
    local Forward2D = Vector(Forward.x,0,Forward.z);

    local result = Vector(0,0,0)
    
    if input.KeyPressed(KEYS_W) then result = result + Forward2D end
    if input.KeyPressed(KEYS_S) then result = result - Forward2D end
    if input.KeyPressed(KEYS_D) then result = result + Right end
    if input.KeyPressed(KEYS_A) then result = result - Right end
    if input.KeyPressed(KEYS_SHIFTKEY) then
        Center = Center + result * 0.3 * zoom_value * 0.03 / parent_sz
    else
        Center = Center + result * 0.1 * zoom_value * 0.03 / parent_sz
    end


    self.center = Center
end