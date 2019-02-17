module.Require("procedural")

function ENT:CreateStaticLight( pos, color,power)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2) 
	lighttest:SetParent(self)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn() 
	if power then lighttest:SetBrightness(power) end
	lighttest:SetPos(pos)  
	return lighttest
end


 
function ENT:Init()

	self:SetSizepower(10000)
	--self:SetSeed()
	--self:SetGlobalName() 

end
function ENT:Spawn() 
	if self.loaded then return nil end
	
	local wtype = self:GetParameter(VARTYPE_CHARACTER)
	
	local data = json.Load(wtype)
	if data then
		local seed = data:Read("seed") or 0
		local name = data:Read("name") or "unknown"
		if isnumber(seed) then
			self:SetSeed(seed)
		end
		if isstring(name) then
			self:SetName(name)
		end
		local space = ents.Create()
		space:SetLoadMode(0)
		if isnumber(seed) then
			space:SetSeed(seed+1000) 
		end
		space:SetParent(self) 
		space:SetSizepower(1000) 
		
		local sspace = space:AddComponent(CTYPE_PHYSSPACE)  
		sspace:SetGravity(Vector(0,-4,0))
		space.space = sspace
		
		space:Spawn()  
		
		
		
		local b = procedural.Builder()
		b:BuildNode(data,space)
 
		--local map = SpawnSO(wtype,space,Vector(0,0,0),1)  
		--local light = self:CreateStaticLight(Vector(-1.3,1.2,-2.5)/2*10,Vector(200,200,200)/255,190000000 * 100)
		 
		--light.light:SetShadow(true)
		self.space = space 
		 
		   
		--if CLIENT then
		--	local nav = space:AddComponent(CTYPE_NAVIGATION)   
		--	nav:AddStaticMesh(map)
		--	self.nav = nav
		--end
			  
		SpawnSO("map/citytest/sky.json",space,Vector(0,0,0),5,NO_COLLISION) 
		  
		if CLIENT then 
			local cbm =  space:AddComponent(CTYPE_CUBEMAP)
			cbm:SetSize(512)
			cbm:SetTarget() 
			space.cubemap = cbm
		
			cbm:RequestDraw()
			--local cbm  = SpawnCubemap(otherspace,Vector(0,0.002,0),512)
			--space.cubemap = cbm
			--otherspace.cubemap:RequestDraw()
			
			space:AddNativeEventListener(EVENT_ENTER,"cubmapset",function() 
				--GlobalSetCubemap(cbm,true)   
			end)
			space:AddNativeEventListener(EVENT_LEAVE,"dt",function()    
				self:Despawn()
			end)
			
		end
		
		--local flatgrass_door = SpawnDT("door/door2.stmd",space,Vector(4.656322E-10, 0, 0.007867295),Vector(0,0,0),0.1)
		--flatgrass_door:SetGlobalName("foyer.flatgrass.door")
		--flatgrass_door.target = "flatgrass.door"
		--self.doot = flatgrass_door
		self.loaded = true
		
		SetInterior(wtype,self)
	end
end 
function ENT:Despawn() 
	--local wtype = self:GetParameter(VARTYPE_CHARACTER)
	--SetInterior(wtype,nil)
end

local static = ENT.static or {}
ENT.static = static

static.interiors = static.interiors or {}

function SetInterior(dynmapfile,ent)
	static.interiors[dynmapfile] = ent
end
function GetInterior(dynmapfile, donotspawn)
	local i = static.interiors[dynmapfile]
	if (not i or not IsValidEnt(i)) and not donotspawn then  
		i = ents.Create("interior_worldspace")
		i:SetParameter(VARTYPE_CHARACTER,dynmapfile)
		i:Spawn()
		return i, true
	end 
	return i, false
end
function ListLoadedInteriors()
	return static.interiors
end

function _ReloadInterior(iid)
	if CLIENT then
			MsgN("sad  reload ",iid)
		if string.ends(iid,".dnmd") then
			local int = GetInterior(iid,true)
			if int and int.space then
				MsgN("interior reload ",iid,int)
				
				local pl = LocalPlayer() or GetCamera()
				if pl then
					engine.PausePhysics()
					
					local tempspace = ents.Create("world_void")
					tempspace:Spawn()
					local cp = pl:GetPos()
					pl:SetParent(tempspace)
					int.space:Leave(pl)
					if int and IsValidEnt(int) then
						int:Despawn()
					end
					
					int = GetInterior(iid)
					if int and int.space then
						int.space:Enter(pl)
						pl:SetParent(int.space)
						pl:SetPos(cp)--+Vector(0,0.2,0)/int.space:GetSizepower())
						
						tempspace:Despawn()
					end 
					debug.Delayed(100,function()
						engine.ResumePhysics()
						if pl.phys then
							pl.phys:SetVelocity(Vector(0,0,0))
						end 
						pl:SetPos(cp+Vector(0,0.7,0)/int.space:GetSizepower())
					end)
				end 
			end
		end
	end
end

hook.Add("file.reload","interior_autoreload",_ReloadInterior)

