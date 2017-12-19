TSNODE = false

--function ENT:Init()  
--end
--function ENT:Spawn() 
--end
function ENT:Enter()
	--local debugwhite = "textures/debug/white.json"
	--for k=1,100 do
	--	local pos = Vector(math.random(-100000,100000)/100000,0,math.random(-100000,100000)/100000)
	--	SpawnSO("debris/rock01.smd",self,pos,0.75).model:SetMaterial(debugwhite) 
	--	
	--end
	--TSNODE = self
	render.SetGroupMode(RENDERGROUP_CURRENTPLANET,RENDERMODE_ENABLED) 
end
function ENT:Leave()
	if TSNODE == self then
		TSNODE = false
	end
	render.SetGroupMode(RENDERGROUP_CURRENTPLANET,RENDERMODE_BACKGROUND) 
end

function ENT:GetElevation()
	
end


function GETPOS()
	local c = GetCamera()
		MsgN("sadsad")
	if TSNODE then
		local surf, part = c:GetParentWithComponent(CTYPE_PARTITION2D)
		MsgN("asd")
		if(surf and part) then
			local pos = surf:GetLocalCoordinates(c)
			local chunk = part:GetSurfacePos(TSNODE,pos)
		end
	end
end