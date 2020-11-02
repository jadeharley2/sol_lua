
local TASK_META = TASK_META or {}
 
function TASK_META:Next(task,key) 
	self.next = self.next or {}
	if key then
		self.next[key] = task
	else
		self.next[#self.next+1] = task
	end
	return task
end
function TASK_META:Success(task,key) 
	self.success = self.success or {}
	if key then
		self.success[key] = task
	else
		self.success[#self.success+1] = task
	end
	return task
end
function TASK_META:Fail(task,key)
	self.fail = self.fail or {}
	if key then
		self.fail[key] = task
	else
		self.fail[#self.fail+1] = task
	end
	return task
end
function TASK_META:Abort()
	self.manager:Abort(self)
end
function TASK_META:IsFinished()
	return self._finished == true
end
function TASK_META.__tostring(self)
	return  "Task("..tostring(self._name)..") "..tostring(self.Duration)
end
local task_class = DefineClass("Task","task","lua/env.global/world/tasks/",TASK_META)
  
function Task(type,...) 
	if isfunction(type) then
		local t = {Step=type,_base=TASK_META}
		setmetatable(t,TASK_META)
		return t
	elseif istable(type) then
		local t = type
		t._base=TASK_META
		setmetatable(t,TASK_META)
		return t 
	else
		local t = task_class:Create(type)
		t:Setup(...)
		return t 
	end 
end 

local TASKMANAGER_META = DEFINE_METATABLE("TaskManager")

function TASKMANAGER_META:Init(ent)
	self.ent = ent
	self.thread = self:CreateThread()
	ent._taskmanager = self
end
function TASKMANAGER_META:HasTasks() 
	for k,v in pairs(self.current) do
		return true
	end
	return false
end
function TASKMANAGER_META:Begin(task,enqifrunning)
	if getmetatable(task) ~= TASK_META then
		for k,v in pairs(task) do
			self:AddSingle(v,enqifrunning)
		end
	else 
		self:AddSingle(task,enqifrunning)
	end
	return task
end

function TASKMANAGER_META:AddSingle(task,enqifrunning)
	task.manager = self
	task.ent = self.ent
	if not task.OnBegin or task:OnBegin() then 
		if task.Duration then
			task.endtime = CurTime() + task.Duration
		end
		if task.slot then
			if enqifrunning then
				local nt = self.current[task.slot]
				if nt then
					nt:Next(task)
				else
					self.current[task.slot] = task
				end
			else
				self.current[task.slot] = task
			end
		else
			self.current[task] = true
		end
	end  
end
function TASKMANAGER_META:Abort(task) 
	if task.slot then
		self.current[task.slot] = nil 
	else
		self.current[task] = nil
	end
end
function TASKMANAGER_META:AbortAll(task) 
	self.current = {}
end
function TASKMANAGER_META:End(task) 
	if task.slot then
		local t = self.current[task.slot] 
		if t and t.OnEnd then t:OnEnd('forced') end
		self.current[task.slot] = nil 
	else
		local t = self.current[task] 
		if t and t.OnEnd then t:OnEnd('forced') end
		self.current[task] = nil
	end
end

function TASKMANAGER_META:RunLoop()
	local ctasks = self.current
	if ctasks then
		for k,v in pairs(ctasks) do
			
			local task = v
			if istable(k) then
				task = k
			end
			
			if task.endtime then
				if CurTime()>task.endtime then
					if task.OnEnd then task:OnEnd(result,rtype) end
					task._finished = true
					self.current[k] = nil
					self:FinishTask(task,true)
					return true
				end
			end
			if not task.Step and not task.endtime then
				MsgN("malformed task ",task)
				self.current[k] = nil 
				return true
			elseif task.errored then
				MsgN("errored task ",task)
				self.current[k] = nil 
				return true
			else
				task.times = (task.times or 0) + 1
				task.errored = true
				local result, rtype = task:Step()
				task.errored = nil
				if result ~=nil then
					if task.OnEnd then task:OnEnd(result,rtype) end
					task._finished = true
					self.current[k] = nil
					self:FinishTask(task,result,rtype)
					return true
				end
			end
		end
	end
end
function TASKMANAGER_META:FinishTask(task,result,rtype)
	if result then 
		if task.success then 
			if rtype and task.success[rtype] then
				self:Begin(task.success[rtype])
			else
				self:Begin(task.success)
			end 
		end
	else 
		if task.fail then 
			if rtype and task.fail[rtype] then
				self:Begin(task.fail[rtype])
			else
				self:Begin(task.fail)
			end
		end
	end
	if task.next then 
		if rtype and task.next[rtype] then
			self:Begin(task.next[rtype])
		else
			self:Begin(task.next)
		end 
	end
end


local onerror = function(err)
	MsgN("task error:",err)  
	MsgN(debug.traceback())
end
function TASKMANAGER_META:CreateThread()
	return coroutine.create(function()
		while(true) do
			xpcall(self.RunLoop,onerror,self)
			coroutine.yield()
		end
	end)
end

function TASKMANAGER_META:Update()
	local thread = self.thread
	if thread then 
		if ( coroutine.status( thread ) == "dead" ) then
			self.thread = self:CreateThread()
			MsgN("Thread Restarted")
			return 
		end
		local ok, message = coroutine.resume(thread, self )
		if ( ok == false ) then 
			ErrorNoHalt( self, " Error: ", message, "\n" ) 
			self.thread = nil 
		end  
	else 
		self.thread = self:CreateThread()
		MsgN("Thread Restarted")  
	end
end 
		


TASKMANAGER_META.__index = TASKMANAGER_META

function TaskManager(ent) 
	local tm = {current={}}
	setmetatable(tm,TASKMANAGER_META)
	tm:Init(ent)
	return tm 
end 

console.AddCmd("listtasks",function ()
	local actor = LocalPlayer().viewEntity
	if IsValidEnt(actor)  then
		local tm = actor._taskmanager or actor.tmanager 
		if tm then
			PrintTable(tm.current)
		end
	end
end)
console.AddCmd("task_start",function (arg)
	local actor = LocalPlayer()
	if IsValidEnt(actor)  then
		local tm = actor._taskmanager or actor.tmanager 
		if tm then
			local tt = Task(arg)
			if tt then
				tm:Begin(tt)
			else
				MsgN("error while creating task",arg)
			end
		end
	end
end)
console.AddCmd("task_abortall",function (arg)
	local actor = LocalPlayer()
	if IsValidEnt(actor)  then
		local tm = actor._taskmanager or actor.tmanager 
		if tm then
			tm:AbortAll()
		end
	end
end)
 
  

            
--debug.AddAPIInfo("/userclass/Task",{
--	AddReaction={_type="function",_arguments={
--		{_name="id",_valuetype="number|string"},
--		{_name="condition",_valuetype="function"},
--		{_name="action",_valuetype="function"},
--		{_name="tag",_valuetype="any"},
--	}},
--	React={_type="function",_returns={{_valuetype="boolean"}}},
--	Init={_type="function"},
--	Update={_type="function"},
--	RunTaskStep={_type="function"},
--})