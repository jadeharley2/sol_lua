 

function ENT:Init()  
	self:SetSpaceEnabled(false) 
	self:SetSizepower(1)
	
	self.rqu = Stack()
	self.busy = false
end

function ENT:Spawn()   
	local interface = self:AddComponent(CTYPE_INTERFACE)
	self.interface = interface   
	local rparam = render.RenderParameters()
	interface:SetParameters(rparam)
	local size = self.size or 512
	self.rt = CreateRenderTarget(size,size,"")
	interface:SetRenderTarget(0,self.rt )
	
	self:AddNativeEventListener(EVENT_RENDERER_FINISH,"event",function(s,e,c)
		 
		--if c == s then
			--MsgN("render end") 
			self.busy = false 
			self.cooldowntime = CurTime() + 0.001
			local nt = self.rt:Copy()
			if self.callback then self.callback(nt) end
		--end
	end)
	self.cooldowntime = CurTime() 
	 
	self:Hook("main.postcontroller","textureRenderer", function() 
		if IsValidEnt(self) then
			self:Update()
		else
			--self:DDFreeAll()
		end
	end)
end 
function ENT:Draw(target,root,callback,args) 
	self.rqu:Push({target,root,callback,args})
	--MsgN("render request")
end
function ENT:Update() 
	self.cooldowntime = self.cooldowntime or CurTime()
	local cdt = self.cooldowntime -CurTime() 
	if not self.busy and cdt<0 and self.rqu:Peek() then
		--MsgN("render start")
		self.busy = true
		local ln = self.rqu:Pop()
		local interface = self.interface
		local target,root,callback,args = ln[1],ln[2],ln[3],ln[4]
		self.target = target
		self.callback = callback
		--interface:SetRenderTarget(0,target)
		if args then
			if args.blend then
				interface:SetBlend(args.blend)
			end
			if args.backcolor or args.backalpha then
				interface:SetBack(args.backcolor or Vector(0,0,0),args.backalpha or 0)
			end
		end
		interface:SetRoot(root) 
		interface:RequestDraw() 
		--rqu[#rqu] = nil
		--self.rqu = rqu 
		--PrintTable(self.rqu)
	end
end 