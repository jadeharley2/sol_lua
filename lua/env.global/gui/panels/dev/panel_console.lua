
local font_d16 = "fonts/d12.json"

function PANEL:Init()
	self.lastupdate =0

	self:SetColor(Vector(0,0,0))
	
	local input_text = panel.Create("input_text")
	input_text.downcolor = Vector(50,50,50)/256
	input_text.upcolor = Vector(0,0,0)/256
	input_text.hovercolor = Vector(80,80,80)/256
	input_text:SetColor(input_text.upcolor)
	input_text:SetTextColor( Vector(1,1,1))
	input_text:Dock(DOCK_BOTTOM)
	input_text:SetFont2(font_d16)
	input_text:SetSize(20,20)
	input_text.OnKeyDown = function(n,key) self:InputKeyDown(n,key) end 
	input_text.OnTextChanged = function(n,text) self:TextChanged(n,text) end 
	input_text.FilterChar = function(n,char) 
		if char == '`' then
			return false
		end
	end
	self.input_text = input_text
	
	self.input_history_id = 0
	self.input_history = {}
	self.tvars = {}
	--self.input_history_up = Stack(50)
	--self.input_history_down = Stack(50)
	
	local list = panel.Create("list") 
	list.reverse = true
	list.lineheight = 16
	list.font = font_d16
	list:Dock(DOCK_FILL)
	list:SetSize(30,30)
	self.list = list 
	
	self.screendiv = 4
	
	self:Add(input_text)  
	self:Add(list)   
	
	self.upd = debug.DelayedTimer(0,100,-1,function() self:Refresh() end)
	 
	--self:SetCanRaiseMouseEvents(false)
	self.first = true
end
function PANEL:AutoFormat(text)
	local low = string.lower (text)
	text = cstring.replace(text,'\t','    ')
	if string.find(low,'error') then
		text = '\a[red]'..text
	elseif string.find(low,'warning') then
		text = '\a[#FF9900]'..text
	elseif string.find(low,'info') then
		text = '\a[#00AAFF]'..text
	end
	return text
end
function PANEL:Refresh(force)  
	if self.enabled then
		local list = self.list  
		if list then 
			local lastupdatetime = debug.ConsoleLastUpdate()
			if(self.lastupdate<lastupdatetime) then
					self.lastupdate = lastupdatetime
				local lines = debug.ConsoleGet(100)
	
				list:ClearItems()
				if self.filter and string.len(self.filter)>0 then
					local nlines = {}
					for k,v in pairs(lines) do
						if string.match(v,self.filter) then
							nlines[k] = self:AutoFormat(v)
						end
					end
					lines = nlines
				else
					for k,v in ipairs(lines) do
						lines[k] = self:AutoFormat(v)
						list:AddItem(gui.FromTable({
							text = lines[k],
							textcolor = {255,255,255}, 
							color = {200,100,100},
							size = {16,16},
							font = font_d16,
							dock = DOCK_TOP,
							textonly = true,
						}))
					end
				end

				--list.lines ={}-- lines
				list.reverse = false
				--list:Refresh() 
			end
		end
		--self.input_text:Select() 
		if self.first then 
			local wsize = GetViewportSize()
			local sdiv = self.screendiv or 4
			self:SetSize(wsize.x,wsize.y/sdiv)
			--self:SetPos(0,wsize.y-wsize.y/sdiv-30)

			self.list:ScrollToBottom()
			self.first = false
		end
	end
end
function PANEL:Select() 
	debug.Delayed(100,function()
		self.input_text:Select() 
	end)
end
function PANEL:Resize() 
	--self:Refresh()
	--MsgN("C")
end
function PANEL:InputKeyDown(n,key) 
	if key== KEYS_ENTER then
		local text = n:GetText()
		console.Call(text) 
		
		--while self.input_history_down:Peek() do
		--	local txt = self.input_history_down:Pop()
		--	if not string.empty(txt) then 
		--		self.input_history_up:Push(txt)
		--	end
		--end
		--if text ~= self.input_history_up:Peek() and not string.empty(text) then
		--	self.input_history_up:Push(text)
		--end
		if text then
			local ltext = self.input_history[#self.input_history]
			--MsgN(text,ltext,text ~= ltext)
			if text ~= ltext then
				self.input_history[#self.input_history+1]=text
			end
		end
		self.input_history_id = #self.input_history+1

		--if text == "debug" then 
		--	local debugp = panel.Create("window_debug")  
		--	debugp:SetTitle("Debug") 
		--	debugp:UpdateLayout() 
		--	debugp:SetPos(-800,0)
		--	debugp:Show()                
		--	--self:GetParent():Add(debugp) 
		--elseif text == "testgui" then  
		--	local debugp = panel.Create("tree")
		--	debugp:SetPos(-800,0)
		--	debugp:SetSize(400,800)
		--	debugp:Show()   
		--	--self:GetParent():Add(debugp)    
		--	debugp:UpdateLayout() 
		--elseif text == "testcolors" then
		--	MsgN("WHITE\a[black]BLACK\a[red]RED\a[green]GREEN\a[blue]BLUE"
		--	.."\a[yellow]YELLOW\a[cyan]CYAN\a[magenta]MAGENTA"
		--	.."\a[#556677]a?\a[#552388]a?\a[#AABBCC]a?")  
		if string.starts(text,"filter") then   
			local arg = string.sub(text,7) 
			if arg then
				self.filter = string.trim(arg)
			else
				self.filter = nil
			end
			self:Refresh()
			self.list:ScrollToBottom() 
		end
		n.text = ""
		n:SetText2("") 
		self:Refresh()
	end
	if key == KEYS_UP then
		local maxval = #self.input_history+1+#self.tvars

		self.input_history_id = math.Clamp(self.input_history_id-1,1,maxval)
		 

		--local text = n:GetText()
		--input_history
		--local upt = self.input_history_up:Pop() 
		--if upt then 
		--	self.input_history_down:Push(text) 
		--	n.text = upt
		--	n:SetText2(upt) 
		--end
	end
	if key == KEYS_DOWN then
		local maxval = #self.input_history+1+#self.tvars

		self.input_history_id = math.Clamp(self.input_history_id+1,1,maxval)
		
		--local text = n:GetText()
		--local upt = self.input_history_down:Pop() 
		--if upt then 
		--	self.input_history_up:Push(text) 
		--	n.text = upt
		--	n:SetText2(upt)   
		--end
	end
	if key == KEYS_UP or key == KEYS_DOWN then
		local hlen = #self.input_history

		if self.input_history_id==hlen+1 then
			local upt = ""
			n.text = upt
			n:SetText2(upt)  
		elseif self.input_history_id>hlen+1 then
			local mindex = self.input_history_id-hlen-1
			--MsgN("mindex",mindex)
			local upt= self.tvars[mindex]
			n.text = upt
			n:SetText2(upt)   
		else -- less
			local upt = self.input_history[self.input_history_id]
			n.text = upt
			n:SetText2(upt) 
		end 
	end
	--if key == KEYS_ESCAPE then 
	--	self.input_text:Deselect() 
	--	if MAIN_MENU.worldIsLoaded then 
	--		MAIN_MENU:MenuToggle() 
	--	end
	--end
	if key == KEYS_SCROLL then 
		if self.screendiv>2 then
			self.screendiv = 1.2
		else
			self.screendiv = 4 
		end
		self.first = true
		debug.Delayed(100,function()
			self.list:ScrollToBottom() 
			self:Refresh() 
		end)
	end
	if key == KEYS_OEMTILDE then 
		--self:Close()
		--self.input_text:Deselect()  
		--self.enabled = false  
		--MsgN("ee")
		ToggleConsole()
	end
	if key == KEYS_PAGEDOWN then 
		self.list:Scroll(600)
	end
	if key == KEYS_PAGEUP then 
		self.list:Scroll(-600)
	end
	if key == KEYS_HOME then 
		self.list:ScrollToTop()
	end
	if key == KEYS_END then 
		self.list:ScrollToBottom()
	end
	
	
	if key == KEYS_TAB then 
		if self.tvars and #self.tvars>0 and self.input_history_id==#self.input_history+1 then
			n.text = self.tvars[1]
			n:SetText2(n.text) 
		end
	end

	if key ~= KEYS_UP and key ~= KEYS_DOWN then
		self:TextChanged(n,n:GetText())
		self.input_history_id=#self.input_history+1
	end
	 
end
function PANEL:TextChanged(n,text)   
	self.tvars = {}
	if string.len( text)>=3 then
		local variants = console.AutoComplete(text)
		local ctmp = {}
		local tvars = {}
		--self.input_history_down:Clear()
		if variants then
			for k, v in ipairs(variants) do
				if #ctmp> 10 then break end
				ctmp[#ctmp+1] = {text=v[1]}
				tvars[#tvars+1] = v[1]
			end
			--for k, v in ipairs(ctmp) do 
			--	--self.input_history_down:Push(ctmp[#ctmp-k+1].text) 
			--end
		end 
		self.tvars = tvars

		local w = self:GetSize().x*0.5
		ContextMenu(self,ctmp,
			self.input_text:GetScreenPos()--*2
			+self.input_text:GetSize()*Point(0,1)
			,0,
			function(b)
				b:SetSize(w,30)
				b:SetTextColor(Vector(0.8,0.8,1))
				b:SetColorAuto(Vector(0,0,0))
			end) 
	else
		ContextMenu(self,nil)
	end
end



console.AddCmd("debug",function()
	local debugp = panel.Create("window_debug")  
	debugp:SetTitle("Debug") 
	debugp:UpdateLayout() 
	debugp:SetPos(-800,0)
	debugp:Show()      
end)
console.AddCmd("testgui",function(panelname)
	local debugp = panel.Create("window")
	debugp:SetPos(-800,0)
	debugp:SetSize(400,800)
	debugp:Show()     
	debugp:UpdateLayout()  
	if panelname then
		local pp = panel.Create(panelname)
		if pp then
			pp:SetSize(100,100);
			pp:Dock(DOCK_FILL)
			debugp.inner:Add(pp)
			debugp:UpdateLayout()
		end
	end
end) 
console.AddCmd("testcolors",function()
	MsgN("WHITE\a[black]BLACK\a[red]RED\a[green]GREEN\a[blue]BLUE"
	.."\a[yellow]YELLOW\a[cyan]CYAN\a[magenta]MAGENTA"
	.."\a[#556677]#556677\a[#552388]#552388\a[#AABBCC]#AABBCC")   
end)

--placeholder
console.AddCmd("filter",function() end)


