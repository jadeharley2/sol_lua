LOCALTABLET = LOCALTABLET or false
PANEL.basetype = "window"

function PANEL:Init() 
	self.fixedsize = true
	self.base.Init(self)  
end 

function PANEL:Setup(formid, data)
	LOCALTABLET = self
	local comdata = data.parameters.scriptdata.computer
	self.memory = comdata.memory
	self.filesystem = self:InitFS()
	self:SetSize(600,800)
	local ptable = {}

	self.inner:Add(gui.FromTable({
		texture = "textures/gui/tablet_bg.png",
		mouseenabled =false,
		size = {850,1000}
	}))


	local floater = panel.Create() 
	floater:SetSize(600,800-20)
	floater:SetColor(Vector(0,0.1,0))
	floater:SetColor2(Vector(0,0,0))
	floater:SetTextOnly(true)
	self.floater = floater
	
	
	
	local ff_grid = panel.Create("floatcontainer") 
	ff_grid:Dock(DOCK_FILL)
	ff_grid:SetScrollbars(1) 
	ff_grid:SetFloater(floater) 
	ff_grid:SetColor(Vector(0.1,0,0))
	ff_grid:SetColor2(Vector(0,0,0))
	ff_grid:SetTextOnly(true)
	ff_grid.inner:SetTextOnly(true)
	self.ff_grid = ff_grid
	self.inner:Add(ff_grid)
	local y = floater
 
	gui.FromTable({  
		subs = {
			{ name = "desktop",
				ismode = true,
				size = {32,32},
				texture = "models/items/space/tex/default.png",
				rotation = 180,
				dock = DOCK_FILL,
				subs = {
					{   
						textonly = true,
						rotation = 180,
						dock = DOCK_FILL,
						subs = {
							{ type = "fileicon",
								--text = "Files",  
								_sub_title = {
									text = "Files"
								},
								pos = {-450,-400},
								--dock = DOCK_TOP,
								OnClick = function (s) 
									self:SwitchTo("filemanager") 
									self.fsview:OpenPath()
								end
							},
							{ type = "fileicon",
								--text = "Files",  
								texture = "textures/gui/icons/com/camera.png", 
								_sub_title = {
									text = "Camera"
								},
								pos = {450,-400},
								--dock = DOCK_TOP,
								OnClick = function (s)  
									self:SwitchTo("camera")  
								end
							} ,
							{ type = "fileicon",
								--text = "Files",  
								texture = "textures/gui/icons/com/writer.png", 
								_sub_title = {
									text = "Writer"
								},
								pos = {450,-580},
								--dock = DOCK_TOP,
								OnClick = function (s)   
									self:SwitchTo("writer")  
								end
							} 
						}
					} 
				}
			},
			{ name = "filemanager", 
				color = {0.3,0.3,0.3},
				pos = {-1200,0},
				ismode = true,
				dock = DOCK_FILL,
				subs = {
					{ 
						color = {0.2,0.2,0.2},
						size = {64,64}, 
						dock = DOCK_BOTTOM,
						subs = { 
							{ type = "button", 
								texture = "textures/gui/icons/com/back.png", 
								size = {64,64}, 
								margin = {5,5,5,5},
								dock = DOCK_LEFT,
								OnClick = function (s) self:SwitchTo("back") end
							}
						}
					},
					{type = "files",  name = "fsview",
						dock = DOCK_FILL,
						itemheight = 32,
						_sub_menu= {
							size ={32,32},
						},
						_sub_pardir = {32,32},
						OnItemDoubleClick = function (s,item)
							self:OpenFile(item)
						end
					}
				}
			},
			{ name = "fileviewer", 
				color = {0.3,0.3,0.3},
				pos = {-1200,0},
				ismode = true,
				dock = DOCK_FILL,
				subs = {
					{ name = "filevname",
						color = {0.2,0.2,0.2},
						size = {32,32}, 
						dock = DOCK_TOP,
						text = "FILENAME",
						textcolor = {1,1,1}
					},
					{ 
						color = {0.2,0.2,0.2},
						size = {64,64}, 
						dock = DOCK_BOTTOM,
						subs = { 
							{ type = "button", 
								texture = "textures/gui/icons/com/back.png", 
								size = {64,64}, 
								margin = {5,5,5,5},
								dock = DOCK_LEFT,
								OnClick = function (s) self:SwitchTo("back") end
							}
						}
					},
					{ name = "fileplace",
						dock = DOCK_FILL,
						color = {0.3,0.3,0.3},
					}
				}
			},
			{ name = "camera", 
				color = {0.3,0.3,0.3},
				pos = {-1200,0},
				ismode = true,
				dock = DOCK_FILL,
				subs = {
					{ 
						color = {0.2,0.2,0.2},
						size = {64,64}, 
						dock = DOCK_TOP, 
					},
					{ 
						color = {0.2,0.2,0.2},
						size = {64,64}, 
						dock = DOCK_BOTTOM,
						subs = { 
							{ type = "button", 
								texture = "textures/gui/icons/com/back.png", 
								size = {64,64}, 
								margin = {5,5,5,5},
								dock = DOCK_LEFT,
								OnClick = function (s) self:SwitchTo("back")   end
							},
							{ type = "button", 
								texture = "textures/gui/icons/com/camera.png", 
								size = {64,64}, 
								margin = {5,5,5,5}, 
								OnClick = function (s) 
									self:MakeShot()
								end
							},
							{ type = "button", 
								texture = "textures/gui/icons/com/folder.png", 
								size = {64,64}, 
								margin = {5,5,5,5},
								dock = DOCK_RIGHT,
								OnClick = function (s) self:SwitchTo("filemanager") self.fsview:OpenPath("camera/")  end
							},
						}
					},
					{   name = "backcamv",
						color = {0,0,0},
						dock = DOCK_FILL, 
						size = {600-10,400-10}, 
						margin = {5,5,5,5}, 
					},
					{   name = "camview",
						--dock = DOCK_TOP, 
						size = {600-10,400-10}, 
						--margin = {5,5,5,5},
						texture = "@main_final"
					}
				}
			},
			{ name = "writer", 
				color = {0.3,0.3,0.3},
				pos = {-1200,0},
				ismode = true,
				dock = DOCK_FILL,
				subs = {
					{ 
						color = {0.2,0.2,0.2},
						size = {64,64}, 
						dock = DOCK_TOP, 
					},
					{ 
						color = {0.2,0.2,0.2},
						size = {64,64}, 
						dock = DOCK_BOTTOM,
						subs = { 
							{ type = "button", 
								texture = "textures/gui/icons/com/back.png", 
								size = {64,64}, 
								margin = {5,5,5,5},
								dock = DOCK_LEFT,
								OnClick = function (s) self:SwitchTo("back")   end
							},
							{ type = "button", 
								texture = "textures/gui/panel_icons/stats.png", 
								size = {64,64}, 
								margin = {5,5,5,5},
								dock = DOCK_RIGHT,
								OnClick = function (s)
									--self.bddpanel:SetVisible(false)
									self.bbrpanel:SetVisible(not self.bbrpanel:GetVisible())
									self:UpdateLayout()
								end
							},
							{ type = "button", 
								--texture = "textures/gui/panel_icons/stats.png", 
								text  = "+",
								size = {64,64}, 
								margin = {5,5,5,5},
								dock = DOCK_RIGHT,
								OnClick = function (s)
									--self.bbrpanel:SetVisible(false)
									self.bddpanel:SetVisible(not self.bddpanel:GetVisible())
									self:UpdateLayout()
								end
							},
						}
					},
					{ name = "bbrpanel",
						color = {0.1,0.15,0.2},
						size = {64,64},
						dock = DOCK_LEFT,
						--visible = false,
						subs = { 
							{ type = "button", 
								dock = DOCK_TOP,
								texture = "textures/gui/panel_icons/new.png", 
								size = {64,64}, 
								margin = {0,5,0,5}, 
								OnClick = function (s)  
									self.wri_bookplace:ClearItems()
									self.wri_book = nil
								end
							},
							{ type = "button", 
								dock = DOCK_TOP,
								texture = "textures/gui/panel_icons/load.png", 
								size = {64,64}, 
								margin = {0,5,0,5}, 
								OnClick = function (s)  
									self:OpenFileDialog(function (path,data)
										if data._type=="book" then
											if string.starts( data.formid,"book.") then 
												local book = panel.Create('book_page')
												book.bclose:SetVisible(false)
												book:SetForm( data.formid,true)
												self.wri_bookplace:ClearItems()
												self.wri_bookplace:AddItem(book)
												self.wri_book = book
												return true
											end 
										end
									end)
								end
							},
							{ type = "button", 
								dock = DOCK_TOP,
								texture = "textures/gui/panel_icons/save.png", 
								size = {64,64}, 
								margin = {0,5,0,5}, 
								OnClick = function (s)  
									--test 
									json.Write("PROFILE@userdata/test.json",{a = 1,b = 2, c = 3})
								end
							},
						}
					},
					{ name = "bddpanel",
						color = {0.1,0.15,0.2},
						size = {64,64},
						dock = DOCK_RIGHT,
						--visible = false,
						subs = { 
							{ type = "button", 
								dock = DOCK_TOP,
								texture = "textures/gui/panel_icons/image.png", 
								size = {64,64}, 
								margin = {0,5,0,5}, 
								OnClick = function (s)   
									if self.wri_book then 
										self:OpenFileDialog(function (path,data)
											if data._type=="image" then  
												if self.wri_book then 
													local imd = { 
														texture = data.data,
														size = {256,256},
													}
													self.wri_book:ApplyEditHooks(imd)
													local imag = gui.FromTable(imd) 	
													self.wri_book:Add(imag)
													imag:UpdateLayout()
													self:UpdateLayout()
												end
												return true 
											end
										end)
									end
								end
							},
							{ type = "button", 
								dock = DOCK_TOP,
								texture = "textures/gui/panel_icons/form.png", 
								size = {64,64}, 
								margin = {0,5,0,5}, 
								OnClick = function (s)  
								end
							}, 
							{ type = "button", 
								dock = DOCK_TOP,
								texture = "textures/gui/panel_icons/image.png", 
								size = {64,64}, 
								margin = {0,5,0,5}, 
								OnClick = function (s)   
									if self.wri_book then 
										self:OpenFileDialog(function (path,data)
											if data._type=="image" then   
												if self.wri_book then 
													self.wri_book:SetTexture(data.data)
												end
												return true 
											end
										end)
									end
								end
							},
						}
					},
					{  type = "list",  name = "wri_bookplace",
						color = {0,0,0},
						dock = DOCK_FILL, 
						size = {600-10,400-10}, 
						margin = {5,5,5,5}, 
					} 
				}
			},
		}  
	},y,{},ptable)
	for k,v in pairs(ptable) do
		self[k] = v
	end
	self.ptable = ptable

	self.fsview:SetFileSystem(self.filesystem)
	self.switchstack = Stack()
	self:SwitchTo("desktop")
	self:UpdateLayout() 
	ff_grid:Scroll(-9999999)
	ff_grid.vbar:SetSize(0,0)
end  
function PANEL:OpenFileDialog(callback)
	self.fsopenhook = callback
	self:SwitchTo("filemanager")
	--self.fsview:OpenPath()
end
function PANEL:OpenFile(filename)
	local data = table.get(self.memory,filename,'/') 
	if data then
		if self.fsopenhook then
			if self.fsopenhook(filename,data) then
				self:SwitchTo("back")
			end
		else
			self.fileplace:Clear()
			self.filevname:SetText(filename)
			if data._type=="book" then
				if string.starts( data.formid,"book.") then 
					book = panel.Create('book_page')
					book.bclose:SetVisible(false)
					book:SetForm( data.formid)
					self.fileplace:Add(book)
				end
				self:SwitchTo("fileviewer")
			elseif data._type =="image" and data.data then
				self.fileplace:Add(gui.FromTable({
					size = {600,600},
					dock = DOCK_FILL,
					texture = data.data
				}))  
				
				self:SwitchTo("fileviewer")
			end
		end
	end
end
function PANEL:MakeShot() 
	local orig = LoadTexture("@main_final")
	if orig then 
		local filename = "shot"..tostring(math.floor(CurTime()))
		local copy = orig:Copy('@'..filename)
		if copy then
			local path = "userdata/images/"..filename..".png"
			copy:Save("PROFILE@"..path)

			self.memory.camera = self.memory.camera or {}
			self.memory.camera[filename] = {
				_type = "image",
				data = path--'@'..filename
			}
			self.backcamv:SetColor(Vector(1,1,1))
			self.backcamv:AnimateColor("Color",Vector(0,0,0),0.3,easing.easeout)
		end
	end
end
function PANEL:SwitchTo(mode)
	if mode=="back" then 
		self.fsopenhook = nil
		if self.switchstack:Peek() then
			mode = self.switchstack:Pop()
		else
			mode = "desktop"
		end
	else
		if self.curmode then
			self.switchstack:Push(self.curmode)
		end
	end
	self.curmode = mode
	PrintTable(self.switchstack)
	for k,v in pairs(self.ptable) do
		if v.ismode then
			if k~='desktop' then
				if  k==mode then
					v:SetPos(-1200,0)
					v:MoveTo(Point(0,0),0.1,easing.ease)
					debug.Delayed(40,function ()
						v:SetVisible(true)
					end)
				else 
					v:MoveTo(Point(-1200,0),0.1,easing.ease)
					debug.Delayed(200,function ()
						v:SetVisible(false)
					end)
				end
			end
		end
	end
	self:UpdateLayout() 
end
function PANEL:InitFS()  
	local fs = {}
	fs.GetDirectories = function(dir)
		local ray = table.get(self.memory,dir,'/') or {}
		local rez = {}
		for k,v in pairs(ray) do
			if not v._type then 
				rez[#rez+1] = dir..'/'..k
			end
		end
		return rez
	end
	fs.GetFiles = function(dir)
		local ray = table.get(self.memory,dir,'/') or {}
		local rez = {}
		for k,v in pairs(ray) do
			if v._type then 
				rez[#rez+1] = dir..'/'..k
			end
		end
		return rez
	end 
	return fs
end
function PANEL:UploadFile(path,ftype,formid,data)
	table.set(self.memory,path,'/',{
		_type = ftype,
		formid = formid,
		data = data
	})
end

console.AddCmd("cp_load",function(formid)
	if LOCALTABLET then
		local name = forms.GetName(formid)
		if name then
			LOCALTABLET:UploadFile("download/"..name,"book",formid)
		end
	else
		MsgN("computer not found!")
	end
end)