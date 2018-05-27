
task.slot = "movement"

function task:Setup(target)
	self.target = target 
	return true
end 
function task:OnBegin() 
	return true
end 
function task:Step() 
	local actor = self.ent 
	local target = self.target 
	 
	local parent = actor:GetParent()
	local sz = parent:GetSizepower()
	local LW = actor:GetLocalSpace(parent)
	local positionCurrent = actor:GetPos()
	local positionTarget = target:GetPos() 
	if target then
		local dir =  ((positionTarget-positionCurrent)*sz):TransformN(LW)
		  
		local Up = actor:Up():Normalized()
		local rad, polar,elev = actor:GetHeadingElevation(-dir) 
		local drf = polar/ 3.1415926 * 180  
		actor:TRotateAroundAxis(Up, (-drf)/200) 
	end
end
function task:OnEnd(result)
	
end