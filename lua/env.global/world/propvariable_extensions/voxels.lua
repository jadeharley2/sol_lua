
 
hook.Add("prop.variable.load","voxels",function (self,j,tags)  
    
    local v = j.voxels 
    if v then
        self.vox = self:RequireComponent(CTYPE_CVOX) 
        if v.dynamic then
            self.vox:InitDynamic(v.radius)
        else 
            self.vox:InitStatic(unpack(v.size or {4,4,4}))
        end
         
    end
end) 