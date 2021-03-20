MOVETYPE_IDLE = 0
MOVETYPE_WALK = 1 
MOVETYPE_RUN = 2
MOVETYPE_SWIM = 3
MOVETYPE_FLY = 4
 
DeclareEnumValue("event","SET_VEHICLE",				80002) 
DeclareEnumValue("event","EXIT_VEHICLE",			80003) 
 
DeclareEnumValue("event","ACTOR_JUMP",				81007) 
DeclareEnumValue("event","CHANGE_CHARACTER",		81008) 
DeclareEnumValue("event","TOOL_DROP",				81011) 

DeclareEnumValue("event","RESPAWN_AT",				82033) 
DeclareEnumValue("event","STATE_CHANGED",			82034) 
DeclareEnumValue("event","GIVE_ITEM",				82066) 
DeclareEnumValue("event","PICKUP_ITEM",				82067) 
DeclareEnumValue("event","PICKUP_TOOL",				82068) 
DeclareEnumValue("event","PICKUP",					82069) 

DeclareEnumValue("event","ABILITY_CAST",			83001) 
DeclareEnumValue("event","EFFECT_APPLY",			83002) 
DeclareEnumValue("event","GIVE_ABILITY",			83003) 
DeclareEnumValue("event","TAKE_ABILITY",			83004) 

DeclareEnumValue("event","GESTURE_START",			83012) 
DeclareEnumValue("event","GESTURE_END",				83013) 

DeclareEnumValue("event","TASK_BEGIN",				84001) 
DeclareEnumValue("event","TASK_END",				84002) 
DeclareEnumValue("event","TASK_RESET",				84009) 

DeclareEnumValue("event","LERP_HEAD",				85001)
DeclareEnumValue("event","LOOK_AT",					85002)  
 
DeclareEnumValue("event","SET_AI",					85011)  
 
DeclareVartype("AITYPE",85031,"string","ai type name")
--EVENT_SET_VEHICLE = 80002
--
--EVENT_HEALTH_CHANGED = 81003
--EVENT_MAXHEALTH_CHANGED = 81004
--EVENT_DEATH = 81005
--EVENT_SPAWN = 81006
--EVENT_ACTOR_JUMP = 81007
--EVENT_CHANGE_CHARACTER = 81008
--EVENT_TOOL_DROP = 81011
--
--EVENT_RESPAWN_AT = 82033
--EVENT_STATE_CHANGED = 82034
--EVENT_GIVE_ITEM = 82066
--EVENT_PICKUP_ITEM = 82067
--
--EVENT_ABILITY_CAST = 83001
--EVENT_EFFECT_APPLY = 83002
--EVENT_GIVE_ABILITY = 83003
--EVENT_TAKE_ABILITY = 83004


function ENT:Init()  
	self:AddTag(TAG_ACTOR)
	local phys = self:RequireComponent(CTYPE_PHYSACTOR)  
	local model = self:RequireComponent(CTYPE_MODEL)  
	local storage = self:RequireComponent(CTYPE_STORAGE)  
	local equipment = self:RequireComponent(CTYPE_EQUIPMENT)  
	local health = self:RequireComponent(CTYPE_HEALTH) 
	self.model = model
	self.phys = phys
	self.storage = storage
	self.equipment = equipment
	self.health = health
	self:SetSpaceEnabled(false)
	
	self.speedmul = 1
	self.walkspeed = 3
	self.runspeed = 6
	self.movementtype = MOVETYPE_IDLE
	
	
	
	
	self:SetParameter(VARTYPE_MAXHEALTH,100)
	self:SetParameter(VARTYPE_HEALTH,100)
 
	
	self:AddTag(TAG_PHYSSIMULATED)
	
	self.tmanager = TaskManager(self)
	
end

function ENT:Spawn()
	local model = self.model
	local phys = self.phys  
	--local modelfile = self:GetParameter(VARTYPE_MODEL)
	local char = self:GetParameter(VARTYPE_CHARACTER)
	if char then
		self:SetCharacter(char)
	end
	self:InitPhys()
	local graph = self.graph
	if graph then
		graph:SetState(self:GetParameter(VARTYPE_STATE) or "idle")
	end
	local par = self:GetParent()
	if par and par.mountpoints then
		self:Delayed("svh",1000,function()
			self:SetVehicle(par,1)
		end)
	end 
	self:Delayed("ai",1100,function()
		local aitype = self[VARTYPE_AITYPE]
		MsgN(self,aitype,"ai")
		if aitype then
			self:SetAi(aitype)
		end
	end)

end
function ENT:Load()
	self:SetPos(self:GetPos())
	self:CopyAng(self)
	local char = self:GetParameter(VARTYPE_CHARACTER)
	--MsgN("WTF?? ",char)
	self:SetCharacter(char)
	self:InitPhys()
end
function ENT:Despawn() 
	self:DDFreeAll() 
end

function ENT:InitPhys()
	local phys = self.phys  
	local physok = self.physok  
	if phys and not physok then
		local data = self.data
		if data then
			phys:SetShape(data.height or 1.9,data.radius or 0.4)
		else
			phys:SetShape(1.9,0.4)
		end
		phys:SetMass(10) 
		phys:SetupCallbacks()
		--self:AddNativeEventListener(EVENT_PHYSICS_COLLISION_STARTED,"event",
		--function(selfobj,eid,collider,velonhit) 
		--	selfobj:VelocityCheck()--collider,velonhit)
		--end)
		self.physok =true
	end
end

function ENT:PlayAnimation(aname,exitnode,ns)
	exitnode = exitnode or "idle"
	self.model:ResetAnimation(aname,ns)
	MsgN(aname)
	--local nodename = "_autoanim_"..aname
	--local graph = self.graph
	--graph:NewState(nodename,function(s,e) return e.model:ResetAnimation(aname,ns) end)
	--graph:NewTransition(nodename,exitnode,CND_ONEND)
	--graph:SetState(nodename)
end
function ENT:PlayIdle() 
	self:UpdateLean()
	if self.model:HasAnimation("idle1") then
		local lastspecial = self.lastspecialidle or 0
		local ct = CurTime()
		if lastspecial + 12 < ct  then
			local rm =math.random(1,100)
			if rm>94 then  
				local ar = math.random(1,4)
				local aname = "idle"..ar
				while (ar>0 ) do
					if self.model:HasAnimation(aname) then break end
					ar = ar - 1
					aname = "idle"..ar
				end
				self.lastspecialidle = ct+ math.random(1,14)
				--MsgN(ct)
				return self.model:SetAnimation(aname) 
			end  
		end 
	end
	return self.model:SetAnimation("idle") 
end
function ENT:LoadGraph(tab)

	local graph = BehaviorGraph(self,tab) 
	--if tab then
	--	graph.debug =true
	--end
	if not tab then
		graph:NewState("idle",function(s,e) 
			return e:PlayIdle()
		end) 
		graph:NewState("idle_loop",function(s,e)  return 0 end)
		
		graph:NewState("cidle",function(s,e) e.model:SetAnimation("cidle")  
			--e.phys:SetMovementDirection(Vector(0,0,0)) 
		end)
		
		graph:NewState("run",function(s,e) e.model:SetAnimation("run") end)
		graph:NewState("walk",function(s,e) e.model:SetAnimation("walk") end)
		graph:NewState("cwalk",function(s,e) e.model:SetAnimation("cwalk") end)
		
		graph:NewState("attack",function(s,e)  
			e.phys:SetMovementDirection(Vector(0,0,0)) 
			return e.model:SetAnimation("attack") 
		end)
		
		graph:NewState("ability",function(s,e)   
			local anim = e.abilityanim
			if anim then return e.model:SetAnimation(anim) end
		end)
		
		graph:NewState("soar_idle",function(s,e) e.model:SetAnimation("soar_idle")  end)
		graph:NewState("soar_in",function(s,e) return e.model:SetAnimation("soar_in")  end)
		graph:NewState("soar_out",function(s,e) return e.model:SetAnimation("soar_out")  end)
		
		graph:NewState("jump",function(s,e) e.model:InvokeEvent('step','') return e.model:SetAnimation("jump") end)
		graph:NewState("jump_inair",function(s,e) return e.model:SetAnimation("jump_inair") end)
		graph:NewState("land",function(s,e) e.model:InvokeEvent('step','') return e.model:SetAnimation("land") end)
		
		graph:NewState("sit",function(s,e) 
			e.phys:SetMovementDirection(Vector(0,0,0)) 
			e.model:SetAnimation("sit")  
		end)
		graph:NewState("sleep",function(s,e) 
			e.phys:SetMovementDirection(Vector(0,0,0)) 
			e.model:SetAnimation("sleep")  
		end)
		
		graph:NewState("sit.chair",function(s,e) 
			e.phys:SetMovementDirection(Vector(0,0,0)) 
			if e.model:HasAnimation("sit.chair") then
				e.model:SetAnimation("sit.chair")  
			else
				e.model:SetAnimation("sit")  
			end
		end)
		graph:NewState("sit.capchair",function(s,e) 
			e.phys:SetMovementDirection(Vector(0,0,0)) 
			if e.model:HasAnimation("sit.capchair") then
				e.model:SetAnimation("sit.capchair")  
			else
				e.model:SetAnimation("sit")  
			end  
		end)
		graph:NewState("sit.saddle",function(s,e) 
			e.phys:SetMovementDirection(Vector(0,0,0)) 
			if e.model:HasAnimation("sit.saddle") then
				e.model:SetAnimation("sit.saddle")  
			else
				e.model:SetAnimation("sit")  
			end   
		end)
		graph:NewState("vehicle_exit_start",function(s,e) return e.model:SetAnimation("capchair.exit")end)
		graph:NewState("vehicle_exit_end",function(s,e) e.model:SetAnimation("idle",true)   e:SetVehicle() return 0 end)
		
		graph:NewState("recall",function(s,e) return e.model:SetAnimation("recall") end)
		graph:NewState("recall_end",function(s,e) if e.Recall then return e:Recall(s) end return 0 end)
		
		graph:NewState("turn_l",function(s,e) return e.model:ResetAnimation("turn_l",e.turn_sharp_in or false)  end)
		graph:NewState("turn_r",function(s,e) return e.model:ResetAnimation("turn_r",e.turn_sharp_in or false)  end)
		graph:NewState("aturnidle",function(s,e) e.model:SetAnimation("idle",e.turn_sharp_out or false) return 0 end)
		

		graph:NewState("flight_start",function(s,e) 
			if e.model:HasAnimation("fly_wings") then
				if CLIENT then
					local sp = self.spparts
					if sp and sp.wings and sp.wings_folded then
						sp.wings.model:Enable(true)
						sp.wings.model:SetMaxRenderDistance(100)
						sp.wings_folded.model:Enable(false)
						sp.wings_folded.model:SetMaxRenderDistance(0)
					end
				end
				e.model:PlayLayeredSequence(38,"fly_wings") 
			end
		end)
		graph:NewState("flight_end",function(s,e) 
			if e.model:HasAnimation("fly_wings") then 
				if CLIENT then
					local sp = self.spparts
					if sp and sp.wings and sp.wings_folded then
						sp.wings.model:Enable(false)
						sp.wings.model:SetMaxRenderDistance(0)
						sp.wings_folded.model:Enable(true)
						sp.wings_folded.model:SetMaxRenderDistance(100)
					end
				end
				e.model:StopLayeredSequence(38) 
			end
		end)
		
		graph:NewState("flight_idle",function(s,e) e.model:SetAnimation("fly_idle")   end)
		graph:NewState("flight_move",function(s,e) e.model:SetAnimation("fly_move")   end)
		
		
		graph:NewState("gesture",function(s,e) return 0 end)

		graph:NewState("dead",function(s,e)
			local phys = e.phys
			phys:SetMovementDirection(Vector(0,0,0)) 
			phys:SetGravity() 
			phys:SetAirSpeed(0)
			e.isflying = false
			e.model:SetAnimation("death")   
			return 5
		end)
		
		graph:NewState("respawn",function(s,e) 
			self:Respawn()
		end)
		
		graph:NewState("spawn",function(s,e)
			if e.Recall then e:Recall(s) end
			return e.model:SetAnimation("spawn")  
		end)
		--graph:NewTransition("idle","run",function(s,e) return e.move or e.targetpos end)
		--graph:NewTransition("run_stop","run",function(s,e) return e.move or e.targetpos end)
		--graph:NewTransition("run","idle",function(s,e) 
		--	if e.move then e.phys:SetMovementDirection(e.move) end
		--	if e.targetpos then e.phys:SetMovementDirection(e.targetpos) end
		--if e.targetpos then
		--	local pos = e.targetpos
		--	local dir = pos - e:GetPos()
		--	local dist = dir:Length()
		--	MsgN(dist)
		--	if dist < 0.002 then
		--		e.targetpos = nil
		--	else
		--		dir = dir / dist
		--		e:SetAng(Vector(0,math.atan2(dir.z,dir.x)/3.1415926*-180,0)) 
		--		e.phys:SetMovementDirection(Vector(0,0,1))
		--	end
		--end
		---return not e.move and not e.targetpos 
		-----
		-----
		---end)
		--graph:NewTransition("run_stop","idle",function(s,e) return s.anim_end < CurTime() end)
		
		graph:NewGroup("g_movement",{"walk","run"})
		
		graph:NewGroup("g_turn",{"turn_l","turn_r"})
		
		graph:NewTransition("attack","idle",BEH_CND_ONEND)
		graph:NewTransition("ability","idle",BEH_CND_ONEND)
		--
		--graph:NewTransition("soar_in","soar_idle",BEH_CND_ONEND)
		--graph:NewTransition("soar_idle","soar_out",function(s,e) return e.move end)
		--graph:NewTransition("soar_out","idle",BEH_CND_ONEND)
		graph:NewTransition("jump","land", BEH_CND_ONGROUND)
		graph:NewTransition("jump_inair","land",BEH_CND_ONGROUND) 
		graph:NewTransition("jump","jump_inair",BEH_CND_ONEND)
		graph:NewTransition("land","idle",BEH_CND_ONEND)
		
		graph:NewTransition("idle","jump",BEH_CND_NOTONGROUND) 
		graph:NewTransition("g_movement","jump",BEH_CND_NOTONGROUND)
		
		graph:NewTransition("idle","walk",BEH_CND_ONCALL,"walk")
		graph:NewTransition("idle","run",BEH_CND_ONCALL,"run")
		graph:NewTransition("g_movement","idle",BEH_CND_ONCALL,"idle")  
		graph:NewTransition("walk","run",BEH_CND_ONCALL,"run") 
		graph:NewTransition("run","walk",BEH_CND_ONCALL,"walk") 
		--graph:NewTwoWayTransition("walk","run",BEH_CND_ONCALL) 
		graph:NewTransition("idle","jump",BEH_CND_ONCALL,"jump")
		graph:NewTransition("g_movement","jump",BEH_CND_ONCALL,"jump")
		
		graph:NewTransition("idle","attack",BEH_CND_ONCALL,"attack")
		
		graph:NewTransition("idle","recall",BEH_CND_ONCALL,"recall")
		graph:NewTransition("recall","recall_end",BEH_CND_ONEND)
		graph:NewTransition("recall_end","idle",BEH_CND_ONEND)
		
		
		--if self.model:HasAnimation("idle1") then 
			graph:NewTransition("idle","idle_loop",BEH_CND_ONEND)
			graph:NewTransition("idle_loop","idle",BEH_CND_ONEND) 
		
		--end
		
		graph:NewTransition("idle","cidle",function(s,e) return self:Crouching() end)
		graph:NewTransition("cidle","idle",function(s,e) return not self:Crouching() end) 
		graph:NewTransition("walk","cwalk",function(s,e) return self:Crouching() end)
		graph:NewTransition("cwalk","walk",function(s,e) return not self:Crouching() end)
		graph:NewTransition("run","cwalk",function(s,e) return self:Crouching() end) 
		graph:NewTransition("cidle","cwalk",BEH_CND_ONCALL,"cwalk")
		graph:NewTransition("cwalk","cidle",BEH_CND_ONCALL,"cidle")
		
		graph:NewTransition("idle","flight_start",BEH_CND_ONCALL,"flight_start")
		graph:NewTransition("flight_idle","flight_end",BEH_CND_ONCALL,"flight_end")
		graph:NewTransition("flight_idle","flight_move",BEH_CND_ONCALL,"flight_move")
		graph:NewTransition("flight_move","flight_idle",BEH_CND_ONCALL,"flight_idle")
		
		graph:NewTransition("flight_start","flight_idle",BEH_CND_ONEND)
		graph:NewTransition("flight_end","idle",BEH_CND_ONEND)
		
		graph:NewTransition("flight_move","idle",function(s,e) if e.phys:OnGround() then e:Land() return true end end)
		graph:NewTransition("flight_idle","idle",function(s,e) if e.phys:OnGround() then e:Land() return true end end)
		
		
		
		graph:NewTransition("vehicle_exit_start","vehicle_exit_end",BEH_CND_ONEND)
		graph:NewTransition("vehicle_exit_end","idle",BEH_CND_ONEND)
		
		graph:NewTransition("idle","gesture",BEH_CND_ONCALL,"gesture_start")
		graph:NewTransition("gesture","idle",BEH_CND_ONCALL,"gesture_end")
		
		
		graph:NewTransition("idle","turn_l",BEH_CND_ONCALL,"turn_l")
		graph:NewTransition("idle","turn_r",BEH_CND_ONCALL,"turn_r")
		graph:NewTransition("g_turn","turn_l",BEH_CND_ONCALL,"turn_l")
		graph:NewTransition("g_turn","turn_r",BEH_CND_ONCALL,"turn_r") 
		graph:NewTransition("g_turn","walk",BEH_CND_ONCALL,"walk")
		graph:NewTransition("g_turn","run",BEH_CND_ONCALL,"run")
		graph:NewTransition("turn_l","aturnidle",BEH_CND_ONEND)
		graph:NewTransition("turn_r","aturnidle",BEH_CND_ONEND)
		graph:NewTransition("aturnidle","idle",BEH_CND_ONEND) 
		
		
		graph:NewState("unc_transition",function(s,e)
			e.phys:SetMovementDirection(Vector(0,0,0)) 
			return e.model:SetAnimation("tr_en_t_com")   
		end)
		graph:NewState("unc_stop",function(s,e)
			e.phys:SetMovementDirection(Vector(0,0,0)) 
			--TurnIntoStone(e)
			return e.model:SetAnimation("tr_com_t_ncom")   
		end) 
		graph:NewTransition("idle","unc_transition",BEH_CND_ONCALL,"unc_transition")
		graph:NewTransition("unc_transition","unc_stop",BEH_CND_ONEND)
		
		
		graph:NewTransition("dead","respawn",BEH_CND_ONEND)
		graph:NewTransition("spawn","idle",BEH_CND_ONEND)
	else 
	end
	
	graph:SetState("idle")
	 
	
	if CLIENT then
		graph.callback = function(g,e,n)
			if e == LocalPlayer() then 
				if network.IsConnected() then
					network.CallServer('_1',e,EVENT_STATE_CHANGED,n)
				end
			end
		end
	end
	
	return graph
end

ENT.prf = Profiler("actor")

function ENT:Think()
	--self.prf:IS()
	--debug.ProfilerBegin("actor")
	--self.prf:ES("vel")
	self:VelocityCheck()
	--self.prf:EE()
	local ai = self.controller 
	if ai and not ai.camZoom then
		if ai.Update then
			ai:Update()
		end
	end
	if ai==nil then
		--MsgN("X",self)
		--self:SetHeadAngles(0,0)
	end

	--if self == LocalPlayer() then
	--	self.prf:IS()
	--end
	if CLIENT and (not network.IsConnected() or self == LocalPlayer()) then
		local graph = self.graph 
		if graph then
			graph:Run() 
		end
	end
	--self:RunTaskStep() 
	--if(self:GetSeed()==1000065)then
	--	 MsgN("a")
	--end
	if SERVER or not network.IsConnected() then
		self.tmanager:Update() 
	end
	
	local m = self.model
	local ct = CurTime()
	local srb = self.resetblink
	local snb = self.nextblink

	local headsub = self:GetByName('head',true,true)
	local hsm = false
	local flexid =-1
	if headsub then 
		for k,v in pairs(headsub) do
			hsm = v.model 
			if hsm then
				flexid = hsm:GetFlex('blink') 
			end
			
			if srb then
				if ct>srb then
					m:StopLayeredSequence(10)
					self.nextblink = ct+1+math.random(1,8)
					self.resetblink = nil
					
					if flexid>=0 then  
						hsm:SetFlexSpeed(flexid,3)
						hsm:SetFlexValue(flexid,0) 
					end 
				end
			elseif not srb  and (not snb or ( snb and ct>snb )) then
				m:PlayLayeredSequence(10,"_blink_auto")
				self.resetblink = ct+0.1 
				if flexid>=0 then  
					hsm:SetFlexSpeed(flexid,2)
					hsm:SetFlexValue(flexid,1) 
				end 
			end
		end
	end




	if self:GetParameter(VARTYPE_STATE) == "sit.capchair" then
		if self.acd then
			if ct>self.acd then
				self.model:SetAnimation("sit.capchair")
				self.acd = nil
			end
		elseif math.random(1,1000)>990 then
			--if math.random(1,1000)>500 then
				self.acd =ct+ self.model:SetAnimation("sit.capchair.s1") 
			--else
			--	self.acd =ct+ self.model:SetAnimation("sit.capchair.s2") 
			--end
		end		
	end
	--if string.find(tostring(self),"Nami") then
	--MsgN("nb ",snb," rb ",srb," ct ",ct)
	--end 
	
--	--MsgN(self.phys:OnGround())
--	--if input.KeyPressed(KEYS_K) then
--		--self.phys:SetStance(STANCE_STANDING)
--		--self.phys:SetMovementDirection(Vector(100,0,100))
--		--self.phys:SetStandingSpeed(1000) 
--		--self.phys:SetAirSpeed(1000) 
--	--else
--	--	self.phys:SetMovementDirection(Vector(0,0,0))
--	--end
	self:UpdateLean() 
	--debug.ProfilerBegin("actor")
	--self.prf:IE()
	if CLIENT and self == LocalPlayer() then 
		self:SetUpdating(true,20)
	else
		self:SetUpdating(true,100)
	end
	
end
function ENT:BeginTask(a,...)
	if isstring(a) then
		return self.tmanager:Begin(Task(a,...))
	else 
		return self.tmanager:Begin(a,...)
	end
end
function ENT:EndTask(a)
	return self.tmanager:End(a) 
end
function ENT:ResetTM()
	self.tmanager = TaskManager(self)
end
function ENT:HasTasks()
	return self.tmanager and self.tmanager:HasTasks()
end

function ENT:GetCharacter()
	return self._character
end
function ENT:SetCharacter(id)
 

	id = id or "vikna"
	
	if id then 
		local path = forms.GetForm("character",id)
		if path then
			local data = json.Read(path)--"forms/characters/"..id..".json")
			if data then 
				self._character = id
				self.data = data
				self.directmove=false
				self.directflight=false
				self.eyemul = {1,1}
				self.eyeattachment = nil
				self.norotation = nil
				self.nomovement = nil
				self.saccadic = nil
				self.base_scale = nil
				 
				if self._spcom then
					for k,v in pairs(self._spcom) do
						self:RemoveComponent(v)
					end
				end

				if self.isflying then self:Land() end
				self:SetParameter(VARTYPE_CHARACTER,id)
				 
				local world = matrix.Scaling(0.03) 
				local model = self.model
				local phys = self.phys
				
				if data.name and self:GetName() == "" then self:SetName(data.name) end
				
				if data.species then
					self:SetSpecies(data.species)
				end
				
				self.abilities = {}
				
				self:Config(data)
				local model_scale = self.model_scale or 1
				local base_scale = self.base_scale or 1
				 
				model:SetModel(self:GetParameter(VARTYPE_MODEL))
				model:SetRenderGroup(RENDERGROUP_LOCAL) 
				model:SetBlendMode(BLEND_OPAQUE) 
				model:SetRasterizerMode(RASTER_DETPHSOLID) 
				model:SetDepthStencillMode(DEPTH_ENABLED)  
				model:SetBrightness(1)
				model:SetFadeBounds(0,99999,0)   
				model:SetMatrix(world*matrix.Translation(-phys:GetFootOffset()*0.75)*matrix.Scaling(0.001*model_scale*base_scale))---*matrix.Scaling(0.0000001)
				
				model:SetDynamic(true)
				model:SetUpdateRate(60)
				model:SetBBOX(Vector(-20,-20,0),Vector(20,20,80))
				--model:SetBrightness(0)
				--model:SetBlendMode(BLEND_ADD) 
				--model:SetRenderGroup(RENDERGROUP_NONE) 
				
				self.graph = self:LoadGraph(data.behaviour) or self.graph
				
				if CLIENT then
					local bpr = self.spparts
					if bpr then
						for k,v in pairs(bpr) do
							if v and IsValidEnt(v) then v:Despawn() end
						end 
						self.spparts = nil
					end
				end
				if CLIENT and data.parts and self.species then
					local bpath = self.species.model.basedir
					local bpr = self.spparts or {}
					for k,v in pairs(data.parts) do 
						local bp = SpawnBP(bpath..v..".stmd",self,0.03)
						bp:SetName(k)
						bpr[k] = bp
					end
					self.spparts = bpr
					
					if data.materials then
						local bmatdir = data.basematdir
						for k,v in pairs(data.materials) do
							local keys = k:split(':') 
							local bpart = keys[1] 
							local id = tonumber( keys[2])
							if id==nil and bpart == 'mat' then
								local newmat = dynmateial.LoadDynMaterial(v,bmatdir)
								for partname,part in pairs(self.spparts) do
									for matid,matname in pairs(part.model:GetMaterials()) do
										if string.find(matname,keys[2]) then
											part.model:SetMaterial(newmat,matid-1)
										end
									end
								end

							else
								local part = self.spparts[bpart]
								if bpart == "root" then part = self end 
								if part then  
									local mat = dynmateial.LoadDynMaterial(v,bmatdir)
									part.model:SetMaterial(mat,id)
								end
							end
							
							--
							----procedural check
							--local proc = {}
							--for kk,vv in pairs(v) do
							--	if istable(vv) and vv.subs then 
							--		local root = gui.FromTable(vv) 
							--		proc[kk] = root
							--		v[kk] = "textures/ponygen/body.dds"
							--	end
							--end  
							--local mat = NewMaterial(bmatdir, json.ToJson(v))
							--local part = self.spparts[bpart]
							--if bpart == "root" then part = self end 
							--if part then 
							--	for k,v in pairs(proc) do
							--		RenderTexture(512,512,v,function(rtex)
							--			SetMaterialProperty(mat,k,rtex) 
							--		end)  
							--	end
							--	part.model:SetMaterial(mat,id)
							--end
						end 
					end
					--TEST!
					--[[
					local mat = NewMaterial("models/mlppony/tex/", json.ToJson({
						shader = "shader.model", 
						g_MeshTexture = "models/mlppony/tex/body_luna.jpg",
						g_MeshTexture_n = "models/mlppony/tex/base_normal.dds",
					}))
					local root = panel.Create()
					local btex = panel.Create() root:Add(btex)
					btex:SetSize(1024,1024)
					btex:SetTexture(LoadTexture("textures/ponygen/body.dds"))
					btex:SetColor(Vector(56,73,125)/255) 
					
					local tex = RenderTexture(1024,1024,root) 
					SetMaterialProperty(mat,"g_MeshTexture",tex)
					self.spparts.body.model:SetMaterial(mat,0)
					]]
				--END
				
					if bpr and bpr.wings and bpr.wings_folded then 
						bpr.wings.model:Enable(false)
						bpr.wings.model:SetMaxRenderDistance(0)
						bpr.wings_folded.model:Enable(true)
						bpr.wings_folded.model:SetMaxRenderDistance(100)
					end
				
				end 
				if data.flexes and self.spparts then 
					for k,v in pairs(data.flexes) do
						local keys = k:split(':') 
						local bpart = keys[1] 
						local id = tonumber( keys[2]) 

						local part = self.spparts[bpart]
						if bpart == "root" then part = self end 
						if part then   
							part.model:SetFlexValue(id,v)
						end 
					end
				end
				
				if data.bodytype then 
					self:SetBodytype(data.bodytype)
				end

				hook.Call("actor.setcharacter",self,id) 

				if SERVER or not network.IsConnected() and not self.equipment_asquired then
					self.equipment_asquired = true
					if data.equipment then  
						for k,v in pairs(data.equipment.items or {}) do
							self:SendEvent(EVENT_GIVE_ITEM,v)
						end
						--for k,v in pairs(data.equipment.tools or {}) do
						--	self:Give(v)
						--end
					end
				end
				if SERVER then
					local slfEquipment = self.equipment
					if slfEquipment and data.equipment and data.equipment.items then
						local slfseed = self:GetSeed()
						for k,v in pairs(data.equipment.items) do
							local ei = ItemIA("forms/apparel/"..v..".json",slfseed+2492*k,{
								--parameters = {name = "Cape"},
								flags = {"storeable"},
							})
							slfEquipment:Equip(ei)
						end 
					end 
				end

				local phys = self.phys   
				if phys then
					if data.height then phys:SetHeight(data.height) end
					if data.radius then phys:SetRadius(data.radius) end
					if data.mass   then phys:SetMass(data.mass) end 
				end
				if self.saccadic then 
					model:SetSaccadic(self.saccadic)
				end
				
				self:SetUpdating(true,100)
				self:SetSize()
				--MsgN("faf ",self:GetPos())
				--self:SetPos(self:GetPos()) 
			else  
				--if CLIENT and network.IsConnected() then
				--	network.CallServer("_GetCharacter",self,LocalPlayer(),id) 
				--end 
				Msg("warning error reading json: ",path)
			end
		else
			Msg("warning unknown form id: ",id)
		end
	end
end
console.AddCmd("body_part_add",function(k,v)
	local self = LocalPlayer()
	MsgN(k,'-',v)
	local bpr = self.spparts or {}
	
	local bpath = self.species.model.basedir
	local bp = SpawnBP(bpath..v..".stmd",self,0.03)
	if IsValidEnt(bp) then
		bp:SetName(k)
		bpr[k] = bp
		self.spparts = bpr
	end
end)
console.AddCmd("body_part_del",function(k)
	local self = LocalPlayer()
	local bpr = self.spparts or {}
	
	local bp = bpr[k] 
	if IsValidEnt(bp) then
		bp:Despawn()
		bpr[k] = nil
		self.spparts = bpr
	end
end)
console.AddCmd("body_part_list",function(k)
	local self = LocalPlayer()
	local bpr = self.spparts or {}
	for k,v in SortedPairs(bpr) do
		MsgN(k)
	end
end)
function ENT:SetSpecies(spstr) 
	if spstr then 
		local spd = spstr:split(':')
		local species = spd[1]
		local variation = spd[2]
		
		local data = json.Read("forms/species/"..species..".json")
		if data then 
			MsgN("species",species,variation)
			self:Config(data,species,variation)
			
			local nvariation =  data.model.variations[variation] 
			
			self.species = data
			self.variation_id = variation
			self.variation = nvariation
			
			self.tpsheight = nvariation.tpscamheight or 0.5
			self.fpsheight = nvariation.fpscamheight or 1
		end
	end
end
function ENT:SetBodytype(formid)
	if isstring(formid) then
		local d = forms.ReadForm('bodytype.'..formid)
		if d and d.bones then
			self.model:SetBoneData(json.ToJson(d.bones or {}))
		end
	elseif istable(formid) and formid.bones then 
		self.model:SetBoneData(json.ToJson(formid.bones or {}))
	end
end
function ENT:Config(data,species,variation)

	self:RemoveEventListener(EVENT_USE,"use_event")
	self:RemoveTag(TAG_USEABLE) 
	local phys = self.phys
	if species then
		if data.bodyparts then
		
		
		end 
	end

	local slfEquipment = self.equipment
	if slfEquipment then
		if SERVER then
			slfEquipment:Clear()
		end
		if data.equipment and slfEquipment then
			if data.equipment.slots then
				for k,v in pairs(data.equipment.slots) do
					slfEquipment:AddSlot(v)
				end 
			end 
		end
	end
	if data.components then 
		self._spcom = self._spcom or {}
		for k,v in pairs(data.components) do
			local nc = self:AddComponent(k) 
			self._spcom[k] = nc
		end
	end
	if data.model then
		if isstring(data.model) then
			self:SetModel(data.model) 
		else
			local varbase = data.model.variations[variation]
			local skel = varbase.skeleton
			self:SetModel(data.model.basedir..skel..".stmd") 
		end
	end 
	if data.mass then phys:SetMass(data.mass) end
	if data.variables then
		for k, v in pairs(data.variables) do 
			self[k] = v
		end
	end
	if species then
		self.walkspeed =nil
		self.runspeed =nil
		self.flyspeed =nil
		self.flyfastspeed =nil
		self:SetParameter(VARTYPE_MAXHEALTH,100)
		self:SetParameter(VARTYPE_HEALTH,100)
	end
	if data.movement then
		if data.movement.walk then self.walkspeed = data.movement.walk.speed or self.walkspeed end
		if data.movement.run then self.runspeed = data.movement.run.speed or self.runspeed end 
		if data.movement.fly then self.flyspeed = data.movement.fly.speed or self.flyspeed end 
		if data.movement.flyfast then self.flyfastspeed = data.movement.flyfast.speed or self.flyfastspeed end 
		 
		if data.movement.rotspeed then self.rotspeed = data.movement.rotspeed or self.rotspeed end 
	end
	if data.attributes then
		self.attributes = data.attributes
		for k,v in pairs(data.attributes) do
			if v == "mount" then 
				--self:AddEventListener(EVENT_USE,"use_event",function(self,user) 
				--	user:SendEvent(EVENT_SET_VEHICLE,self,1,self)
				--end)
				--self:AddTag(TAG_USEABLE) 
				self.info = self:GetName()
				self:AddInteraction("mount",
				{text="Mount",action= function (self,user)
					user:SendEvent(EVENT_SET_VEHICLE,self,1,self)
				end}) 
			end
		end
	end
	if data.abilities then
		for k,v in pairs(data.abilities) do
			self:GiveAbility(v) 
		end
	end
	if data.health then
		self:SetParameter(VARTYPE_MAXHEALTH,data.health)
		self:SetParameter(VARTYPE_HEALTH,data.health)
	end
	if data.scale then 
		self.base_scale = data.scale
	end

end

function ENT:SetAi(id)
	if id then
		local ai = Ai(id,self)
		if ai then
			self.controller = ai
		end
		self[VARTYPE_AITYPE] = id
	else
		self.controller = nil
		self[VARTYPE_AITYPE] = nil
	end
end
function ENT:Say(text) 
	if not network.IsConnected() then
		hook.Call("chat.msg.received", self, text)
	end
end

function ENT:SetModel(mdl)
	self:SetParameter(VARTYPE_MODEL,mdl) 
end
function ENT:SetSize(val)
	val = val or self.innerscale or 1
	local model = self.model
	local phys = self.phys
	if model and phys then
		self.scale = val
		self.phys:SetHeight((self.data.height or 1.7)*val)
		self.phys:SetRadius((self.data.radius or (0.6*0.6))*val) 
		self.phys:SetMass((self.data.mass or (20))*val) 
		self.phys:SetJumpSpeed(4.5*val)
		self.innerscale = val or 1

		local base_scale = self.base_scale or 1
		local model_scale = self.model_scale or 1

		local nw = matrix.Scaling(0.03)*matrix.Translation(-phys:GetFootOffset()*0.75/val)*matrix.Scaling(0.001*val*base_scale*model_scale)
		model:SetMatrix(nw)
		for k,v in pairs(self:GetChildren(true)) do
			if v and v.model then
				v.model:SetMatrix(nw)
			end
		end
	end
end
 
--[[ ######## MOVEMENT ######## ]]--

function ENT:Turn(ang)
	if self.norotation then return nil end
	if self.model:HasAnimation("turn_l") then 
		MsgN("TURN",ang)
		local graph = self.graph
			--graph.debug = true
		if graph then
			if (ang*self:GetScale().x>0) then  
				if graph:Call("turn_l") then 
					local Up = self:Up():Normalized()
					self:TRotateAroundAxis(Up, ang) 
					return true  
				end
				--self:PlayAnimation("turn_l","idle",true) 
			else 
				if  graph:Call("turn_r") then
					local Up = self:Up():Normalized()
					self:TRotateAroundAxis(Up, ang) 
					return true
				end
				--self:PlayAnimation("turn_r","idle",true) 
			end
		end
	else 
		return false
	end
end


function ENT:Jump()
	local phys = self.phys
	local ong = phys:OnGround()
	if self:IsFlying() then
		if ong then
			phys:Jump()
		else
			--phys:ApplyImpulse(self:Up())
			self:ApplyFlightImpulse(self:Up()) 
		end
	else
		if ong then 
			if self.graph:Call("jump") then
				phys:Jump()
			end 
		else
			self:StartFlight()
		end
	end
end
function ENT:Move(dir,run,updatespeed,speedmul)
	if self.nomovement then return false end
	local phys = self.phys
	local graph = self.graph
	local scale = self.scale or 1
	local spmul = self.speedmul or 1
	local spscale = scale*spmul
	
	speedmul = math.Clamp(speedmul or 1,0,1)

	self.lastdir = dir
	self.lastrun = run
	if dir then
		if self:IsFlying() then 
			if run then
				phys:SetAirSpeed(self.flyfastspeed*spscale*speedmul) 
			else
				phys:SetAirSpeed(self.flyspeed*spscale*speedmul) 
			end 
			graph:Call("flight_move")   
		else 
			if self:Crouching() then
				if graph:Call("cwalk") or updatespeed  then 
					phys:SetCrouchingSpeed(self.walkspeed*spscale*speedmul) 
				end
			else
				if run then 
					if graph:Call("run") or updatespeed then 
						phys:SetStandingSpeed(self.runspeed*spscale*speedmul) 
					end
				else  
					if graph:Call("walk") or updatespeed  then 
						phys:SetStandingSpeed(self.walkspeed*spscale*speedmul)  
					end
				end
			end
		end 
		if self:IsFlying() then
			local sForward = self:Right():Normalized()
			phys:SetViewDirection(sForward)
			--phys:SetMovementDirection(dir) 
			if self.directflight then

			else
				if run then
					self:ApplyFlightImpulse(self:Right():Normalized()*10) 
				else
					self:ApplyFlightImpulse(self:Right():Normalized()) 
				end
			end
			phys:SetLinearDamping(self.airdamping or 0.3) 
			phys:SetMovementDirection(dir)  
		--	phys:SetGravity(self.flightUp or Vector(0,-0.0001,0))
		elseif self:IsMoving() then 
			local sForward = self:Right():Normalized()
			phys:SetViewDirection(sForward)
			phys:SetMovementDirection(dir) 
		end
		
		local dfa = (math.atan2(-dir.z,dir.x)/3.1415926*180+90)
		if dfa > 180 then dfa = dfa - 360 end
		--MsgN(dfa)
		local model = self.model
		model:SetPoseParameter("move_yaw",dfa) 

		--model:SetPoseParameter("move_x",dir.x*200)
		--model:SetPoseParameter("move_y",dir.z*200) 
		
		local veldir =self.phys:GetVelocity()-- Vector(0,0,0)
		local lworld = self:GetWorld():Inversed()
		veldir = veldir:TransformN(lworld)/(self.scale or 1)
		model:SetPoseParameter("move_x",veldir.z*100)
		model:SetPoseParameter("move_y",veldir.x*100)  
	else 
		self:Stop()
	end
	self:UpdateLean()
end
function ENT:ApplyFlightImpulse(pow)
	local scale = self.scale or 1
	local spmul = self.speedmul or 1
	local spscale = scale*spmul
	local phys = self.phys
	local vel = math.max(1,phys:GetVelocity():Length())*10
	phys:ApplyImpulse(pow*self.flyspeed*spscale/vel) 
end

function ENT:UpdateLean()
	local phys = self.phys
	local model = self.model
	 
	if phys and model then
		if phys:OnGround() then
			local sRight = self:Forward():Normalized()
			local sForward = self:Right():Normalized()
		
			local sd_depth,sd_pos,sd_normal = phys:GetSupportData()
			local sd_rddir = sForward:Cross(sd_normal):Normalized()
			local sd_fddir = sRight:Cross(sd_normal):Normalized() 
			local rang = sRight:Angle(sd_rddir)/3.1415926*180
			local fang = sForward:Angle(-sd_fddir)/3.1415926*180
			if (sRight.y>sd_rddir.y) then rang = -rang end
			if (sForward.y<sd_fddir.y) then fang = -fang end
			model:SetPoseParameter("lean_x",rang)
			model:SetPoseParameter("lean_y",fang) 
		else
			if self:IsFlying() then
				model:SetPoseParameter("lean_x",0)
				model:SetPoseParameter("lean_y",0) 
			end
		end
	end
end
function ENT:UpdateSpeed(run)
	 
	local phys = self.phys 
	local scale = self.scale or 1
	local spmul = self.speedmul or 1
	local spscale = scale*spmul
	
	if self:IsFlying() then 
		if run then
			phys:SetAirSpeed(self.flyspeed*10*spscale) 
		else
			phys:SetAirSpeed(self.flyspeed*spscale) 
		end    
	else 
		if self:Crouching() then 
			phys:SetCrouchingSpeed(self.walkspeed*spscale)  
		else
			if run then  
				phys:SetStandingSpeed(self.runspeed*spscale)  
			else   
				phys:SetStandingSpeed(self.walkspeed*spscale)   
			end
		end
	end 
end
function ENT:IsMoving() 
	if self.phys and  self.phys.GetMovementDirection then
		local mv = self.phys:GetMovementDirection()
		return true --mv:LengthSquared()>0.00001
	end
	--local cs = self.graph:CurrentState()
	--return cs =="walk" or cs == "cwalk" or cs == "run" or cs == "flight_move"
end
function ENT:IsReallyMoving()--actual movement 
	if self.phys and  self.phys.GetMovementDirection then
		local mv = self.phys:GetMovementDirection()
		return mv:LengthSquared() > 0.00001
	end 
end
function ENT:IsRunning() 
	return self:IsMoving() and self.lastrun
end
function ENT:Stop()
	local phys = self.phys
	self.lastdir = Vector(0,0,0)
	phys:SetMovementDirection(Vector(0,0,0)) 
	if self:IsFlying() then
		self.graph:Call("flight_idle")
		phys:SetAirSpeed(0)
		phys:SetLinearDamping(0.5)
	else
		if self:Crouching() then
			if self.graph:Call("cidle") then end
		else
			if self.graph:Call("idle") then  end
		end
	end
	local model = self.model 
	model:SetPoseParameter("move_x",0,true)
	model:SetPoseParameter("move_y",0,true)
	
	self:UpdateLean()
end
function ENT:Attack() 
	if self.graph:Call("attack") then 
	end
end
function ENT:Recall() 
	if self.graph:Call("recall") then 
	end
end
function ENT:EnableGraphUpdate() 
	self.graph.disabled = nil
end
function ENT:DisableGraphUpdate() 
	self.graph.disabled = true
end
function ENT:StartFlight()
	if self:CanFly() then
		self.graph:SetState("flight_start")
		--self.graph:SetState("idle")
		local phys = self.phys
		phys:SetGravity(Vector(0,-0.0001,0))
		phys:SetAirSpeed(100)
		self.isflying = true
		
		local model = self.model
		if model then
			model:SetPoseParameter("lean_x",0)
			model:SetPoseParameter("lean_y",0) 
		end
	end
end
function ENT:Land(nostate)
	if not nostate then self.graph:SetState("flight_end") end
	local phys = self.phys
	phys:SetGravity() 
	phys:SetAirSpeed(0)
	phys:SetLinearDamping(0)
	self.isflying = false
	
	self:UpdateLean()
end
function ENT:CanFly()
	local fs = self.flyspeed
	return fs and fs ~= 0
end
function ENT:IsFlying()  
	return self.isflying or false
end
 
function ENT:Crouching() 
	return self.phys and self.phys:GetStance() ==1--.duckmode or false
end
function ENT:SetCrouching(value)
	--self.duckmode = value
	if value and not self:IsFlying() then
		self.phys:SetStance(1)
		if self.graph then
			return self.graph:Call("duck")
		end
	else
		self.phys:SetStance(0)
		if self.graph then
			return self.graph:Call("idle")
		end
	end
end
function ENT:Duck()
	if self:IsFlying() then
		--self.phys:ApplyImpulse(-self:Up()) 
		self:ApplyFlightImpulse(-self:Up()) 
	end
end
function ENT:SetSpeedMul(mul)
	self.speedmul = mul
	self.model:SetPlaybackRate(mul)
	
	local lastdir = self.lastdir
	local lastrun = self.lastrun
	
	self:UpdateSpeed(lastrun)
	
	if mul <=0 then
		self:Stop()
		self:SetUpdating(false)
	else
		if lastdir then
		end 
		self:SetUpdating(true,100)
	end
end
function ENT:GetSpeedMul()
	return self.speedmul or 1
end
function ENT:Freeze()
	self:SetSpeedMul(0)
end
function ENT:Unfreeze()
	self:SetSpeedMul(1)
end
  

function ENT:GetHeadingElevation(dir,b) 
	if dir then 
		if not b then
			dir = dir:Rotate(Vector(0,-180,0))
		end
		local rad = dir:Length()
		local polar = math.atan2(dir.z,dir.x)
		--if dir.x < 0 then polar = polar + 3.1415926 end
		local elev = math.asin(dir.y/rad)
		return rad,polar,elev
	end
end
function ENT:EyeLookAt(dir) 
	--MsgN(debug.traceback())
	--local sz = self:GetParent():GetSizepower()
	--local Up = self:Up():Normalized()
	if IsValidEnt(dir) then
		dir = self:GetLocalCoordinates(dir)---Up* (0.67/sz)
	end
	local rad, polar,elev = self:GetHeadingElevation(dir,true)
	--self.model:SetPoseParameter("head_yaw",  polar/ 3.1415926 * 180)
	--self.model:SetPoseParameter("head_pitch",elev/ 3.1415926 * 180)
	self:SetEyeAngles(elev/ 3.1415926 * 180,polar/ 3.1415926 * 180,false,true) 
end
function ENT:GestureToggle(layer, name)  
	local g = self.gestures
	if g then
		local ge = g[name]
		if ge then
			if ge.active then
				self:SendEvent(EVENT_GESTURE_END,layer,name)
			else
				self:SendEvent(EVENT_GESTURE_START ,layer,name)
			end
			return true
		end
	end
end
function ENT:GestureStart(layer, name) 
	local g = self.gestures
	
	if g then
		local gest = g[name]
		if gest then
			local m = self.model
			local gesttype = gest.type or "overlay" 
			gest.active = true
			if gesttype == 'overlay' then
				m:PlayLayeredSequence(layer,name) 
				local fadein = gest.fadein or gest.fade or 0.02
				local fadeout = gest.fadeout or gest.fade or 0.02
				m:SetLayerFade(layer,fadein,fadeout)
			elseif gesttype == 'normal' then
				self.graph:SetState("gesture") 
				local time = m:SetAnimation(name,gest.stepstart or false)
				if not gest.loop then
					self:Delayed("gesture_end",(gest.time or time)*1000,function()
						self:GestureEnd(layer,name)
						--self.graph:SetState("idle") 
						--m:SetAnimation("idle",gest.stepend or false)
						--gest.active = false
					end)
				end
			end
			if gest.variables then
				gest.variables_restore = {}
				for k,v in pairs(gest.variables) do
					gest.variables_restore[k] = self[k]
					self[k] = v
				end
			end
			hook.Call("gesture.start",self,name)
		end
	end
end
function ENT:GestureEnd(layer, name) 
	local g = self.gestures
	if g then
		local gest = g[name]
		if gest then
			local m = self.model
			local t = 1 
			local gesttype = gest.type or "overlay" 
			if gesttype == 'overlay' then
				m:StopLayeredSequence(layer)
				gest.active = false
			elseif gesttype == 'normal' then
				self.graph:SetState("idle") 
				m:SetAnimation("idle")
				gest.active = false
			end
			if gest.variables_restore then
				for k,v in pairs(gest.variables) do
					MsgN(k,nil)
					self[k] = nil
				end
				for k,v in pairs(gest.variables_restore) do
					MsgN(k,v)
					self[k] = v
				end
			end
		end
	end
end
function ENT:EyeLookAtLerped(dir) 
	if self.lad then
		self.lad:Stop()
		self.lad=nil
	end
	if IsValidEnt(dir) then 
		local entt = dir
		if self.model:HasAttachment("head") then
			if entt:GetClass()=='base_actor' and entt.model:HasAttachment("head") then
				dir = self:GetLocalCoordinates(entt,entt.model:GetAttachmentPos("head")) - self.model:GetAttachmentPos("head")---Up* (0.67/sz)
			else
				dir = self:GetLocalCoordinates(entt) - self.model:GetAttachmentPos("head")---Up* (0.67/sz)
			end  
		else
			dir = self:GetLocalCoordinates(entt) 
		end
	end
	
	local m = self.model
	local tpp_yaw = 0
	local tpp_pitch = 0
	if dir~=nil then
	  
		--dir = dir + Up* (0.67/sz) 
	--	local rad, polar,elev = self:GetHeadingElevation(dir,true)
	--	local tpp_yaw = polar/ 3.1415926 * 180 
	--	local tpp_pitch = elev/ 3.1415926 * 180
--
	--	local turn_angle = self.turn_angle or 90
	--	if math.abs(tpp_yaw)>=turn_angle then  
	--		local trsl = self:Turn(-polar) 
	--	end

		local rad, polar,elev = self:GetHeadingElevation(dir,true)
		tpp_yaw = polar/ 3.1415926 * 180 
		tpp_pitch = elev/ 3.1415926 * 180
	end
	local t = 0 
	local cpp_yaw = m:GetPoseParameter("head_yaw")
	local cpp_pitch = m:GetPoseParameter("head_pitch")

	local cobcd = false
	local co = GetCurrentController()
	if self.controller ==co then
		self.controller = nil
		cobcd=true
	end
	self.lad = self:Timer("lookat",0.3,10,15,function()
		t = t + 1/15 
		local ss_p =cpp_pitch + (tpp_pitch-cpp_pitch)*t -- Smoothstep(cpp_pitch,tpp_pitch,t)
		local ss_y =cpp_yaw + (tpp_yaw-cpp_yaw)*t -- Smoothstep(cpp_yaw,tpp_yaw,t)
		
		--MsgN(t," : ",cpp_yaw," : ",tpp_yaw," : ",ss_y)
		self:SetEyeAngles(ss_p,ss_y)
		--m:SetPoseParameter("head_yaw",  Smoothstep(cpp_yaw,tpp_yaw,t))
		--m:SetPoseParameter("head_pitch", Smoothstep(cpp_pitch,tpp_pitch,t))
		if  t>=(14/15) then
			if cobcd then
				self.controller = co
			end
			self.lad = nil
		end
	end)
	
end
function ENT:SetHeadAngles(pitch,yaw) 
	self.headangles = {yaw,pitch}
	local m = self.model
	m:SetPoseParameter("head_yaw",yaw,true) 
	m:SetPoseParameter("head_pitch",pitch,true) 
end
function ENT:SetEyeAngles(pitch,yaw,forced,nopred) 
	if not math.bad(pitch) then pitch = 0 end
	if not math.bad(yaw) then yaw = 0 end
	local m = self.model
	local noeyedelay = self.noeyedelay or true
	self.eyeangles = {pitch,yaw}
	local lms = self.lastheadmove or 0
	local ha = self.headangles or {0,0}
	local amul = self.eyemul or {0,0}
	
	m:SetPoseParameter("eyes_x",yaw*amul[2])
	m:SetPoseParameter("eyes_y",pitch*amul[1]) 
	--m:SetPoseParameter("head_yaw",yaw)
	--m:SetPoseParameter("head_pitch",pitch) 
	
	if forced or self:IsReallyMoving() or noeyedelay or (Point(ha[1],ha[2]):Distance(Point(yaw,pitch))>30) or CurTime()-lms>3 then
		self.headangles = {yaw,pitch}
		self.lastheadmove = CurTime() 
	end
	m:SetPoseParameter("head_yaw",ha[1],true)--nopred or false)
	m:SetPoseParameter("head_pitch",ha[2],true)--nopred or false) 
	
	local sForward = self:Right():Normalized()
	--self.phys:SetViewDirection(sForward)
	
	--local spp = self.spparts
	--if spp then
	--	if spp.eyes then
	--		spp.eyes.model:SetEyeAngles(pitch,yaw)
	--	
	--	end
	--end
	--m:SetEyeAngles(pitch,yaw)
end
function ENT:EyeAngles()
	local eyea = self.eyeangles or {0,0}
	return eyea[1], eyea[2]
end

function ENT:SetEyeTarget(pos)
	self:SetParameter(VARTYPE_VIEWTARGET,pos)
end
function ENT:GetEyeTarget(pos)
	return self:GetParameter(VARTYPE_VIEWTARGET)
end

--[[ ######## VEHICLES ######## ]]--

function ENT:SetVehicle(veh,mountpointid,assignnode,servercall) 
	if veh then
		mountpointid = mountpointid or 1
		assignnode = assignnode or veh
		servercall = servercall or false
		
		local mountpoint = veh.mountpoints[mountpointid]
		if not mountpoint then return false end
		if IsValidEnt(mountpoint.ent) then MsgN("OCCUPIED",mountpoint.ent) return false end
		
		local smodel = self.model
		if (mountpoint.state and smodel:HasAnimation(mountpoint.state)) or smodel:HasAnimation("sit") then

			local phys = self.phys
			self.IsInVehicle = true
			self.vehicle = veh
			self.graph:SetState(mountpoint.state or "sit")
			self:SetParent(veh)
			phys:SetVelocity(Vector(0,0,0))
			--self.phys:SetMass(-1)
			self:SetPos(mountpoint.pos or Vector(0,0,0))--pos)
			self:SetAng(mountpoint.ang or Vector(0,0,0))
			if mountpoint.attachment then
				veh.model:Attach(self,mountpoint.attachment)
			end
			self.currentmountpoint = mountpoint
			local weld = self.weld
			if weld then
				weld:Break()
			end
			self:SetUpdateSpace(false)
			
			mountpoint.ent = self
			--local ply = self.player
			--if assignnode and ply then 
			--	self.assignednode = assignnode
			--	ply:AssignNode(assignnode)
			--end
			if SERVER then
				if veh.player then
					veh.player:UnassignNode(veh)
				end
				if self.player then
					self.player:AssignNode(assignnode)
					self.assignnode = assignnode 
				end
			end
			--if CLIENT and LocalPlayer()==self then
			--	network.RequestAssignNode(assignnode)
			--	self.assignednode = assignnode
			--end
			CALL(function() 
				self.weld = constraint.Weld(phys,nil,Vector(0,0,0))
				self.nocol = constraint.NoCollide(phys,nil)
			end)
		else

			return false
		end
		
		 
	else
		local v = self.vehicle
		if v then
			local weld = self.weld
			if weld then
				weld:Break()
				self.weld = nil
			end 
			local phys = self.phys
			constraint.NoCollide(phys,nil,true)
			
			local cmp = self.currentmountpoint
			if cmp and cmp.attachment then
				v.model:Detach(self)
			end
			self.IsInVehicle = false
			local vparent = self.vehicle:GetParent()
			if SERVER or not network.IsConnected() then 
				--self:SetPos(Vector(1.321081, 0.5610389, 0.01457999))--Vector(0,0,0))
				--self:Eject()
				self:SetParent(vparent)
				self:SetPos(v:GetPos()+Vector(0,0.5/vparent:GetSizepower(),0))
				--self:SendEvent(EVENT_RESPAWN_AT,self.vehicle:GetPos()+Vector(0,2,0)/vparent:GetSizepower())
				if self.player and self.assignnode then
					self.player:UnassignNode(self.assignnode)
					self.assignnode = nil
				end
				if v.player then
					v.player:AssignNode(v)
				end
			else
				self:SetParent(vparent)
				self:SetPos(v:GetPos()+Vector(0,0.5/vparent:GetSizepower(),0))
			end 
			self.vehicle = nil
			self.graph:SetState("idle")
			--self:SetParent(v:GetParent())
			--self:SetPos(v:GetPos())
			--self.phys:SetMass(10)
			self:SetUpdateSpace(true)
			
			--local ply = self.player
			--if self.assignednode and ply then 
			--	self.assignednode = nil
			--	ply:UnassignNode(self.assignednode)
			--end
			--if CLIENT and self.assignednode and  LocalPlayer()==self then 
			--	self.assignednode = nil
			--	network.RequestUnassignNode(v)
			--end
			cmp.ent = nil
		end
	end
	
	self:VelocityCheck(true)
	--if not servercall and CLIENT then
	--	network.CallServer("actor_set_vehicle",self,veh,mountpointid,assignnode) 
	--end
end 
function ENT:GetVehicle() 
	return self.vehicle
end
function ENT:HandleDriving(driver)
	local cc = GetCurrentController()
	if cc then
		cc:HandleMovement(self)
	end
end

--[[ ######## ITEMS ######## ]]--

function ENT:Give(formid,count,silent)
 MsgN(formid)
	local s = self.storage
	if s and s:HasFreeSlot() then
		local item = forms.GetItem(formid)
		if item then
			local eq = self.equipment 
			MsgN(self,formid)
			if eq and item:Read("/parameters/luaenttype")  == 'item_apparel' then
				eq:Equip(item)
			else
				s:PutItemAsData(nil,item,count) 
				hook.Call("inventory_update",self)
			end
			if CLIENT and not silent and self == LocalPlayer() then
				MsgInfo("new item: "..forms.GetName(formid)) 
			end
		end
		--local p = forms.GetForm("apparel",type) or forms.GetForm(type)
		--if p  then 
		--	local item = ItemIA(p,GetFreeUID())
		--	local eq = self.equipment 
		--	if eq then
		--		eq:Equip(item)
		--	else
		--		s:PutItemAsData(s:GetFreeSlot(),item) 
		--	end
		--else
		--	local itemb = forms.GetItem(type)
		--	if itemb then
		--		s:PutItemAsData(s:GetFreeSlot(),itemb) 
		--	end
		--end
	end 
end

function ENT:Equip(formid)
	local s = self.storage
	local eq = self.equipment 
	if s and eq then
		local item = s:GetItem(formid) 
		if item then 
			PrintTable(item)
			eq:Equip(item)
		end
	end
end


console.AddCmd("giveto",function(formid,count)  
	--if CLIENT then
	--	if b then
	--		for k,v in pairs(LocalPlayer():GetParent():GetChildren()) do
	--			if v[VARTYPE_CHARACTER] == a or v[VARTYPE_FORM] == a and v.Give then
	--				MsgN(v)
	--				if not network.IsConnected() then
	--					v:Give(b)
	--				else
	--					v:SendEvent(EVENT_GIVE_ITEM,b)
	--				end
	--				break
	--			end
	--		end
--
	--	else
	--		if not network.IsConnected() then
	--			LocalPlayer():Give(formid,tonumber(count or 1))
	--		else
	--			LocalPlayer():SendEvent(EVENT_GIVE_ITEM,a)
	--		end
	--	end
	--else
	--	MsgN( a,b)
	--	local ply = Player(tonumber(a))
	--	if ply then
	--		ply:SendEvent(EVENT_GIVE_ITEM,b,tonumber(count or 1)
	--	end
	--end
end)
if CLIENT then
	local bformlist = {
		"apparel","tool","resource"
	}
	console.AddCmd("give",function(formid,count) 
		count = tonumber(count or 1)
		if not network.IsConnected() then
			LocalPlayer():Give(formid,count)
		else
			LocalPlayer():SendEvent(EVENT_GIVE_ITEM,formid,count)
		end  
	end,"give form to actor",function(str)
		local r = {} 
		str = cstring.trim(str)
		--MsgN(str)
		if string.starts(str,"apparel") then
			local lst = forms.GetList("apparel")
			local substr = string.sub(str,9)
			for k,v in SortedPairs(lst) do
				if string.starts(k,substr) then r[#r+1] = "apparel."..k end
			end 
		elseif string.starts(str,"resource") then
			local lst = forms.GetList("resource")
			local substr = string.sub(str,10)
			for k,v in SortedPairs(lst) do
				if string.starts(k,substr) then r[#r+1] = "resource."..k end
			end 
		else
			for k,v in SortedPairs(bformlist) do
				if string.starts(v,str) then r[#r+1] = v  end
			end
		end
		return json.ToJson(r)
	end)
else --SERVER
	console.AddCmd("give",function(plyid,formid,count) 
		local ply = Player(tonumber(plyid))
		if ply then
			count = tonumber(count or 1) 
			ply:SendEvent(EVENT_GIVE_ITEM,b,count)
		end  
	end)
end
console.AddCmd("give_ability",function(formid) 
	LocalPlayer():SendEvent(EVENT_GIVE_ABILITY,formid)
end)
console.AddCmd("equip",function(a,b)  
	if CLIENT then
		if b then
			for k,v in pairs(LocalPlayer():GetParent():GetChildren()) do
				if v[VARTYPE_CHARACTER] == a or v[VARTYPE_FORM] == a and v.Give then
					MsgN(v)
					if not network.IsConnected() then
						v:Equip(b) 
					end
					break
				end
			end

		else
			if not network.IsConnected() then
				LocalPlayer():Equip(a) 
			end
		end
	else 
		---
	end
end)

--[[ ######## WEAPON|TOOLS ######## ]]--

function ENT:HasTool(type) 
	local inv = self.inventory 
	if inv then
		return #inv:Select(function(e) return e and e.type==type  end)>0
	end
end
function ENT:HasItem(formid)
	if not string.ends(formid,'.json') then
		formid = forms.GetForm(formid) 
	end
	local s = self.storage
	if s then
		if s:HasItem(formid) then return true end
	end
	local e = self.equipment
	if e then
		if e:HasItem(formid) then return true end
	end
	return false
end

function ENT:PickupWeapon(weap)
	----local wr = self.weapons or {}
	----self.weapons = wr
	----
	----if not wr[weap.type] then
	----	wr[weap.type] = weap
	----	weap:OnPickup(self) 
	----	self:SetActiveWeapon(weap.type)
	----else
	----	return false 
	----end
	local inv = self.inventory 
	if inv then
		inv:AddItem(self,weap)
	end
	weap:OnPickup(self) 
	self:SetActiveWeapon(weap)
end
function ENT:DropWeapon(aw)
	local em = self.model 
	if aw and self.activeweapon == aw then 
		--if aw and em then em:Detach(aw) end 
		aw:Unequip(self)
		self.activeweapon = nil   
		local inv = self.inventory 
		if inv then
			inv:RemoveItem(self,aw)
		end
		aw:OnDrop(self)
	end
end
function ENT:DropActiveWeapon()
	local aw = self.activeweapon
	if aw then self:DropWeapon(aw) end
end
function ENT:GetActiveWeapon()
	return self.activeweapon
end
function ENT:SetActiveWeapon(weap)  
	if weap then
		if weap:GetParent()==self then
			local em = self.model
			local aw = self.activeweapon
			if aw and em then  
				aw:Unequip(self)
				if self.inventory then
					self.inventory:AddItem(self,aw)
				else
					self:DropWeapon(aw)
				end 
			end 
			self.activeweapon = weap
			
			weap:Equip(self)
			
			return true 
		end
	else
		--local em = self.model
		--local aw = self.activeweapon
		--if aw and em then em:Detach(aw) end 
		--self.activeweapon = nil
		--em:StopLayeredSequence(2)
		--em:StopLayeredSequence(1)
		local em = self.model
		local aw = self.activeweapon
		if aw and em then  
			aw:Unequip(self)
			if self.inventory then
				self.inventory:AddItem(self,aw)
			else
				self:DropWeapon(aw)
			end 
		end 
		return true
	end
	return false
end
 

function ENT:WeaponFire(dir,alternative,iscontinuous) 
	if CLIENT then
		local weap = self:GetActiveWeapon() 
		if alternative then
			if RF and weap.AltFire and weap:IsReady(iscontinuous) then
				weap:SendEvent(EVENT_TOOL_FIRE,1,dir)  
				return true
			end  
		else
			if weap.Fire and weap:IsReady(iscontinuous) then  
				weap:SendEvent(EVENT_TOOL_FIRE,0,dir) 
				return true
			end 
		end
	end
	return false
end
 
--[[ ######## EQUIPMENT|APPAREL ######## ]]--

function ENT:GetEquipped(slot)
	local e = self.equipment
	if e then
		return e:GetEquipped(slot) 
	end
	return nil
end
function ENT:Equip(item) 
	local e = self.equipment
	if e then
		return e:Equip(slot) 
	end
	return nil
end
function ENT:Unequip(item)
	self:SendEvent(EVENT_UNEQUIP,item) 
end
function ENT:UnequipSlot(slot)
	self:SendEvent(EVENT_UNEQUIPSLOT,slot) 
end
function ENT:UnequipAll(slot)
	self:SendEvent(EVENT_UNEQUIPALL) 
end


--[[ ######## ABILITIES ######## ]]--

function ENT:SetActiveAbility(abname)
	self.activeAbility = abname
	MsgN("set ab to: ",abname)
end
function ENT:GetActiveAbility()
	return self.activeAbility 
end
function ENT:GetAbility(abname)
	return self.abilities[abname]  
end
function ENT:Cast(abname)
	local aa = self.abilities[abname]  
	if aa then
		aa:Cast(self)
	end
end
function ENT:CastActiveAbility()
	local aname = self.activeAbility 
	if aname then
		local ab = self.abilities[aname] 
		if ab then
			ab:Cast(self)
		end
	end
end
function ENT:GiveAbility(aname)
	
	local ab = Ability(aname)
	if ab then
		self.abilities[aname] = ab
		if CLIENT and not silent and self == LocalPlayer() then
			MsgInfo("new ability: "..ab.name) 
		end
	end
end
function ENT:TakeAbility(aname)
	self.abilities[aname] = nil
end

 


--[[ ######## OTHER ######## ]]--

function ENT:Alert()
	self.graph:Call("unc_transition")
end

function ENT:VelocityCheck(teleport)
	if true then return end
	if self:GetVehicle() then return end
	local lastvel = self.lastvel
	local vel = self.phys:GetVelocity()
	if lastvel and not teleport and not self:IsFlying() then 
		local veldelta = vel-lastvel 
		self:VelocityHit(nil,veldelta)
	end
	self.lastvel = vel
end
function ENT:VelocityHit(hitby,velonhit)
	local avvel = velonhit:Length() -- self.phys:GetVelocity():Length()
	local scale = self.scale or 1
	--if avvel > 0 then
	if avvel > 5 then
		local vol = math.min(1,(avvel-5)/5)
		self:EmitSound(table.Random({"hit1.ogg","hit2.ogg","hit3.ogg"}),vol*0.9)
	end
	
	if avvel > 10 then
		local damage = math.pow((avvel-9)/scale,2)
		self:Hurt(damage)
		
		MsgN("CC: ",self,hitby," vel: ",avvel)
	end  
	--end
end


function ENT:SetSkin(str)
	if str then
		local model = self.model
		for k,v in pairs(str:split(',')) do
			local pr = v:split(':')
			model:SetSkin(pr[1],tonumber(pr[2]))
		end
	end
end

hook.Add('interact.options','pickup',function(u,e,t)
    if e:HasTag(TAG_STOREABLE) then
        t.pickup = {text = "pick up"}
    end
end) 
hook.Add('interact','pickup',function(user,e,t)
    if t=='pickup' then
        local inv = user:GetComponent(CTYPE_STORAGE)
        if inv then 
            local freeslot = inv:GetFreeSlot()
            if e:HasTag(TAG_STOREABLE) then
                MsgN("pickup",user, e)
                e:SendEvent(EVENT_PICKUP,user)
                if inv:PutItem(freeslot,e) then
                    if CLIENT then
                        user:EmitSound("events/lamp-switch.ogg",1)
                    end
                    return freeslot
                end
            end
        end
    end
end) 
function ENT:PickupNearest()
	local inv = self:GetComponent(CTYPE_STORAGE)
	if inv then 
		local freeslot = inv:GetFreeSlot()
		if freeslot then
			local maxPickupDistance = 2
			local pos = self:GetPos()
			local par = self:GetParent()
			local sz = par:GetSizepower()
			local entsc = par:GetChildren()
			local nearestent = false
			local ndist = maxPickupDistance*maxPickupDistance
			for k,v in pairs(entsc) do
				if v~=self and v:HasTag(TAG_STOREABLE) then 
					local edist = pos:DistanceSquared(v:GetPos())*sz*sz 
					if edist<ndist and edist>0 then
						nearestent = v
						ndist = edist
					end 
				end
			end
			if nearestent then
				MsgN("pickup",self, nearestent)
				nearestent:SendEvent(EVENT_PICKUP,self)
				if inv:PutItem(freeslot,nearestent) then
					if CLIENT then
						self:EmitSound("events/lamp-switch.ogg",1)
					end
					return freeslot
				end
			end 
		end
	end
	return false
end



function ENT:GetEyeTrace()
	local model = self.model
	if model then 
		--local pos = Vector(0,0,0) 
		-- 
		--if model:HasAttachment("eyes") then pos = model:GetAttachmentPos("eyes") 
		--elseif model:HasAttachment("head") then pos = model:GetAttachmentPos("head")   
		--elseif model:HasAttachment("muzzle") then pos = model:GetAttachmentPos("muzzle") end
		--
		--
		--local parentphysnode = self:GetParentWithComponent(CTYPE_PHYSSPACE)
		--if parentphysnode then
		--	local space = parentphysnode:GetComponent(CTYPE_PHYSSPACE)
		--	local lw = parentphysnode:GetLocalSpace(cam)
		--	local hit, hpos, hnorm, dist, ent = space:RayCast(lw:Position(),lw:Forward())
		--	return {Hit = hit,Position=hpos,Normal=hnorm,Distance = dist, Node = parentphysnode, Space = space,Entity = ent}
		--end
		
	end
end



function ENT:GetAllParts()
	local parts = {self}
	local spp = self.spparts
	if spp then 
		for k,v in pairs(spp) do
			parts[#parts+1] = v
		end
	end
	return parts
end

 
function ENT:KeyDown(key) 
	if CLIENT and LocalPlayer() == self then
		return input.KeyPressed(key)
	end
	return false
end


ENT._typeevents = {
	[EVENT_DAMAGE] = {networked = true, f = function(self,amount)  

	end},
	[EVENT_HEALTH_CHANGED] = {networked = true, f = function(self,val) 
		--self:SetParameter(VARTYPE_HEALTH,val)  
		if CLIENT and LocalPlayer() == self then 
			local mhp = self:GetParameter(VARTYPE_MAXHEALTH) 
			healthbar:UpdateHealth(val,mhp) 
		end
		--self:SetVehicle(nil) 
	end},
	[EVENT_MAXHEALTH_CHANGED] = {networked = true, f = function(self,val)
		if CLIENT and LocalPlayer() == self then 
			local hp = self:GetParameter(VARTYPE_HEALTH) 
			healthbar:UpdateHealth(hp,val) 
		end
	end},
	[EVENT_DEATH] = {networked = true, f = function(self)  
		if CLIENT and LocalPlayer() == self then  
			healthbar:UpdateHealth(0,self[VARTYPE_MAXHEALTH]) 
		end 
		self.graph:SetState("dead") 
	end},
	[EVENT_SPAWN] = {networked = true, f = function(self)  
		if CLIENT and LocalPlayer() == self then  
			healthbar:UpdateHealth(self[VARTYPE_HEALTH],self[VARTYPE_MAXHEALTH]) 
		end 
		self.graph:SetState("spawn") 
	end},
	[EVENT_CHANGE_CHARACTER] = {networked = true, f = ENT.SetCharacter},
	[EVENT_TOOL_DROP] = {networked = true, f = ENT.DropActiveWeapon},
	[EVENT_ACTOR_JUMP] = {networked = true, f = ENT.Jump},
	[EVENT_SET_VEHICLE] = {networked = true, f = ENT.SetVehicle},
	[EVENT_EXIT_VEHICLE] = {networked = true, f =function(self)
		local m = self.model
		if m and m:HasAnimation("capchair.exit") then
			self.graph:SetState("vehicle_exit_start") 
		else
			self.graph:SetState("idle") 
			self:SetVehicle()
		end
	end},
	
	[EVENT_RESPAWN_AT] = {networked = true, f = function(self,pos) 
		self:SetPos(pos)
		self.phys:SetVelocity(Vector(0,0,0))
	end},
	[EVENT_STATE_CHANGED] = {networked = true, f = function(self,newstate) 
		if SERVER or self ~= LocalPlayer() then self.graph:SetState(newstate) end 
	end},
	
	[EVENT_GIVE_ITEM] = {networked = true, f = ENT.Give,log = true}, 
	[EVENT_PICKUP_ITEM] = {networked = true, f = function(self,item) 
		self:Give(type)
		local inv = self.inventory
		if inv then
			inv:AddItem(self, item)
			item:SendEvent(EVENT_PICKUP,self)
			item:SetPos(Vector(0,0,0))
		end
	end,log = true},
	[EVENT_PICKUP_TOOL] = {networked = true, f = function(self,tool) 
		self:PickupWeapon(tool)
	end,log = true},
	[EVENT_PICKUP] = {networked = true, f = function(self) 
		self:PickupNearest()
	end,log = false},
	
	[EVENT_ABILITY_CAST] = {networked = true, f = ENT.Cast},  
	[EVENT_GIVE_ABILITY] = {networked = true, f = ENT.GiveAbility},
	[EVENT_TAKE_ABILITY] = {networked = true, f = ENT.TakeAbility}, 
	[EVENT_TASK_BEGIN] = {networked = true, f = ENT.BeginTask}, 
	[EVENT_TASK_END] = {networked = true, f = ENT.EndTask}, 
	[EVENT_TASK_RESET] = {networked = true, f = ENT.ResetTM},  
	
	[EVENT_GESTURE_START] = {networked = true, f = ENT.GestureStart}, 
	[EVENT_GESTURE_END] = {networked = true, f = ENT.GestureEnd}, 
	
	[EVENT_LERP_HEAD] = {networked = true, f = ENT.EyeLookAtLerped}, 
	[EVENT_LOOK_AT] = {networked = true, f = ENT.EyeLookAt}, 
	[EVENT_SET_AI] = {networked = true, f = ENT.SetAi}, 
	
	[EVENT_ITEM_ADDED] = {networked = true, f = function(e,index) 
		MsgN("new item at: "..tostring(index or '?')) 
	end}, 
	[EVENT_ITEM_TAKEN] = {networked = true, f = function(e,index) 
		MsgN("taken item from: "..tostring(index or '?')) 
	end}, 
	
}
 
ENT.editor = {
	name = "Actor",
	properties = {
		character = {text = "character",type="parameter",valtype="string",key=VARTYPE_CHARACTER,reload=true}, 
		hp_amount = {text = "health",type="parameter",valtype="number",key=VARTYPE_HEALTH},
		hp_max_amount = {text = "maximum health",type="parameter",valtype="number",key=VARTYPE_MAXHEALTH}, 
		enabled = {text = "enabled",type="parameter",valtype="number",key=VARTYPE_MAXHEALTH},  
		posess = {text = "posess",type="action",action = function(ent)  
			worldeditor:Close() 
			SetLocalPlayer(ent)
			SetController("actor") 
		end},
		ai = {text="ai",type="parameter",valtype="string",reload=false,
		apply = function(n,u,k,v) MsgN(n,u,k,v) n:SendEvent(EVENT_SET_AI,v) end,
		get = function(n,u,k) 
			if n.controller then return n.controller.typename or "" else 
				return ""
			end
		end,
	}
	},  
	
}

debug.AddAPIInfo("/userclass/Entity/base_actor",{
	SetMaxHealth={_type="function",_arguments={{_name="value",_valuetype="number"}}},
	SetSkin={_type="function",_arguments={{_name="str",_valuetype="string"}}},
	
})

hook.Add('formspawn.character','spawn',function(form,parent,arguments) 
	local aparts = string.split(form,'.')
	local loctype = string.join('.',table.Skip(aparts,1)) 

	local actorD = ents.Create("base_actor")
	actorD:SetSizepower(1000)
	actorD:SetParent(parent)
	actorD:AddTag(TAG_EDITORNODE)
	actorD:SetSeed(arguments.seed or 0)
	actorD:SetCharacter(loctype)
	actorD:Spawn()
	actorD:SetPos(arguments.pos or Vector(0,0,0)) 
	return actorD
end) 
hook.Add('formcreate.character','spawn',function(form,parent,arguments) 
	local aparts = string.split(form,'.')
	local loctype = string.join('.',table.Skip(aparts,1)) 

	local actorD = ents.Create("base_actor")
	actorD:SetSizepower(1000)
	actorD:SetParent(parent)
	actorD:AddTag(TAG_EDITORNODE)
	actorD:SetSeed(arguments.seed or 0)
	actorD:SetCharacter(loctype)
	actorD:Create()
	actorD:SetPos(arguments.pos or Vector(0,0,0)) 
	return actorD
end)

if SERVER then
	local function _GetCharacter(plr,sender,id)
		MsgN(a,plr,sender,id)
		local cli = sender.player
		local fname = forms.GetForm("character",id) -- "forms/characters/"..id..".json"
		if fname then
			local data = json.Read(fname)
			if data then  
				MsgN("Send ",fname)
				cli:SendFile(fname) 
				local model = data.model
				if model then
					MsgN("Send ",model)
					cli:SendFile("models/"..model,true)
				end
				cli:Call('_1',plr,EVENT_CHANGE_CHARACTER,id)
			end
		end
	end

	hook.Add("umsg._GetCharacter","char",_GetCharacter)
end

local movemode = false
local lastpos = false
console.AddCmd("debug_movemode",function()
	movemode = not movemode
	if movemode then
		hook.Add(EVENT_GLOBAL_UPDATE,"debug_movenode",function()
			local cam = GetCamera()
			local tr = GetMousePhysTrace(cam) 
			if tr then
				local e = tr.Node
				debug.ShapeBoxCreate(3030,e,
					matrix.Translation(Vector(-0.5,-0.5,-0.5)+tr.Normal*0.5) 
					*matrix.Scaling(1/e:GetSizepower())
					*matrix.Translation(tr.Position))
				lastpos = tr.Position
				--MsgInfo(tr.Position)
			end
		end)
		hook.Add("input.mousedown","debug_movenode",function()
			if lastpos and input.leftMouseButton() then
				local move = Task("moveto",lastpos,1.5,true) 
				LocalPlayer():BeginTask(move)
				MsgN("move!",lastpos)
			end
		end)
	else
		hook.Remove(EVENT_GLOBAL_UPDATE,"debug_movenode")
		hook.Remove("input.mousedown","debug_movenode")
	end
end)

console.AddCmd("hideplayer",function()
	for k,v in pairs(LocalPlayer():GetChildren()) do
		if v.model then
			v.model:Enable(false)
		end
	end
end)
if CLIENT then
	console.AddCmd("setcharacter",function(char)
		LocalPlayer():SendEvent(EVENT_CHANGE_CHARACTER, char)
	end)
	console.AddCmd("setbodytype",function(bdtp)
		LocalPlayer():SetBodytype(bdtp)
	end)
end