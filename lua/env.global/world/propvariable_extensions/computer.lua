


local UpdateModel  = function(self)
	local data = self._persist
	if self.model then
		if data.powered then
			self.model:SetMaterial("models/items/space/tex/screen.json",1)
		else
			self.model:SetMaterial("models/items/space/tex/screen_off.json",1) 
		end
	end
end
local CTogglePower = function(self,user)
	local data = self._persist
	data.powered = not (data.powered or false) 
	UpdateModel(self)
end
local CTogglePowerText = function(self,user)
	local data = self._persist
	if data.powered then
		return 'turn off'
	else
		return "turn on"
	end 
end
local inter_actions = {
	power = CTogglePower
}
hook.Add("prop.variable.load","computer",function (self,j,tags) 
	if j.computer then   
		self.usetype = "computer"
		self.info = "computer"  
		self.computer = j.computer
		if not self._persist.computer then
			self._persist.powered = false
			self._persist.computer = j.computer
		end
		UpdateModel(self)
	end
end)
hook.Add("prop.variable.newitem","computer",function (ftype,data,j) 
    if j.computer then    
        local _persist = data.parameters.scriptdata or {}
        data.parameters.scriptdata = _persist
        
        if not _persist.computer then
            _persist.powered = false
            _persist.computer = j.computer 
        end 
	end
end)

hook.Add('interact.options','computer',function (USER,ENT,t)
	if ENT.computer then
		local sdata = ENT._persist 
		t.power = {text=CTogglePowerText(ENT,USER)} 
	end
end)
hook.Add('interact','computer',function (USER,ENT,t)
	if ENT.computer then
		local f = inter_actions[t] 
		if f then f(ENT,USER) end 
	end
end)
hook.Add("item_properties",'computer',function(item,context,storage,itempanel)
	local sdata = item.data.parameters.scriptdata
	if isjson(sdata) and sdata.powered~=nil then 
		local self = {_persist = sdata}
		local user = storage:GetNode()
		if sdata.powered then
			context[#context+1] = {
				text = "open",
				action = function(c)
					pa = panel.Create('computer_interface')
					pa:Setup(item.formid,item.data)
					pa:Show()
				end
			}
		end
		context[#context+1] = {
			text = CTogglePowerText(self,user),
			action = function(c)
				CTogglePower(self,user)
			end
		}
	end
end)