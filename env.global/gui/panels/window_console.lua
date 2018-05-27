PANEL.basetype = "window"

function PANEL:Init()
	--PrintTable(self)
	self.base.Init(self)
	self:SetColor(Vector(0.6,0.6,0.6))
	local inner = self.inner
	local list = panel.Create("list") 
	list.reverse = true
	list.lineheight = 30
	--self.mv:SetColors(Vector(50,50,50)/256,Vector(150,150,150)/256,Vector(80,80,80)/256)
	--self.mv:SetTextColor(Vector(1,1,1))
	self.list = list
	--self:Add(list)
	local input_text = panel.Create("input_text")
	self.input_text = input_text
	
	input_text.downcolor = Vector(50,50,50)/256
	input_text.upcolor = Vector(0,0,0)/256
	input_text.hovercolor = Vector(80,80,80)/256
	input_text:SetColor(input_text.upcolor)
	input_text:SetTextColor( Vector(1,1,1))
	self.input_history_up = Stack(50)
	self.input_history_down = Stack(50)
	input_text.OnKeyDown = function(n,key) 
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
			n:SetText("") 
			self:Resize()
		end
		if key == KEYS_UP then
			local text = n:GetText()
			local upt = self.input_history_up:Pop() 
			if upt then 
				self.input_history_down:Push(text) 
				n.text = upt
				n:SetText(upt) 
			end
		end
		if key == KEYS_DOWN then
			local text = n:GetText()
			local upt = self.input_history_down:Pop() 
			if upt then 
				self.input_history_up:Push(text) 
				n.text = upt
				n:SetText(upt) 
			end
		end
		if key == KEYS_ESCAPE then 
			self.input_text:Deselect() 
			if MAIN_MENU.worldIsLoaded then 
				MAIN_MENU:MenuToggle() 
			end
		end
		if key == KEYS_OEMTILDE then 
			self.input_text:Deselect() 
			if MAIN_MENU.worldIsLoaded then  hook.Call("menu")  end 
			self:SetVisible(false)
			self.enabled = false  
		end
	end 
	
	--hook.Add( "console.onchanged","gui.console.refresh",function()
	self.upd = debug.DelayedTimer(0,100,-1,function() self:Resize() end)
	
	input_text:SetSize(30,30)
	list:SetSize(30,30)
	
	inner:Add(input_text) input_text:Dock(DOCK_BOTTOM)
	inner:Add(list)   list:Dock(DOCK_FILL)
	 
	self.clist = {self,inner,list,self.mv,self.bc}
	local calpha = 0.3
	for k,v in pairs(self.clist) do
		v:SetAlpha(calpha)
	end 
	self.list:SetAlpha(calpha*4) 
	self.input_text:SetAlpha(calpha*3)
	
	--test
	--if not FOO then
	--	local bar = panel.Create("bar")  
	--	bar:SetSize(800,30)
	--	bar:SetPos(0,20)
	--	bar:UpdateValues()
	--	self:Add(bar)
	--	--FOO = bar
	--	hook.Add("main.predraw","test1213"..debug.GetHashString(self),function() 
	--		local perf = render.GetGroupPerfomance()
	--		local vv = {}
	--		for k,v in pairs(perf) do
	--			vv[#vv+1] = {v=v,text =k}
	--		end
	--		bar:SetValue(vv)  
	--	end)
	--end 
	self.bc.OnClick = function() 
		self.input_text:Deselect() 
		self:SetVisible(false)
		self.enabled = false  
	end
end

function PANEL:Resize() 
	local list = self.list 
	--local input_text = self.input_text 
	if list then
		--local ss = self:GetSize() 
		--list:SetSize(ss.x-20,ss.y-80)
		--list:SetPos(0,20)
		local lines = debug.ConsoleGet(100) 
		list.lines = lines
		list:Refresh()
		--input_text:SetSize(ss.x-20,30)
		--input_text:SetPos(0,-ss.y+50)
	end
end

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end
function PANEL:Select() 
	debug.Delayed(100,function()
		self.input_text:Select() 
	end)
end