if SERVER then
--OUTDATED

--	function swap(id1,id2) 
--		local plys = player.player_list
--		local p1 = plys[id1]
--		local p2 = plys[id2]
--		if p1 and p2 then
--			p1.actor.player = p2.client
--			p2.actor.player = p1.client
--			local mactor = p1.actor
--			local p1name = p1.client:GetName()
--			local p2name = p2.client:GetName()
--			p1.actor = p2.actor
--			p2.actor = mactor
--			p1.client:AssignNode(p1.actor)
--			p2.client:AssignNode(p2.actor)
--			p1.client:SetTag(VARTYPE_NAME,p2name)
--			p2.client:SetTag(VARTYPE_NAME,p1name)
--			p1.actor.isswapped = not p1.actor.isswapped
--			p2.actor.isswapped = not p2.actor.isswapped
--			p1.client:SendLua("cli_swap(ents.GetById("..tostring(120000+id2).."))")
--			p2.client:SendLua("cli_swap(ents.GetById("..tostring(120000+id1).."))")
--		else
--			MsgN("playernotfound: ",p1," , ", p2)
--		end
--	end
--	function swap2(id1,id2)
--		swap(id1,id2)
--		local plys = player.GetAll()
--		local p1 = plys[id1]
--		local p2 = plys[id2]
--		if p1 and p2 then
--		p1.client:SendLua("local bc = ents.GetById("..tostring(120000+id1)..") TACTOR:SetPos(bc:GetPos()) ")
--		p2.client:SendLua("local bc = ents.GetById("..tostring(120000+id2)..") TACTOR:SetPos(bc:GetPos()) ")
--		end
--	end
--	MsgN("sw load")
else
 
--	function swap()
--		if not LocalPlayer() or not TM2 then return false end
--		SetController("freecamera")
--		local cc = LocalPlayer()
--		SetLocalPlayer(TM2)
--		TM2 = cc
--		SetController("actor")
--		return true
--	end
--	
--	function cli_swap(newactor)
--		local oldac = LocalPlayer()
--		oldac.isswapped = true  
--		SetLocalPlayer(newactor) 
--		newactor:SetGlobalName('player') 
--		newactor.controller = nil
--		SetController('actor') 
--		newactor.isswapped = true
--	end
end
--data/lua/env.global/autorun/swtest.lua
--dialog test

DeclareEnumValue("event","DIALOG_START",					3332221) 
DeclareEnumValue("event","DIALOG_END",						3332222) 

function temp_opendialog(ply, target)

end

--[[
for k,v in pairs(player.GetAll()) do
	v:AddTag(TAG_USEABLE)
	v._events = v._events or {}
	v._events[EVENT_USE] = {networked = true, f = function(self,user)  
			if SERVER then
				if not self._indialog and not user._indialog then
					MsgN(user._indialog)
					user._indialog = true
					self._indialog = true 

					self:SendEvent(EVENT_LERP_HEAD,user)
					user:SendEvent(EVENT_LERP_HEAD,self)
	 
	
					self:SendEvent(EVENT_DIALOG_START,user)
					user:SendEvent(EVENT_DIALOG_START,self)
				end

			end
		end
	}

	v._events[EVENT_DIALOG_START] = {networked = true, f = function(self,user)   
		if(user==LocalPlayer()) then 
			local dialog = panel.Create("window_npc_dialog")  
			self._dialog = dialog 
			actor_panels.SetSide(dialog,ALIGN_BOTTOM)
			actor_panels.AddPanel(dialog,true) 
			dialog:Start(facial.getai(self),self:GetName()) 
			dialog:Open("",
			{
				{t="Обмен",f= function()
					dialog:Close()
					actor_panels.OpenInventory(user,ALIGN_BOTTOM,nil)
					actor_panels.OpenCharacterInfo(user,ALIGN_LEFT,nil)
					actor_panels.OpenInventory(self,ALIGN_TOP,nil)
					actor_panels.OpenCharacterInfo(self,ALIGN_RIGHT,nil)
					return false
				end}, 
				{t="Иди за мной",f= function()
					actor_panels.CloseAll()
					self:SendEvent(EVENT_TASK_BEGIN,"follow",user,2)
					return false
				end}, 
				{t="Не ходи за мной",f= function()
					actor_panels.CloseAll()
					self:SendEvent(EVENT_TASK_RESET)
					return false
				end}, 
			})
			hook.Add("actor_panels.closed","dialog_end",function()
				self:SendEvent(EVENT_DIALOG_END,user)
				user:SendEvent(EVENT_DIALOG_END,self)
				MsgN("dialog end")
			end)
			MsgN("dialog start")
		end
	end} 
	v._events[EVENT_DIALOG_END] = {networked = true, f = function(self,user) 
		if SERVER then
			user._indialog = false
			self._indialog = false
		else
			hook.Remove("actor_panels.closed","dialog_end")
			actor_panels.CloseAll()
		end
	end}
end 
]]

 
--hook.Remove(EVENT_GLOBAL_UPDATE,"pctest")
--hook.Add(EVENT_GLOBAL_UPDATE,"pctest",function()
--	
--	local lp = LocalPlayer() 
--	if lp then
--		local l = lp.model
--		local ang = debug.PC_Orientation()
--		--l:SetIKTarget("",Vector(15,48,14),Vector(-90,-70,-90))
--		--l:SetIKTarget("",Vector(0,18,14),Vector(-90,0,-90))--Vector(ang.z-90,ang.y,-ang.x))
--		--l:SetIKTarget("",Vector(10,48,14),Vector(ang.z-90,ang.y,-ang.x)) 
--	end
--
--end)