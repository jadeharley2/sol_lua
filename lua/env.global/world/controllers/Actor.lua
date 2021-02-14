BLOCK_MOUSE = false
if CLIENT then
	global_infobar = global_infobar or panel.Create("infobar") 
end
local HIDE_CHAR_IN_FIRST_PERSON = function() return settings.GetBool("player.fpmode2",true) end

local MODE_FIRSTPERSON = 1
local MODE_THIRDPERSON = 2

local VEC_FORWARD = Vector(0,0,-1)
local VEC_RIGHT = Vector(1,0,0)
local VEC_UP = Vector(0,1,0) 
 
OBJ.mouse_lastpos = {0,0}
OBJ.camZoom = 0

--OBJ.actor 

OBJ.mouseWheelValue = 0
OBJ.mouseWheelDelta = 0
OBJ.mouseactive = true

OBJ.flightmode = true
OBJ.waitforreturn = true


function OBJ:Init()
	
	local cam = GetCamera()
	local actor = LocalPlayer()
	if not actor or not IsValidEnt(actor) then  	
		local cp = cam:GetParent()
		if cp and IsValidEnt(cp) and cp.Duck then
			SetLocalPlayer(cp)
			actor = cp  
		else
			SetController("freecamera") 
			return 
		end
	end
	healthbar = panel.Create("healthbar")  
	--healthbar:SetPos(-1610,-980) --+csize.x +csize.y 
	healthbar:Show()
	healthbar:UpdatePos()  
	healthbar:UpdateHealth(actor:GetParameter(VARTYPE_HEALTH),actor:GetParameter(VARTYPE_MAXHEALTH))
	 
	infobar = global_infobar
	infobar:SetPos(0,-180) --+csize.x +csize.y 
	infobar:Show()
	
	quickmenu = panel.Create("quickmenu")   
	quickmenu:Show() 
	quickmenu:UpdatePos()
	healthbar:SetPos(quickmenu:GetPos()+Point(0,50))
	
	
	cam:SetAng(Vector(0,-90,0))
	--actor:SetAng(Vector(0,0,0))
	actor:SetUpdateSpace(true)
	AddOrigin(actor)
	if not actor.controller then
		actor.controller = self
	end
	cam:SetUpdateSpace(false)
	cam:SetParent(actor)
	cam:SetPos(Vector(0,0,0))
	self.mouseWheelValue = input.MouseWheel()  
	self.ctargetval = 0
	self.fponly = settings.GetBool("server.firstperson")
	if self.fponly then
		self.camZoom = 0
	end
	 
	
	if healthbar and actor:HasTag(TAG_ACTOR) and actor.GetHealth then
		healthbar:UpdateHealth(actor:GetHealth(),actor:GetMaxHealth())
	end
	if self.camZoom==0 then 
		self:SwitchToFirstperson(actor)
	end
	
	hook.Add("event.item.droprequest","process",function(itemframe) 
		self:HandleDrop(actor,itemframe)
		return true
	end)
	hook.Add("settings.changed","actorcontroller",function()
		self:UnInit()
		self:Init()
	end)

	--TEMP
	--if not actor.inventory then
	--	actor.inventory = Inventory(4*8,actor:GetSeed()+3000) 
	--end
	
	
	if GLOBAL_healthbar then GLOBAL_healthbar:Close() GLOBAL_healthbar=nil end
	if GLOBAL_infobar then GLOBAL_infobar:UpdateBar(nil) GLOBAL_infobar:Close() GLOBAL_infobar=nil end
	if GLOBAL_quickmenu then GLOBAL_quickmenu:Close() GLOBAL_quickmenu=nil end 
	GLOBAL_healthbar = healthbar
	GLOBAL_infobar = infobar
	GLOBAL_quickmenu = quickmenu
	
	self:CreateCharacterPanels(actor)
	 
	quickmenu:SetData(actor.qdata,actor.storage)
	self.rmode = true
end

function OBJ:UnInit()

	local cam = GetCamera()
	local actor = LocalPlayer()
	if not actor then return end
	
	local cp = cam:GetPos()
	if actor and IsValidEnt(actor) then 
		actor:SetUpdateSpace(false) 
		if actor.controller == self then
			actor.controller = nil
		end
	end
	cam:SetUpdateSpace(true)
	--cam:SetParent(actor:GetParent())
	if actor and IsValidEnt(actor) then  
		RemoveOrigin(actor)
		--local acp = actor:GetParent()
		--local szd = actor:GetSizepower() / acp:GetSizepower()
		--cam:SetPos(actor:GetPos()+cp*szd)
	end
	 
	
	
	if self.lms_active then
		input.SetCursorHidden(false)
		self.lms_active = false
	end
	
	hook.Remove("settings.changed","actorcontroller")
	hook.Remove("event.item.droprequest","process")
	
	if actor and IsValidEnt(actor)  then 
		self:SwitchToThirdperson(actor)
		
		actor.qdata = quickmenu:GetData()
	end
	
	self:DestroyCharacterPanels(actor)
	actor_panels.CloseAll()
	actor_panels.FreePersistent() 
	
	cam:Eject()

	local healthbar = GLOBAL_healthbar
	local infobar = GLOBAL_infobar
	local quickmenu = GLOBAL_quickmenu
	if healthbar then healthbar:Close() GLOBAL_healthbar=nil end
	if infobar then infobar:UpdateBar(nil) infobar:Close() GLOBAL_infobar=nil end
	if quickmenu then quickmenu:Close() GLOBAL_quickmenu=nil end 
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
	local actor = LocalPlayer() 
	local aibusy = self:ActorIsBusy()
	if not aibusy and actor:IsAlive() then
		if actor.IsInVehicle then 
			if (key == KEYS_V) then 
				actor:SendEvent(EVENT_EXIT_VEHICLE) --SetVehicle(nil)
			end
		else
			if (key == KEYS_E) then 
				self:HandleUse(actor)
			end
			 
			if (key == KEYS_Q) then  
				if actor_panels.HasPanels() then
					actor_panels.CloseAll()
				else
					actor_panels.OpenInventory(actor,ALIGN_BOTTOM,nil)
					actor_panels.OpenCharacterInfo(actor,ALIGN_LEFT,nil) 
					actor_panels.OpenPanel("spawnmenu",nil,ALIGN_CENTER) 
				end
				--local cpanels = self.cpanels or {}
				--if cpanels.inv then
				--	if not SHOWINV then
				--		cpanels:Open()
				--		SHOWINV = true 
				--	else
				--		cpanels:Close()
				--		SHOWINV = false
				--		CloseIWindows()
				--	end
				--	MsgN(SHOWINV)
				--end
			end
			if key == KEYS_F then
				self:HandlePickup(actor)
			end
			if key == KEYS_TAB then
				self.flightmode = not self.flightmode
			end
			
			
			if key == KEYS_J then
				actor:Alert()
			end
			if key == KEYS_R then
				--if actor:GetActiveWeapon() then
					--actor:SendEvent(EVENT_TOOL_DROP)
				--end
			end
			if key == KEYS_SPACE then actor:SendEvent(EVENT_ACTOR_JUMP) end
		end 
		
		--if quickmenu then
		--		--local ab = actor.abilities
		--		--if ab then
		--		--	local a1 = ab[2] if a1 then a1:Cast(actor) end
		--		--end
		--		
		--	if (input.KeyPressed(KEYS_D1)) then quickmenu:Select(actor,1) end
		--	if (input.KeyPressed(KEYS_D2)) then quickmenu:Select(actor,2) end
		--	if (input.KeyPressed(KEYS_D3)) then quickmenu:Select(actor,3) end
		--	if (input.KeyPressed(KEYS_D4)) then quickmenu:Select(actor,4) end
		--	if (input.KeyPressed(KEYS_D5)) then quickmenu:Select(actor,5) end
		--	if (input.KeyPressed(KEYS_D6)) then quickmenu:Select(actor,6) end
		--	if (input.KeyPressed(KEYS_D7)) then quickmenu:Select(actor,7) end
		--	if (input.KeyPressed(KEYS_D8)) then quickmenu:Select(actor,8) end
		--	if (input.KeyPressed(KEYS_D9)) then quickmenu:Select(actor,9) end
		--	if (input.KeyPressed(KEYS_D0)) then quickmenu:Select(actor,10) end 
		--end
	end
	if (key == KEYS_F5) then 
		local fc = settings.GetBool("server.nofreecam")
		if not fc then
			SetController("freecamera")
		end
	end
	--if (key == KEYS_F6) then 
	--	SetController("starmap")
	--end
			 
	if key == KEYS_C then
		self:ToggleMouse()
	end
		 
	if key == KEYS_Z then
		swap()
	end

	local actor_parent = actor:GetParent()
	if actor_parent and actor_parent.OnActorKeyDown then
		actor_parent:OnActorKeyDown(actor,key)
	end

end
function OBJ:MouseDown()
	--MsgN("MOUSE IS DED")
end

function OBJ:ToggleMouse()
	if self.mouseactive then
		--input.SetCursorHidden(false)
		self.mouseactive = false
	else 
		--input.SetCursorHidden(true)
		self.mouseactive = true 
	end
	
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


function OBJ:CreateCharacterPanels(actor)
	local cpanels = self.cpanels or {}
	if not cpanels.inv then
		local vsize = GetViewportSize()
		cpanels.inv = panel.Create("window_inventory")
		cpanels.inv:UpdateLayout()
		cpanels.inv:SetTitle("Inventory")
		cpanels.inv:SetPos(0,-vsize.y+180+150)
		cpanels.inv:UpdateLayout()
		SHOWINV = false
	end
	if not cpanels.char then
		local vsize = GetViewportSize()
		cpanels.char = panel.Create("window_character") 
		cpanels.char:SetTitle("Character")
		cpanels.char:SetPos(-vsize.x+180+150,0) 
		cpanels.char:Set(actor)
	end
	function cpanels:Open()
		cpanels.char:Set(actor)--refresh
		for k,v in pairs(cpanels) do
			if not isfunction(v) and v.Open then v:Open() end
		end
	end
	function cpanels:Close() 
		for k,v in pairs(cpanels) do
			if not isfunction(v) and v.Close then v:Close() end
		end
	end
	hook.Add("player.inventory.open","inventory",function() 
		if not SHOWINV then
			cpanels:Open() 
			SHOWINV=true 
		end
	end)
	hook.Add("player.inventory.close","inventory",function() 
		cpanels:Close() 
		SHOWINV=false 
	end)
	hook.Add("event.inventory.update","updatecurrent",function()  
	end) 
	self.cpanels = cpanels
end
function OBJ:DestroyCharacterPanels(actor)
	local cpanels = self.cpanels or {}
	if cpanels.Close then
		cpanels:Close()
	end
	self.cpanels = nil
end


function OBJ:ActorIsBusy()
	local actor = LocalPlayer()  
	if actor.controller and actor.controller.pai then return false end
	return actor.controller ~= self or (not actor:GetUpdating()) or ( actor.Dead and actor:Dead())
end

function OBJ:Update() 

	local actor = LocalPlayer() 
	if not actor or not IsValidEnt(actor) then 
		if self.waitforreturn then
			SetController("actorwait") 
		else
			SetController("freecamera") 
		end
		return 
	end
	local dt = 1
	
	if actor:HasTag(TAG_ACTOR) then
		if actor:GetUpdating() and not self:ActorIsBusy() and actor:IsAlive() then 
			if actor.IsInVehicle then
				if not input.GetKeyboardBusy() then  
					self:HandleDriving(actor)
				end
			else
				if not input.GetKeyboardBusy() and network.CanBeControlled(actor) then  
					self:HandleActions(actor)
					self:HandleMovement(actor)
				end 
			end
		end
	end
	
	self:HandleSwitch(actor)
	self:HandleCameraMovement(actor)
	self:HandleGetInfo(actor)
	--
end 

function OBJ:HandleMovement(actor) 
	--if actor:IsFlying() then
	--	self:HandleFlight(actor)
	--else
		--if self.camZoom==0 or self.fponly then
		--	self:HandleFirstPersonMovement(actor)
		--else
			self:HandleThirdPersonMovement(actor)
		--end
	--end
end

function OBJ:HandleActions(actor) 
	--local E = input.KeyPressed(KEYS_E)
	--if E then
	--	actor:Attack()
	--end
	
	local B = input.KeyPressed(KEYS_B)
	if B then
		if actor.Recall then actor:Recall() end
	end
	
	local weap = actor:GetActiveWeapon()
	if weap then
		self:HandleWeapon(actor,weap)
	else  
		local abil = actor:GetActiveAbility()
		if abil then
			self:HandleAbility(actor,abil)
		end
	end
	--self:HandleDrop(actor)
end
function OBJ:HandleWeapon(actor,weap)
	local LF = input.leftMouseButton()
	local RF = input.rightMouseButton()
	local R = input.KeyPressed(KEYS_R)
	local F = input.KeyPressed(KEYS_F)
	
	
	if self:MouseLocked() then
		local dir = Vector(1,0,0)
		if LF or RF then
			local parentphysnode = actor:GetParentWithComponent(CTYPE_PHYSSPACE)
			if parentphysnode then
				local cam = GetCamera()
				local lw = parentphysnode:GetLocalSpace(cam) 
				dir = lw:Forward()
			end
		end
		if LF then actor:WeaponFire(dir,false,self.clf) self.clf = true end 
		if RF then actor:WeaponFire(dir,true,self.crf) self.crf = true end  
		if F and weap.OnF then
			weap:OnF() 
		end 
		self.rmode = true
	end
	if not LF then self.clf = false end
	if not RF then self.crf = false end
	--if RF and weap.AltFire and weap:IsReady() then weap:SendEvent(EVENT_TOOL_FIRE,1) end  
	--if R then
	--	actor:SendEvent(EVENT_TOOL_DROP)
	--end
end
function OBJ:HandleAbility(actor,abname)
	local LF = input.leftMouseButton()
	local RF = input.rightMouseButton()
	local R = input.KeyPressed(KEYS_R)
	local F = input.KeyPressed(KEYS_F)
	 
	if self:MouseLocked() then
		if LF then  
			--actor:CastActiveAbility()
			actor:SendEvent(EVENT_ABILITY_CAST,abname)  
		end 
		if RF then 
			
		end  
		
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
	local is_first_person = self.camZoom ==0
	
	local result = Vector(0,0,0)
	
	local W = input.ActionActive(ACT_MOVE_FORWARD)
	local A = input.ActionActive(ACT_MOVE_LEFT)
	local S = input.ActionActive(ACT_MOVE_BACK)
	local D = input.ActionActive(ACT_MOVE_RIGHT)
	 
	local IsRunning = input.ActionActive(ACT_SPRINT)
	local asc = actor:GetScale()
	asc = Vector(asc.z,asc.y,asc.x)
	 
	if W then result = result - Vector(0,0,1)*asc end
	if S then result = result + Vector(0,0,1)*asc end
	if D then result = result - Vector(1,0,0)*asc end
	if A then result = result + Vector(1,0,0)*asc end
	if actor:IsFlying() then 
		if input.ActionActive(ACT_MOVE_UP) then result = result + Vector(0,1,0) actor:Jump() end
		if input.ActionActive(ACT_MOVE_DOWN) then result = result - Vector(0,1,0) end
		--if input.KeyPressed(KEYS_ALTKEY) then result = result - Vector(0,1,0) end
		--actor.viewForward = Forward
		--actor.viewRight = Right
		--actor.viewUp =  cam:Up():Normalized()
		local sp = actor:GetParent():GetLocalSpace(actor)
		
		local sRight = actor:Forward():Normalized()
		self.rmode=true
		--if W then actor:TRotateAroundAxis(sRight, 0.1) end
		--if S then actor:TRotateAroundAxis(sRight, -0.1) end
		--if A then actor:TRotateAroundAxis(Up, 0.1) end
		--if D then actor:TRotateAroundAxis(Up, -0.1) end
		--actor.flightUp = cam:Up():Normalized()*Vector(-1,-1,1)*0.00001--:TransformN(sp):Normalized()
		--actor.moveDir = Forward:TransformN(sp):Normalized() --+ Right*result.x + actor.viewUp*result.y
	end
	--if input.KeyPressed(KEYS_SPACE) then actor:SendEvent(EVENT_ACTOR_JUMP) end--result = result - Up end
	--if input.KeyPressed(KEYS_CONTROLKEY) then result = result + Up end
	
	if result ~= Vector(0,0,0) then 
		result = result:Normalized()
	end
	
	
	--test lean
	--if phys:OnGround() then
	--	local sd_depth,sd_pos,sd_normal = phys:GetSupportData()
	--	local sRight = actor:Forward():Normalized()
	--	local sd_rddir = sForward:Cross(sd_normal):Normalized()
	--	local sd_fddir = sRight:Cross(sd_normal):Normalized() 
	--	local rang = sRight:Angle(sd_rddir)/3.1415926*180
	--	local fang = sForward:Angle(-sd_fddir)/3.1415926*180
	--	if (sRight.y>sd_rddir.y) then rang = -rang end
	--	if (sForward.y<sd_fddir.y) then fang = -fang end
	--	model:SetPoseParameter("lean_x",rang)
	--	model:SetPoseParameter("lean_y",fang) 
	--end
	---
	
	if SHOWINV and self.wasmoving then
		actor:Stop() 
		self.wasmoving = false
	end
	if not aibusy and not SHOWINV then
		if input.ActionActive(ACT_DUCK) then
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
				--actor.directmove = true
			if actor.directmove then
				--actor.directmove = false
				
				local pp = actor.model:GetPoseParameter("move_yaw") 
				pp = pp + (targetval - pp)/10 
				actor:Move(-result,IsRunning)
			else
				local smt = (self.sm_targetval or 0) 
				local ISR = 0
				if IsRunning then ISR = 1 end
				local rotspeed = actor.rotspeed or 1
				smt = smt + math.AngleDelta(-targetval,smt)/((20 + (20*ISR))*rotspeed)  --4
				if is_first_person and HIDE_CHAR_IN_FIRST_PERSON() and settings.GetBool("player.fpmode2_rotintertia") then
					--rotspeed =0.1
					smt = -targetval
				end
				self.sm_targetval = smt
				local angd = math.AngleDelta(smt , self.ctargetval or 0)
				local dval = angd/180*3.1415926
				actor:TRotateAroundAxis(Up, dval)
				cam:TRotateAroundAxis(inUp, -dval)
				Right = cam:Right():Normalized()
				
				self.ctargetval = math.NormalizeAngle((self.ctargetval or 0) + angd)
				--MsgN(angd)
				actor:Move(Vector(0,0,1),IsRunning)
			end
			 
			self.rmode = true
			self.wasmoving = true
		else
			if actor:IsMoving() and self.wasmoving then actor:Stop() self.wasmoving = false end
		end 
	 
		local mlock = self:MouseLocked() -- input.rightMouseButton()
		if mlock then 
			
			local mousePos = input.getMousePosition()
			local size = GetViewportSize() 
			local center = size / 2
			center = Point(math.floor( center.x),math.floor(center.y))
			local offset = mousePos - center
			if not self.lms_active then
				input.SetCursorHidden(true)
				self.lms_active = true
				self.lmp = mousePos
				offset = Point(0,0)
			end
			local offx = offset.x
			local offy = offset.y
			self.mouse_lastpos = mousePos
			input.setMousePosition(center)
			
			
			local angtX = ((self.totalCamRotationX or 0) + (offy / -1000))/ 3.1415926 * 180
			if math.abs(angtX)>90 then
				offy = 0
			end
			
			cam:TRotateAroundAxis(Right, (offy / -1000))
			Right = cam:Right():Normalized()
			
			self.totalCamRotationY = (self.totalCamRotationY or 0) + (offx / -1000)*asc.z
			local tcr = self.totalCamRotationY
			 
			cam:TRotateAroundAxis(inUp, (offx / -1000))
			Right = cam:Right():Normalized()
			local totalCamAngle = tcr / 3.1415926 * 180
			local turn_angle = actor.turn_angle or 90
			if tcr and math.abs(totalCamAngle)>=turn_angle then
				--if actor.model:HasAnimation("turn_l") then
				--	cam:TRotateAroundAxis(Up, -tcr)
				--	actor:TRotateAroundAxis(Up, tcr)
				--end
				local trsl = actor:Turn(tcr)
				if trsl then
					self.totalCamRotationY = 0
					cam:TRotateAroundAxis(Up, -tcr*asc.z)
					Right = cam:Right():Normalized()
					--actor:TRotateAroundAxis(Up, tcr)  
				elseif trsl == nil then
					--no rotation
				else
					self.rmode = true
				end
				--if actor.model:HasAnimation("turn_l") then
				--	local tcr2 = self.totalCamRotationY
				--	cam:TRotateAroundAxis(Up, -tcr2)
				--	actor:TRotateAroundAxis(Up, tcr2)  
				--	self.totalCamRotationY = 0
				--	if(totalCamAngle>0) then 
				--		actor:PlayAnimation("turn_l","idle",true) 
				--	else 
				--		actor:PlayAnimation("turn_r","idle",true) 
				--	end
				--else
				--	self.rmode = true 
				--end
				--self.totalCamRotationY = nil
			end
			if self.rmode and not actor.norotation then 
				local tcr2 = self.totalCamRotationY/10--2 
				if not actor.directflight and actor:IsFlying() then
					local sRight = actor:Forward():Normalized()
					local cctcr2 =(self.totalCamRotationX or 0)/10--2 
					actor:TRotateAroundAxis(sRight, -cctcr2) 
					cam:TRotateAroundAxis(Right, -cctcr2) 
					Right = cam:Right():Normalized()
					actor:TRotateAroundAxis(Up, tcr2) 
					cam:TRotateAroundAxis(inUp, -tcr2)
					self.totalCamRotationY = self.totalCamRotationY - tcr2
					self.totalCamRotationX = (self.totalCamRotationX or 0) - cctcr2
					if  math.abs(tcr2)<0.001 and math.abs(cctcr2)<0.001 then
						self.rmode = false 
						self.totalCamRotationY = 0
						local tgt = ( (self.totalCamRotationX or 0) / 3.1415926 * 180)
						cam:SetAng(Vector(tgt,-90-self.ctargetval,0)) 
					end
					
				else
					cam:TRotateAroundAxis(inUp, -tcr2*asc.z)
					actor:TRotateAroundAxis(Up, tcr2) 
					self.totalCamRotationY = self.totalCamRotationY - tcr2 
					if  math.abs(tcr2)<0.0001 then
						self.rmode = false 
						self.totalCamRotationY = 0
						local tgt = ( (self.totalCamRotationX or 0) / 3.1415926 * 180)
						cam:SetAng(Vector(tgt,-90-self.ctargetval,0)) 
					end
				end
				
				 
			end
			 
			self.totalCamRotationX = (self.totalCamRotationX or 0) + (offy / -1000)
			
		end 
	end
	
	--stabilizer
	if not actor:IsFlying() or self.flightmode then
		local aspd,aspp,aspn = actor.phys:GetSupportData()
		local vel = math.max(1,actor.phys:GetVelocity():Length()) 
		if not actor:IsFlying() then
			vel = 0.5
		end
		local sp = actor:GetParent():GetLocalSpace(actor)

		local div = 50
		if actor.phys:OnGround() then
			div = 5
		end
		local downvector =  Vector(0,0,1)--actor:GetPos():Normalized()--
		local rinlocal =  Vector(1,0,0)
		local downInLocal = downvector:TransformN(sp)
		local dd_r,dd_p,dd_e = actor:GetHeadingElevation(downInLocal)
		
		actor:TRotateAroundAxis(sForward , dd_e/div) 
		
		local sRight = actor:Forward():Normalized()
		--local sr2 = Vector(sForward.x,0,sForward.z):Normalized()
		local downInLocal = rinlocal:TransformN(sp)
		local dd_r,dd_p,dd_e = actor:GetHeadingElevation(downInLocal)
		
		actor:TRotateAroundAxis(sRight, dd_e/div/vel) 
		
		
		--local sRight = actor:Forward():Normalized()
		--local sd_rddir = sForward:Cross(aspn):Normalized()
		--local sd_fddir = sRight:Cross(aspn):Normalized() 
		--local rang = sRight:Angle(aspn)/10
		--local fang = sForward:Angle(aspn)/10 
		--local dd_r,dd_p,dd_e = actor:GetHeadingElevation(sd_rddir)
		--MsgN(dd_p*100)
		--actor:TRotateAroundAxis(aspn ,0.01)-- dd_r/10/div) 
		--actor:TRotateAroundAxis(sRight, dd_e/div) 
		
	end
	--
	if not actor.directmove then	
		actor.model:SetPoseParameter("move_yaw",0)
		actor.model:SetPoseParameter("move_x",0)
		actor.model:SetPoseParameter("move_y",100)
	end
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
	--if input.KeyPressed(KEYS_SPACE) then actor:SendEvent(EVENT_ACTOR_JUMP) end--result = result - Up end
	--if input.KeyPressed(KEYS_CONTROLKEY) then result = result + Up end
	
	if result ~= Vector(0,0,0) then 
		result = result:Normalized()
	end
	
	if not aibusy then
		if input.KeyPressed(KEYS_CONTROLKEY) then
			 actor:Duck() --ifthen
				if not actor:Crouching() then actor:SetCrouching(true) end
			--end
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
			--actor.model:SetPoseParameter("move_yaw",pp)
			--
			--actor.model:SetPoseParameter("move_x",result.x*-100)
			--actor.model:SetPoseParameter("move_y",result.z*-100)
			
			if actor:Move(-result,IsRunning) then
			
				self.rmode = true
			 
			end
		else
			--actor.move = nil
			--graph:SetState("idle")
			if actor:IsMoving() then actor:Stop() end
		end
	
		local mlock = self:MouseLocked() -- input.rightMouseButton()
		if mlock then 
			
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
				if math.abs(angtY)>95 then
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
			local totalCamAngle = tcr / 3.1415926 * 180
			local turn_angle = actor.turn_angle or 90
			if tcr and math.abs(totalCamAngle)>=turn_angle then
				--if actor.model:HasAnimation("turn_l") then
				--	cam:TRotateAroundAxis(Up, -tcr)
				--	actor:TRotateAroundAxis(Up, tcr)
				--end
				local trsl = actor:Turn(tcr)
				if trsl then
					cam:TRotateAroundAxis(Up, -tcr)
					self.totalCamRotationY = 0   
				elseif trsl == nil then
					--no rotation
				else
					self.rmode = true
				end
				--if actor.model:HasAnimation("turn_l") then
				--	local tcr2 = self.totalCamRotationY
				--	cam:TRotateAroundAxis(Up, -tcr2)
				--	actor:TRotateAroundAxis(Up, tcr2)  
				--	self.totalCamRotationY = 0
				--	if(totalCamAngle>0) then 
				--		actor:PlayAnimation("turn_l","idle",true) 
				--	else 
				--		actor:PlayAnimation("turn_r","idle",true) 
				--	end
				--else
				--	self.rmode = true
				--end
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
function USE(actor,entity) 
	local nearestent = false
	if entity then
		nearestent = entity
	else 
		nearestent = NEARESTUSEABLE(actor)
	end
	if nearestent then
		nearestent:SendEvent(EVENT_USE,actor)
		hook.Call("event.use",actor,nearestent)
	end 
end
function NEARESTUSEABLE(actor) 
	local nearestent = false
	local maxUseDistance = 2
	local pos = actor:GetPos()
	local par = actor:GetParent()
	local sz = par:GetSizepower()
	local ents = par:GetChildren()
	local ndist = maxUseDistance*maxUseDistance
	for k,v in pairs(ents) do
		if v~=actor and v._interact then --HasTag(TAG_USEABLE) 
			local edist = pos:DistanceSquared(v:GetPos())*sz*sz 
			if edist<ndist and edist>0 then
				nearestent = v
				ndist = edist
			end
		end
	end
	if not nearestent then
		for k,v in pairs(ents) do
			for kk,vv in pairs(v:GetChildren()) do
				if vv~=actor  and vv._interact then --vv:HasTag(TAG_USEABLE) then 
					local edist = actor:GetDistanceSq(vv)   
					if edist<ndist and edist>0 then
						nearestent = vv
						ndist = edist
					end
				end
			end
		end
	end
	if not nearestent and par and par:GetParent() then 
		for k,v in pairs(par:GetParent():GetChildren()) do
			if v~=par then
				if v~=actor  and v._interact then --v:HasTag(TAG_USEABLE) then 
					local edist = actor:GetDistanceSq(v)   
					if edist<ndist and edist>0 then
						nearestent = v
						ndist = edist
					end
				end
--
				for kk,vv in pairs(v:GetChildren()) do
					if vv~=actor  and vv._interact then -- vv:HasTag(TAG_USEABLE) then 
						local edist = actor:GetDistanceSq(vv)   
						if edist<ndist and edist>0 then
							nearestent = vv
							ndist = edist
						end
					end
				end 
			end
		end
	end
	MsgN("n",nearestent)
	return nearestent
end
function USE_ITEM(actor,item)  
	if item then
		item:SendEvent(EVENT_USE,actor)
		hook.Call("event.use",actor,item)
	end 
end
function OBJ:HandleUse(actor)
	local target = GetInteractiveEnt(actor, self.viewEntity) 
	if IsValidEnt(target) then
		local intent = actor.intent
		if intent then	
			Interact(actor,target,intent)
		end
	end
	--USE(actor) 
end
function OBJ:HandlePickup(actor) 
	actor:SendEvent(EVENT_PICKUP)-- PickupNearest()    
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
				c:OnDrop() 
				if item.OnDrop then item:OnDrop(actor) end
				c.inv:RemoveItem(actor,item)  
				
				local ccc = GetCameraPhysTrace(GetCamera(),actor.phys)
				if ccc and ccc.Hit then
					item:SetPos(ccc.Position)
					item:SetParent(ccc.Node)
				end
		 	end
		--end
	--end
end

function OBJ:HandleSwitch(actor)
	local cmode = self.mode or MODE_THIRDPERSON
	
	if self.camZoom==0 then
		if cmode ~= MODE_FIRSTPERSON then
			self.mode = MODE_FIRSTPERSON
			self:SwitchToFirstperson(actor)
		end
	else
		if cmode ~= MODE_THIRDPERSON then
			self.mode = MODE_THIRDPERSON
			self:SwitchToThirdperson(actor)
		end
	end
	
end

function OBJ:SwitchToFirstperson(actor)
	if HIDE_CHAR_IN_FIRST_PERSON() then
		actor.model:Enable(false)
		if actor.spparts then
			for k,v in pairs(actor.spparts) do
				v.model:Enable(false)
			end
		end
		--if actor.equipment then
		--	for k,v in pairs(actor.equipment) do
		--		if v.ent then
		--			v.ent.model:Enable(false)
		--		end
		--	end
		--end
	else
		--if actor.spparts then
		--	if actor.spparts.hair then
		--		actor.spparts.hair.model:Enable(false)
		--	end
		--end
	end
	actor.model:SetHideHead(true)
	
	local cam = GetCamera()
	local tgt = ( (self.totalCamRotationX or 0) / 3.1415926 * 180)
	cam:SetAng(Vector(tgt,-90-self.ctargetval,0)) 
	hook.Call("controller.actor.view","first")
end
function OBJ:SwitchToThirdperson(actor)
	--if HIDE_CHAR_IN_FIRST_PERSON() then
		actor.model:Enable(true)
		actor.model:SetHideHead(false)
		
	--	if actor.spparts then
	--		for k,v in pairs(actor.spparts) do
	--			v.model:Enable(true)
	--		end
	--	end
		--if actor.equipment then
		--	for k,v in pairs(actor.equipment) do
		--		if v.ent then
		--			v.ent.model:Enable(true)
		--		end
		--	end
		--end
	--end
	
	local cam = GetCamera()
	local tgt = ( (self.totalCamRotationX or 0) / 3.1415926 * 180)
	cam:SetAng(Vector(tgt,-90-self.ctargetval,0)) 
	hook.Call("controller.actor.view","third")
end
function OBJ:HandleCameraMovement(actor)
	
	local ep,ey = 0,0
	if actor.EyeAngles then 	ep,ey = actor:EyeAngles() end
	
	local cam = GetCamera()
	local cam_parent = cam:GetParent()
	local parent_sz = cam_parent:GetSizepower()
	local Forward = cam:Forward():Normalized()  
	local Right = cam:Right():Normalized()
	local Up = actor:Up():Normalized()
	local inUp = Vector(0,1,0)
	local ascale = actor.scale or 1
	local scax = actor:GetScale().x
	
	local mlock = self:MouseLocked()
	local mhag = input.MouseIsHoveringAboveGui() or MOUSE_LOCKED
	local lmb = input.leftMouseButton()
	local rmb = mlock  -- input.rightMouseButton()
	
	local controlled =-- not self:ActorIsBusy()--
	actor:GetUpdating() and actor.controller and (actor.controller == self or actor.controller.pai)--self:IsControlling( actor) 
	
	local tps_height = actor.tpsheight or 1.3
	local fps_height = actor.fpsheight or 1.6
	
	local is_first_person = self.camZoom ==0
	local is_VR = vr.IsEnabled()
	
	if not controlled and is_first_person then
		local sx =  ep * 3.1415926 / 180
		local sy = -ey * 3.1415926 / 180
		cam:TRotateAroundAxis(Right, sx - (self.totalCamRotationX or 0) )
		cam:TRotateAroundAxis(inUp,  sy - (self.totalCamRotationY or 0)  )
		self.totalCamRotationX = sx
		self.totalCamRotationY = sy
	end
	if not SHOWINV then
		if not mhag and (controlled or not is_first_person) and (lmb or (actor.IsInVehicle and IsValidEnt(actor.vehicle) and not actor.vehicle:HasTag(TAG_ACTOR) and rmb)) then  
			
			local mousePos = input.getMousePosition()
			local size = GetViewportSize() 
			local center = size / 2
			center = Point(math.floor( center.x),math.floor(center.y))
			local offset = mousePos - center

			if not self.lms_active then
				input.SetCursorHidden(true)
				self.lms_active = true
				self.lmp = mousePos
				offset = Point(0,0)
			end

			local offx = offset.x
			local offy = offset.y
			
			self.mouse_lastpos = mousePos
			input.setMousePosition(center)
			
			if lmb and is_first_person then
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
	end
	if self.lms_active and (not (lmb or rmb) or mhag) then
		input.SetCursorHidden(false)
		self.lms_active = false
		if self.lmp then input.setMousePosition(self.lmp) end
	end
	
	--Up = actor:Up():Normalized() / parent_sz
	Up = inUp / parent_sz
	
	Forward = cam:Forward():Normalized() / parent_sz 
	Right = cam:Right():Normalized() / parent_sz
	 
	if controlled and not is_VR and actor.IsAlive and actor:IsAlive() and actor:HasTag(TAG_ACTOR) then 
		
		if actor.directmove then
			actor:SetEyeAngles( --pitch, yaw 
				( (self.totalCamRotationX or 0) / 3.1415926 * 180),
				(-(self.totalCamRotationY or 0) / 3.1415926 * 180)*scax) 
		else
			actor:SetEyeAngles( --pitch, yaw 
				( (self.totalCamRotationX or 0) / 3.1415926 * 180),
				(-(self.totalCamRotationY or 0 ) / 3.1415926 * 180*scax + (self.ctargetval or 0))) 
				 
		end
		
		local tr = GetCameraPhysTrace(nil,actor.phys)
		if tr and tr.Hit then 
			actor:SetEyeTarget(tr.Position)
		end
		
		
	end
	
	if is_first_person then
		if HIDE_CHAR_IN_FIRST_PERSON() then
			cam:SetPos( Up *fps_height* ascale  )
		else
			local pos = Vector(0,0,0)
			local world = matrix.Identity()
			local m = actor.model
			if m then
				local eyeatt = actor.eyeattachment  
				if eyeatt and m:HasAttachment(eyeatt) then pos,world = m:GetAttachmentPos(eyeatt) 
				elseif m:HasAttachment("eyes") then pos,world = m:GetAttachmentPos("eyes") 
				elseif m:HasAttachment("head") then pos,world = m:GetAttachmentPos("head")   
				elseif m:HasAttachment("muzzle") then pos,world = m:GetAttachmentPos("muzzle") end -- * parent_sz
			end 
			--cam:SetPos((pos - Forward * 2 * 0    +Vector(-0.4,0,0)  - Forward * self.camZoom) / parent_sz)
			--DrawPoint(-10,actor,pos)
			--cam:SetAng(matrix.Rotation(Vector(-90,0,0))*world*matrix.Rotation(Vector(0,180,0)))
			cam:SetPos(( pos + Forward * 0.05 * ascale) )
		end
	else
		--cam:SetPos((Up*1.1   +Vector(-0.4,0,0) - Forward * self.camZoom) / parent_sz)
		--[[ -- TODO: FIX SIZEPOWER
		local tripleA = ascale * ascale * ascale
		local cd_start = (Up*0.5 ) * tripleA
		local cd_dir = Right:Normalized()
		local cd_maxdist = 0.5 * tripleA /1000
		
		local cp_start =GetTracedLocalPos(actor, cd_start, cd_dir, cd_maxdist,0.3,actor.phys)--(Up*0.5+ Right* 0.5 ) * tripleA
		local cp_dir = -Forward:Normalized()
		local cp_maxdist = self.camZoom * tripleA /1000
		local rt = GetTracedLocalPos(actor, cp_start, cp_dir, cp_maxdist,0.8,actor.phys)
		cam:SetPos(rt)
		]] 
		
		local m = actor.model
		local thirdpersonatt = actor.thirdattachment 
		local tpcp = Up*tps_height
		if thirdpersonatt and m:HasAttachment(thirdpersonatt) then 
			tpcp = m:GetAttachmentPos(thirdpersonatt)   
		end
		cam:SetPos( (tpcp  - Forward * self.camZoom  + Right* 0.5 )* ascale    )
	end
	
	--for i=0,50 do
	--	local pos = actor.model:GetBonePos(i)
	--	DrawPoint(i,actor,pos)
	--end
	
	if is_VR then
		local hpos,ang,mang = vr.GetHead() 
		actor:SetEyeAngles( ang.x/ 3.1415926 * 180 ,-ang.y/ 3.1415926 * 180) 
		 
		cam:SetAng(mang*matrix.Rotation(0,-90,0))
		Right = cam:Right():Normalized() / parent_sz
		--local ep,ey = actor:EyeAngles()
		--local sx =  ep * 3.1415926 / 180
		--local sy = -ey * 3.1415926 / 180
		--cam:TRotateAroundAxis(Right, sx - (self.totalCamRotationX or 0) )
		--cam:TRotateAroundAxis(Up,  sy - (self.totalCamRotationY or 0)  )
		--self.totalCamRotationX = sx
		--self.totalCamRotationY = sy
		
		if is_first_person then
			local pos = Vector(0,0,0)
			local m = actor.model
			if m then 
				if m:HasAttachment("eyes") then pos = m:GetAttachmentPos("eyes") 
				elseif m:HasAttachment("head") then pos = m:GetAttachmentPos("head")   
				elseif m:HasAttachment("muzzle") then pos = m:GetAttachmentPos("muzzle") end -- * parent_sz
			end
			--local Right = -mang:Forward():Normalized() / parent_sz
			local ep = vr.GetCurrentEye()
		--	local m = actor.model
			local pos2 = pos 
			if ep == 1 then
				--if m:HasAttachment("eyel") then 
				--	pos2 = m:GetAttachmentPos("eyel") 
				--else
					pos2 = pos -Right*0.03*1.1* ascale   --  m:GetAttachmentPos("eyel") 
				--end
			else
				--if m:HasAttachment("eyer") then 
				--	pos2 = m:GetAttachmentPos("eyer") 
				--else
					pos2 = pos +Right*0.03*1.1* ascale   -- m:GetAttachmentPos("eyer")  
				--end
			end		
			cam:SetPos( pos2 )
		else
			local pos = Vector(0,0,0)
			local m = actor.model
			if m then 
				if m:HasAttachment("eyes") then pos = m:GetAttachmentPos("eyes") 
				elseif m:HasAttachment("head") then pos = m:GetAttachmentPos("head")   
				elseif m:HasAttachment("muzzle") then pos = m:GetAttachmentPos("muzzle") end -- * parent_sz
			end
			
			local ep = vr.GetCurrentEye()
		--	local m = actor.model
			local pos2 = pos
			local Forward = cam:Forward():Normalized() / parent_sz 
			local Right = cam:Right():Normalized() / parent_sz
			if ep == 1 then
					pos2 = (Up  - Forward * self.camZoom  + Right* 0.3 -Right*0.04 )* ascale * ascale * ascale   
			else
					pos2 = (Up  - Forward * self.camZoom  + Right* 0.3 +Right*0.04 )* ascale * ascale * ascale   
			end		
			cam:SetPos( pos2 )
		
		end
			self.rmode = true
	end
end


function OBJ:HandleFlight(actor)
	 
	
end

function OBJ:HandleGetInfo(actor)
	if infobar then
		local is_VR = vr.IsEnabled()
		if is_VR then
			infobar:UpdateBar()
		else
			local tr = GetCameraPhysTrace(nil,actor.phys)
			if tr and tr.Hit then 
				local nn = tr.Entity--GetNearestNode(actor:GetParent(),tr.Position) 
				if nn ~= actor then
					self.viewEntity = nn
					actor.viewEntity = nn
					infobar:UpdateBar(nn)
				else
					self.viewEntity = nil
					actor.viewEntity = nil
					infobar:UpdateBar()
				end
			else
				self.viewEntity = nil
				actor.viewEntity = nil
				infobar:UpdateBar()
			end
		end
	end
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