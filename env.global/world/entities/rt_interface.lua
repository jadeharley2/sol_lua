
function SpawnScreen(target,ent,guiroot,sm)
	local e = ents.Create("rt_interface")  
	e.target = target
	e.guiroot = guiroot
	e.sm = sm
	e:SetParent(ent) 
	e:Spawn()
	return e
end

function ENT:Init()  
	self:SetSpaceEnabled(false) 
	self:SetSizepower(1000)
end

function ENT:Spawn()  

	local interface = self:AddComponent(CTYPE_INTERFACE)
	interface:SetRenderTarget(0,self.target)
	interface:SetRoot(self.guiroot)
	interface:RequestDraw(self.sm)
	self.interface = interface  
	
	self:SetUpdating(true)
end

function ENT:Think() 
	self.interface:RequestDraw(self.sm)
end