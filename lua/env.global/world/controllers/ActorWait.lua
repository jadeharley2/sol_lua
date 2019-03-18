 
global_player_await_id = false

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
		if p and IsValidEnt(p) then
			SetLocalPlayer(p)
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

 