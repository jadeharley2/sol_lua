
local VEC_FORWARD = Vector(0,0,-1)
local VEC_RIGHT = Vector(1,0,0)
local VEC_UP = Vector(0,1,0)

OBJ.mouse_lastpos = {0,0}
OBJ.camZoom = 0

--OBJ.actor 

OBJ.mouseWheelValue = 0
OBJ.mouseWheelDelta = 0 

function OBJ:Init()
	
	local cam = GetCamera()
	cam:SetAng(Vector(0,-90,0))
	--TACTOR:SetAng(Vector(0,0,0))
	TACTOR:SetUpdateSpace(true)
	AddOrigin(TACTOR)
	if not TACTOR.controller then
		TACTOR.controller = self
	end
	cam:SetUpdateSpace(false)
	cam:SetParent(TACTOR)
	self.mouseWheelValue = input.MouseWheel()  
	self.ctargetval = 0
	self.fponly = settings.GetBool("server.firstperson")
	if self.fponly then
		self.camZoom = 0
	end
	
	hook.Add("event.item.droprequest","process",function(itemframe) 
		self:HandleDrop(TACTOR,itemframe)
		return true
	end)
	if INVWINDOW and TACTOR.inventory then
		INVWINDOW:SetInventory(TACTOR.inventory) 
	end
end
function OBJ:UnInit()
	local cam = GetCamera()
	local cp = cam:GetPos()
	TACTOR:SetUpdateSpace(false) 
	if TACTOR.controller == self then
		TACTOR.controller = nil
	end
	cam:SetUpdateSpace(true)
	cam:Eject()
	--cam:SetParent(TACTOR:GetParent())
	RemoveOrigin(TACTOR)
	
	local szd = TACTOR:GetSizepower() / TACTOR:GetParent():GetSizepower()
	
	--cam:SetPos(TACTOR:GetPos()+cp*szd)
	if self.lms_active then
		input.SetCursorHidden(false)
		self.lms_active = false
	end
end

function OBJ:MouseWheel()
	if self.fponly then
		self.camZoom = 0
	else
		local mWVal = input.MouseWheel() 
		if not input.GetKeyboardBusy() then
			if (input.KeyPressed(KEYS_X)) then 
				self.mouseWheelDelta = self.mouseWheelDelta + (mWVal - self.mouseWheelValue)
				self.camZoom = math.Clamp( self.mouseWheelDelta / 500,0,10)
			end
		end
		self.mouseWheelValue = mWVal 
	end
end 

local timer = 0
function OBJ:KeyDown(key)
	if input.GetKeyboardBusy() then return nil end
	local actor = TACTOR 
	local aibusy = self:ActorIsBusy()
	if not aibusy then
		if actor.IsInVehicle then 
			if (input.KeyPressed(KEYS_V)) then 
				actor:SetVehicle(nil)
			end
		else
			if (input.KeyPressed(KEYS_E)) then 
				self:HandleUse(actor)
			end
			 
			if input.KeyPressed(KEYS_F) then
				self:HandlePickup(actor)
			end
		end
		
		
		if (input.KeyPressed(KEYS_D1)) then 
			local ab = actor.abilities
			if ab then
				local a1 = ab[1] if a1 then a1:Cast(actor) end
			end
		end
		if (input.KeyPressed(KEYS_D2)) then 
			local ab = actor.abilities
			if ab then
				local a1 = ab[2] if a1 then a1:Cast(actor) end
			end
		end
		if (input.KeyPressed(KEYS_D3)) then 
			local ab = actor.abilities
			if ab then
				local a1 = ab[3] if a1 then a1:Cast(actor) end
			end
		end
		if (input.KeyPressed(KEYS_D4)) then 
			local ab = actor.abilities
			if ab then
				local a1 = ab[4] if a1 then a1:Cast(actor) end
			end
		end
	end
	if (input.KeyPressed(KEYS_I)) then  
		if not actor.inventory then
			actor.inventory = Inventory(4*8) 
		end
		if not INVWINDOW then
			local vsize = GetViewportSize()
			INVWINDOW = panel.Create("window_inventory")
			INVWINDOW:UpdateLayout()
			INVWINDOW:SetTitle("Inventory")
			INVWINDOW:SetPos(0,-vsize.y+180)
			INVWINDOW:SetSize(500,180)
			INVWINDOW:UpdateLayout()
			INVWINDOW:SetInventory(actor.inventory)
			INVWINDOW:UpdateLayout()
			hook.Add("event.inventory.update","updatecurrent",function(inv) 
				if INVWINDOW then
					INVWINDOW:SetInventory(INVWINDOW.inv) 
				end
			end)
			SHOWINV = false
		end
		
		if not SHOWINV then
			INVWINDOW:Show()
			SHOWINV = true
		else
			INVWINDOW:Close()
			SHOWINV = false
		end
	end
	if (input.KeyPressed(KEYS_F5)) then 
		local fc = settings.GetBool("server.nofreecam")
		if not fc then
			SetController("freecameracontroller")
		end
	end
	if (input.KeyPressed(KEYS_F6)) then 
		SetController("starmapcontroller")
	end
			 
	if input.KeyPressed(KEYS_C) then
		self:ToggleMouse()
	end
end 
function OBJ:ActorIsBusy()
	local actor = TACTOR 
	
	return actor.controller ~= self or (not actor:GetUpdating())
end

function OBJ:Update() 

	local actor = TACTOR 
	
	local dt = 1
	
	if actor:GetUpdating() and actor.controller == self then 
		if actor.IsInVehicle then
			if not input.GetKeyboardBusy() then  
				self:HandleDriving(actor)
			end
		else
			if not input.GetKeyboardBusy() and network.CanBeControlled(actor) then  
				self:HandleActions(actor)
				self:HandleMovement(actor)
			end
			---self:HandleWaterTest(actor)
		end
	end

	self:HandleCameraMovement(actor)
	
	--
end


function OBJ:HandleMovement(actor) 
	--if actor:IsFlying() then
	--	self:HandleFlight(actor)
	--else
		if self.camZoom==0 or self.fponly then
			self:HandleFirstPersonMovement(actor)
		else
			self:HandleThirdPersonMovement(actor)
		end
	--end
end

function OBJ:HandleActions(actor) 
	local E = input.KeyPressed(KEYS_E)
	if E then
		actor:Attack()
	end
	
	local B = input.KeyPressed(KEYS_B)
	if B then
		if actor.Recall then actor:Recall() end
	end
	
	local weap = actor:GetActiveWeapon()
	if weap then
		self:HandleWeapon(actor,weap)
	end
	
	
	--self:HandleDrop(actor)
end
function OBJ:HandleWeapon(actor,weap)
	local F = input.KeyPressed(KEYS_F)
	local R = input.KeyPressed(KEYS_R)
	if F then
		weap:Fire()
	end
	if R then
		actor:DropActiveWeapon()
	end
end
function OBJ:HandleThirdPersonMovement(actor)
	local model = actor.model
	local phys =  actor.phys
	local graph =  actor.graph
	
	
	local cam = GetCamera()
	local cam_parent = cam:GetParent()
	local parent_sz = cam_parent:GetSizepower()
	local Forward = cam:Forward():Normalized()
	local sForward = actor:Right():Normalized()
	local Right = cam:Right():Normalized()
	local Up = actor:Up():Normalized()
	local inUp = Vector(0,1,0)
	local aibusy = self:ActorIsBusy()
	
	local result = Vector(0,0,0)
	
	local W,A,S,D = input.KeyPressed(KEYS_W),input.KeyPressed(KEYS_A),input.KeyPressed(KEYS_S),input.KeyPressed(KEYS_D)
	 
	local IsRunning =  input.KeyPressed(KEYS_SHIFTKEY)
	 
	if W then result = result - Vector(0,0,1) end
	if S then result = result + Vector(0,0,1) end
	if D then result = result - Vector(1,0,0) end
	if A then result = result + Vector(1,0,0) end
	if input.KeyPressed(KEYS_SPACE) then actor:Jump() end--result = result - Up end
	--if input.KeyPressed(KEYS_CONTROLKEY) then result = result + Up end
	
	if result ~= Vector(0,0,0) then 
		result = result:Normalized()
	end
	
	if not aibusy then
		if input.KeyPressed(KEYS_CONTROLKEY) then
			actor:Duck()
			if not actor:Crouching() then actor:SetCrouching(true) end
		else 
			if actor:Crouching() then actor:SetCrouching(false) end
		end
	 
	
	
		if W or A or S or D and result ~= Vector(0,0,0) then
			--actor.move = -result
			--graph:SetState("run")
			
			
			
			local targetval = 0
			if W then
				if A then targetval = -45 end
				if D then targetval = 45 end
				if not A and not D then targetval = 0 end
			elseif S then
				if A then targetval = -135 end
				if D then targetval = 135 end
				if not A and not D then targetval = -180 end
			else 
				if A then targetval = -90 end
				if D then targetval = 90 end
			end
			local smt = (self.sm_targetval or 0) 
			smt = smt + math.AngleDelta(-targetval,smt)/4
			self.sm_targetval = smt
			local angd = math.AngleDelta(smt , self.ctargetval or 0)
			local dval = angd/180*3.1415926
			actor:TRotateAroundAxis(Up, dval)
			cam:TRotateAroundAxis(inUp, -dval)
			self.ctargetval = math.NormalizeAngle((self.ctargetval or 0) + angd)
			--MsgN(angd)
			actor:Move(Vector(0,0,1),IsRunning)
			
			self.rmode = true
			
		else
			if actor:IsMoving() then actor:Stop() end
		end 
	
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
			local offx = offset.x
			local offy = offset.y
			self.mouse_lastpos = mousePos
			input.setMousePosition(center)
			
			
			local angtX = ((self.totalCamRotationX or 0) + (offy / -1000))/ 3.1415926 * 180
			if math.abs(angtX)>90 then
				offy = 0
			end
			
			cam:TRotateAroundAxis(Right, (offy / -1000))
			
			self.totalCamRotationY = (self.totalCamRotationY or 0) + (offx / -1000)
			local tcr = self.totalCamRotationY
			
			cam:TRotateAroundAxis(inUp, (offx / -1000))
			if tcr and math.abs(tcr)>1 then
				self.rmode = true
				--cam:TRotateAroundAxis(Up, -tcr)
				--actor:TRotateAroundAxis(Up, tcr)  
				--self.totalCamRotationY = nil
			end
			if self.rmode then
				local tcr2 = self.totalCamRotationY/2
				cam:TRotateAroundAxis(inUp, -tcr2)
				actor:TRotateAroundAxis(Up, tcr2) 
				self.totalCamRotationY = tcr2
				if  math.abs(tcr2)<0.01 then
					self.rmode = false
					self.totalCamRotationY = nil
					local tgt = ( (self.totalCamRotationX or 0) / 3.1415926 * 180)
					cam:SetAng(Vector(tgt,-90-self.ctargetval,0)) 
				end
			end
			
			
			self.totalCamRotationX = (self.totalCamRotationX or 0) + (offy / -1000)
			
		end 
	end
	
	actor.model:SetPoseParameter("move_yaw",0)
	--phys:SetViewDirection(sForward)
end

function OBJ:HandleFirstPersonMovement(actor)
	local model = actor.model
	local phys =  actor.phys
	local graph =  actor.graph
	
	
	local cam = GetCamera()
	local cam_parent = cam:GetParent()
	local parent_sz = cam_parent:GetSizepower()
	local Forward = cam:Forward():Normalized()
	local sForward = actor:Right():Normalized()
	local Right = cam:Right():Normalized()
	local Up = actor:Up():Normalized()
	local inUp = Vector(0,1,0)
	local aibusy = self:ActorIsBusy()
	
	
	local result = Vector(0,0,0)
	
	local W,A,S,D = input.KeyPressed(KEYS_W),input.KeyPressed(KEYS_A),input.KeyPressed(KEYS_S),input.KeyPressed(KEYS_D)
	 
	local IsRunning =  input.KeyPressed(KEYS_SHIFTKEY)
	
	
	if W then result = result - Vector(0,0,1) end
	if S then result = result + Vector(0,0,1) end
	if D then result = result - Vector(1,0,0) end
	if A then result = result + Vector(1,0,0) end
	if input.KeyPressed(KEYS_SPACE) then actor:Jump() end--result = result - Up end
	--if input.KeyPressed(KEYS_CONTROLKEY) then result = result + Up end
	
	if result ~= Vector(0,0,0) then 
		result = result:Normalized()
	end
	
	if not aibusy then
		if input.KeyPressed(KEYS_CONTROLKEY) then
			actor:Duck()
			if not actor:Crouching() then actor:SetCrouching(true) end
		else 
			if actor:Crouching() then actor:SetCrouching(false) end
		end
		if W or A or S or D and result ~= Vector(0,0,0) then
			--actor.move = -result
			--graph:SetState("run")
			
			local pp = actor.model:GetPoseParameter("move_yaw")
			local targetval = 0
			if W then
				if A then targetval = -45 end
				if D then targetval = 45 end
				if not A and not D then targetval = 0 end
			elseif S then
				if A then targetval = -135 end
				if D then targetval = 135 end
				if not A and not D then targetval = -180 end
			else 
				if A then targetval = -90 end
				if D then targetval = 90 end
			end
			pp = pp + (targetval - pp)/10
			actor.model:SetPoseParameter("move_yaw",pp)
			
			actor:Move(-result,IsRunning)
			
			self.rmode = true
		else
			--actor.move = nil
			--graph:SetState("idle")
			if actor:IsMoving() then actor:Stop() end
		end
	
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
			local offx = offset.x
			local offy = offset.y
			self.mouse_lastpos = mousePos
			input.setMousePosition(center)
			
			 
				local angtY = ((self.totalCamRotationY or 0) + (offx / -1000))/ 3.1415926 * 180
				if math.abs(angtY)>90 then
					offx = 0
				end 
			local angtX = ((self.totalCamRotationX or 0) + (offy / -1000))/ 3.1415926 * 180
			if math.abs(angtX)>90 then
				offy = 0
			end
			
			cam:TRotateAroundAxis(Right, (offy / -1000))
			
			self.totalCamRotationY = (self.totalCamRotationY or 0) + (offx / -1000)
			local tcr = self.totalCamRotationY
			
			cam:TRotateAroundAxis(inUp, (offx / -1000))
			if tcr and math.abs(tcr)>1 then
				self.rmode = true
				--cam:TRotateAroundAxis(Up, -tcr)
				--actor:TRotateAroundAxis(Up, tcr)  
				--self.totalCamRotationY = nil
			end
			if self.rmode then
				local tcr2 = self.totalCamRotationY/2
				cam:TRotateAroundAxis(inUp, -tcr2)
				actor:TRotateAroundAxis(Up, tcr2) 
				self.totalCamRotationY = tcr2
				if  math.abs(tcr2)<0.01 then
					self.rmode = false
					self.totalCamRotationY = nil
					local tgt = ( (self.totalCamRotationX or 0) / 3.1415926 * 180)
					cam:SetAng(Vector(tgt,-90,0))
				end
			end
			--
			self.totalCamRotationX = (self.totalCamRotationX or 0) + (offy / -1000)
			--actor:TRotateAroundAxis(Up, (offset.x / -1000)) 
		end 
	end
	
	--phys:SetViewDirection(sForward)
	
end
function OBJ:HandleDriving(actor)
	local W,A,S,D,Q,E= input.KeyPressed(KEYS_W),input.KeyPressed(KEYS_A),input.KeyPressed(KEYS_S),input.KeyPressed(KEYS_D),input.KeyPressed(KEYS_Q),input.KeyPressed(KEYS_E)
	local vehicle = actor.vehicle
	 
	if vehicle.Throttle then
		if W then
			vehicle:Throttle(1)
		end
		if S then
			vehicle:Throttle(-1)
		end
	end 
	if vehicle.Turn then
		if A then
			vehicle:Turn(1)
		end
		if D then
			vehicle:Turn(-1)
		end
	end
	if vehicle.Turn2 then
		if Q then
			vehicle:Turn2(1)
		end
		if E then
			vehicle:Turn2(-1)
		end
	end
	local vehHandleDriving = vehicle.HandleDriving
	if vehHandleDriving then
		vehHandleDriving(vehicle,actor)
	end
end
function OBJ:HandleUse(actor)
	local maxUseDistance = 2
	local pos = actor:GetPos()
	local par = actor:GetParent()
	local sz = par:GetSizepower()
	local ents = par:GetChildren()
	local nearestent = false
	local ndist = maxUseDistance*maxUseDistance
	for k,v in pairs(ents) do
		if v~=actor and v:HasFlag(FLAG_USEABLE) then 
			local edist = pos:DistanceSquared(v:GetPos())*sz*sz 
			if edist<ndist and edist>0 then
				nearestent = v
				ndist = edist
			end
		end
	end
	if nearestent then
		nearestent:SendEvent(EVENT_USE,actor)
		hook.Call("event.use",actor,nearestent)
	end 
end
function OBJ:HandlePickup(actor)
	local inv = actor.inventory
	if inv then
		local maxPickupDistance = 2
		local pos = actor:GetPos()
		local par = actor:GetParent()
		local sz = par:GetSizepower()
		local entsc = par:GetChildren()
		local nearestent = false
		local ndist = maxPickupDistance*maxPickupDistance
		for k,v in pairs(entsc) do
			if v~=actor and v:HasFlag(FLAG_STOREABLE) then 
				local edist = pos:DistanceSquared(v:GetPos())*sz*sz 
				if edist<ndist and edist>0 then
					nearestent = v
					ndist = edist
				end
			end
		end
		if nearestent then
			nearestent:SendEvent(EVENT_PICKUP,actor)
			if inv:AddItem(nearestent) then
				local storage = inv.storage
				if not storage then 
					storage = ents.Create()	
					storage:SetSizepower(1000)
					storage:Spawn() 
					inv.storage = storage
				end 
				nearestent:SetParent(storage)
				hook.Call("event.pickup",actor,nearestent)
				hook.Call("event.inventory.update",inv,actor)
			end
		end 
	end
end
function OBJ:HandleDrop(actor,c)
	--	MsgN("C da ",CURRENT_DRAG)
	--if CURRENT_DRAG then
	--	local mhag = input.MouseIsHoveringAboveGui()
	--	local lmb = input.leftMouseButton()
	--	MsgN(mhag," da ",lmb)
	--	if not mhag and lmb then
			--local c = CURRENT_DRAG
			local item = c.item
			if item then 
				c:Drop() 
				c.inv:RemoveItem(item) 
				item:SetParent(actor:GetParent())
				item:SetPos(actor:GetPos())
				hook.Call("event.drop",actor,item)
				hook.Call("event.inventory.update",c.inv,actor)
		 	end
		--end
	--end
end

function OBJ:HandleCameraMovement(actor)
	
	local ep,ey = actor:EyeAngles()
	
	local cam = GetCamera()
	local cam_parent = cam:GetParent()
	local parent_sz = cam_parent:GetSizepower()
	local Forward = cam:Forward():Normalized()  
	local Right = cam:Right():Normalized()
	local Up = actor:Up():Normalized()
	local inUp = Vector(0,1,0)
	
	local mhag = input.MouseIsHoveringAboveGui()
	local lmb = input.leftMouseButton()
	local rmb = input.rightMouseButton()
	
	local controlled =  actor:GetUpdating() and actor.controller == self 
	
	if not controlled and self.camZoom==0 then
		local sx =  ep * 3.1415926 / 180
		local sy = -ey * 3.1415926 / 180
		cam:TRotateAroundAxis(Right, sx - (self.totalCamRotationX or 0) )
		cam:TRotateAroundAxis(inUp,  sy - (self.totalCamRotationY or 0)  )
		self.totalCamRotationX = sx
		self.totalCamRotationY = sy
	end
	
	if not mhag and (controlled or self.camZoom>0) and (lmb or (actor.IsInVehicle and not actor.vehicle:HasFlag(FLAG_ACTOR) and rmb)) then  
		if not self.lms_active then
			input.SetCursorHidden(true)
			self.lms_active = true
		end
		local mousePos = input.getMousePosition()
		local size = GetViewportSize() 
		local center = size / 2
		center = Point(math.floor( center.x),math.floor(center.y))
		local offset = mousePos - center
		local offx = offset.x
		local offy = offset.y
		
		self.mouse_lastpos = mousePos
		input.setMousePosition(center)
		
		if lmb and self.camZoom==0 then
			local angtY = ((self.totalCamRotationY or 0) + (offx / -1000))/ 3.1415926 * 180
			if math.abs(angtY)>90 then
				offx = 0
			end
		end
		local angtX = ((self.totalCamRotationX or 0) + (offy / -1000))/ 3.1415926 * 180
		if math.abs(angtX)>90 then
			offy = 0
		end
		
		cam:TRotateAroundAxis(Right, (offy / -1000))
		cam:TRotateAroundAxis(inUp, (offx / -1000)) 
		self.totalCamRotationY = (self.totalCamRotationY or 0) + (offx / -1000)
		self.totalCamRotationX = (self.totalCamRotationX or 0) + (offy / -1000)
		--actor:TRotateAroundAxis(Up, (offset.x / -1000))  
	end
	if self.lms_active and (not (lmb or rmb) or mhag) then
		input.SetCursorHidden(false)
		self.lms_active = false
	end
	
	--Up = actor:Up():Normalized() / parent_sz
	Up = inUp / parent_sz
	
	Forward = cam:Forward():Normalized() / parent_sz 
	Right = cam:Right():Normalized() / parent_sz
	
	if controlled and not vr.IsEnabled() then 
		actor:SetEyeAngles( --pitch, yaw 
			( (self.totalCamRotationX or 0) / 3.1415926 * 180),
			(-(self.totalCamRotationY or 0) / 3.1415926 * 180)) 
	end
	
	if self.camZoom==0 then
		local pos = Vector(0,0,0)
		local m = actor.model
		if m then
			if m:HasAttachment("eyes") then pos = m:GetAttachmentPos("eyes") 
			elseif m:HasAttachment("head") then pos = m:GetAttachmentPos("head") end -- * parent_sz
		end
		--cam:SetPos((pos - Forward * 2 * 0    +Vector(-0.4,0,0)  - Forward * self.camZoom) / parent_sz)
		--DrawPoint(-10,actor,pos)
		cam:SetPos(( pos + Forward * 0.05) )
	else
		--cam:SetPos((Up*1.1   +Vector(-0.4,0,0) - Forward * self.camZoom) / parent_sz)
		cam:SetPos( Up - Forward * self.camZoom )
	end
	
	--for i=0,50 do
	--	local pos = actor.model:GetBonePos(i)
	--	DrawPoint(i,actor,pos)
	--end
	
	if vr.IsEnabled() then
		local pos,ang,mang = vr.GetHead() 
		actor:SetEyeAngles( ang.x/ 3.1415926 * 180 ,ang.y/ 3.1415926 * 180) 
		 
		cam:SetAng(mang*matrix.Rotation(0,-90,0))
		--local ep,ey = actor:EyeAngles()
		--local sx =  ep * 3.1415926 / 180
		--local sy = -ey * 3.1415926 / 180
		--cam:TRotateAroundAxis(Right, sx - (self.totalCamRotationX or 0) )
		--cam:TRotateAroundAxis(Up,  sy - (self.totalCamRotationY or 0)  )
		--self.totalCamRotationX = sx
		--self.totalCamRotationY = sy
		
		if self.camZoom==0 then
			local ep = vr.GetCurrentEye()
			local m = actor.model
			local pos = m:GetAttachmentPos("head") 
			if ep == 1 then
				pos = m:GetAttachmentPos("eyel") 
			else
				pos = m:GetAttachmentPos("eyer")  
			end			
			cam:SetPos( pos )
		end
	end
end

function OBJ:HandleWaterTest(actor)
	local planet = actor:GetParentWithFlag(FLAG_PLANET) 
	if planet then
		local dist = actor:GetDistance(planet)
		local radius = planet.radius
		if radius then
			local sealevel_height = dist-radius 
			if sealevel_height<0 then
				actor.phys:ApplyImpulse(Vector(0,-sealevel_height,0))
			end
		end
	end
end

function OBJ:HandleFlight(actor)
	 
	
end

function DrawPoint(id,parent,pos,size)
	size = size or 5
	parent._pt = parent._pt or {}
	local e = parent._pt[id]
	if not e then
		e = ents.Create()
		e:SetParent(parent)
		e:SetSizepower(size)
		e:SetSpaceEnabled(false) 
		e:Spawn()
		parent._pt[id] = e;
	end
	e:SetPos(pos)
	e:SetSizepower(size)
end