
task.slot = "movement"

function task:Setup(target) 
	self.target = target 
	self.dtt = 100 -- log eta timer  

	self.warpspeed = 0
	self.warpspeed_max =-1

	return true
end 
function task:OnBegin()  
	MsgN("task: Ship warp")
	local ship = self.ent  
	local target = self.target

	local origin = target[1]
	local pos = target[2]
	
	local shipparent = ship:GetParent()
	
	local start_sz = shipparent:GetSizepower()
	local start_scpos = shipparent:GetLocalCoordinates(ship) 
	local start_pcpos = shipparent:GetLocalCoordinates(origin)--pos
	local start_dir = start_pcpos-start_scpos
--MsgN("CO: ",sz)
	self.start_ldist =start_scpos:Distance(start_pcpos) *start_sz 
	self.warp_meanspeed = 5000--1 * CONST_AstronomicalUnit --1000
	--0.1 * CONST_AstronomicalUnit -- 0.1 au per second
	local warp_eda = CurTime()
	local warp_eft = self.start_ldist / self.warp_meanspeed
	local warp_eta = warp_eda + warp_eft
	MsgN("warp target asquired")
	MsgN("warp total distance: ",self.start_ldist/CONST_AstronomicalUnit, " au")
	MsgN("warp estimated total time: ",warp_eft, " seconds")
	MsgN("warp mode enabled")
	ship.warpmode = true
	 
	return true
end 
function task:Step()    
	local ship = self.ent   
	local target = self.target[1]
 
	local cshipparent = ship:GetParent()
	local sz = cshipparent:GetSizepower()  
	local scpos = cshipparent:GetLocalCoordinates(ship) 

	local pcpos = cshipparent:GetLocalCoordinates(target)--pos
	local dir = pcpos-scpos
	DrawPoint(1000,ship,dir:Normalized()*100,10000)
--MsgN("CO: ",sz)
	local ldist =scpos:Distance(pcpos) 
	local realdist = ldist*sz 
	--ship:LookAt(-dir:Normalized())
	--MsgN(-dir:Normalized())
	--ship:RotateLookAtStep(coord,100)
	
	local percent_completed = math.max(0.0001,math.min(1, 1-realdist/self.start_ldist))

	if realdist > self.start_ldist/2 then
		self.warpspeed = self.warpspeed + 0.001
		if self.warpspeed_max<self.warpspeed then self.warpspeed_max = self.warpspeed end
	else
		--xnwarpspeed = math.max(0,warpspeed - 0.01)
		self.warpspeed = --warpspeed - 0.01, 
			math.min(1,math.max(0,realdist/self.start_ldist*2*33))*self.warpspeed_max
	end
	if realdist > 4*UNIT_MM then
		local maxedwarpspeed = math.min(20,self.warpspeed)
		--local warpspeed = math.sin(percent_completed*3.1415926)
		ship:Throttle(maxedwarpspeed*maxedwarpspeed*self.warp_meanspeed*0.01,true,dir:Normalized()) --*1000*4 --*maxedwarpspeed
		ship:BendSpacetime(maxedwarpspeed/8)
		--self.warpm:SetBrightness(math.min(1,warpspeed*4)*0.5)
		--self:SetScale(Vector(1,1,math.max(0.01,1-warpspeed/2)))
	else
		MsgN("warp destination reached") 
		ship:DisableWarpMode() 
		return true
	end
	if self.dtt <0 then
		local td,un = DistanceNormalize(realdist)
		MsgN(ship:GetParent()," - ",ship," - ",origin)
		MsgN("d: ",td," ",un," v: ",ship.velocity_c:GetVelocity():Length()," p: ",percent_completed)
		self.dtt = 100
	else
		self.dtt = self.dtt - 1
	end
	ship.velocity_c:SetLinearDamping(0.99)
	--if percent_completed>0.5 then
	--	ship.velocity = ship.velocity*0.1 
	--end 
end
function task:OnEnd(result)
	local ship = self.ent   
	ship.velocity_c:SetLinearDamping(0.1)
end 