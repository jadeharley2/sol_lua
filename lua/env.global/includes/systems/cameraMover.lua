
cameramover = cameramover or {}



record = DEFINE_METATABLE("Record") 

function record:AddNode() 
    local curid = self.track:AddCurrentState()
    if self.lastid > 0 then
        self.track:Link(self.lastid,curid)
    end
    self.lastid = curid
end

 

function record:BeginPath() 
    self.lastid = 0
    self.track:Clear() 
end 
function record:EndPath(loop) 
    if loop then
        self.track:Link(self.lastid,1)
    end
    self.updater:SetPath(self.track,1,2,0)
end 
function record:Clear() 
    self.lastid = 0
    self.track:Clear() 
end

function record:Play(speed,continue)
    speed = speed or 1
	self.updater:SetOffsetAng(matrix.Identity())
    self.updater:SetOffsetPos(Vector(0,0,0)) 
    
    if not continue then self.updater:SetPath(self.track,1,2,0) end
    self.updater:SetEnabled(true) 
    self.updater:SetDamping(0)
    self.updater:SetSpeed(speed)
    self.updater:SetAngSlerp(0.03) 
    self.updater:SetUseOrientation(true)
    --hook.Add(EVENT_GLOBAL_PREDRAW,'camerarec',function()
    --    self:Think()
    --end)
end
function record:Pause() 
    self.updater:SetEnabled(false) 
    hook.Remove(EVENT_GLOBAL_PREDRAW,'camerarec')
end
function record:Stop() 
    self.updater:SetEnabled(false) 
    self.updater:SetPath(self.track,1,2,0)
    hook.Remove(EVENT_GLOBAL_PREDRAW,'camerarec')
end
function record:Save(fn) 
    self.track:Save(fn)
end
function record:Load(fn) 
    self.track:Load(fn)
end
function record:OnPathNode(id) 
    MsgN('reach',id)
end
function record:Think() 
    
end


record.__index = record

function cameramover.NewRecord(ent)
    local pth = ent:GetComponent(CTYPE_PATHFOLLOW) or ent:AddComponent(CTYPE_PATHFOLLOW) 
    local cpp = ent:GetComponent(CTYPE_PATH) or ent:AddComponent(CTYPE_PATH)
    local e = setmetatable({ent = ent,track = cpp,updater = pth},record)
    pth:SetOnReach(function(nodeid)
        e:OnPathNode(nodeid)
    end)
    return e
end