PANEL.basetype = "window"
FFFF = true
function PANEL:Init()
	--PrintTable(self)
	self.base.Init(self)
	self:Resize(Point(500,200))
	self:SetColor(Vector(0.6,0.6,0.6))
	local inner = self.inner
	
	local list = panel.Create("list")
	--self.mv:SetColors(Vector(50,50,50)/256,Vector(150,150,150)/256,Vector(80,80,80)/256)
	--self.mv:SetTextColor(Vector(1,1,1))
	list.reverse = true
	self.list = list
	
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
			local player = LocalPlayer()
			network.ChatSay(player,text)
			
			while self.input_history_down:Peek() do
				local txt = self.input_history_down:Pop()
				if not string.empty(txt) then 
					self.input_history_up:Push(txt)
				end
			end
			
			if player and not network.IsConnected() then
				player:Say(text)
			end
			if text ~= self.input_history_up:Peek() and not string.empty(text) then
				self.input_history_up:Push(text)
			end
			self:Deselect() 
			n.text = ""
			n:SetText("") 
			self.list:ScrollToBottom()
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
			self:Deselect() 
		end
	end
	input_text.OnDeselect = function(n) 
		self:SetVisibility(false)
	end
	
	self.list.lines = {}
	--self.list.items = {{text = 1},{text = 2},{text = 3},{text = 4},{text = 5}}
	
	hook.Add( "chat.msg.received",debug.GetHashString(self),function(sender,text)
		if sender then
			self.list.lines[#self.list.lines+1] = sender:GetName().. ":" .. text
		else
			self.list.lines[#self.list.lines+1] = text
		end
		self:Resize()
	end)
	hook.Add( "chat.clear",debug.GetHashString(self),function()
		self.list.lines = {}
		self:Resize()
	end)
	hook.Add( "network.disconnect",debug.GetHashString(self),function()
		self.list.lines[#self.list.lines+1] = "DISCONNECTED FROM SERVER"
		self:Resize()
	end)
	hook.Add( "network.connect",debug.GetHashString(self),function()
		self.list.lines = {}
		self:Resize()
	end)
	hook.Add( "window.resize",debug.GetHashString(self),function()
		local vsize = GetViewportSize()
		local csize = self:GetSize() 
		self:SetPos(-vsize.x+csize.x,-vsize.y+csize.y)
	end)
	
	input_text:SetSize(30,30)
	list:SetSize(30,30)
	
	inner:Add(input_text) input_text:Dock(DOCK_BOTTOM)
	inner:Add(list)   list:Dock(DOCK_FILL)
	
	self.clist = {self,inner,list,self.mv,self.bc}
	local calpha = 0.2
	for k,v in pairs(self.clist) do
		v:SetAlpha(calpha)
	end 
	self.list:SetAlpha(calpha*4) 
	self.input_text:SetAlpha(calpha*3)
	--self:OnResize() 
end

function PANEL:Resize() 
	local list = self.list 
	--local input_text = self.input_text 
	if list then
	--	local ss = self:GetSize() 
	--	list:SetSize(ss.x-20,ss.y-80)
	--	list:SetPos(0,20)  
		list:Refresh()
	--	input_text:SetSize(ss.x-20,30)
	--	input_text:SetPos(0,-ss.y+50)
		list:ScrollToBottom()
	end
end
function PANEL:SetVisibility(onoff)
	local calpha = calpha or 0.2
	if onoff then calpha = 0.2 else calpha = 0.01 end
	
	for k,v in pairs(self.clist) do
		v:SetAlpha(calpha)
	end 
	for k,v in pairs(self.borders) do
		v:SetAlpha(calpha)
	end 
	self.list:SetAlpha(calpha+0.4) 
	self.input_text:SetAlpha(calpha+0.3)
end
function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
	self:SetVisibility(true)
end
function PANEL:MouseLeave() 
	self:SetVisibility(false)
end

function PANEL:Select()
	self:SetVisibility(true)
	self.input_text:Select()
end
function PANEL:Deselect()
	self.input_text:Deselect()
	self:SetVisibility(false)
end

function PANEL:Msg(text)
	local list = self.list
	if list then
		list.lines[#list.lines+1] = text 
		list:ScrollToBottom()
	end
end
function PANEL:ClearAll() 
	local list = self.list
	if list then
		list.lines = {}
		list:ScrollToBottom()
	end
	self:Resize()
end