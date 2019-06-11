

function ENT:Init()    
	local trigger = self:AddComponent(CTYPE_PHYSTRIGGER)  
    self.trigger = trigger 
    self:SetSizepower(1)
    self:SetSpaceEnabled(false)  
end 
function ENT:Spawn()   
	self:AddNativeEventListener(EVENT_TRIGGER_TOUCH_START,"event",self.TouchStart)
    self:AddNativeEventListener(EVENT_TRIGGER_TOUCH_END,"event",self.TouchEnd)
    local sz = self:GetSizepower()
    self.trigger:SetShape(sz,sz,sz) 
end 
function ENT:Load() 
end
function ENT:TouchStart(eid,node)  
    local s = self.OnTouchStart
    if s then s(self,node) end 
end
function ENT:TouchEnd(eid,node) 
    local s = self.OnTouchEnd
    if s then s(self,node) end 
end