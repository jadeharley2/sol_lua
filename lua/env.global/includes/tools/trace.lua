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
function GetMousePhysTrace(cam,actorphys)
	cam = cam or GetCamera()
	local mpos = input.getInterfaceMousePos()+Vector(0,0,0.1)
	local wdir = cam:Unproject(mpos):Normalized()
	local parentphysnode = cam:GetParentWithComponent(CTYPE_PHYSSPACE)
	if parentphysnode then
		local space = parentphysnode:GetComponent(CTYPE_PHYSSPACE)
		local lw = parentphysnode:GetLocalSpace(cam)
		
		local hit, hpos, hnorm, dist, ent = space:RayCast(lw:Position(),wdir,actorphys)
		return {Hit = hit,Position=hpos,Normal=hnorm,Distance = dist, Node = parentphysnode, Space = space,Entity = ent}
	end
	return nil
end
--pos, dir = relative to node(inside space)
--dir = normalized
--maxlen = in node space lengths
function GetTracedLocalPos(node,pos,dir,maxlen,dirmul,actorphys)
	dirmul = dirmul or 1
	local parentphysnode = node:GetParentWithComponent(CTYPE_PHYSSPACE)
	if parentphysnode then
		local space = parentphysnode:GetComponent(CTYPE_PHYSSPACE)
		local lw = parentphysnode:GetLocalSpace(node)
		local lwdiff = parentphysnode:GetSizepower()/node:GetSizepower()
		 
		local wpos = pos:TransformC(lw)
		local wdir = dir:TransformN(lw)
		
		local hit, hpos, hnorm, dist, ent = space:RayCast(wpos,wdir,actorphys)
		--MsgN(ent)
		dist = dist*lwdiff* dirmul
		if dist < maxlen then 
			return pos + dir * dist 
		end 
	end
	return pos + dir*maxlen
end

function IsVisibleAround(node,target,actorphys)
	actorphys = actorphys or node.phys
	local parentphysnode = node:GetParentWithComponent(CTYPE_PHYSSPACE)
	if parentphysnode then
		local space = parentphysnode:GetComponent(CTYPE_PHYSSPACE)
		local lw = parentphysnode:GetLocalSpace(node)
		local lwdiff = parentphysnode:GetSizepower()/node:GetSizepower()
		
		local pos = node:GetPos()
		local pos2 = target:GetPos()
		local dir = pos2-pos
		
		--local wpos = pos:TransformC(lw)
		--local wdir = dir:TransformN(lw)
		
		local hit, hpos, hnorm, dist, ent = space:RayCast(pos,dir,actorphys)
		--MsgN(hit, hpos, hnorm, dist, ent)
		--debug.ShapeBoxCreate(100,node:GetParent(),matrix.Scaling(0.001)*matrix.Translation(hpos),Vector(1,0,0))
		if hit and ent == target then
			return true
		end
	end 
	return false
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
				if not flagfilter or v:HasTag(flagfilter) then 
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
				if not flagfilter or v:HasTag(flagfilter) then  
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