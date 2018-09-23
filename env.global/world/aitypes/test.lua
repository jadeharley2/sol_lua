EVENT_CCOMMAND = 9999901
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

ACT_LOOKAT_RNDTRG = function(s,e,t) 
	local par = e:GetParent()
	local ted = false;
	local mindst=100;
	for k,v in pairs(par:GetChildren()) do
		local edist = v:GetDistanceSq(e);
		if edist<mindst then
			ted = v
			mindist = edist
		end
	end
	--MsgN("t:",ted)
	if ted then
		e:SendEvent(EVENT_LERP_HEAD,ted)
		--e:EyeLookAtLerped(ted) 
	end
end
ACT_ABILITY = function(s,e,t) 
	local ab = e.abilities
	local abid = t.aid or 1
	MsgN("abc",abid)
	if ab then
		local a1 = ab[abid] if a1 then a1:Cast(e) end
	end
end

hook.Add("umsg.test1234","aaa",function(s,e,t) 
	local button = Entity(231632412)
	if button then
		local eid = e:GetSeed()
		local eid2 = t:GetSeed()
		local com = [[
		local e = Entity(]]..tostring(eid)..[[)
		local tent = Entity(]]..tostring(eid2)..[[)
		local button = Entity(231632412)
		local move = Task("moveto",button,2) 
		move:Next(Task(function(T) USE(T.ent) return true end))
			:Next(Task("wait",2))
			:Next(Task(function(T) T.ent:SendEvent(EVENT_GIVE_ITEM,"tools.bow_kindred_gal") return true end)) 
			:Next(Task("moveto",tent,2))
		e:BeginTask(move)]]
		network.BroadcastLua(com)
	end
end)
ACT_TEST_PRESSBUTTON = function(s,e,t) 
	if network.IsConnected() then 
		network.CallServer("test1234",1,e,t.ent) 
	else
		local button = Entity(231632412)
		if button then
			local eid = e:GetSeed()  
			local button = Entity(231632412)
			local move = Task("moveto",button,2) 
			move:Next(Task(function(T) USE(T.ent) return true end))
				:Next(Task("wait",2))
				:Next(Task(function(T) T.ent:SendEvent(EVENT_GIVE_ITEM,"tools.bow_kindred_gal") return true end)) 
				:Next(Task("moveto",t.ent,2))
			e:BeginTask(move)
		end
	end
end

ACT_MOVETO = function(s,e,t) 
	--MsgN(e," s ",s," s.target ",s.target," t ",t," t.ent ",t.ent) 
	e:SendEvent(EVENT_TASK_BEGIN,"moveto",(s.target or t.ent),3)
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
	--self:AddReaction("j2",CND_ONRND,{ACT_SETSENDERASTARGET,ACT_LOOKAT},
	--	{msg={"fiv","фыв"}, max = 1000 })
	--self:AddReaction("j3",CND_ONRND,{ACT_SETSENDERASTARGET,ACT_MOVETO},
	--	{msg={"сюда","ddd"}, max = 1000 })
	
	self:AddReaction("jd3",CND_ONRND,ACT_LOOKAT_RNDTRG, {max = 1000 })
	
	self:AddReaction("cc1",CND_ONCHAT,ACT_ABILITY,{msg={"d1"}, aid = 1 })
	self:AddReaction("cc2",CND_ONCHAT,ACT_ABILITY,{msg={"d2"}, aid = 2 })
	self:AddReaction("cc3",CND_ONCHAT,ACT_ABILITY,{msg={"d3"}, aid = 3 }) 
	self:AddReaction("aa-1",CND_ONCHAT,ACT_SAY,{msg={"киндред","kindred"},say="что?"})
	
	local e = self.ent
	e:AddFlag(FLAG_USEABLE)
	e:AddFlag(FLAG_NPC)
	e:RemoveFlag(FLAG_PLAYER)
	local char = e:GetParameter(VARTYPE_CHARACTER) or ""
	local cpath, cname = forms.GetForm("character",char)-- json.Read("forms/characters/"..char..".json")
	if cname then e:SetName(cname) end
	e.usetype = "talk"
	e:AddEventListener(EVENT_USE,"e",function(s,user)
		--if self:Alive() then
			self:OpenMenu(user)
		--end
	end)  
	e:AddEventListener(EVENT_CCOMMAND,"e",function(s,user,com)
		--if self:Alive() then
			self:OpenMenu(user)
		--end
	end) 
	
	self.seen = Set()
end
function ai:OnUpdate()
	local e = self.ent
	local ee = e.eyeangles
	if ee then
		e:SetEyeAngles(ee[1],ee[2]) 
	end 
	--MsgN("upd:",self)
end 
local phrases = {
	agreement = {"хорошо", "ладно", "ок", "угу", "ага"},
}
function ai:OpenMenu(ply)
	if self.dialog then
		self.dialog:Close()
		self.dialog = nil
	end
	if CLIENT and self.dialog == nil then
		local e = self.ent 
		if e then
			MsgN("asd",e,ply)
			e:SendEvent(EVENT_LERP_HEAD,ply)
			ply:SendEvent(EVENT_LERP_HEAD,e)
			--ply:EyeLookAtLerped(e)
			if  ply == LocalPlayer()  then
				local p = panel.Create("window_npc_dialog")  
				--p:Init(e:GetName(),300,500)
				
				local greettext= "Что тебе нужно?";
				if not self.seen:Contains(ply) then
					self.seen:Add(ply)
					greettext = "Привет. ".. greettext
				end
				self.task = nil
				self.target = ply
				
				p:SetPos(0,-400) 
				p:Start(self,e:GetName())
				
				local main = {
					{t="Как дела?",f=function(ai,dialog) 
						dialog:Open("Нормально. А у тебя?",
						{
							{t="Хорошо",f= function() dialog:Open("норм") end},
							{t="Средне",f= function() dialog:Open("хех") end},
							{t="Плохо",f= function() dialog:Open(":(") end},
						})
						return true;
					end},
				}
				if self.ftask then
					main[#main+1] =
					{t="Стой тут",f=function(ai,dialog) 
						ai.ftask = nil
						if ai.ftask and ai.ftask.Abort then ai.ftask:Abort() end
						e:SendEvent(EVENT_TASK_RESET)
						dialog:Open(table.Random(phrases.agreement))
						e:Stop()
						return false
					end}
				else 
					main[#main+1] =
					{t="Иди за мной",f=function(ai,dialog)  
						ai.ftask = true
						e:SendEvent(EVENT_TASK_BEGIN,"follow",ai.target,2)
						dialog:Open(table.Random(phrases.agreement))
						return false
					end}
					main[#main+1] =
					{t="гуляй",f=function(ai,dialog)  
						ai.ftask =true
						e:SendEvent(EVENT_TASK_BEGIN,"wander")
						dialog:Open(table.Random(phrases.agreement))
						return false
					end}
				end
				
				if e:HasTool("bow_kindred_gal") then
					if self.atask then
						main[#main+1] =
						{t="Хватит",f = function(ai,dialog)
							ai.atask = nil
							if ai.atask and ai.atask.Abort then ai.atask:Abort() end
							e:SendEvent(EVENT_TASK_RESET)
							dialog:Open(table.Random(phrases.agreement))
							return false
						end}
					else
						main[#main+1] =
						{t="Атакуй меня",f = function(ai,dialog)
							ai.atask = true
							e:SendEvent(EVENT_TASK_BEGIN,"attack",ai.target)
							
							dialog:Open(table.Random(phrases.agreement))
							return false
						end}
					end
				else
					main[#main+1] =
					{t="Возьми оружие",f = function(ai,dialog)
						if e:HasTool("bow_kindred_gal") then
							dialog:Open("у меня уже есть. не видишь?")
						else
							dialog:Open(table.Random(phrases.agreement).." сейчас")
							ACT_TEST_PRESSBUTTON(ai,e,{ent = ply})
						end
						return false
					end}
				end
				
				
				p:Open(greettext,main)
				self.dialog = p
				--[[
				
				local bcol = Vector(83,164,255)/255
				local pcol = Vector(0,0,0)
				
				local label = panel.Create()
				label:SetText("Привет. Что тебе нужно?")
				label:SetTextAlignment(ALIGN_CENTER)
				label:SetSize(400,20)
				label:SetPos(0,100) 
				label:SetTextColor(bcol)
				label:SetColor(pcol)
				--label:SetAlpha(0.7)
				label:SetTextOnly(true)
				p:Add(label)
		 
				local opt = {}
				local bopt = panel.Create("button")
				bopt:SetText("Иди за мной")
				bopt:SetSize(300,20)
				bopt:SetPos(0,0+25)
				p:SetupStyle(bopt)
				bopt.OnClick = function() 
					for k,v in pairs(opt) do p:Remove(v) end
					label:SetText("Хорошо.") 
					self.target = ply
					self:AddReaction("j3",CND_ONRND,{ACT_MOVETO}, { max = 300 })
					debug.Delayed(1000,function() p:Close() self.dialog = nil  BLOCK_MOUSE = false  end)
				end
				p:Add(bopt)
				opt[#opt+1] = bopt
				
				local bopt = panel.Create("button")
				bopt:SetText("Стой здесь")
				bopt:SetSize(300,20)
				bopt:SetPos(0,0-25)
				p:SetupStyle(bopt)
				bopt.OnClick = function() 
					for k,v in pairs(opt) do p:Remove(v) end
					label:SetText("Хорошо.")
					self.consys["j3"]  = nil
					 
					debug.Delayed(1000,function() p:Close() self.dialog = nil BLOCK_MOUSE = false end)
					
				end
				p:Add(bopt)
				opt[#opt+1] = bopt
				]]
				BLOCK_MOUSE = true 
			end
		else
			MsgN("wat?",e)
		end
	end
end
 