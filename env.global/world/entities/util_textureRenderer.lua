 

function ENT:Init()  
	self:SetSpaceEnabled(false) 
	self:SetSizepower(1)
	
	self.rqu = Stack()
	self.busy = false
end

function ENT:Spawn()   
	local interface = self:AddComponent(CTYPE_INTERFACE)
	self.interface = interface   
	
	self:AddNativeEventListener(EVENT_RENDERER_FINISH,"event",function(s,e,c)
		 
		--if c == s then
			MsgN("render end") 
			self.busy = false 
			self.cooldowntime = CurTime() + 0.1
			if self.callback then self.callback(self.target) end
		--end
	end)
	self.cooldowntime = CurTime() + 1
	
	hook.Add("main.postcontroller","textureRenderer", function() self:Update() end)
end 
function ENT:Draw(target,root,callback) 
	self.rqu:Push({target,root,callback})
	MsgN("render request")
end
function ENT:Update() 
	self.cooldowntime = self.cooldowntime or CurTime()
	local cdt = self.cooldowntime -CurTime() 
	if not self.busy and cdt<0 and self.rqu:Peek() then
		MsgN("render start")
		self.busy = true
		local ln = self.rqu:Pop()
		local interface = self.interface
		local target,root,callback = ln[1],ln[2],ln[3]
		self.target = target
		self.callback = callback
		interface:SetRenderTarget(0,target)
		interface:SetRoot(root) 
		interface:RequestDraw() 
		--rqu[#rqu] = nil
		--self.rqu = rqu 
		--PrintTable(self.rqu)
	end
end 