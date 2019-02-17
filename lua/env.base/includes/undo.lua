
local undo_meta = DEFINE_METATABLE("Undo")

function undo_meta:Add(undofunc,redofunc,tag)
	local ur = {u = undofunc,r = redofunc,t = tag} 
	self.uh:Push(ur) 
end

 

function undo_meta:Undo() 
	local cf = self.uh:Pop() 
	if cf then 
		self.rh:Push(cf)
		cf.u(cf.t)
	end 
end
function undo_meta:Redo()
	local cf = self.rh:Pop() 
	if cf then  
		self.uh:Push(cf)
		cf.r(cf.t)
	end
end

undo_meta.__index = undo_meta
undo_meta.__newindex = undo_meta

function Undo(maxhistory)
	maxhistory = maxhistory or 10
	local u = {uh = Stack(maxhistory),rh = Stack(maxhistory)}
	setmetatable(u,undo_meta)
	return u
end

