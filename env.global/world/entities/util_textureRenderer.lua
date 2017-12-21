 

function ENT:Init()  
	self:SetSpaceEnabled(false) 
	self:SetSizepower(1)
end

function ENT:Spawn()   
	local interface = self:AddComponent(CTYPE_INTERFACE)
	self.interface = interface   
end
function ENT:Draw(target,root,callback)
	local interface = self.interface
	interface:SetRenderTarget(0,target)
	interface:SetRoot(root) 
	interface:RequestDraw(nil,callback) 
end