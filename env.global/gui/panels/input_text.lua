PANEL.basetype = "button"
local CURRENT_INPUT = false
local UNDO_SETTEXT = function(t) t.a.text = t.b t.a:SetText(t.b) end
local REDO_SETTEXT = function(t) t.a.text = t.c t.a:SetText(t.c) end
local NUMBER_CHARS = Set("0","1","2","3","4","5","6","7","8","9")
local NUMBER_ADD_CHARS = Set(".","-")
local function cwinput(key) 
	local CI = CURRENT_INPUT
	if(CI) then  
		local text = CI.text
		local und = CI.undo 
		
		local ctext = text
		
		
		if key==KEYS_BACK then
			text = CStringSub(text,1,CStringLen(text)-1)
		else 
			if input.KeyPressed(KEYS_CONTROLKEY) then
				if key==KEYS_V then 
					text = text .. ClipboardGetText()
				elseif key==KEYS_Z then 
					und:Undo()
					return
				elseif key==KEYS_Y then 
					und:Redo()
					return
				end
			else
				--local nchar = input.CharPressed(key)
				--if CI.rest_numbers then
				--	if NUMBER_CHARS:Contains(nchar) then
				--		text = text .. nchar
				--	end
				--else
				--	text = text .. nchar
				--end
			end
		end
		CI.text = text
		CI:SetText(text)
		 
		
		local kd = CI.OnKeyDown 
		if(kd) then
			kd(CI,key)
		end
		
		local dtext = CI.text
		if dtext~=ctext then 
			und:Add(UNDO_SETTEXT,REDO_SETTEXT,{a=CI,b=ctext,c=dtext})
		end
	end
end
local function cwinput2(char) 
	if CURRENT_INPUT then
		local text = CURRENT_INPUT.text
		if CURRENT_INPUT.rest_numbers then
			if NUMBER_CHARS:Contains(char) then
				text = text .. char
			end
		else
			text = text .. char
		end
		CURRENT_INPUT.text = text
		CURRENT_INPUT:SetText(text)
	end
end

function PANEL:Init()
	--PrintTable(self)
	self.undo = Undo(20)
	self.base.Init(self) 
	self.base.SetColorAuto(self,Vector(0.1,0.1,0.1),0.1)
	self:SetTextColor(Vector(1,1,1))
	self:SetTextCutMode(true)
	hook.Add("input.keydown", "gui.input.text", cwinput)
	hook.Add("input.keypressed", "gui.input.text", cwinput2)
end

 

function PANEL:OnClick() 
	self:Select()
end 
function PANEL:ToggleCaret()
	local caret = self.caret or ""
	if caret == "" then
		caret = "|"
	else
		caret = ""
	end
	self:SetText(self.text..caret)
	self.caret = caret
end
function PANEL:CaretCycle() 
	debug.Delayed(400,function() 
		if CURRENT_INPUT == self then
			self:CaretCycle() 
			self:ToggleCaret()
		end
	end)
end
function PANEL:Select()
	if CURRENT_INPUT ~= self then
		self.text = self:GetText() or ""
		CURRENT_INPUT = self
		input.SetKeyboardBusy(true)
		hook.Add("input.mousedown", "gui.textinput.deselect", function()
			self:Deselect()
			hook.Remove("input.mousedown","gui.textinput.deselect") 
		end)
		local on = self.OnSelect
		if on then on(self) end
		self:CaretCycle()
	end
end
function PANEL:Deselect()
	if CURRENT_INPUT == self then
		self:SetText(self.text or "")
		CURRENT_INPUT = false
		input.SetKeyboardBusy(false)
		local on = self.OnDeselect
		if on then on(self) end
	end
end