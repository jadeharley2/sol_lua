 
global_player_await_id =global_player_await_id or false

function OBJ:Init()  
	local cam = GetCamera()
	cam:SetUpdateSpace(true)
end
function OBJ:UnInit()  
	local cam = GetCamera()
	cam:SetUpdateSpace(false)
end
 
function OBJ:Update()   
	if global_player_await_id then
		local awp = Entity(global_player_await_id) 
		if IsValidEnt(awp) and IsValidEnt(awp:GetParent()) then 
			SetLocalPlayer(awp)
			SetController("actor")
			global_player_await_id=false
		end
	else
		local p = LocalPlayer(true)
		if p and IsValidEnt(p) then
			SetController("actor")
		end
	end
end

 