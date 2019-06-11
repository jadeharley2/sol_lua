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
ACT_LOOKAT = function(s,e,t) e:EyeLookAtLerped(t.ent or s.target) end
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
	if s.pai then return end
	local par = e:GetParent()
 
		local ted = false;
		for k,v in pairs(par:GetChildren()) do
			if v~=e and v and IsValidEnt(v) then
				local cls = v:GetClass()
				if string.find(cls,"actor") then
					ted = v
				end 
			end
		end
		
		if ted then
			e:SendEvent(EVENT_LOOK_AT,ted)
			--MsgN(">>",ted) 
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
	MsgN("hi3!",self.cname) 
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
	
	self:AddReaction("jd3",CND_ONIDLE,ACT_LOOKAT_IDLING, {max = 100 })
	
	self:AddReaction("cc1",CND_ONCHAT,ACT_ABILITY,{msg={"d1"}, aid = 1 })
	self:AddReaction("cc2",CND_ONCHAT,ACT_ABILITY,{msg={"d2"}, aid = 2 })
	self:AddReaction("cc3",CND_ONCHAT,ACT_ABILITY,{msg={"d3"}, aid = 3 }) 
	self:AddReaction("aa-1",CND_ONCHAT,ACT_SAY,{msg={"киндред","kindred"},say="что?"})
	
	local e = self.ent
	e:AddTag(TAG_USEABLE)
	e:AddTag(TAG_NPC)
	e:RemoveTag(TAG_PLAYER)
	local char = e:GetParameter(VARTYPE_CHARACTER) or ""
	local cpath, cname = self.cname or  forms.GetForm("character",char)-- json.Read("forms/characters/"..char..".json")
	self.cname = cname
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
	--	e:SetEyeAngles(ee[1],ee[2]) 
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

			local greettext= "Что тебе нужно?";
			if not self.seen:Contains(ply) then
				self.seen:Add(ply)
				greettext = "Привет. ".. greettext
				self:Mood(MOOD_SURPRISED,0.5,0.5)
			else 
				self:Mood(MOOD_HAPPY,0.5)
				greettext = table.Random({"Aга?","Что тебе нужно?","М?","Да?"})
			end
			self.task = nil
			self.target = ply

			if ply == LocalPlayer()  then
				local p = panel.Create("window_npc_dialog")  
				--p:Init(e:GetName(),300,500)
				
				p:SetPos(0,-400) 
				p:Start(self,e:GetName())
				
				local main = {
					{t="Как дела?",f=function(ai,dialog) 
						dialog:Open("Нормально. А у тебя?",
						{
							{t="Хорошо",f= function() dialog:Open("норм") self:Mood(MOOD_HAPPY,0.5) end},
							{t="Средне",f= function() dialog:Open("хех") self:Mood(MOOD_NEUTRAL) end},
							{t="Плохо",f= function() dialog:Open(":(") self:Mood(MOOD_SAD,0.5) end},
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
						e:ResetTM()
						return false
					end}
				else 
					main[#main+1] =
					{t="Иди за мной",f=function(ai,dialog) 
						if e:GetVehicle() then e:SendEvent(EVENT_EXIT_VEHICLE) end 
						ai.ftask = true
						e:SendEvent(EVENT_TASK_BEGIN,"follow",ai.target,2)
						dialog:Open(table.Random(phrases.agreement))
						MsgN('ads')
						return false
					end}
					main[#main+1] =
					{t="гуляй",f=function(ai,dialog)  
						if e:GetVehicle() then e:SendEvent(EVENT_EXIT_VEHICLE) end 
						ai.ftask =true
						e:SendEvent(EVENT_TASK_BEGIN,"wander")
						dialog:Open(table.Random(phrases.agreement))
						return false
					end}
					
				end
				
				main[#main+1] =
				{t="подбери",f=function(ai,dialog)   
					dialog:Close()
					
					if e:PickupNearest() and CLIENT then
						GetCamera():SetParent(e) 
					end
					return false
				end}  

				if e:GetVehicle() then 
					main[#main+1] =
					{t="встань",f=function(ai,dialog)   
						dialog:Close() 
						e:SendEvent(EVENT_EXIT_VEHICLE)
						return false
					end}  
				else
					main[#main+1] =
					{t="используй",f=function(ai,dialog)   
						local ner = NEARESTUSEABLE(e)
						if ner then
							dialog:Close() 
							USE(e)
						else
							dialog:Open("Тут ничего нет")
						end
						return false
					end}
				end  
				
				main[#main+1] =
				{t="покажи что у тебя есть",f=function(ai,dialog)   
					dialog:Open(table.Random({"Вот","Смотри"}))
					CloseInventoryWindow(e)
					OpenInventoryWindow(e) 
					local psp = panel.Create("window_character")
					psp:Set(e)
					psp:Show()
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
							{t=repst,f= function() self:Vocalize(repst,1,1) end}, 
						})
						return true;
					end},
				}
				p:Open("Эй",main)
				self.dialog = p
				self:Vocalize(greettext,1,1)
			else
				self:Vocalize(greettext,1,1)
			end
		else
			MsgN("wat?",e)
		end
	end
end
 
function ai:InDialog()
	return self.dialog~=nil
end


--WARNING: LIPSYNC TEST 
	local flex_vo_a    	=10 
	local flex_vo_e    	=11 
	local flex_vo_o    	=12 
	local flex_vo_p    	=13 
	local flex_vo_th 	=14 
	local flex_tng_up 	=15 
	local flex_lip_open =16  
	local flex_lip_pt  	=17  
	function ai:VFEXL(tab,pow)
		
		if not self or not self.ent or not IsValidEnt(self.ent) then return end 
		local head = self.ent:GetByName('head',true,true)
		if head then
			for k,v in pairs(head) do
				local m = v.model
				pow = pow or 1
				m:SetFlexValue(flex_vo_a,tab[1]*pow)
				m:SetFlexValue(flex_vo_e,tab[2]*pow)
				m:SetFlexValue(flex_vo_o,tab[3]*pow)
				
				m:SetFlexValue(flex_vo_p,tab[4]*pow)
				m:SetFlexValue(flex_vo_th,tab[5]*pow)

				m:SetFlexValue(flex_tng_up,tab[6]*pow)
				m:SetFlexValue(flex_lip_open,tab[7]*pow)
				--m:SetFlexValue(flex_lip_pt,tab[8]*pow)
			end
		end
	end
	function ai:VocSyl(sy,pow)
		if sy=='a' 		then	self:VFEXL({1,0,0, 0,0, 0,0,0},pow) 
		elseif sy=='e' 	then 	self:VFEXL({0,0.5,0, 0,0, 0,0,0},pow) 
		elseif sy=='o' 	then  	self:VFEXL({0,0.5,0.5 ,0,0, 0,0,0},pow) 
		elseif sy=='u' 	then  	self:VFEXL({0,0,1, 0,0, 0,0,0},pow) 
		elseif sy=='i' 	then  	self:VFEXL({0.1,0,0, 0,0, 0,1,0},pow) 
		elseif sy=='j' or sy=='z' 
						then 	self:VFEXL({0,0,0, 0,0.5, 1,1,0},pow) 
		elseif sy=='n' or sy=='s' or sy=='t' or sy=='k' or sy=='d' or sy=='q'
			or sy=='r' or sy=='g'
						then 	self:VFEXL({0,0,0, 0,0, 1,1,0},pow)  
		elseif sy=='b' or sy=='p' or sy=='m'
						then 	self:VFEXL({0,0,0, 1,0, 0,0,0},pow) 
		elseif sy=='v' or sy=='f' or sy=='w'	
						then 	self:VFEXL({0,0,0, 0,1, 0,0.9,0},pow) 
		elseif sy=='h' 	then 	self:VFEXL({0.5,0,0, 0,0, 0.5,0,0},pow) 
		elseif sy==' ' 	then 	self:VFEXL({0,0,0, 0,0, 0,0,0},pow) 

		--ru
		elseif sy=='а' 	then 	self:VFEXL({1,0,0, 0,0, 0,0,0},pow)
		elseif sy=='е' 	then 	self:VFEXL({0,0.5,0, 0,0, 0,0,0},pow) 
		elseif sy=='э' 	then 	self:VFEXL({0,1,0, 0,0, 0,0,0},pow) 
		elseif sy=='о' 	then 	self:VFEXL({0,0.5,0.5 ,0,0, 0,0,0},pow)  
		elseif sy=='и' 	then 	self:VFEXL({0.1,0,0, 0,0, 0,1,0},pow) 
		elseif sy=='у' 	then 	self:VFEXL({0,0,1, 0,0, 0,0,0},pow)  
		elseif sy=='я' 	then 	self:VFEXL({1,0,0, 0,0, 0,0,0},pow) --йа
		elseif sy=='ё' 	then 	self:VFEXL({0,0.5,0.5 ,0,0, 0,0,0},pow) --йо
		elseif sy=='ю' 	then 	self:VFEXL({0,0,1, 0,0, 0,0,0},pow)   --йу

		elseif sy=='ж' or sy=='з' 
						then 	self:VFEXL({0,0,0, 0,0.5, 1,1,0},pow) 
		elseif sy=='н' or sy=='с' or sy=='т' or sy=='к' or sy=='д'
			or sy=='р' or sy=='г'
						then 	self:VFEXL({0,0,0, 0,0, 1,1,0},pow)  
		elseif sy=='б' or sy=='п' or sy=='м'
						then 	self:VFEXL({0,0,0, 1,0, 0,0,0},pow) 
		elseif sy=='в' or sy=='ф'	
						then 	self:VFEXL({0,0,0, 0,1, 0,0.9,0},pow) 
		elseif sy=='х' 	then 	self:VFEXL({0.5,0,0, 0,0, 0.5,0,0},pow) 

		end
	end 
	
	function ai:Vcommand(com,arg1,arg2)
		if com == 'm' then
			self:Mood(tonumber(arg1 or '0'))
		end
	end
	
	function ai:Vocalize(text,speed,power,enable_commands)
		power = power or 1
		local lspeed = 100 / (speed or 1)
		local index = 1

		text = text .. ' '
		
		local subtimer = 0
		--MsgN(text)
		hook.Add(EVENT_GLOBAL_PREDRAW,"vocalize_",function()
			subtimer = subtimer + 1

			if (subtimer%2==0) then
				local syl = CStringSub(text,index,2)
				if enable_commands then
					if syl == '§' then
						local command = ''
						for k=1, 100 do
							index = index +1
							syl = CStringSub(text,index,2)
							if syl == '§' then break end
							command = command .. syl 
						end
						MsgN("com:",command)
						self:Vcommand(unpack(string.split(command,';')))
					end
				end
				--MsgN(syl)
				self:VocSyl(syl,power)
				index = index +1
			end
			if(input.len(text)<index) then
				hook.Remove(EVENT_GLOBAL_PREDRAW,"vocalize_")
			end
		end)
		--debug.DelayedTimer(100,lspeed,CStringLen(text),function()
		--	local syl = CStringSub(text,index,2)
		--	if enable_commands then
		--		if syl == '§' then
		--			local command = ''
		--			for k=1, 100 do
		--				index = index +1
		--				syl = CStringSub(text,index,2)
		--				if syl == '§' then break end
		--				command = command .. syl 
		--			end
		--			MsgN("com:",command)
		--			self:Vcommand(unpack(string.split(command,';')))
		--		end
		--	end
		--	--MsgN(syl)
		--	self:VocSyl(syl,power)
		--	index = index +1
		--end)

	end
--TEST END
--WARNING: MOODSYNC TEST 
	local flex_eyes_upper_ang    	=0 
	local flex_eyes_lower_hep    	=1 
	local flex_eyes_a    			=2 
	local flex_eyes_b    			=3 
	local flex_brow_nerw    		=4 
	local flex_brow_surpr    		=5 
	local flex_brow_angry    		=6 
	
	local flex_mouth_smile    		=17
	function ai:VFMVL(tab,pow)
		local head = self.ent:GetByName('head',true,true)
		if head then
			for k,v in pairs(head) do
				local m = v.model
				pow = pow or 1
				m:SetFlexValue(flex_eyes_upper_ang,tab[1]*pow)
				m:SetFlexValue(flex_eyes_lower_hep,tab[2]*pow)

				m:SetFlexValue(flex_eyes_a,tab[3]*pow) 
				m:SetFlexValue(flex_eyes_b,tab[4]*pow)

				m:SetFlexValue(flex_brow_nerw,tab[5]*pow) 
				m:SetFlexValue(flex_brow_surpr,tab[6]*pow)
				m:SetFlexValue(flex_brow_angry,tab[7]*pow) 

				m:SetFlexValue(flex_mouth_smile,tab[8]*pow) 
				
				m:SetFlexValue(flex_lip_open,(tab[9] or 0) * pow)
			end
		end
	end

	MOOD_NEUTRAL 	= 0
	MOOD_HAPPY 		= 1
	MOOD_SAD 		= 2
	MOOD_ANGRY 		= 3
	MOOD_NERVOUS 	= 4
	MOOD_SURPRISED 	= 5 

	function ai:Mood(mood,power,decaytime)
		power = power or 1

		if mood == MOOD_NEUTRAL then 		self:VFMVL({0.3,0.3, 0,0, 0,0,0, 0},power)
		elseif mood == MOOD_HAPPY then 		self:VFMVL({0,1, 0,0, 0,1,0, 1},power)
		elseif mood == MOOD_SAD then 		self:VFMVL({-0.2,0, 0,0.4, 0.5,0,0, -0.1},power)
		elseif mood == MOOD_ANGRY then 		self:VFMVL({1,1, 0,0, 0,0,1, -1},power)
		elseif mood == MOOD_SURPRISED then 	self:VFMVL({0,0, 0,0, 0.5,1,0, -0.5,1},power) 
		elseif mood == MOOD_NERVOUS then 	self:VFMVL({-0.2,0, 0,0, 1,0.5,0, -0.5},power) 
		end
		if decaytime then 
			debug.Delayed(decaytime*1000,function() 
				self:VFMVL({0.3,0.3, 0,0, 0,0,0, 0})
			end)
		end
	end
 
--TEST END
if CLIENT then
	local stai = table.Copy(ai)
	stai.__index = stai
	facial = {}
	facial.say = function(ent, text,speed,power,enable_commands)
		local ai = setmetatable({ent = ent},stai) 
		ai:Vocalize(text,speed or 1,power or 1,enable_commands or false)

		local ep = LocalPlayer()
		env.EnvEvent(ep:GetParent(),ep:GetPos(),ENV_EVENT_AUDIAL,{text = text})
	end
	facial.setmood = function(ent, mood,power)
		local ai = setmetatable({ent = ent},stai) 
		ai:Mood(mood or 0, power or 1)
	end

	console.AddCmd("csay",function(text,speed,power)
		facial.say(LocalPlayer(),text,tonumber(speed or '1'),tonumber(power or '1'))
	end)
	console.AddCmd("cmood",function(mood,power)
		facial.setmood(LocalPlayer(),tonumber(mood or '0'),tonumber(power or '1'))
	end)

	facial.getai  = function(actor)
		return  setmetatable({ent = ent},stai) 
	end

	
	local function reversedipairsiter(t, i)
		i = i - 1
		if i ~= 0 then
			return i, t[i]
		end
	end
	function reversedipairs(t)
		return reversedipairsiter, t, #t + 1
	end
	local findany = function(s,t)
		for k,v in pairs(t) do
			if input.find(s,v,1,true) then return true end
		end
		return false
	end
	local replany = function(s,t,r)
		for k,v in pairs(t) do
			s = input.replace(s,v,r)
		end
		return s
	end
	hook.Add( "chat.msg.received",'facial expressions',function(sender,text)
		if sender and IsValidEnt(sender) then
			text = replany(text,{'-_-'},'§m;'..MOOD_NEUTRAL..'§')
			text = replany(text,{'>:('},'§m;'..MOOD_ANGRY..'§')
			text = replany(text,{'8|','o_o','O_O','O_o','o_O'},'§m;'..MOOD_SURPRISED..'§')
			text = replany(text,{':D','xD'},'§m;'..MOOD_HAPPY..';1§')
			text = replany(text,{':)',';)','(:'},'§m;'..MOOD_HAPPY..';0.5§')
			text = replany(text,{':(','D:','):'},'§m;'..MOOD_SAD..'§')
			MsgN('r:',text)
			facial.say(sender,text,1,1,true)

			--if findany(text,{':D','xD'})  then
			--	facial.setmood(sender,MOOD_HAPPY,1)
			--elseif findany(text,{':)',';)','(:'})  then
			--	facial.setmood(sender,MOOD_HAPPY,0.5)
			--elseif findany(text,{':(','D:','):'})  then
			--	facial.setmood(sender,MOOD_SAD)
			--elseif findany(text,{'>:('})  then
			--	facial.setmood(sender,MOOD_ANGRY)
			--elseif findany(text,{'8|'})  then
			--	facial.setmood(sender,MOOD_SURPRISED)
			--end
		end 
	end)
end