 
 
function ENT:Init()  
	--local orbit = self:AddComponent(CTYPE_ORBIT)  
	--self.orbit = orbit
	self.radius = 1000000 -- 1000km
end

function ENT:Spawn()

	local sections = {}
	
	for k=1,360 do
		local section = ents.Create() 
		section:SetParent(self)
		section:SetSizepower(self.radius/36*4/10)
		local ang = Vector(k*1,0,0)
		section:SetPos(Vector(0,0.9,0):Rotate(ang))
		section:SetAng(ang)
		section:Spawn() 
		if k%10==0 then
			section.thering = SpawnSO("test/ring2.json",section,Vector(0,0,0),0.75*50) 
		end
		sections[#sections+1] = section
	end
	
	local model_radius = 883.961
	local real_radius = 900000
	local model_scale = 1020
	self.sections = sections
	self.thering = SpawnSO("test/ring3.json",self,Vector(0,0,0),model_scale) 
	self.thering :SetAng(Vector(0,90,0))
	--self:SetUpdating(true)
	
	  
end
function ENT:Enter()  
 
	--render.SetGroupBounds(RENDERGROUP_STARSYSTEM,1e8,0.5*UNIT_LY)
	--render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_BACKGROUND)
	
	--render.SetGroupBounds(RENDERGROUP_PLANET,1e2,1e10)
	--render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_BACKGROUND)
end
----
function ENT:Leave()   
	--render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_ENABLED)
	--render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_ENABLED)
end

function ENT:Think()
	self:SetAng(Vector(0.1*CurTime(),0,0))

end