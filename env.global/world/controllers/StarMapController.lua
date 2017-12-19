
local VEC_FORWARD = Vector(0,0,-1)
local VEC_RIGHT = Vector(1,0,0)
local VEC_UP = Vector(0,1,0)

OBJ.mouse_lastpos = {0,0}
OBJ.speed = 0.01
 

OBJ.mouseWheelValue = 0
OBJ.mouseWheelDelta = 0

function OBJ:Init() 
	if STARMAP then
		network.RequestAssignNode(STARMAP)
		self.mouseWheelValue = input.MouseWheel()  
		--local c = GetCamera()
		--local cp = c:GetParent()
		--c:LookAt(-c:GetLocalCoordinates(STARMAP))
	else
		return false
	end
end
function OBJ:UnInit() 
	network.RequestUnassignNode(STARMAP)
end

function OBJ:MouseWheel()
	local mWVal = input.MouseWheel() 
	if not STARMAP then return nil end
	
	if not input.GetKeyboardBusy() then
		self.mouseWheelDelta = self.mouseWheelDelta + (mWVal - self.mouseWheelValue)
		STARMAP.holo_scale = math.pow(2, self.mouseWheelDelta / 1000) * 30
		STARMAP:SetNWDouble("holo_scale",STARMAP.holo_scale)
	end
	self.mouseWheelValue = mWVal 
end

function OBJ:KeyDown(key)  
	if (input.KeyPressed(KEYS_D0)) then 
		SetController("actorcontroller")
	end
	if input.KeyPressed(KEYS_E) then
		local selected = TESTSELECTOR:GetParent()
		local target = selected.ref
		if target then
			local ship = STARMAP:GetParent()
			
			local type = selected.type
			if type == "system" then
				--ship:HyperjumpSequence(Coordinate(target))
			elseif type == "station" then
				--ship:SendEvent(EVENT_DOCK,target)
				--ship:DockSequence(target) -- InstaDock -- cheats
			else
				self:MoveTo(50,selected:GetPos()/2,-5000,function()
					self.selectedcelestial = selected
					STARMAP:LoadCelestialMap(selected)
					STARMAP.holo_center = Vector(0,0,0)
					self:SetScale(10000)
					self:MoveTo(50,Vector(0,0,0),-5000,function() end)
				end)
				--ship:SendEvent(EVENT_WARPJUMP,target)
				--if network.IsConnected() then
				--	network.CallServer("ship_jump",ship,target)
				--else
				--	ship:WarpSequence(Coordinate(target))
				--end
			end
		end
	end
	if input.KeyPressed(KEYS_F) then
		local selected = TESTSELECTOR:GetParent()
		local target = selected.ref
		if target then
			local ship = STARMAP:GetParent()
			local type = selected.type
			MsgN("d",type)
			if type == "system" then
				--ship:HyperjumpSequence(Coordinate(target))
				ship:SendEvent(EVENT_HYPERJUMP,target)
			elseif type == "station" then
				ship:SendEvent(EVENT_DOCK,target)
			else
				ship:SendEvent(EVENT_WARPJUMP,target)
			end
		end
	end
	if input.KeyPressed(KEYS_R) then
		local state = STARMAP.state
		if state == "starsystem" then
			self:MoveTo(50,Vector(0,0,0),10000,function()
				STARMAP:LoadGalaxyMap()
				--STARMAP.holo_center = Vector(0,0,0)
				self:SetScale(-10000) 
				self:MoveTo(15,Vector(0,0,0),-3000,function() end)
			end)
		elseif state == "galaxy" then
			self:MoveTo(15,Vector(0,0,0),-5000,function()
				STARMAP:LoadSystemMap()
				--STARMAP.holo_center = Vector(0,0,0)
				self:SetScale(10000)
				self:MoveTo(50,Vector(0,0,0),-500,function() end)
			end)
		else
			self:MoveTo(50,Vector(0,0,0),10000,function()
				STARMAP:LoadSystemMap()
				local scel = self.selectedcelestial
				if scel then
					STARMAP.holo_center = scel:GetPos()/2
				end
				self:SetScale(-10000) 
				self:MoveTo(50,STARMAP.holo_center,-1000,function() end)
			end)
		end
	end
end
function OBJ:MoveTo(time,pos,zoom,on_end)
	local start = STARMAP.holo_center
	local t = 0 --t/100
	debug.DelayedTimer(0,1,time,function() 
		STARMAP.holo_center = LerpVector(STARMAP.holo_center,pos,0.5)  
		self:SetScale(self.mouseWheelDelta + (zoom-self.mouseWheelDelta)/5)
		t = t+1 
		if t==time then on_end() end 
	end)
end
function OBJ:SetScale(scale)
	self.mouseWheelDelta = scale
	STARMAP.holo_scale = math.pow(2, self.mouseWheelDelta / 1000) * 30
	STARMAP:SetNWDouble("holo_scale",STARMAP.holo_scale)
end
function OBJ:Update() 

	 
	local dt = 1
	
	if not STARMAP then return nil end
	
	local cam = STARMAP.cam
	local cam_parent = cam:GetParent()
	local parent_sz = cam_parent:GetSizepower()
	local Forward = cam:Forward():Normalized()
	local Right = cam:Right():Normalized()
	local Up = cam:Up():Normalized()
	
	local result = Vector(0,0,0)
	if input.KeyPressed(KEYS_W) then result = result - Forward end
	if input.KeyPressed(KEYS_S) then result = result + Forward end
	if input.KeyPressed(KEYS_D) then result = result - Right end
	if input.KeyPressed(KEYS_A) then result = result + Right end
	if input.KeyPressed(KEYS_SPACE) then result = result - Up end
	if input.KeyPressed(KEYS_CONTROLKEY) then result = result + Up end

	if result ~= Vector(0,0,0) then 
		result = result:Normalized()
	end
	
	if input.KeyPressed(KEYS_Q) then 
		--cam:RotateAroundAxis(VEC_FORWARD, -0.01)
	end
	if input.KeyPressed(KEYS_E) then 
		--cam:RotateAroundAxis(VEC_FORWARD, 0.01)
	end
	if input.rightMouseButton() then
		local mousePos = input.getMousePosition()
		local size = GetViewportSize() 
		local center = size / 2
		center = Point(math.floor( center.x),math.floor(center.y))
		local offset = mousePos - center
		self.mouse_lastpos = mousePos
		input.setMousePosition(center)
		STARMAP:RotateAroundAxis(Right, (offset.y / -1000))
		STARMAP:RotateAroundAxis(VEC_UP, (offset.x / 1000))
	end 
	
	if input.KeyPressed(KEYS_SHIFTKEY) then 
		result = result*4
	end 
	if input.KeyPressed(KEYS_ALT) then 
		result = result/4
	end 
	
	STARMAP.holo_center = STARMAP.holo_center - result / parent_sz * STARMAP.holo_scale *0.1
	
	
	
	local mo = STARMAP.origin 
	local mopp = mo:GetParent()
	local mop = mo:GetPos()
	if input.leftMouseButton() then
		if TESTSELECTOR then
			local he = false
			local mdist = 1e10
			for k,v in pairs(STARMAP.objects) do
				local vdist =mopp:GetLocalCoordinates(v):DistanceSquared(mop) -- v:GetPos()
				if vdist<mdist then
					mdist = vdist
					he = v
				end
			end
			
			if he and TESTSELECTOR:GetParent() ~= he then
				TESTSELECTOR:SetParent(he)
			end
		end
	end
	
	--if CAMTESTPR then
		--if not CAMTESTPR_FIRST then
		--	CAMTESTPR:SetUpdating(false)
		--	CAMTESTPR:SetParent(cam:GetParent())
		--	CAMTESTPR_FIRST = true
		--	CAMTESTPR:SetSpaceEnabled(false)  
		--end
	--	local mousePos = input.getInterfaceMousePos()
	--	local lp = cam:Unproject(mousePos )--:Normalized()
	--	local cpp = (cam:GetPos() + lp*30)--
	--	local hit,hd,hp,he = cam:Trace(lp)--,{CAMTESTPR})
	--	if hit and hd < 30 then
	--		cpp = hp
	--		if input.leftMouseButton() then
	--			if TESTSELECTOR then
	--				if TESTSELECTOR:GetParent() ~= he then
	--					TESTSELECTOR:SetParent(he)
	--				end
	--			end
	--		end
	--	end 
		--CAMTESTPR:SetPos(cpp)
	
	STARMAP:SetNWVector("holo_center",STARMAP.holo_center)
	--end 
end