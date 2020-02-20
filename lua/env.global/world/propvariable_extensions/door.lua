local function DoorUse(s,user)  
	MsgN(s,user,s.flatnum)
	if s.flatnum then
		if s.doorstate  then
			s.doorstate =false
			s.model:ResetAnimation("close")
			s.coll:Enable(true)
			s:Delayed("f",1000,function()
				s:GetParent().procgen:Collapse(s.flatnum)
			end)
		else
			s:GetParent().procgen:Expand(s.flatnum)
			s.doorstate =true
			s:Delayed("f",50,function()
				s.model:ResetAnimation("open")
				s.coll:Enable(false)
			end)
		end
	end
	if CLIENT then
	--	s:EmitSound("door/door_wood_close.ogg",1)
	end
end


hook.Add("prop.variable.load","door",function (self,j,tags) 
    if j.door then 
		self.usetype = "use door"
		self:AddTag(TAG_USEABLE)
		self:AddEventListener(EVENT_USE,"a",DoorUse)
		self:SetNetworkedEvent(EVENT_USE,true)
		self:SetUpdating(true)
		self.model:SetDynamic()
		self.model:SetAnimation('idle')
		self.model:ForceUpdate()
		self.doorstate = false
		local wio = self:AddComponent(CTYPE_WIREIO)
		wio:AddOutput("out")
	end
end)