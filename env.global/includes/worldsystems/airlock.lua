local airlock = DEFINE_METATABLE("airlock")
function airlock:Open()
	self.door_in:Unlock() 
	self.door_out:Unlock() 
	self.door_in:Open() 
end
function airlock:Close()
	self.door_in:Close() 
	self.door_out:Close() 
	self.door_in:Lock() 
	self.door_out:Lock()
end
function airlock:Setup()
	self.door_out.OnUse = function(a,e) 
		if not self.door_in.locked and not self.door_out.locked then 
			self.door_in:Close() 
			self.door_out:Open() 
			if CLIENT then e:Eject() end 
		end 
	end 
	self.door_in.OnUse = function(a,e) 
		if not self.door_in.locked and not self.door_out.locked then 
			self.door_out:Close() 
			self.door_in:Open() 
		end  
	end 
	self:Close()
end 
airlock.__index = airlock


function Airlock(din,dout)
	local u = {door_in = din,door_out = dout}  
	setmetatable(u,airlock) 
	u:Setup()
	return u
end