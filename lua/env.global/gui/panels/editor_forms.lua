
 
local bsstyle = {
	p = {
		color = {0,0,0},
		textcolor = {1,1,1},
	},
	key = { 
		states = {
			idle    = {color = {0,0,0}},
			hover   = {color = {0.3,0.3,0.3}},
			pressed = {color = {1,1,1}},
		}, 
		stat = "idle",
		color = {0,0,0},
	},
} 
local layout = {
	name = "self",
	color = {0,0,0},
	size = {1000,600},
	subs = { 
		{name = "infopanel"    ,type="panel",  -- class = "submenu",
			visible = true, 
			size = {600,300},
			color = {0,0,0}, 
			dock = DOCK_BOTTOM,
			subs = {
				{name = "infopanel_header"    ,type="panel",  -- class = "submenu",
					color = {0.1,0.1,0.1},
					textcolor = {1,1,1},
					text = "Header",
					dock = DOCK_TOP,
					size = {600,20},
				},
				{name = "infopanel_text"    ,type="panel",  -- class = "submenu",
					color = {0,0,0},
					textcolor = {0.8,0.8,0.8}, 
					dock = DOCK_FILL,
					size = {600,20},
				},
			},
		}, 
		{type="panel",  -- class = "submenu",
			visible = true, 
			size = {400,300},
			color = {0,0,0}, 
			dock = DOCK_LEFT, 
			subs= { 
				{type="floatcontainer",name = "formtypelist",  -- class = "submenu",
					visible = true, 
					size = {200,200}, 
					dock = DOCK_TOP,
					color = {0,0,0}, 
					textonly=true, 
					Floater = {type="panel",
						scrollbars = 1,
						color = {0,0,0}, 
						size = {200,200}, 
						autosize={false,true}
					},
				},  
				{type="floatcontainer",name = "formlist",  -- class = "submenu",
					visible = true, 
					size = {600,300}, 
					dock = DOCK_FILL,
					color = {0,0,0}, 
					textonly=true,  
					Floater = {type="panel",
						scrollbars = 1,
						color = {0,0,0}, 
						size = {200,200}, 
						autosize={false,true}
					},
				}, 
			}
		}, 
		{type="list",  -- class = "submenu",
			visible = true, 
			size = {400,300},
			color = {0,0,0}, 
			dock = DOCK_FILL,  
			subs= { 
				{type="floatcontainer",name = "formcontainer",  -- class = "submenu",
					visible = true, 
					size = {600,300}, 
					dock = DOCK_FILL,
					color = {0,0,0}, 
					textonly=true, 
					Floater = {type="panel",
						scrollbars = 1,
						color = {0,0,0}, 
						size = {200,200}, 
						autosize={false,true}
					},
				}, 
			}
		}, 
		 
	}
}

 

function PANEL:Init()  
	 
	local nt = {}
	gui.FromTable(layout,self,{},nt,"menu") 
	self.formcontainer = nt.formcontainer.floater
	
	nt.formtypelist.inner:SetColor(Vector(0,0,0))
	nt.formlist.inner:SetColor(Vector(0,0,0))
	nt.formcontainer.inner:SetColor(Vector(0,0,0))
	
	self.formlist = nt.formlist 
	
	
	self:LoadFormTypeList(nt.formtypelist.floater,nt.formtypelist)
	
	--self:LoadForm("forms/items/tools/bow_kindred.json")
	
	self:UpdateLayout() 
end 
function PANEL:LoadFormTypeList(lst,lsf)
	lst:Clear()
	local testlist = forms.GetList()

	for k,v in SortedPairs(testlist,stdcomp) do
		lst:Add(gui.FromTable({ type="button",  -- class = "submenu", 
			size = {16,16},
			states = {
				idle    = {color = {0,0,0}},
				hover   = {color = {0.3,0.3,0.3}},
				pressed = {color = {1,1,1}},
			}, 
			stat = "idle",
			color = {0,0,0}, 
			textcolor = {1,1,1},
			text = v,
			dock = DOCK_TOP,  
			OnClick = function(s)
				--local path = forms.GetForm('character',k)
				--self:LoadForm(path)
				--lsf:SetScroll(0)
				self:LoadFormList(self.formlist.floater,self.formlist,v)
				self:UpdateLayout() 
			end
		})) 
	end
end
function PANEL:LoadFormList(lst,lsf,typ)
	lst:Clear()
	local testlist = forms.GetList(typ)

	for k,v in SortedPairs(testlist,stdcomp) do
		lst:Add(gui.FromTable({ type="button",  -- class = "submenu", 
			size = {16,16},
			states = {
				idle    = {color = {0,0,0}},
				hover   = {color = {0.3,0.3,0.3}},
				pressed = {color = {1,1,1}},
			}, 
			stat = "idle",
			color = {0,0,0}, 
			textcolor = {1,1,1},
			text = k,
			dock = DOCK_TOP,  
			OnClick = function(s)
				local path = forms.GetForm(typ,k)
				self:LoadForm(path)
				--lsf:SetScroll(0)
			end
		})) 
	end
	
end

function PANEL:LoadForm(path)
	local data = json.Read(path)
	if not data then return end
	self.curpath = path 
	self.curdata = data 
	
	local c = self.formcontainer
	
	c:Clear()
	self:NewProperty(c,"form: "..path,data) 
	self:UpdateLayout()
end 
function PANEL:ReloadForm()
	if self.curdata then
		local c = self.formcontainer
		c:Clear()
		self:NewProperty(c,"form: "..self.curpath, self.curdata) 
		self:UpdateLayout()
	end
end 

local func_new = function(p,s,t)
	local tag = t.tag
	tag[1][tag[2]] = tag[3]    
	tag[4]:ReloadForm() 
end

function PANEL:ContextNew(v,keytype) 
	ContextMenu(self,{ 
		{text = "table"  ,action = func_new, tag = {v,'@edit@',{},self} }, 
		{text = "string" ,action = func_new, tag = {v,'@edit@',"",self}  }, 
		{text = "number" ,action = func_new, tag = {v,'@edit@',0,self}   }, 
		{text = "boolean",action = func_new, tag = {v,'@edit@',false,self} }, 
	})
end

function PANEL:NewProperty(parent,k,v,pt)
	local pn = gui.FromTable({
		type = "panel",
		size = {20,20}, 
		color = {0,0,0},  
		dock = DOCK_TOP, 
		autosize = {false,true},
	})
	
	local valtype = type(v)
	
	if valtype == 'table' then  
		
		local nt = {}
		local kk = gui.FromTable(
		{type = "panel", class = "p",
			size = {20,20},
			dock = DOCK_TOP,
			subs = {
				{type = "button", 
					size = {20,20},
					dock = DOCK_RIGHT,  
					text = "X",
					textonly=true,
					textalignment = ALIGN_CENTER, 
					states = {
						idle    = {textColor = {1,0.3,0}},
						hover   = {textColor = {0.8,0.1,0}},
						pressed = {textColor = {1,1,1}},
					}, 
					state = "idle",
					OnClick = function(s)  
						if pt then
							pt[k] = nil
						end  
						self:ReloadForm()
					end,
				},
				{type = "button", 
					size = {20,20},
					dock = DOCK_RIGHT,  
					text = "A",
					textonly=true,
					textalignment = ALIGN_CENTER, 
					states = {
						idle    = {textColor = {0.3,1,0}},
						hover   = {textColor = {0.1,0.8,0}},
						pressed = {textColor = {1,1,1}},
					}, 
					OnClick = function(s)
						self:ContextNew(v)
					end,
					state = "idle",
				},
				{type = "button", name = "bexpand",
					size = {20,20},
					dock = DOCK_RIGHT,  
					text = "+", 
					textonly=true,
					visible = false,
					textalignment = ALIGN_CENTER, 
					states = {
						idle    = {textColor = {0.3,0.3,1}},
						hover   = {textColor = {0.1,0.1,0.3}},
						pressed = {textColor = {1,1,1}},
					}, 
					OnClick = function(s)  
						if pn.val then
							pn.val:SetVisible(true)
						end 
						nt.bexpand:SetVisible(false)
						nt.bcollapse:SetVisible(true)
						self.formcontainer:UpdateLayout()
					end,
					state = "idle",
				},
				{type = "button", name = "bcollapse",
					size = {20,20},
					dock = DOCK_RIGHT,  
					text = "-", 
					textonly=true,
					textalignment = ALIGN_CENTER, 
					states = {
						idle    = {textColor = {0.3,0.3,1}},
						hover   = {textColor = {0.1,0.1,0.8}},
						pressed = {textColor = {1,1,1}},
					}, 
					OnClick = function(s)  
						if pn.val then
							pn.val:SetVisible(false)
						end 
						nt.bexpand:SetVisible(true)
						nt.bcollapse:SetVisible(false)
						self.formcontainer:UpdateLayout()
					end,
					state = "idle",
				},
				{type = "input_text",  class = "key", name="key",
					size = {130,20},
					dock = DOCK_FILL,  
					text = tostring(k or "nil"),
					OnKeyDown = function(ss,kk)
						if kk == KEYS_ENTER then
							local tt = ss:GetText() 
							if k~=tt and tt~="" then
								pt[tt] = pt[k]
								pt[k] = nil 
							end
							ss:Deselect() 
							self:ReloadForm()
							self:ContextNew(v)
						end
					end,
				},
			
			}
		},nil,bsstyle,nt,"root")
		pn:Add(kk) 
		
		if k=='@edit@' then
			nt.key:SetText("")
			nt.key:Select()
		end
		
		local cn = 0
		for k,v in pairs(v) do cn = cn + 1 end
		
		if cn>0 then
			local tab = gui.FromTable({type = "panel", 
				size = {20,20},
				dock = DOCK_LEFT,  
				color = {0,0,0},  
				subs = {{type = "panel", 
					dock = DOCK_FILL,  
					margin = {9,1,9,1}, 
					color = {1,1,1},  
				}}
			})
			pn:Add(tab)
			local vv = gui.FromTable({type = "panel", 
				size = {20,20},
				dock = DOCK_TOP,
				autosize = {false,true},   
			})
			pn:Add(vv)
			local hadd = 0
			for k2,v2 in SortedPairs(v,stdcomp) do 
				hadd = hadd + self:NewProperty(vv,k2,v2,v)  
			end  
			pn.val = vv
			--pn:SetSize(20,hadd+20)
		end
	else 
		local kk = gui.FromTable({type = "input_text", class = "key",
			size = {130,20},
			dock = DOCK_LEFT,
			text = tostring(k or "nil"),
			OnKeyDown = function(ss,kk)
				if kk == KEYS_ENTER or kk == KEYS_TAB then
					local tt = ss:GetText()
					if k~=tt and tt~="" then
						pt[tt] = pt[k]
						pt[k] = nil
					end
					ss:Deselect()
					if kk == KEYS_TAB then
						self.editvalue = {pt,tt}
					end
					self:ReloadForm()
				end 
			end,
		},nil,bsstyle)
		pn:Add(kk)
		if k=='@edit@' then
			kk:SetText("")
			kk:Select()
		end
			
		local kkd = gui.FromTable({type = "button", 
			size = {20,20},
			dock = DOCK_RIGHT,  
			text = "X",
			textonly=true,
			textalignment = ALIGN_CENTER, 
			states = {
				idle    = {textColor = {1,0.3,0}},
				hover   = {textColor = {0.8,0.1,0}},
				pressed = {textColor = {1,1,1}},
			}, 
			state = "idle",
			OnClick = function(s)  
				if pt then
					pt[k] = nil
				end  
				self:ReloadForm()
			end,
		})
		pn:Add(kkd)
		
		local edv = self.editvalue
		local vv = false
		if valtype == 'string' then 
			vv = gui.FromTable({type = "input_text", 
				size = {20,20},
				dock = DOCK_TOP,
				text = tostring(v or "NIL"),
				OnKeyDown = function(ss,kk)
					if kk == KEYS_ENTER then
						pt[k] = ss:GetText()
						ss:Deselect() 
					end
				end,
			})
			if edv then
				if edv[1]==pt and edv[2]==k then
					vv:OnClick()
					self.editvalue = nil
				end
			end
		elseif valtype == 'number' then 
			vv = gui.FromTable({type = "input_text", 
				size = {20,20},
				dock = DOCK_TOP,
				text = tostring(v or "0"),
				rest_numbers = true,
				OnKeyDown = function(ss,kk)
					if kk == KEYS_ENTER then
						pt[k] = tonumber(ss:GetText())
						ss:Deselect() 
					end 
				end,
			})
			if edv then
				if edv[1]==pt and edv[2]==k then
					vv:OnClick()
					self.editvalue = nil
				end
			end
		elseif valtype == 'boolean' then 
			vv = gui.FromTable({type = "checkbox", 
				size = {20,20},
				dock = DOCK_TOP,
				value = v or false,
			})
			if edv then
				if edv[1]==pt and edv[2]==k then 
					self.editvalue = nil
				end
			end
		else 
			vv = gui.FromTable({type = "panel", 
				size = {20,20},
				dock = DOCK_TOP,
				text = tostring(v or "NIL"),
			})
			if edv then
				if edv[1]==pt and edv[2]==k then 
					self.editvalue = nil
				end
			end
		end
		if vv then 
			pn:Add(vv)
		end
	end
	parent:Add(pn)
	return pn:GetSize().y
end
  