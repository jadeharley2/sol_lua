tempvars = tempvars or {}

function tempvars.DoorUse(s,user)  
	--if s.ismoving  then return false end
	MsgN(s,user,s.flatnum)
	--s.model:SetDynamic()
	local direction = s.direction or 1
	if s.doorstate  then
		s.doorstate =false
		s.ismoving = true
		s.model:ResetAnimation("close")
		s:RotateToAdd(Vector(0,1,0),math.pi/2*direction,0.3)--:Next(function ()
		--	s.ismoving = false
		--end)
		--s.coll:Enable(true)
		if s.flatnum then
			s:Delayed("f",1000,function()
				s:GetParent().procgen:Collapse(s.flatnum)
			end)
		end
	else
		if s.flatnum then
			s:GetParent().procgen:Expand(s.flatnum)
		end
		s.doorstate =true
		s.ismoving = true
		s:RotateToAdd(Vector(0,1,0),-math.pi/2*direction,0.3)--:Next(function ()
		--	s.ismoving = false
		--end)
		s:Delayed("f",50,function()
			s.model:ResetAnimation("open")
			--s.coll:Enable(false)
		end)
	end 
	if CLIENT then
	--	s:EmitSound("door/door_wood_close.ogg",1)
	end
end


hook.Add("prop.variable.load","door",function (self,j,tags) 
    if j.door then 
		self.info = "door" 
		self:SetUpdating(true)
 
		self:AddInteraction("opendoor",{text="open",action=function(...) tempvars.DoorUse(...) end})

		self.model:SetDynamic()
		self.model:SetAnimation('idle')
		self.model:ForceUpdate()
		self.doorstate = false
		local wio = self:RequireComponent(CTYPE_WIREIO)
		wio:AddOutput("out")
	end
end)






