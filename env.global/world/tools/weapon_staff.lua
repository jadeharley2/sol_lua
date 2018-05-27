TOOL.nextfiretime = 0.5

function TOOL:OnSet() 
	self.state = "idle"
end 
function TOOL:ToLocal(node,pos)
	local w = self:GetLocalSpace(node)
	return pos:TransformC(w) 
end
function TOOL:Fire(dir)
	self.dir = dir
	local state = self.state
	--MsgN("state: ",state)
	if state == "idle" then
		local nft = self.nextfiretime
		local ct = CurTime()
		local fd = self.firedelay
		if ct > nft then 
			self.nextfiretime = ct + fd
			
			local user = self:GetParent()
			local aid = self.aid or 0
			aid = (aid + 1)%2
			self.aid = aid 
			user.model:SetAnimation("attack"..tostring(aid+1))
			 
		end
	elseif state == "hold" then
	end
end

function TOOL:AltFire() 
end

function TOOL:Reload()

end
 