
local layout ={
	color = {0,0,0},
	size = {1000,800},
	subs = { 
		{ name = "menu",  
			size = {20,20},
			dock = DOCK_TOP,
			color = {0,0,0}, 
			subs = { 
				{type = "button", name = "pardir", texture = "textures/gui/panel_icons/left.png",--text = "<-",
					size = {20,20},
					dock = DOCK_LEFT
				},
				{name = "path"    ,type="input_text",   
					color = {0,0,0}, 
					dock = DOCK_FILL,
					textcolor = {1,1,1},
					text = "/", 
				}, 
			}
		},
		{type="list",  name = "lst",
			size = {20,20},
			color = {0,0,0}, 
			dock = DOCK_FILL,  
			subs= { 
				{type="floatcontainer",name = "items",  -- class = "submenu",
					visible = true, 
					size = {200,200}, 
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
local itemstyle = { btn={type = "button", 
	size = {20,20},
	dock = DOCK_TOP,
	textcolor = {1,1,1},
	margin = {1,1,1,1}
} }
function PANEL:Init()  
	gui.FromTable(layout,self,{},self)
	self.pardir.OnClick = function() self:OpenParentDirectory() end
	self.path.OnKeyDown = function(n,key) self:InputKeyDown(n,key) end 
	self:OpenPath(self.cpath or "")
end 

function PANEL:InputKeyDown(n,key) 
	if key== KEYS_ENTER then
		local text = n:GetText()
		if #text>1 and string.sub(text,1,1)=='/' then
			text = string.sub(text,2)
		end
		self:OpenPath(text)
	end
end
function PANEL:SetFilter(filter)
	MsgN(filter)
	self.filter = filter
end
function PANEL:SetFileSystem(fs) 
	self.filesystem = fs
	self:OpenPath(self.cpath or "")
end
function PANEL:SetFormFS(formtype)
	local u = false
	if not formtype then
		u = {}
		for k,v in pairs(forms.GetList()) do
			--MsgN(k,v)
			local z = {} 
			for kk,vv in pairs(forms.GetList(v)) do
				z[kk] = vv
				--MsgN(kk)
			end
			u[v] = table.MakeKVTree(z,'.')
		end
	else
		u = forms.GetList(formtype)
	end
	if u then
		ud = table.MakeKVTree(u,'.')
		local fs = {}
		fs.GetDirectories = function(dir)
			local ray = table.get(ud,dir,'/') or {}
			local rez = {}
			for k,v in pairs(ray) do
				if(istable(v)) then 
					rez[#rez+1] = dir..'/'..k
				end
			end
			return rez
		end
		fs.GetFiles = function(dir)
			local ray = table.get(ud,dir,'/') or {}
			local rez = {}
			for k,v in pairs(ray) do
				if(not istable(v)) then 
					rez[#rez+1] = dir..'/'..k
				end
			end
			return rez
		end
		self:SetFileSystem(fs)
	end
end
local selectpath = function(s)
	--MsgN(s.dpath)
	s.dmenu:OpenPath(s.dpath)
end
local selectfile = function(s) 
	--MsgN(s.dpath)
	s.dmenu:OnItemClick(s.dpath)
end
local getfolder = function(pth)
	local pts = string.split(pth,"/") 
	return string.join("/",table.Take(pts,math.max(0,#pts-1))) 
end
local getfilename = function(pth)
	local pts = string.split(pth,"/") 
	return pts[#pts] or ''
end
function PANEL:OpenParentDirectory()
	local pth = getfolder(self.cpath)
	self:OpenPath(pth)
end
function PANEL:OpenPath(pth)
	local file = self.filesystem or file
	pth = pth or ""
	self.cpath = pth
	local fpth = pth
	if not string.ends(fpth,'/') then fpth = fpth .. '/' end
	self.path:SetText2(fpth)
	--self.path.text = fpth
	local items = self.items.floater
	items:Clear() 
	--items:Add(gui.FromTable({class="btn",text = ".." ,size = {20,16},dock = DOCK_TOP, 
	--TextColorAuto = Vector(0.1,0.7,1),
	--ColorAuto = Vector(0.2,0.2,0.2),
	--margin = {1,1,1,1},
	--dpath = getfolder(pth), dmenu = self, OnClick = selectpath 	},nil,itemstyle))
	
	local udir = {}
	for k,v in pairs(file.GetDirectories(pth)) do udir[v] = true end
	
	local ufls = {}
	for k,v in pairs(file.GetFiles(pth)) do ufls[v] = true end
	
	for k,v in SortedPairs(udir) do 
		local sb = getfilename(k).."/"
		local uk = k 
		if string.sub(uk,1,1)=='/' then uk = string.sub(uk,2) end
		local item =gui.FromTable({class="btn",text = sb,size = {20,16},dock = DOCK_TOP, 
		TextColorAuto = Vector(0.1,0.7,1),
		ColorAuto = Vector(0.2,0.2,0.2),
		margin = {1,1,1,1},
		dpath = uk, dmenu = self, OnClick = selectpath },nil,itemstyle)
		local r = self:OnDisplay(item,uk,true)
		if r~=false then items:Add(item) end
	end
	local filter = self.filter
	for k,v in SortedPairs(ufls) do 
		local sb = getfilename(k) 
		if not filter or sb:match(filter) then 
			local item = gui.FromTable({class="btn",text = sb,size = {20,16},dock = DOCK_TOP, 
			TextColorAuto = Vector(1,1,1),
			ColorAuto = Vector(0.2,0.2,0.2),
			margin = {1,1,1,1},
			dpath = k, dmenu = self,OnClick = selectfile },nil,itemstyle)
			local r = self:OnDisplay(item,k,false)
			if r~=false then items:Add(item) end
		end 
	end
	self:UpdateLayout()
	self.items:Scroll(-9999999)
end

function PANEL:OnSelected() 
end
function PANEL:OnItemClick(s) 

end

function PANEL:OnDisplay(item,data,isdirectory) 
end

 
function OpenFileDialog(cpath,filter,callback)
	if abstract_filepanel then
		abstract_filepanel:Close() 
		abstract_filepanel = nil
	end
	local pp = {}
	local p = gui.FromTable({
		size = {500,500},
		subs = {
			{
				size = {20,20},
				dock = DOCK_BOTTOM,
				color = {0,0,0},
				subs = {
					{ type = 'button', name = 'bclose',
						text = 'cancel',
						size = {200,200},
						dock = DOCK_RIGHT
					}, 
				}
			},
			{ type = 'files', name = 'files',
				dock = DOCK_FILL,
				Filter = filter  
			}
		}
	},nil,{},pp)  
	abstract_filepanel = p
	pp.bclose.OnClick = function()
		p:Close()
		abstract_filepanel = nil
	end
	pp.files.OnItemClick = function(s,item)
		p:Close()
		abstract_filepanel = nil
	    if callback then callback(item) end
	end
	pp.files:OpenPath(cpath or '')
	p:Show()
	pp.files.items:Scroll(-9999999)

end