
function unpack(r)
	if r then
		return r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8],r[9],r[10]
	end
end

local function CrtHook(obj, funcname,inner)  
	local realfn = obj[funcname]
	obj[funcname] = function(self,...)
		inner(self,...)
		return realfn(self,...)
	end
end
local function CrtEventHook(obj, funcname,rec,evname)
	evname = evname or funcname
	local realfn = obj[funcname]
	obj[funcname] = function(self,...)
		rec:AddEvent(evname,...)
		return realfn(self,...)
	end
end
local function CrtStubHook(obj, funcname)
	local realfn = obj[funcname]
	obj[funcname] = function() end
	obj["_r_"..funcname] = realfn
end
local function RemoveHook(obj, funcname)
	obj[funcname] = nil
	obj["_r_"..funcname] = nil
end

local rdtlist = {--"Move",
"Jump","Stop","Attack","TRotateAroundAxis",
"SetEyeAngles","SetCrouching",
"Throttle","Turn","Turn2","SendEvent","WeaponFire"}
 
meta_recorder = meta_recorder or {}


function meta_recorder:Start()
	self.events = { }
	self.starttime = CurTime()
	--CrtEventHook(self.ent,"SetPos",self)
	self:AddEvent("SetAbsPos",self.ent:GetAbsPos()+Vector(0,1,0))
	self:AddEvent("SetAng",self.ent:GetWorld())
	for k,v in pairs(rdtlist) do
		CrtEventHook(self.ent,v,self)
	end 
	 
	local realfn = self.ent['Move']
	local cparent = self.ent:GetParent()
	self.ent['Move'] = function(e,...)
		local nparent = e:GetParent()
		if nparent~=cparent then
			self:AddEvent('SetParent',nparent)
			cparent = nparent
		end
		self:AddEvent('Move',...)
		return realfn(e,...)
	end
	 
	local realSetVehicle = self.ent["SetVehicle"]
	self.ent["SetVehicle"] = function(e,v,...)
		self:AddEvent("SetVehicle",v,...)
		if v then 
			self.veh = Recorder(v)
			self.veh:Start()
			self:AddEvent("subPlay",self.veh)
		else 
			if self.veh then
				self.veh:Stop()
				self:AddEvent("subStop",self.veh)
			end
		end
		realSetVehicle(e,v,...)
	end
	
	hook.Add("event.use","asd",function()
		self:AddEvent("use")
	end)
end
function meta_recorder:AddEvent(name,...)
	local time = CurTime() - self.starttime
	--MsgN("recorder.newevent ",name," at ",time)
	local id = #self.events+1
	local e ={ n = name,a = {...},t = time}
	self.events[id] = e
end
function meta_recorder:DoEvent(e)
	--MsgN("recorder.event: ",e.name," : ",unpack(e.args))
	local fn = self.ent["_r_"..e.n] or self.ent[e.n] or self["ev_"..e.n]
	fn(self.ent,unpack(e.a))
end
function meta_recorder:Stop()
	self.ploop = false
	for k,v in pairs(rdtlist) do
		RemoveHook(self.ent,v)
	end  
	RemoveHook(self.ent,'Move')
	self.ent["SetVehicle"] = nil
	hook.Remove(EVENT_GLOBAL_PREDRAW, "recorder.play")
	hook.Remove("event.use","asd")
	self.lastevent = self.events[1]
	self.ent.controller = self.aicon or self.ent.controller 
end
function meta_recorder:Play() 
	self.aicon = self.ent.controller
	self.ent.controller = self
	for k,v in pairs(rdtlist) do
		CrtStubHook(self.ent,v)
	end  
	self.starttime = CurTime()
	self.lastevent = self.events[1]
	MsgN("recorder.trackstart")
	local cid = 1
	hook.Add(EVENT_GLOBAL_PREDRAW, "recorder.play", function() 
		local time = CurTime() -  self.starttime
		--MsgN("recorder.time ",time) 
		local ct=true 
		while ct do
			ct = false
			local nextevent = self.events[cid] 
			if nextevent then        
				if nextevent.t<=time then
					self:DoEvent(nextevent)
					self.lastevent = nextevent
					cid = cid + 1
					ct = true
				end
			else
				if self.ploop then
					self.starttime = CurTime()
					self.lastevent = self.events[1]
					cid = 1
				else
					MsgN("recorder.trackend")
					self:Stop() 
				end
			end
		end
	end) 
end
function meta_recorder:PlayLooped()
	self.ploop = true
	self:Play() 
end 
function meta_recorder:Save(fname)
	json.Write("output/records/"..fname..".rec",self)
end
function meta_recorder:Load(fname)
	local data = json.Read("output/records/"..fname..".rec")
	if data then
		self.events = { }
		for k,v in pairs(data) do
			if k~="ent" then
				self[k] = v
			end
		end
	end
end

meta_recorder.ev_use = function(actor)
	--if true then return nil end
	local maxUseDistance = 2
	local pos = actor:GetPos()
	local par = actor:GetParent()
	local sz = par:GetSizepower()
	local ents = par:GetChildren()
	local nearestent = false
	local ndist = maxUseDistance*maxUseDistance
	for k,v in pairs(ents) do
		if v~=actor and v:HasTag(TAG_USEABLE) then 
			local edist = pos:DistanceSquared(v:GetPos())*sz*sz 
			if edist<ndist and edist>0 then
				nearestent = v
				ndist = edist
			end
		end
	end
	if nearestent then
		nearestent:SendEvent(EVENT_USE,actor)
	end  
end

meta_recorder.ev_subPlay = function(actor,rec) 
	if rec then rec:Play() end
end
meta_recorder.ev_subStop = function(actor,rec) 
	if rec then rec:Stop() end
end

meta_recorder.__index = meta_recorder


function Recorder(ent)
	recorder = {events={ },starttime = CurTime(),ent = ent}
	setmetatable(recorder,meta_recorder)
	return recorder
end


function test33333()
	u:Close()

	u =  gui.FromTable({type='valuebar', 
			_sub_bar = {color= {0,1,1}},
			Value = 50
		})
	
	u:Show()  
	hook.Add(EVENT_GLOBAL_PREDRAW,"test343",function()
		u:Think() 
	end)
	debug.DelayedTimer(100,100,10,function()
		u:SetValue(u:GetValue()-1)   
	end)  
end