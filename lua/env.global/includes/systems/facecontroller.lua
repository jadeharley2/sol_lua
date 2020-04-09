facecontroller = facecontroller or {}


local flex_vo_a    	=10 
local flex_vo_e    	=11 
local flex_vo_o    	=12 
local flex_vo_p    	=13 
local flex_vo_th 	=14 
local flex_tng_up 	=15 
local flex_lip_open =16  
local flex_lip_pt  	=17  
function facecontroller.VFEXL(ent,tab,pow)
    
    if not IsValidEnt(ent) then return end 
    local head = ent:GetByName('head',true,true)
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
function facecontroller.VocSyl(ent,sy,pow)
    if sy=='a' 		then	facecontroller.VFEXL(ent,{1,0,0, 0,0, 0,0,0},pow) 
    elseif sy=='e' 	then 	facecontroller.VFEXL(ent,{0,0.5,0, 0,0, 0,0,0},pow) 
    elseif sy=='o' 	then  	facecontroller.VFEXL(ent,{0,0.5,0.5 ,0,0, 0,0,0},pow) 
    elseif sy=='u' 	then  	facecontroller.VFEXL(ent,{0,0,1, 0,0, 0,0,0},pow) 
    elseif sy=='i' 	then  	facecontroller.VFEXL(ent,{0.1,0,0, 0,0, 0,1,0},pow) 
    elseif sy=='j' or sy=='z' 
                    then 	facecontroller.VFEXL(ent,{0,0,0, 0,0.5, 1,1,0},pow) 
    elseif sy=='n' or sy=='s' or sy=='t' or sy=='k' or sy=='d' or sy=='q'
        or sy=='r' or sy=='g'
                    then 	facecontroller.VFEXL(ent,{0,0,0, 0,0, 1,1,0},pow)  
    elseif sy=='b' or sy=='p' or sy=='m'
                    then 	facecontroller.VFEXL(ent,{0,0,0, 1,0, 0,0,0},pow) 
    elseif sy=='v' or sy=='f' or sy=='w'	
                    then 	facecontroller.VFEXL(ent,{0,0,0, 0,1, 0,0.9,0},pow) 
    elseif sy=='h' 	then 	facecontroller.VFEXL(ent,{0.5,0,0, 0,0, 0.5,0,0},pow) 
    elseif sy==' ' 	then 	facecontroller.VFEXL(ent,{0,0,0, 0,0, 0,0,0},pow) 

    --ru
    elseif sy=='а' 	then 	facecontroller.VFEXL(ent,{1,0,0, 0,0, 0,0,0},pow)
    elseif sy=='е' 	then 	facecontroller.VFEXL(ent,{0,0.5,0, 0,0, 0,0,0},pow) 
    elseif sy=='э' 	then 	facecontroller.VFEXL(ent,{0,1,0, 0,0, 0,0,0},pow) 
    elseif sy=='о' 	then 	facecontroller.VFEXL(ent,{0,0.5,0.5 ,0,0, 0,0,0},pow)  
    elseif sy=='и' 	then 	facecontroller.VFEXL(ent,{0.1,0,0, 0,0, 0,1,0},pow) 
    elseif sy=='у' 	then 	facecontroller.VFEXL(ent,{0,0,1, 0,0, 0,0,0},pow)  
    elseif sy=='я' 	then 	facecontroller.VFEXL(ent,{1,0,0, 0,0, 0,0,0},pow) --йа
    elseif sy=='ё' 	then 	facecontroller.VFEXL(ent,{0,0.5,0.5 ,0,0, 0,0,0},pow) --йо
    elseif sy=='ю' 	then 	facecontroller.VFEXL(ent,{0,0,1, 0,0, 0,0,0},pow)   --йу

    elseif sy=='ж' or sy=='з' 
                    then 	facecontroller.VFEXL(ent,{0,0,0, 0,0.5, 1,1,0},pow) 
    elseif sy=='н' or sy=='с' or sy=='т' or sy=='к' or sy=='д'
        or sy=='р' or sy=='г'
                    then 	facecontroller.VFEXL(ent,{0,0,0, 0,0, 1,1,0},pow)  
    elseif sy=='б' or sy=='п' or sy=='м'
                    then 	facecontroller.VFEXL(ent,{0,0,0, 1,0, 0,0,0},pow) 
    elseif sy=='в' or sy=='ф'	
                    then 	facecontroller.VFEXL(ent,{0,0,0, 0,1, 0,0.9,0},pow) 
    elseif sy=='х' 	then 	facecontroller.VFEXL(ent,{0.5,0,0, 0,0, 0.5,0,0},pow) 

    end
end 

function facecontroller.Vcommand(ent,com,arg1,arg2)
    if com == 'm' then
        facecontroller.Mood(ent,tonumber(arg1 or '0'))
    end
end
hook.Remove(EVENT_GLOBAL_PREDRAW,"vocalize_")

function facecontroller.Vocalize(ent,text,speed,power,enable_commands)
    if true then return end 
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
                    facecontroller.Vcommand(ent,unpack(string.split(command,';')))
                end
            end
            --MsgN(syl)
            facecontroller.VocSyl(ent,syl,power)
            index = index +1
        end
        if(cstring.len(text)<index) then
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
function facecontroller.VFMVL(ent,tab,pow)
    local head = ent:GetByName('head',true,true)
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

function facecontroller.Mood(ent,mood,power,decaytime)
    power = power or 1

    if mood == MOOD_NEUTRAL then 		facecontroller.VFMVL(ent,{0.3,0.3, 0,0, 0,0,0, 0},power)
    elseif mood == MOOD_HAPPY then 		facecontroller.VFMVL(ent,{0,1, 0,0, 0,1,0, 1},power)
    elseif mood == MOOD_SAD then 		facecontroller.VFMVL(ent,{-0.2,0, 0,0.4, 0.5,0,0, -0.1},power)
    elseif mood == MOOD_ANGRY then 		facecontroller.VFMVL(ent,{1,1, 0,0, 0,0,1, -1},power)
    elseif mood == MOOD_SURPRISED then 	facecontroller.VFMVL(ent,{0,0, 0,0, 0.5,1,0, -0.5,1},power) 
    elseif mood == MOOD_NERVOUS then 	facecontroller.VFMVL(ent,{-0.2,0, 0,0, 1,0.5,0, -0.5},power) 
    end
    if decaytime then 
        debug.Delayed(decaytime*1000,function() 
            facecontroller.VFMVL(ent,{0.3,0.3, 0,0, 0,0,0, 0})
        end)
    end
end
 







if CLIENT then  
	facial = {}
	facial.say = function(ent, text,speed,power,enable_commands) 
		facecontroller.Vocalize(ent,text,speed or 1,power or 1,enable_commands or false)

		local ep = LocalPlayer()
		env.EnvEvent(ep:GetParent(),ep:GetPos(),ENV_EVENT_AUDIAL,{text = text})
	end
	facial.setmood = function(ent, mood,power) 
		facecontroller.Mood(ent,mood or 0, power or 1)
	end

	console.AddCmd("csay",function(text,speed,power)
		MsgN("say",text)
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
			if cstring.find(s,v,1,true) then return true end
		end
		return false
	end
	local replany = function(s,t,r)
		for k,v in pairs(t) do
			s = cstring.replace(s,v,r)
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