 

function TOOL:OnSet()
	self.state = "idle" 
end   
--globt = globt or false
function TOOL:Fire(dir) 
    local user = self:GetParent() 

    local parentphysnode = user:GetParentWithComponent(CTYPE_PHYSSPACE)
    local lw = parentphysnode:GetLocalSpace(user) 
    local sz = parentphysnode:GetSizepower() 
   
    
    local lwp = user:GetPos()+Vector(0,1.4/sz,0) 
    local tr = self:Trace(lwp,dir)
    if tr and tr.Hit then
        local ang = tr.Normal:ToAngle()
        ang = Vector(ang.y,ang.z-90,-ang.x)
        local globt =--globt or 
         forms.Create("prop.active.gates.and",parentphysnode,{pos = tr.Position, ang = ang})
        --globt:SetPos(tr.Position)
        --globt:SetAng(ang)
    end
end

function TOOL:AltFire() 


end

function TOOL:Reload()

end

function TOOL:Draw()
    WireEditorOpen() 
end

function TOOL:Holster()
    WireEditorClose()
end
