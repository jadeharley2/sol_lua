 

function ENT:Init()  
	self:SetSpaceEnabled(false) 
	self:SetSizepower(1000)
	
	self.rqu = Stack()
	self.busy = false
end

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
function ENT:Spawn()   

	local cc = ents.CreateCamera()
	cc:SetParent(self) 
	cc:Spawn()
	self.cam = cc


	local rparam = render.RenderParameters()   
	local rcamera = self:AddComponent(CTYPE_CAMERA) 
	rcamera:SetCamera(cc) 
	rcamera:SetParameters(rparam)

	self.rt = CreateRenderTarget(256,256,"")
	rcamera:SetRenderTarget(0,self.rt )
	
	self.rcamera = rcamera
	
	self:AddNativeEventListener(EVENT_RENDERER_FINISH,"event",function(s,e,c) 
		--MsgN("thumbnail render finished",self.form)
		self.busy = false    
		self.cooldowntime = CurTime() + 0.001
		local newTexture = self.rt:Copy() 
		if self.callback then self.callback(newTexture) end 
		self:ClearStage()
	end)
	self.cooldowntime = CurTime()  
	self:Start()
	-- self:CreateStaticLight(Vector(10,10,10),Vector(1,1,1),10000)
end 
local onerror = function(err) MsgN(err,"\n", debug.traceback()) end
function ENT:Start()   
	hook.Add("main.postcontroller","thumbnailRenderer", function()  
		local status, err = xpcall(function() self:Update() end,onerror) 
		if status then
			-- all ok
		else
			MsgN("thumbnail render error:",err)
			-- error 
			self:Cleanup()
		end 
	end)
end
function ENT:Cleanup() 
	if self and IsValidEnt(self) then
		for k,v in pairs(self:GetChildren()) do v:Despawn() end  
		local cc = ents.CreateCamera()
		cc:SetParent(self) 
		cc:Spawn()
		self.cam = cc
		self.rcamera:SetCamera(cc)  
		self.cooldowntime = CurTime() 
	end
	hook.Remove("main.postcontroller","thumbnailRenderer")
	RTHUMB = nil
end

function ENT:Draw(form,callback)  
	
	
	self.rqu:Push({form,callback})
	--MsgN("render request")
end
function ENT:ClearStage()
	if self.entity then
		for k,v in pairs(self.entity:GetChildren()) do
			if v and IsValidEnt(v) then
				v:Despawn()
			end
		end
		self.entity:Despawn()
		self.entity = nil
	end
end
function ENT:SetForm(form)  
	self:ClearStage() 
	if true then  
		local p = false
		if form:find('/') then 
			local ext = file.GetExtension(form)
			if ext =='.stmd' or ext == '.dnmd' or ext == '.mdl' then -- or ext == '.smd'
				p = SpawnSO(form,self,Vector(0,0,0),1,NO_COLLISION)
			elseif ext == '.json' then

			end
		else
			--MsgN("spawnform ",form)
			p = forms.Spawn(form,self,{})-- 
		end


		--SpawnPV(path,self,Vector(0,0,0),nil,0) 




		if p then
			self.entity = p
			self.cam:SetPos(Vector(1,1,1)*10/1000)
			self.cam:SetAng(Vector(-33.4475441,45,0))
			--self.cam:LookAt(Vector(0,0,0))
			self.cam:SetFOV(10)
			
			self.rcamera:SetScreenSpace(false)
			 
			ModNodeMaterials(p,{FullbrightMode=true},nil,true)
			local m = p.model
			if m then
				local vpos,vsize = m:GetVisBox(self)
				if vpos then
					MsgN(vpos,vsize)
					local vlen = vsize:Length()
					self.cam:SetPos(vpos/2+Vector(1,1,1)*8000*vlen/1000)
				end
			end 
			return true
		else 
			if self.callback then self.callback(false) end 
			self:ClearStage()
			return false
		end
	end 
end
function ENT:Update() 
	self.cooldowntime = self.cooldowntime or CurTime()
	local cdt = self.cooldowntime -CurTime() 
	if cdt<0  then
		if not self.busy and self.rqu:Peek() then
			self.busy = true
			local ln = self.rqu:Pop() 
			if ln then
				local form,callback = ln[1],ln[2]
				--MsgN("render start",form)

				self.form = form
				self.callback = callback
				if self:SetForm(form) then
					--self.rcamera:RequestDraw() 
					self.stage = "drawprep"
					self.cooldowntime = CurTime() + 0.001
				else
					self.busy = false
					self.cooldowntime = CurTime() + 0.001
				end
			end
		elseif self.stage == 'drawprep' then
			ModNodeMaterials(self.entity,{FullbrightMode=true},nil,true)
			self.stage = nil
			self.rcamera:RequestDraw() 
		end
	end 
end 