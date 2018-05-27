
local prof = DEFINE_METATABLE("Profiler")

--Iteration
function prof:IS()
	local ct = debug.time()
	self.startt = ct
	self.events = {}
end
function prof:IE()
	local ct = debug.time()
	self.endt = ct
	self.loopt = ct-self.startt 
	self.totalt = self.totalt + self.loopt
	MsgN("all profiler events for ",self.name)
	PrintTable(self.events)
	MsgN("")
end

--Event
function prof:ES(name)
	self.current = {name,debug.time()}
end
function prof:EE()
	local c = self.current
	local ct = debug.time()
	self.events[#self.events+1] = {c[1],c[2],ct,ct-c[2]}
end
 
function Profiler(name)
	local m = {totalt=0,name=name}
	setmetatable(m,prof)
	return m
end