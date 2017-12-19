
_AI_chat = {}
hook.Add("chat.msg.received","airead",function(sender,text)  
	if sender and text then
		_AI_chat[#_AI_chat+1] = {f=sender,m=text}
	end 
end)

CND_ONRND = function(s,e,t)  
	return math.random(0,t.max or 100)<50
end
CND_ONCHAT = function(s,e,t)   
	s._aichc = s._aichc or 0
	if s._aichc<#_AI_chat then
		local lmsg = _AI_chat[#_AI_chat]
		if(t.msg)then
			for k,v in tableq(t.msg) do 
				if string.find(string.trim(lmsg.m),v) then  
					if e~=lmsg.f then
						s._aichc = #_AI_chat
						return true
					end
				end
			end
		else 
			s._aichc = #_AI_chat
			return true
		end
	end
	return false 
end

ACT_SETSENDERASTARGET = function(s,e,t) 
	local lmsg = _AI_chat[#_AI_chat] 
	if lmsg then s.target = lmsg.f end 
end
ACT_SAY = function(s,e,t) e:Say(t.say) end
ACT_JUMP = function(s,e,t) e:Jump() end
ACT_LOOKAT = function(s,e,t) e:EyeLookAtLerped(t.ent or s.target) end
ACT_ABILITY = function(s,e,t) 
	local ab = e.abilities
	local abid = t.aid or 1
	MsgN("abc",abid)
	if ab then
		local a1 = ab[abid] if a1 then a1:Cast(e) end
	end
end
ACT_MOVETO = function(s,e,t) 
	e:MoveTo(t.ent or s.target)
end
ACT_RANDMOVE = function(s,e,t) 
	local dd = math.random(1,4)
	if dd == 1 then
		e:Move(t.dir or Vector(1,0,0))
	elseif dd ==2 then
		e:Move(t.dir or Vector(-1,0,0))
	elseif dd ==3 then
		e:Move(t.dir or Vector(0,1,0))
	elseif dd ==3 then
		e:Move(t.dir or Vector(0,-1,0))
	end
	
	debug.Delayed(1000,function() e:Stop() end)
end 
function ai:OnInit() 
	MsgN("hi3!") 
	local greet = {"hi","hello","прив","привет"}
	local how = {"как дела"}
	self:AddReaction("greet",CND_ONCHAT,ACT_SAY,{msg=greet,say="привет"})
	self:AddReaction("greset",CND_ONCHAT,{ACT_SETSENDERASTARGET,ACT_LOOKAT},
		{msg={"f"} })
	self:AddReaction("how",CND_ONCHAT,ACT_SAY,{msg=how,say="нормально"})
	self:AddReaction("j",CND_ONCHAT,ACT_JUMP,{msg={"jump","прыг"} })
	self:AddReaction("j2",CND_ONRND,{ACT_SETSENDERASTARGET,ACT_LOOKAT},
		{msg={"fiv","фыв"}, max = 1000 })
	--self:AddReaction("j3",CND_ONRND,{ACT_SETSENDERASTARGET,ACT_MOVETO},
	--	{msg={"aaa","ddd"}, max = 1000 })
	self:AddReaction("cc1",CND_ONCHAT,ACT_ABILITY,{msg={"d1"}, aid = 1 })
	self:AddReaction("cc2",CND_ONCHAT,ACT_ABILITY,{msg={"d2"}, aid = 2 })
	self:AddReaction("cc3",CND_ONCHAT,ACT_ABILITY,{msg={"d3"}, aid = 3 }) 

end
 