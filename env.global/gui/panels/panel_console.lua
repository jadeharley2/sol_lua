
function PANEL:Init()
	self:SetColor(Vector(0,0,0))
	
	local input_text = panel.Create("input_text")
	input_text.downcolor = Vector(50,50,50)/256
	input_text.upcolor = Vector(0,0,0)/256
	input_text.hovercolor = Vector(80,80,80)/256
	input_text:SetColor(input_text.upcolor)
	input_text:SetTextColor( Vector(1,1,1))
	input_text:Dock(DOCK_BOTTOM)
	input_text:SetSize(30,30)
	input_text.OnKeyDown = function(n,key) self:InputKeyDown(n,key) end 
	input_text.OnTextChanged = function(n,text) self:TextChanged(n,text) end 
	self.input_text = input_text
	
	self.input_history_up = Stack(50)
	self.input_history_down = Stack(50)
	
	local list = panel.Create("list") 
	list.reverse = true
	list.lineheight = 30 
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
function PANEL:Refresh() 
	if self.enabled then
		local list = self.list  
		if list then 
			local lines = debug.ConsoleGet(100) 
			list.lines = lines
			list:Refresh() 
		end
		local wsize = GetViewportSize()
		local sdiv = self.screendiv or 4
		self:SetSize(wsize.x,wsize.y/sdiv)
		self:SetPos(0,wsize.y-wsize.y/sdiv-30)
		--self.input_text:Select() 
		if self.first then 
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

function PANEL:InputKeyDown(n,key) 
	if key== KEYS_ENTER then
		local text = n:GetText()
		console.Call(text) 
		
		while self.input_history_down:Peek() do
			local txt = self.input_history_down:Pop()
			if not string.empty(txt) then 
				self.input_history_up:Push(txt)
			end
		end
		if text ~= self.input_history_up:Peek() and not string.empty(text) then
			self.input_history_up:Push(text)
		end
		if text == "debug" then 
			local debugp = panel.Create("window_debug")  
			debugp:SetTitle("Debug") 
			debugp:UpdateLayout() 
			debugp:SetPos(-800,0)
			self:GetParent():Add(debugp) 
		elseif text == "testgui" then  
			local debugp = panel.Create("tree")
			debugp:SetPos(-800,0)
			debugp:SetSize(400,800)
			self:GetParent():Add(debugp)    
			debugp:UpdateLayout() 
		end
		n.text = ""
		n:SetText2("") 
		self:Refresh()
	end
	if key == KEYS_UP then
		local text = n:GetText()
		local upt = self.input_history_up:Pop() 
		if upt then 
			self.input_history_down:Push(text) 
			n.text = upt
			n:SetText2(upt) 
		end
	end
	if key == KEYS_DOWN then
		local text = n:GetText()
		local upt = self.input_history_down:Pop() 
		if upt then 
			self.input_history_up:Push(text) 
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
	if key == KEYS_CONTROLKEY then 
		if self.screendiv>2 then
			self.screendiv = 1.2
		else
			self.screendiv = 4 
		end
		debug.Delayed(100,function()
		self.list:ScrollToBottom() 
		end)
	end
	if key == KEYS_OEMTILDE then 
		--self:Close()
		--self.input_text:Deselect()  
		--self.enabled = false  
		--MsgN("ee")
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
	
	if key ~= KEYS_UP and key ~= KEYS_DOWN then
		self:TextChanged(n,n:GetText())
	end
	 
end
function PANEL:TextChanged(n,text)   
	if string.len( text)>=3 then
		local variants = console.AutoComplete(text)
		local ctmp = {}
		self.input_history_down:Clear()
		if variants then
			for k, v in ipairs(variants) do
				if #ctmp> 10 then break end
				ctmp[#ctmp+1] = {text=v[1]}
			end
			for k, v in ipairs(ctmp) do 
				self.input_history_down:Push(ctmp[#ctmp-k+1].text)
			end
		end 
		local w = self:GetSize().x*0.5
		ContextMenu(self,ctmp,
			self.input_text:GetScreenPos()*2
			+self.input_text:GetSize()*Point(-1,-1),0,
			function(b)
				b:SetSize(w,30)
				b:SetTextColor(Vector(0.8,0.8,1))
				b:SetColor(Vector(0,0,0))
			end) 
	else
		ContextMenu(self,nil)
	end
end


FunctionIsSafeToGet = function(text)
	if string.starts(text,'Entity(') then
		return true
	end	 
	if string.starts(text,'Vector(') then
		return true
	end	 
	if string.starts(text,'LocalPlayer(') then
		return true
	end	 
	if string.starts(text,'Get') then
		return true
	end	 
end

LuaFunctionAutocomplete = function(parent,key)
	local r = {}  
	if parent then
		if type(parent)=='userdata' then
			parent = getmetatable(parent)
		end
		
		if type(parent)=='table' then
			for k,v in pairs(parent) do
				if string.starts(k,key) then 
					r[#r+1] = k
				end
			end
		end
	end
	return r

end
LuaApiGetSub = function(parent,key)

end
