stateevents = stateevents or {}

stateevents.Load = function (self, data)
    self._stateevents = data
end
function stateevents.Call(self, event, ...)
    local se = self._stateevents
    if se then
        local e = se[event]
        if e then
            stateevents.Run(self, e.actions)
        end 
    end
end
function stateevents.Run(self, actionblock)
    for k,v in ipairs(actionblock) do
        if v.op == 'sound' then
            self:EmitSound(v.type,1)
        elseif v.op == 'particle' then
            CALL(SpawnParticles,self,v.type,JVector(v.pos),v.time or 2,v.size or 1,v.speed or 1)
        end
    end
end
hook.Add("prop.variable.load","stateevents",function (self,j,tags)   
    if j.stateevents then 
        self._stateevents = j.stateevents
	end
end)
 