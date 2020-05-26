
task.slot = "movement_head"
task.delaytime = 10
task.bannedents = {}

function task:Setup(target,duration) 
    self.target = target
    self.Duration = duration
	return true
end 
function task:OnBegin()   
    if IsValidEnt(self.target) then
        return true
    end
end 
function task:Step() 
    local actor = self.ent
    local target = self.target
    actor:SendEvent(EVENT_LERP_HEAD,target)
end
function task:OnEnd(result) 
    if result == 'forced'then
        self.ent:SendEvent(EVENT_LERP_HEAD)
    end
end