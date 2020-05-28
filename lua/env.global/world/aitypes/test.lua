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
CND_ONIDLE = function(s,e,t)  
	return (not s.dialog or not s.dialog:IsOpened()) and not e:HasTasks() and math.random(0,t.max or 100)<50
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
ACT_LOOKAT = function(s,e,t) 
	e:EyeLookAtLerped(t.ent or s.target) 
end
ACT_PICKUPA = function(s,e,t)	
	e:PickupNearest() 
end
ACT_LOOKAT_RNDTRG = function(s,e,t) 
	local par = e:GetParent()
	local ted = false;
	local mindst=100;
	local ted = table.Random(par:GetChildren())
	if ted and ted~=e then
		local tclass = ted:GetClass()
		if string.find(tclass,"actor") then -- or string.find(tclass,"prop") then
	--for k,v in pairs(par:GetChildren()) do
	--	local edist = v:GetDistanceSq(e);
	--	if edist<mindst then
	--		ted = v
	--		mindist = edist
	--	end
	--end
	--MsgN("t:",ted)
			if ted then
				e:SendEvent(EVENT_LERP_HEAD,ted)
				--MsgN(">>",ted)
				--e:EyeLookAtLerped(ted) 
			end
		end
	end
end
ACT_LOOKAT_IDLING = function(s,e,t) 
	
	--if s.pai then return end
	--local par = e:GetParent()
 --
	--	local ted = false;
	--	for k,v in pairs(par:GetChildren()) do
	--		if v~=e and v and IsValidEnt(v) then
	--			local cls = v:GetClass()
	--			if string.find(cls,"actor") then
	--				ted = v
	--			end 
	--		end
	--	end
	--	
	--	if ted then
	--		e:SendEvent(EVENT_LOOK_AT,ted)
	--		--MsgN(">>",ted) 
	--	end 
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

console.AddCmd("trade",function() 
	local ply = LocalPlayer()
	local e = GetCameraPhysTrace(GetCamera(),ply.phys)
	if e and IsValidEnt(e.Entity) and e.Entity:GetClass()=="base_actor" then
		actor_panels.OpenInventory(ply,ALIGN_BOTTOM,nil)
		actor_panels.OpenCharacterInfo(ply,ALIGN_LEFT,nil) 
		actor_panels.OpenInventory(e.Entity,ALIGN_TOP,nil)
		actor_panels.OpenCharacterInfo(e.Entity,ALIGN_RIGHT,nil) 
	end
end)
 
function ai:OnInit() 
	MsgN("hi3!",self.cname) 
	local greet = {"hi","hello"}
	local how = {"как дела"}
	self:AddReaction("greet",CND_ONCHAT,ACT_SAY,{msg=greet,say="hi"})
	self:AddReaction("greset",CND_ONCHAT,{ACT_SETSENDERASTARGET,ACT_LOOKAT},
		{msg={"f"} })
	self:AddReaction("how",CND_ONCHAT,ACT_SAY,{msg=how,say="ok"})
	self:AddReaction("j",CND_ONCHAT,ACT_JUMP,{msg={"jump"} })
	--self:AddReaction("j2",CND_ONRND,{ACT_SETSENDERASTARGET,ACT_LOOKAT},
	--	{msg={"fiv","фыв"}, max = 1000 })
	--self:AddReaction("j3",CND_ONRND,{ACT_SETSENDERASTARGET,ACT_MOVETO},
	--	{msg={"сюда","ddd"}, max = 1000 })
	
	self:AddReaction("jd3",CND_ONIDLE,ACT_LOOKAT_IDLING, {max = 100 })
	
	self:AddReaction("cc1",CND_ONCHAT,ACT_ABILITY,{msg={"d1"}, aid = 1 })
	self:AddReaction("cc2",CND_ONCHAT,ACT_ABILITY,{msg={"d2"}, aid = 2 })
	self:AddReaction("cc3",CND_ONCHAT,ACT_ABILITY,{msg={"d3"}, aid = 3 }) 
	self:AddReaction("aa-1",CND_ONCHAT,ACT_SAY,{msg={ "kindred"},say="what?"})
	
	local e = self.ent
	--ENT.usetype = "sit"
	
	e:AddTag(TAG_USEABLE)
	e:AddTag(TAG_NPC)
	e:RemoveTag(TAG_PLAYER)
	local char = e:GetParameter(VARTYPE_CHARACTER) or ""
	local cpath, cname = self.cname or  forms.GetForm("character",char)-- json.Read("forms/characters/"..char..".json")
	self.cname = cname
	if cname then e:SetName(cname) end
	
	e.info = self.name
	e._interact = {
		talk={text="talk",
		action = function (s,user) 
			self:OpenMenu(user)
		end},
	}
	
	self.seen = Set()
end
function ai:OnUpdate()
	--local e = self.ent
	--local ee = e.eyeangles
	--if ee then
	----	e:SetEyeAngles(ee[1],ee[2]) 
	----e:SetEyeAngles(0,0)
	--end 
	----MsgN("upd:",self)
end 
local phrases = {
	agreement = {  "Ok"},--"Good","I'll do this",, ""
}
function ai:OpenMenu(ply)
	if self.dialog then
		self.dialog:Close() 
		self.dialog = nil
	end
	if CLIENT and self.dialog == nil then
		local e = self.ent 
		if e then 
			if e:GetUpdating() then
				e:SendEvent(EVENT_LERP_HEAD,ply)
				ply:SendEvent(EVENT_LERP_HEAD,e)
				--ply:EyeLookAtLerped(e)

				local greettext= "Need something?";
				if not self.seen:Contains(ply) then
					self.seen:Add(ply)
					greettext = "Hello. ".. greettext
					facecontroller.Mood(e,MOOD_SURPRISED,0.5,0.5)
				else 
					facecontroller.Mood(e,MOOD_HAPPY,0.5)
					greettext = table.Random({"Yes?","Need something?","Hm?","Im listening"})
				end
				self.task = nil
				self.target = ply

				if ply == LocalPlayer()  then
					local p = panel.Create("window_npc_dialog")  
					--p:Init(e:GetName(),300,500)
					
					p:SetPos(0,-400) 
					p:Start(self,e:GetName())
					
					local main = {
						{t="How are you?",f=function(ai,dialog) 
							dialog:Open("Im fine. You?",
							{
								{t="Good",f= function() dialog:Open("That's good") facecontroller.Mood(e,MOOD_HAPPY,0.5) end},
								{t="Ok",f= function() dialog:Open("*sigh*") facecontroller.Mood(e,MOOD_NEUTRAL) end},
								{t="Bad",f= function() dialog:Open(":(") facecontroller.Mood(e,MOOD_SAD,0.5) end},
							})
							return true;
						end},
					}
					if self.ftask then
						main[#main+1] =
						{t="Wait here",f=function(ai,dialog) 
							ai.ftask = nil
							if ai.ftask and ai.ftask.Abort then ai.ftask:Abort() end
							e:SendEvent(EVENT_TASK_RESET)
							dialog:Open(table.Random(phrases.agreement))
							e:Stop()
							e:ResetTM()
							return false
						end}
					else 
						main[#main+1] =
						{t="Follow me",f=function(ai,dialog) 
							if e:GetVehicle() then e:SendEvent(EVENT_EXIT_VEHICLE) end 
							ai.ftask = true
							e:SendEvent(EVENT_TASK_BEGIN,"follow",ai.target,2)
							dialog:Open(table.Random(phrases.agreement)) 
							return false
						end}
						main[#main+1] =
						{t="You can go",f=function(ai,dialog)  
							if e:GetVehicle() then e:SendEvent(EVENT_EXIT_VEHICLE) end 
							ai.ftask =true
							e:SendEvent(EVENT_TASK_BEGIN,"wander")
							dialog:Open(table.Random(phrases.agreement))
							return false
						end}
						
					end
					
					main[#main+1] =
					{t="Pick up",f=function(ai,dialog)   
						dialog:Close()
						
						if e:PickupNearest() and CLIENT then
							GetCamera():SetParent(e) 
						end
						return false
					end}  

					if e:GetVehicle() then 
						main[#main+1] =
						{t="Stand up",f=function(ai,dialog)   
							dialog:Close() 
							e:SendEvent(EVENT_EXIT_VEHICLE)
							return false
						end}  
					else
						main[#main+1] =
						{t="Use this",f=function(ai,dialog)   
							local ner = NEARESTUSEABLE(e)
							if ner then
								dialog:Close() 
								Interact(e,ner,'use')
							else
								dialog:Open("What?")
							end
							return false
						end}
					end  
					
					main[#main+1] =
					{t="Show your inventory",f=function(ai,dialog)   
						dialog:Open(table.Random({"Look","Here"})) 
						actor_panels.OpenInventory(ply,ALIGN_BOTTOM,nil)
						actor_panels.OpenCharacterInfo(ply,ALIGN_LEFT,nil) 
						actor_panels.OpenInventory(e,ALIGN_TOP,nil)
						actor_panels.OpenCharacterInfo(e,ALIGN_RIGHT,nil)  
						return false
					end}  
					--if e:HasTool("bow_kindred_gal") then
					--	if self.atask then
					--		main[#main+1] =
					--		{t="Хватит",f = function(ai,dialog)
					--			ai.atask = nil
					--			if ai.atask and ai.atask.Abort then ai.atask:Abort() end
					--			e:SendEvent(EVENT_TASK_RESET)
					--			dialog:Open(table.Random(phrases.agreement))
					--			return false
					--		end}
					--	else
					--		main[#main+1] =
					--		{t="Атакуй меня",f = function(ai,dialog)
					--			ai.atask = true
					--			e:SendEvent(EVENT_TASK_BEGIN,"attack",ai.target)
					--			
					--			dialog:Open(table.Random(phrases.agreement))
					--			return false
					--		end}
					--	end
					--else
					--	main[#main+1] =
					--	{t="Возьми оружие",f = function(ai,dialog)
					--		if e:HasTool("bow_kindred_gal") then
					--			dialog:Open("у меня уже есть. не видишь?")
					--		else
					--			dialog:Open(table.Random(phrases.agreement).." сейчас")
					--			ACT_TEST_PRESSBUTTON(ai,e,{ent = ply})
					--		end
					--		return false
					--	end}
					--end
					
					
					if e._spcom and e._spcom.antr_systems then
						main[#main+1] =
						{t="Turn off",f=function(ai,dialog)   
								e._spcom.antr_systems:Shutdown()
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
				elseif e==LocalPlayer() then
					local p = panel.Create("window_npc_dialog")  
					--p:Init(e:GetName(),300,500)
					
					p:SetPos(0,-400) 
					p:Start(self,ply:GetName())
					
					greettext = table.Random({"Aга?","Что тебе нужно?","М?","Да?"})
					local main = {
						{t=greettext,f=function(ai,dialog) 
							local repst = table.Random(phrases.agreement)
							dialog:Open("Иди за мной",
							{
								{t=repst,f= function() facecontroller.Vocalize(self.ent,repst,1,1) end}, 
							})
							return true;
						end},
					}
					p:Open("Эй",main)
					self.dialog = p
					facecontroller.Vocalize(self.ent,greettext,1,1)
				else
					facecontroller.Vocalize(self.ent,greettext,1,1)
				end
			else
				
				ply:SendEvent(EVENT_LERP_HEAD,e)
				--ply:EyeLookAtLerped(e) 
				self.task = nil
				self.target = ply

				if ply == LocalPlayer()  then
					local p = panel.Create("window_npc_dialog")  
					--p:Init(e:GetName(),300,500)
					
					p:SetPos(0,-400) 
					p:Start(self,e:GetName())
					
					local main = { } 
					if e._spcom and e._spcom.antr_systems then
						main[#main+1] =
						{t="Turn on",f=function(ai,dialog)   
								e._spcom.antr_systems:PowerUp()
							return false
						end}  
						main[#main+1] =
						{t="Open inventory",f=function(ai,dialog)    
							actor_panels.OpenInventory(ply,ALIGN_BOTTOM,nil)
							actor_panels.OpenCharacterInfo(ply,ALIGN_LEFT,nil) 
							actor_panels.OpenInventory(e,ALIGN_TOP,nil)
							actor_panels.OpenCharacterInfo(e,ALIGN_RIGHT,nil)  
							return false
						end}  
					end
					p:Open("...",main)
					self.dialog = p 
					BLOCK_MOUSE = true 
				end
			end
		else 
		end
	end
end
 
function ai:InDialog()
	return self.dialog~=nil
end

