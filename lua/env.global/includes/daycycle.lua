
if SERVER then return end

daycycle = daycycle or {}
--lua_run daycycle.SetDay()
daycycle.SetDay = function() daycycle.SetLocalTime(12) end
daycycle.SetNight = function() daycycle.SetLocalTime(0) end
daycycle.SetDawn = function() daycycle.SetLocalTime(6) end
daycycle.SetDusk = function() daycycle.SetLocalTime(18) end
  
daycycle.SetLocalTime = function(time,transition)
	local caller = GetCamera()
	local planetsurf = caller:GetParentWithFlag(TAG_PLANET_SURFACE)
	local star = caller:GetParentWithFlag(TAG_STAR)
	if planetsurf and star then  
		local aa = daycycle.GetLocalSunAngle(caller,planetsurf,star) 
		local conr = planetsurf:GetComponent(CTYPE_CONSTROT)
		if conr then
			if transition then
				local ivn = 0
				local dt = 0.01/transition 
				local Fcs,Fco,Fcm = conr:GetParams()
				local vstart = Fco
				local vend = Fco - aa + (time-12)/12*3.1415926
				local vdelta = (vend-vstart)  
				debug.DelayedTimer(0,10,transition*100,function()
					ivn = ivn + dt  
					local val = vstart + vdelta*ivn
					conr:SetParams(Fcs, val,Fcm) 
				end)
			else 
				local cs,co,cm = conr:GetParams()
				co = co - aa + (time-12)/12*3.1415926
				conr:SetParams(cs,co,cm)
			end
		end
	else --2d worlds
		local dgl_star0 = ents.GetByName("dgl_star0")
		if dgl_star0 then
			local lpos = dgl_star0:GetPos()
			local dbase = Vector(0,70,0)
			-- 0 = -180
			-- 6 = -90
			-- 12= 0 
			-- 16= 90
			local angle = (time/12-1)*180

			dgl_star0:SetPos(dbase:Rotate(Vector(angle,0,0)))
		end
	end 
	
end
daycycle.GetLocalSunAngle = function(ply,surface,star)
	if ply and surface and star then
		local lp = surface:GetLocalCoordinates(star):Normalized()
		local cp = surface:GetLocalCoordinates(ply):Normalized()
		lp = lp*Vector(1,0,1)  
		cp = cp*Vector(1,0,1)
		local x1 = lp.x
		local x2 = cp.x
		local y1 = lp.z 
		local y2 = cp.z
		local aa = -math.atan2(x1*y2-y1*x2,x1*x2+y1*y2)
		return aa
	end
	return 0
end
daycycle.GetLocalTime = function()
	local caller = GetCamera()
	local planetsurf = caller:GetParentWithFlag(TAG_PLANET_SURFACE)
	local star = caller:GetParentWithFlag(TAG_STAR)
	if planetsurf and star then  
		local aa = daycycle.GetLocalSunAngle(caller,planetsurf,star)*(12/3.1415926)+12--24h
		local hours = math.floor(aa)
		local minutes = math.floor((aa-hours)*60)
		local seconds = math.floor(((aa-hours)*60-minutes)*60)
		--MsgN(lp,";",cp,";",aa,";",hours,":",minutes,":",seconds)
		--MsgInfo(tostring(hours)..":"..tostring(minutes)..":"..tostring(seconds))--lp:Angle(cp))) 
		return tostring(hours)..":"..tostring(minutes)..":"..tostring(seconds)
	end    
	return ""  
end 

console.AddCmd("localtime",function()
	MsgN(daycycle.GetLocalTime())
end)