
function SpawnNodeAtView(type)
	local trace = GetCameraPhysTrace()
	local target = nil
	
	if trace and trace.Hit then
		local space = ents.Create()
		--space:SetLoadMode(1) 
		space:SetParent(trace.Node) 
		space:SetPos(trace.Position)
		space:SetSizepower(1000) 
		space:SetSpaceEnabled(false)
		space:Spawn()  

		engine.LoadNode(space, type)

		--if loaded

		for k,v in pairs(space:GetChildren()) do
			v:Eject()
		end

		return space
	end
end


console.AddCmd("snav",SpawnNodeAtView) 