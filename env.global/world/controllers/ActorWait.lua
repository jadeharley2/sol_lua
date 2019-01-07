 

function OBJ:Init()  
	local cam = GetCamera()
	cam:SetUpdateSpace(true)
end
function OBJ:UnInit()  
	local cam = GetCamera()
	cam:SetUpdateSpace(false)
end
 
function OBJ:Update()   
	local p = LocalPlayer(true)
	if p and IsValidEnt(p) then
		SetController("actor")
	end
end

 