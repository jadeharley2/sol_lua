
 
hook.Add("prop.variable.load","voxels",function (self,j,tags)   
    if j.voxels then
        self.vox = self:RequireComponent(CTYPE_CVOX) 
        self.vox:InitVoxels(unpack(j.voxels.size or {4,4,4}))
         
    end
end)