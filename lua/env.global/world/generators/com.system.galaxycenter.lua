
generator.target = "starSystem"

generator[EVENT_GENERATOR_SETUP] = function(self, node) -- system(self)
	local seed = node:GetSeed()
	
    local rnd = Random(seed + 3452)
    
	local star = ents.Create("star") 
    local radius = 15.5432*CONST_SunRadius
    local mass = 516608.0*CONST_SunMass
    local color = Vector(0,0,0)
	star.szdiff = 20000
	star.radius = radius
	star.color = color
	star:SetSeed(seed + 3218979)
	star:SetName(node:GetName())  
	star:SetParameter(VARTYPE_RADIUS,radius)
	star:SetParameter(VARTYPE_COLOR,color)
	star:SetParameter(VARTYPE_MASS,mass) 
	star:SetSizepower(radius*20000)
    star:SetParameter(VARTYPE_TYPE,NTYPE_BLACKHOLE)
	star:SetParent(node)
    star:Spawn() 
    
end