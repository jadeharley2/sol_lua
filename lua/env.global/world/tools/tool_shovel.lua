 

function TOOL:OnSet()
	self.state = "idle"
	
end  
function TOOL:LoadGraph()

	local graph = BehaviorGraph(self,tab) 
	self.graph = graph
 
	local data = self.data 

	local hdt = data.appearance.holdtype  
	graph:NewState("idle",function(s,e) e:GetParent().model:PlayLayeredSequence(1,hdt.idle,hdt.model) end)
	graph:NewState("fire",function(s,e) 
		local owner = e:GetParent()
		owner.model:PlayLayeredSequence(1,hdt.fire,hdt.model) 
		owner.nomovement = true
		owner.norotation = true
		return hdt.fire_duration or 1
	end)
	graph:NewState("fireend",function(s,e) 
		local owner = e:GetParent() 
		owner.nomovement = false
		owner.norotation = false
		if data.resource then owner:Give(data.resource) end
		return 0
	end)
	graph:NewTransition("idle","fire",BEH_CND_ONCALL,"fire")
	graph:NewTransition("fire","fireend",BEH_CND_ONEND)
	graph:NewTransition("fireend","idle",BEH_CND_ONEND)

	graph:SetState("idle") 
end
function TOOL:Fire(dir) 
	local nft = self.nextfiretime
	local ct = CurTime()
	local fd = self.firedelay
	--MsgN("fired")
	if ct > nft then 
		self.nextfiretime = ct + fd 
		self.graph:Call("fire") 
		return true
	else
		return false
	end
end

function TOOL:AltFire() 
end

function TOOL:Reload()

end

