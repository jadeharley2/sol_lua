
local VEC_FORWARD = Vector(0,0,-1)
local VEC_RIGHT = Vector(1,0,0)
local VEC_UP = Vector(0,1,0)

OBJ.mouse_lastpos = {0,0}
OBJ.speed = 0.01
 

OBJ.mouseWheelValue = 0
OBJ.mouseWheelDelta = 0


function OBJ:Init() 
	local cam = GetCamera()
	cam:SetUpdateSpace(true)
	self.mouseWheelValue = input.MouseWheel()  
    self.pitch = 0
    self.yaw = -135
end
function OBJ:UnInit() 
	local cam = GetCamera()
	cam:SetUpdateSpace(false) 
end

function OBJ:MouseWheel()
	local mWVal = input.MouseWheel() 
	if not input.GetKeyboardBusy() then
        if input.rightMouseButton() then
			self.mouseWheelDelta = self.mouseWheelDelta + (mWVal - self.mouseWheelValue)
			self.speed = math.pow(2, self.mouseWheelDelta / 100) * 0.01
		end
	end
	self.mouseWheelValue = mWVal 
    --print(self.speed)
end
function OBJ:MouseDown() 
end

function OBJ:KeyDown(key)  
	if input.GetKeyboardBusy() then return nil end 
end

function OBJ:Update() 
	if input.GetKeyboardBusy() then return nil end
		
    
    local dt = 1
    
    local cam = GetCamera()
    local fov = cam:GetFOV()
    local cam_parent = cam:GetParent()
    local parent_sz = cam_parent:GetSizepower()
    local Forward = cam:Forward():Normalized()
    local Right = cam:Right():Normalized()
    local Up = cam:Up():Normalized() 
    
    local result = Vector(0,0,0)
    if input.rightMouseButton() then
        if input.KeyPressed(KEYS_W) then result = result - Forward end
        if input.KeyPressed(KEYS_S) then result = result + Forward end
        if input.KeyPressed(KEYS_D) then result = result - Right end
        if input.KeyPressed(KEYS_A) then result = result + Right end
        if input.KeyPressed(KEYS_E) then result = result - Up end
        if input.KeyPressed(KEYS_Q) then result = result + Up end

        if result ~= Vector(0,0,0) then 
            result = result:Normalized()
        end 
        
        if input.KeyPressed(KEYS_NUMPAD1) then 
            cam:SetFOV(fov*0.99)
        end
        if input.KeyPressed(KEYS_NUMPAD2) then 
            cam:SetFOV(fov*1.01)
        end
        if input.KeyPressed(KEYS_NUMPAD3) then 
            cam:SetFOV(80)
        end
        
        local mhag = input.MouseIsHoveringAboveGui()

        local shx = 0
        local shy = 0
        if input.KeyPressed(KEYS_H) then shx = shx - 10 end
        if input.KeyPressed(KEYS_K) then shx = shx + 10 end
        if input.KeyPressed(KEYS_U) then shy = shy - 10 end
        if input.KeyPressed(KEYS_J) then shy = shy + 10 end

        if (self:MouseLocked() and not mhag) or (shx~=0 or shy~=0) then--not mhag and rmb then
            local size = GetViewportSize() 
            local center = size / 2
            center = Point(math.floor( center.x),math.floor(center.y))
            self:UpdateCamRotation(size,center,shx,shy)
        end 
        if self.firstp and not self:MouseLocked() and (shx==0 and shy==0) then
            self.firstp = false
        end
        if self.lms_active and mhag then
            input.SetCursorHidden(false)
            self.lms_active = false
        end
            
        cam:AddPos(  - result * self.speed / parent_sz * dt)
    end
end
function OBJ:UpdateCamRotation(size,center,shx,shy)
	local cam = GetCamera()
	local fov = cam:GetFOV()

	if not self.lms_active then 
		input.SetCursorHidden(true)
		self.lms_active = true
	end

	local mousePos = input.getMousePosition()
	local offset = mousePos - center
	self.mouse_lastpos = mousePos
	input.setMousePosition(center)


	offset = offset + Point(shx,shy)
	if self.firstp then
        self.pitch = self.pitch + (offset.x / 20 ) 
        self.yaw = self.yaw + (offset.y / 20 )
        cam:SetAng(Angle(self.pitch,self.yaw,0))
		--cam:RotateAroundAxis(VEC_RIGHT, (offset.y / -1000 )*fov/80)
		--cam:RotateAroundAxis(VEC_UP, (offset.x / -1000)*fov/80)
	end
	self.firstp = true
end
 
 
function OBJ:MouseLocked()
	if input.WindowActive() and not BLOCK_MOUSE then
		if SHOWINV then return false end
		 
		if self.mouseactive then
			if MAIN_MENU and MAIN_MENU:GetVisible() then
				return false
			else
				return true 
			end
		else 
			
			local mhag = input.MouseIsHoveringAboveGui()
			if not mghag then
				return	 input.rightMouseButton()
			else
				return false
			end
		end
	end
	return false
end
