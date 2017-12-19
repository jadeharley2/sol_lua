function GetCameraPhysTrace(cam,actorphys)
	cam = cam or GetCamera()
	local parentphysnode = cam:GetParentWithComponent(CTYPE_PHYSSPACE)
	if parentphysnode then
		local space = parentphysnode:GetComponent(CTYPE_PHYSSPACE)
		local lw = parentphysnode:GetLocalSpace(cam)
		
		local hit, hpos, hnorm, dist, ent = space:RayCast(lw:Position(),lw:Forward(),actorphys)
		return {Hit = hit,Position=hpos,Normal=hnorm,Distance = dist, Node = parentphysnode, Space = space,Entity = ent}
	end
	return nil
end
function GetNodesInRadius(space,pos,r,flagfilter,nodefilter)
	--flagfilter ent flag (number)
	--nodefilter node ignore table
	local result = {}
	local rsq = r*r
	for k,v in pairs(space:GetChildren()) do
		local dist = v:GetPos():DistanceSquared(pos)
		if dist<=rsq then
			if not nodefilter or not nodefilter[v] then 
				if not flagfilter or v:HasFlag(flagfilter) then 
					result[#result+1] = v 
				end
			end
		end
	end
	return result
end
function GetNearestNode(space,pos,flagfilter,nodefilter)
	--flagfilter ent flag (number)
	--nodefilter node ignore table
	local result = false
	local mindist = 9e30
	for k,v in pairs(space:GetChildren()) do
		local dist = v:GetPos():DistanceSquared(pos)
		if dist<mindist then
			if not nodefilter or not nodefilter[v] then 
				if not flagfilter or v:HasFlag(flagfilter) then  
					result = v 
					mindist = dist
				end
			end
		end
	end
	return result, math.sqrt(mindist)
end

function ent_create(type,data)
	local tr = GetCameraPhysTrace()
	if tr and tr.Hit then
		local ent = ents.Create(type)
		local sz = tr.Node:GetSizepower()
		ent:SetParent(tr.Node)
		ent:SetPos(tr.Position+tr.Normal*(1/sz))
		ent:Spawn()
	end
end