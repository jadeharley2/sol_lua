PANEL.basetype = "button"
PANEL.STATIC = PANEL.STATIC or {}
local static = PANEL.STATIC
static.CURRENT_INPUT = false
static.UNDO_SETTEXT = function(t) t.a.text = t.b t.a:SetText(t.b) t.a.caretpos = t.d end
static.REDO_SETTEXT = function(t) t.a.text = t.c t.a:SetText(t.c) t.a.caretpos = t.d end
static.NUMBER_CHARS = Set("0","1","2","3","4","5","6","7","8","9")
static.NUMBER_ADD_CHARS = Set(".","-")
static.cwinput = function(key)  
	local CI = static.CURRENT_INPUT
	if(CI) then  
		local text = CI.text
		local und = CI.undo 
		
		local ctext = text
		local cp = CI.caretpos
		local ismultiline = CI:GetMultiline()
		if key==KEYS_BACK then
			local tleft =CStringSub(ctext,1,cp-1)
			local tright =CStringSub(ctext,cp+1)
			--MsgInfo(tleft.." - "..tright) 
			text = tleft..tright--CStringSub(text,1,CStringLen(text)-1)
			CI:CaretUpdate(-1)
		elseif key==KEYS_DELETE then 
			local tleft =CStringSub(ctext,1,cp)
			local tright =CStringSub(ctext,cp+2) 
			text = tleft..tright 
			CI:CaretUpdate()
		elseif ismultiline and key==KEYS_ENTER then
			text = text .. "\n"
			CI:CaretUpdate(1)
		elseif ismultiline and key==KEYS_TAB then 
			text = text .. "\t"
			CI:CaretUpdate(1)
		else 
			if input.KeyPressed(KEYS_CONTROLKEY) then
				if key==KEYS_V then  
					local tleft =CStringSub(text,1,cp)
					local tright =CStringSub(text,cp+1)
					local ctext = ClipboardGetText()
					text = tleft .. ctext .. tright
					--text = text .. ClipboardGetText()
					CI:CaretUpdate(CStringLen(ctext),true)
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
				--	if static.NUMBER_CHARS:Contains(nchar) then
				--		text = text .. nchar
				--	end
				--else
				--	text = text .. nchar
				--end
			end
			
			if input.KeyPressed(KEYS_LEFT) then 
				CI:CaretUpdate(-1)
				return
			end
			if input.KeyPressed(KEYS_RIGHT) then 
				CI:CaretUpdate(1)
				return
			end
		end
		if text then
			CI.text = text
			CI:SetText(text)
		else
			CI.text = ""
			CI:SetText("")
		end
		  
		local kd = CI.OnKeyDown 
		if(kd) then
			kd(CI,key)
		end
		
		local dtext = CI.text
		if dtext~=ctext then 
			und:Add(static.UNDO_SETTEXT,static.REDO_SETTEXT,{a=CI,b=ctext,c=dtext,d = cp})
		end
		
		
		
	end
end
static.cwinput2 = function(char) 
	local CI = static.CURRENT_INPUT
	if CI then
		local text = CI.text
		if CI.rest_numbers then
			if static.NUMBER_CHARS:Contains(char) or  static.NUMBER_ADD_CHARS:Contains(char) then 
				local cp = CI.caretpos
				local tleft =CStringSub(text,1,cp)
				local tright =CStringSub(text,cp+1)
				text = tleft .. char .. tright
				--text = text .. char
			end
		else
			local cp = CI.caretpos
			local tleft =CStringSub(text,1,cp)
			local tright =CStringSub(text,cp+1)
			text = tleft .. char .. tright
		end
		CI.text = text
		CI:SetText(text) 
		CI:CaretUpdate(1)
		
		local kd = CI.OnTextChanged 
		if(kd) then
			kd(CI,text)
		end
	end
end

function PANEL:Init()
	self.caret = ""
	--PrintTable(self)
	self.undo = Undo(20)
	self.base.Init(self) 
	self.base.SetColorAuto(self,Vector(0.1,0.1,0.1),0.1)
	self:SetTextColor(Vector(1,1,1))
	self:SetTextCutMode(true)
	self.caretpos = CStringLen(self:GetText())
	
	local caretoverlay = panel.Create()
	self.caretoverlay = caretoverlay 
	caretoverlay:Dock(DOCK_FILL)
	caretoverlay:SetMargin(-8,0,0,0)
	caretoverlay:SetCanRaiseMouseEvents(false)
	caretoverlay:SetTextOnly(true)
	caretoverlay:SetTextColor(Vector(1,1,1))
	self:Add(caretoverlay)
	
	hook.Add("input.keydown", "gui.input.text",function(k) static.cwinput(k) end)
	hook.Add("input.keypressed", "gui.input.text",function(k)  static.cwinput2(k) end)
end

function PANEL:SetText2(text)
	self:SetText(text)
	self:CaretUpdate(CStringLen(text))
	self.text = text
end

function PANEL:OnClick() 
	local text = self:GetText()
	self:CaretUpdate(CStringLen(text))
	self:Select()
end 
function PANEL:MouseEnter()
	hook.Add("input.keydown","input.copyonover",function(k) 
		if input.KeyPressed(KEYS_CONTROLKEY) then
			if k==KEYS_V then   
				if static.CURRENT_INPUT ~= self then
					local text = ClipboardGetText() 
					self:CaretUpdate(CStringLen(text),true)
					self.text = text
					self:SetText(text)
				end
			elseif k==KEYS_C then 
				ClipboardSetText(self:GetText())
				MsgN("asd")
			end
		end
	end)
end
function PANEL:MouseLeave()
	hook.Remove("input.keydown","input.copyonover")
end
function PANEL:ToggleCaret()
	local caret = self.caret or ""
	if caret == "" then
		caret = "|"
	else
		caret = ""
	end 
	self.caret = caret
	self:CaretUpdate()
end
function PANEL:CaretUpdate(lenchange,nocollapse)
	local cp = self.caretpos
	if lenchange then
		cp = cp + lenchange
		if cp < 0 then
			cp = 0
		end
	end
	if not nocollapse then
		local lsp = CStringLen(self:GetText())
		if cp > lsp then
			cp = lsp
		end 
	end
	self.caretpos = cp 
	local text = cstring.sub(self.text or "",1,cp) --string.rep("X", cp)
	text = cstring.regreplace(text,"\a\\[[\\w\\W]*?\\]","") -- remove special commands
	text = cstring.replace(text,"\n\t","_",true) --replace
	self.caretoverlay:SetText(text..(self.caret or ""))
end
function PANEL:CaretCycle() 
	debug.Delayed(400,function() 
		if static.CURRENT_INPUT == self then
			self:CaretCycle() 
			self:ToggleCaret()
		end
	end)
end
function PANEL:Select()
	if static.CURRENT_INPUT ~= self then
		self.text = self:GetText() or ""
		static.CURRENT_INPUT = self
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
	if static.CURRENT_INPUT == self then
		local cp = self.caretpos
		self.caretoverlay:SetText(string.rep(" ", cp))
		static.CURRENT_INPUT = false
		input.SetKeyboardBusy(false)
		local on = self.OnDeselect
		if on then on(self) end
	end
end