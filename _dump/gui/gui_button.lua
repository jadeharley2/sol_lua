
META = {}

function META:Init()

end

function META:PerformLayout() 
	--onMouseDown += mDown;
	--onMouseUp += mUp;
	--onMouseEnter += mEnter;
	--onMouseLeave += mLeave;
	self.color = self.inactiveColor;
end

function META:Draw()
	
end

function META:MouseEnter()
	if (not self.isToggleable or (self.isToggleable and not self.isActiveToggle)) then
		self.color = self.activeColor
		self.isOver = true
	end
end
function META:MouseLeave()
	if (not self.isToggleable or (self.isToggleable and not self.isActiveToggle)) then
		self.color = self.inactiveColor
		self.isOver = false
	end
end
function META:MouseDown() 
	if (self.isToggleable) then
		self.isActiveToggle = not self.isActiveToggle
		if (self.isActiveToggle) then
			self.color = self.pressedColor
		else
			self.color = self.activeColor
		end
	else 
		self.color = self.pressedColor
	end
end
function META:MouseUp() 
	if (not self.isToggleable or (self.isToggleable and not self.isActiveToggle)) then 
		if (self.isOver) then
			self.color = self.activeColor
		else 
			self.color = self.inactiveColor
		end
	end
end

gui = {}
gui.types = {}
function gui.DefineControl(type,table)
	gui.types[type] = table
end
function gui.CreateControl(type)
	--return guiCreateNode(gui.types[type])
end

gui.DefineControl( "button", META )


--local test = gui.CreateControl("button")
--MsgN(test)
--PrintTable(test)
