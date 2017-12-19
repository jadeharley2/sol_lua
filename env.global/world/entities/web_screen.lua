
EVENT_SETURL = 12102

function SpawnWScreen(parent,seed,model,pos,ang)
	local e = ents.Create("web_screen")  
	e:SetModel(model,0.75)
	e:SetSizepower(1)
	e:SetSeed(seed)
	e:SetParent(parent)
	e:SetPos(pos) 
	e:SetAng(ang or Vector(0,0,0))  
	e:Spawn()
	return e
end

function ENT:Init()   
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model 
	self:SetSpaceEnabled(false)  
	
	--local webinterface = self:AddComponent(CTYPE_WEBINTERFACE)  
	--self.webinterface = webinterface 
	--webinterface:Initialize(1024,512)
	--webinterface:SetTextureName("@webrt")
	
	self:AddEventListener(EVENT_SETURL,"set_url",function(url) self:LoadUrl(url) end)
	self:SetNetworkedEvent(EVENT_SETURL) 
end
function ENT:Load()
	local modelval = self:GetParameter(VARTYPE_MODEL)
	local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	if modelval then 
		self:SetModel(modelval,modelscale)
	else
		error("no model specified at spawn time")
	end 
end  
function ENT:Spawn()  
	local modelcom = self.modelcom
	if not modelcom then
		local modelval = self:GetParameter(VARTYPE_MODEL)
		local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
		if modelval then 
			self:SetModel(modelval,modelscale)
		else
			error("no model specified at spawn time")
		end
	end 
	 
	
	--self.webinterface:Load("http://google.com")
end

 
function ENT:SetModel(mdl,scale) 
	scale = scale or 1
	local model = self.model
	local world = matrix.Scaling(scale) * matrix.Rotation(-90,0,0)
	
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(mdl)   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world)
	  
	self.modelcom = true
end 


function ENT:LoadUrl(url)  
	MsgN("open: ", url)
	--self.webinterface:Load(url)
end