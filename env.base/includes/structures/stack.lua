
local stack_meta = {}

function stack_meta:Push(val)
	local s = self.s 
	
	local ns = {val}
	for k,v in pairs(s) do
		if k < self.maxlen then
			ns[k+1] = v
		end
	end
	s = ns  
	self.s = s 
end

function stack_meta:Pop()
	local s = self.s 
	local r = s[1]
	if r~=nil then
		local ns = {}
		for k,v in pairs(s) do 
			ns[k-1] = v 
		end
		ns[0] = nil  
		s = ns
		self.s = s 
	end
	return r
end
function stack_meta:Peek()
	return self.s[1]
end

stack_meta.__index = stack_meta
stack_meta.__newindex = stack_meta



function Stack(maxlen)
	local u = {s={},maxlen = maxlen or 64}
	setmetatable(u,stack_meta)
	return u
end