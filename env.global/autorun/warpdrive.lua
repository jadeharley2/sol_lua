-- lua_run TEST_OpenTonnelTo(GetCamera():GetParent(),TEST_GetNearestStar(GetCamera():GetParent()))
 
function TEST_OpenTonnelTo(self,target)

end

function TEST_OpenTonnelTo(self,target)
	local lwd = self:GetLocalCoordinates(target)
	local dist = self:GetDistance(target)
	local dir = lwd:Normalized()
	MsgN("warp distance: ",dist/UNIT_LY,"ly")
	TEST_OpenWarpTonnel(self,dir,dist)
end

function TEST_GetNearestStar(self)
	local galaxy = self:GetParentWith(NTYPE_GALAXY)
	local current_star = self:GetParentWith(NTYPE_STARSYSTEM)
	MsgN("cgalaxy: ",galaxy)
	MsgN("csystem: ",current_star)
	if galaxy then
		local stars = galaxy:GetChildren()
		local mindist = 9e100
		local fstar = 0
		for k,v in pairs(stars) do
			if v ~=current_star then
				local dist = self:GetDistance(v)
				if dist<mindist then
					mindist = dist
					fstar = v
				end
			end
		end
		
		
		if fstar then
			MsgN(fstar)
			MsgN("at: ",self:GetLocalCoordinates(fstar))
			MsgN("dist: ",self:GetDistance(fstar))
			MsgN()
			return fstar
		end
	end
end
--lua_run TEST_OpenWarpTonnel(GetCamera():GetParent(),100000000)
--lua_run TEST_OpenWarpTonnel(GetCamera():GetParent(),10*UNIT_LY)
function TEST_OpenWarpTonnel(self,dir, distance)
	local ship = self--.ship -- entity
	local origin = ship:GetParent()
	local cpos = ship:GetPos()
	local lforw = dir--ship:Forward()
	local forwardDirection =lforw / origin:GetSizepower()
	
	local enter = ents.Create("warp_portal")
	local exit = ents.Create()
	
	enter:SetSizepower(1000) 
	exit:SetSizepower(1000)
	enter:SetParent(origin) 
	exit:SetParent(origin)
	enter:SetPos(cpos+forwardDirection*3000)--metres
	exit:SetPos(cpos+forwardDirection*distance)
	
	local warp = ents.Create()
	warp:SetSizepower(10000000) 
	warp:SetSpaceEnabled(false)
	warp:Spawn()
	
	local warp_pocket = ents.Create()
	warp_pocket:SetSizepower(10000)  
	warp_pocket:SetParent(warp)
	warp_pocket:Spawn()
	
	local warp_enter = ents.Create()
	local warp_exit = ents.Create("warp_portal")
	
	warp_enter:SetSizepower(100) 
	warp_exit:SetSizepower(100)
	warp_enter:SetParent(warp_pocket)
	warp_exit:SetParent(warp_pocket)
	warp_enter:SetPos(lforw*-0.9)
	warp_exit:SetPos(lforw*0.9)
	
	enter.target = warp_enter
	warp_exit.target = exit
	
	enter.OnTouch = function(s,e)
		MsgN("UPDATE:ENABLED")
		exit:SetUpdateSpace(true)
	end
	warp_enter:Spawn()
	warp_exit:Spawn()
	
	warp_exit.OnTouch = function(s,e)
		MsgN("UPDATE:DISABLED")
		exit:SetUpdateSpace(false)
		exit:SetPos(Vector(0.001,0,0))
		if e.EnteredNewSystem then
			e:EnteredNewSystem()
		end
	end
	
	enter:Spawn()
	exit:Spawn()
	local m1 = SpawnSO("engine/gsphere_24_inv.smd",warp_enter,Vector(0,0,0),0.75*500)
	local m2 = SpawnSO("engine/gsphere_24_inv.smd",warp_exit,Vector(0,0,0),0.75*500)
	
	local m3 = SpawnSO("engine/gsphere_24_inv.smd",enter,Vector(0,0,0),0.75*500)
	local m4 = SpawnSO("engine/gsphere_24_inv.smd",exit,Vector(0,0,0),0.75*500)
	m1:LookAt(lforw)
	m2:LookAt(lforw)
	m3:LookAt(lforw)
	m4:LookAt(lforw)
	m1.model:SetMaterial("textures/debug/fulldark.json") 
	m2.model:SetMaterial("textures/debug/fulldark.json") 
	m3.model:SetMaterial("textures/debug/fulldark.json") 
	m4.model:SetMaterial("textures/debug/fulldark.json") 
	m1.model:SetRenderGroup(RENDERGROUP_PLANET)
	m2.model:SetRenderGroup(RENDERGROUP_PLANET)
	m3.model:SetRenderGroup(RENDERGROUP_PLANET)
	m4.model:SetRenderGroup(RENDERGROUP_PLANET)
	
end