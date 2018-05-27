
local AI_META = AI_META or {}

function AI_META:AddReaction(id,condition,action,tag)
	self.consys = self.consys or {}
	self.consys[id] = {condition,action,tag}
end       
function AI_META:React() 
	if self.consys then    
		for k,v in pairs(self.consys) do
			local condition = v[1]
			local action = v[2]
			local tag = v[3]
			local istrue = true
			if istable(condition) then
				for c,c2 in pairs(condition) do
					if not c2(self,self.ent,tag) then 
						istrue = false
					end 
				end     
			else       
				if not condition(self,self.ent,tag) then istrue = false end
			end       
			if istrue then
				if istable(action) then
					for c,c2 in pairs(action) do
						c2(self,self.ent,tag)
					end
				else     
					local rtime = 300 
					debug.Delayed(rtime,function()
						action(self,self.ent,tag)
					end) 
					return true
				end 
			end
		end
	end
end

function AI_META:Init()
	if self.OnInit then self:OnInit() end
end
function AI_META:Update()
	if self.OnUpdate then self:OnUpdate() end 
	self:React()
	self:RunTaskStep()
end    
function AI_META:RunTaskStep()
	local task = self.task
	if task then  
		if ( coroutine.status( task ) == "dead" ) then
			self.task = nil 
			return 
		end
		local ok, message = coroutine.resume(task, self )
		if ( ok == false ) then 
			ErrorNoHalt( self, " Error: ", message, "\n" ) 
			self.task = nil 
		end  
	end
end 
local ai_class = DefineClass("Ai","ai","lua/env.global/world/aitypes/",AI_META)
    
function Ai(type,ent) 
	local ai = ai_class:Create(type)
	ai.ent = ent
	ai:Init()
	return ai 
end 
  

local AI_TASK_META = AI_TASK_META or {}
  

            
debug.AddAPIInfo("/userclass/Ai",{
	AddReaction={_type="function",_arguments={
		{_name="id",_valuetype="number|string"},
		{_name="condition",_valuetype="function"},
		{_name="action",_valuetype="function"},
		{_name="tag",_valuetype="any"},
	}},
	React={_type="function",_returns={{_valuetype="boolean"}}},
	Init={_type="function"},
	Update={_type="function"},
	RunTaskStep={_type="function"},
})