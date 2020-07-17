

function ENT:Init()

    self.vox = self:RequireComponent(CTYPE_CVOX)
end

function ENT:Spawn()
    self.vox:InitVoxels()
end