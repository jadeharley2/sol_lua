util_static = util_static or {}
function util_static.ButtonUse(s,user)
	--local wio = TryGetComponent("wireio",s)
	--if wio then 
	--	wio:SetOutput("out")
	--end
    if s.wireio then
        if s.bwvalue~=nil then
            if s.bwvalue == 1 then
                s.bwvalue = 0
                s.wireio:SetOutput("out",0)
            else
                s.bwvalue = 1
                s.wireio:SetOutput("out",1)
            end 
            if s.btnanim then
                local model = s.model 
                if s.bwvalue==1 then
                    local action = s.btnanim.on
                    local f = model[action[1]]
                    --PrintTable(action)
                    --MsgN(f)
                    if f then
                        f(model,action[2])
                    end
                else
                    local action = s.btnanim.off
                    local f = model[action[1]]
                    if f then
                        f(model,action[2])
                    end
                end
            end
        else
            s.wireio:SetOutput("out")
        end
	end 
	if CLIENT then
		s:EmitSound(s.btnsound or "events/lamp-switch.ogg",1)
	end
end

hook.Add("prop.variable.load","button",function (self,j,tags)  
    if j.button then 
		local wio = self:RequireComponent(CTYPE_WIREIO)
        if istable(j.button) and j.button.value then
            self.usetype = "press switch"
            self.bwvalue = 0
        else
            self.usetype = "press button" 
        end
        if istable(j.button) then
            self.btnsound = j.button.sound
 
            if j.button.animated and self.model then
                self.btnanim = j.button.animated
                self.model:SetDynamic()
                self.model:SetMatrix(matrix.Rotation(Vector(0,0,0)))
                self:SetUpdating(true) 
            end
        end
		self:AddTag(TAG_USEABLE)
		self:AddEventListener(EVENT_USE,"a",function(...)
            util_static.ButtonUse(...)
        end)
		self:SetNetworkedEvent(EVENT_USE,true)
        wio:AddOutput("out")
         
	end
end) 

hook.Add('item_features','propv.button',function(formid,data,addfeature) 
	if data.button then 
        addfeature("button",{1,1,1},'textures/gui/features/active.png')  
    end
end) 