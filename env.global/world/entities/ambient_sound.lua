
function ENT:Init() 

	self:SetSpaceEnabled(false) 
end
function ENT:Spawn()
	self.snd = sound.Start("ambient/170515__devlab__forest-ambient-01-loop.wav",0.7)
end
function ENT:Despawn()
	local snd = self.snd
	if snd then snd:Stop() snd:Dispose()  self.snd = nil end
end