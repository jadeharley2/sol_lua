if SERVER then

	function swap(id1,id2) 
		local plys = player.GetList()
		local p1 = plys[id1]
		local p2 = plys[id2]
		if p1 and p2 then
			p1.client:SendLua(" TACTOR.isswapped = true TACTOR = ents.GetById("..tostring(120000+id2)..") TACTOR:SetGlobalName('player') SetController('actorcontroller') TACTOR.isswapped = true")
			p2.client:SendLua(" TACTOR.isswapped = true TACTOR = ents.GetById("..tostring(120000+id1)..") TACTOR:SetGlobalName('player') SetController('actorcontroller') TACTOR.isswapped = true")
			p1.actor.player = p2.client
			p2.actor.player = p1.client
			local mactor = p1.actor
			local p1name = p1.client:GetName()
			local p2name = p2.client:GetName()
			p1.actor = p2.actor
			p2.actor = mactor
			p1.client:AssignNode(p1.actor)
			p2.client:AssignNode(p2.actor)
			p1.client:SetTag(VARTYPE_NAME,p2name)
			p2.client:SetTag(VARTYPE_NAME,p1name)
			p1.actor.isswapped = not p1.actor.isswapped
			p2.actor.isswapped = not p2.actor.isswapped
		else
			MsgN("playernotfound: ",p1," , ", p2)
		end
	end
	function swap2(id1,id2)
		swap(id1,id2)
		local plys = player.GetAll()
		local p1 = plys[id1]
		local p2 = plys[id2]
		if p1 and p2 then
		p1.client:SendLua("local bc = ents.GetById("..tostring(120000+id1)..") TACTOR:SetPos(bc:GetPos()) ")
		p2.client:SendLua("local bc = ents.GetById("..tostring(120000+id2)..") TACTOR:SetPos(bc:GetPos()) ")
		end
	end
	MsgN("sw load")
else
 
	function swap()
		if not LocalPlayer() or not TM2 then return false end
		SetController('freecameracontroller')
		local cc = LocalPlayer()
		SetLocalPlayer(TM2)
		TM2 = cc
		SetController('actorcontroller')
		return true
	end
end
--data/lua/env.global/autorun/swtest.lua