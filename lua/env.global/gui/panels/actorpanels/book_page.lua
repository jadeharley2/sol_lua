 
local layout = {
	size = {400,500},
	texture = "textures/gui/rough.png",
	subs = {
		{ name = 'header',
			size = {20,20},
			dock = DOCK_TOP,
			color = {0.5,0.5,0.5}, 
			text = "Book title",
			subs = {
				{ type = "button", name = "bclose",
					size = {20,20},
					dock = DOCK_RIGHT,
					textonly = true,
					text = "X",
					ColorAuto = Vector(0,0,0) 
				},
			}
		},


		{ --buttons panel
			size = {20,20},
			dock = DOCK_BOTTOM,
			color = {0.5,0.5,0.5},
			subs = {
				{ type = "button", name = "bnext",
					size = {20,20},
					dock = DOCK_RIGHT,
					texture = "textures/gui/panel_icons/step.png",
					ColorAuto = Vector(0,0,0) 
				},
				{ type = "button", name = "bprev",
					size = {20,20},
					dock = DOCK_RIGHT,
					texture = "textures/gui/panel_icons/step.png", 
					rotation = 180,
					ColorAuto = Vector(0,0,0)
				},
				{ name = "pagedesc",
					size = {200,20},
					dock = DOCK_LEFT,
					textonly = true,
					text = "Page 1/1" 
				}
			}
		},
	}
}
function PANEL:Init()  
	gui.FromTable(layout,self,{},self)
	self.bnext.OnClick = function(s)
		local pg = self.text:GetPage()+1
		self:SetPage(pg+1)
	end
	self.bprev.OnClick = function(s)
		local pg = self.text:GetPage()+1
		self:SetPage(pg-1)
	end 
	self.bclose.OnClick = function(s)
		local pg = self.text:GetPage()+1
		self:Close()
	end 
	self:EnableHooks()
end 
function PANEL:ApplyEditHooks(v)
	v.type = "button"
	v.OnClick = function (s)
		panel.start_drag(s,1)  
	end
	v.subs = v.subs or {}
	v.subs[#v.subs+1] = {
		dock = DOCK_RIGHT,
		textonly=true,
		size ={8,8},
		subs = {
			{type = "button",
				size ={8,8},
				dock = DOCK_BOTTOM,
				OnClick = function (s)
					local pp = s:GetParent():GetParent()
					panel.start_resize(pp,1,Point(1,1))
				end
			},
			{type = "button",
				size ={8,8},
				dock = DOCK_TOP,
				ColorAuto = Vector(1,0,0),
				OnClick = function (s)
					local pp = s:GetParent():GetParent()
					local up = pp:GetParent()
					up:Remove(pp)
				end
			}
		}
	} 
end
function PANEL:EnableHooks()
	hook.Add('input.keydown',"book",function(key)
		if key == KEYS_LEFT then
			local pg = self.text:GetPage()+1
			self:SetPage(pg-1)
		elseif key == KEYS_RIGHT then
			local pg = self.text:GetPage()+1
			self:SetPage(pg+1)
		elseif key == KEYS_ESCAPE then
			self:DisableHooks()
			self:Close()
			testbook = false
		end
	end)
end
function PANEL:DisableHooks()
	hook.Remove('input.keydown',"book")
end

function PANEL:SetPage(pg) 
	local mpg = self.text:GetPageCount()
	if pg<1 then pg = 1 end
	if pg>mpg then pg = mpg end 
	self.text:SetPage(pg-1)
	self.pagedesc:SetText('Page '..tostring(pg)..'/'..tostring(mpg))
end
function PANEL:GetPage()  
	return self.text:GetPage()+1 
end
function PANEL:Scroll(delta)
	if delta>0 then
		self:SetPage(self:GetPage()-1)
	elseif delta<0 then
		self:SetPage(self:GetPage()+1)
	end
end

function PANEL:SetForm(formid,editmode)
	self.editmode = editmode
	if self.text then
		self:Remove(self.text)
	end
	local ltex = { name = 'text',  
		dock = DOCK_FILL,
		textcolor = {0,0,0},
		textonly = true,
		text = "text",
		textalignment = ALIGN_TOPLEFT,
		multiline=true,
		lineheight = 20,
		linespacing = 5,
		autowrap = true,
		margin = {4,4,4,4},
		-- 39 chars per line of 400 width and lineheight 20 
	}
	if editmode then
		ltex.type = "input_text"
		ltex._sub_caretoverlay = { 
			textalignment = ALIGN_TOPLEFT,
			autowrap = true,
			multiline=true,
			lineheight = 20,
			linespacing = 5, 
		}
	end
	self:Add(gui.FromTable(ltex,nil,{},self))


	local data = forms.ReadForm(formid)
	if data and (data.text or data.lines) then
		local txt = false
		--PrintTable(data.text)
		local intr = data.surface
		if intr then
			if editmode and intr.subs then
				for k,v in pairs(intr.subs) do
					self:ApplyEditHooks(v)
				end
			end
			gui.FromTable(intr,self,{},self) 
		end
		if data.text then
			if isstring(data.text) then
				self.markdown = true
				self:Remove(self.text)
				ltex = { type = "markdown", name = "text",
					dock = DOCK_FILL,
					textonly = true,
					margin = {4,4,4,4},
				}
				self:Add(gui.FromTable(ltex,nil,{},self)) 
				local path = 'data/forms/items/books/'..data.text
				local file = io.open( path, "r" )
				if (file) then 
					contents = file:read('*all')
					file:close()
					self.text:SetMarkdown(contents)
				end
			else
				for k,v in ipairs(data.text) do
					if k == 1 then
						txt = v
					else
						txt = txt .. v
					end
				end
			end
		elseif data.lines then
			for k,v in ipairs(data.lines) do
				if k == 1 then
					txt = v
				else
					txt = txt ..'\n'.. v
				end
			end
		end
		if txt then
			txt = string.replace(txt,'<a>','\a') 
			txt = string.replace(txt,'<br>','\n') 
			txt = string.replace(txt,'<line>','\n\n') 
			txt = string.replace(txt,'<tab>','\t\t') 
			self.text:SetText(txt)
		end
		self.header:SetText(data.name or "Untitled book")
		self:UpdateLayout()
		self:SetPage(1)
	end
	self:UpdateLayout()
end  
function PANEL:OnMouseWheel(delta)  
	self:Scroll(delta)
end
testbook = testbook or false
console.AddCmd('book',function(name,edit)
	if testbook then
		testbook:Close()
		testbook = nil
	else
		name = name or 'testbook'
		testbook = panel.Create('book_page')
		testbook:SetForm('book.'..name,edit~=nil)
		testbook:Show()
	end

end)