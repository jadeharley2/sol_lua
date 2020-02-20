PANEL.basetype = "menu_dialog"

function PANEL:Init()  
	
	self.base.Init(self,"Multiplayer",400)
	
	gui.FromTable({
		subs = {
			{
				text = "Direct connect:",
				textonly = true,
				textcolor = {1,1,1},
				size = {20,20},
				dock = DOCK_TOP,
				subs = {
					{ type = "button", 
						texture = "textures/gui/panel_icons/star.png",
						contextinfo = "Add to favorites",
						size = {20,20},
						dock = DOCK_RIGHT,
						OnClick = function (s)
							MsgTextBox("Enter name:","Add server",{"Ok","Back"},function(result,name)
								MsgN(result,name)
								self:AddFavServer(name,self.server_ip:GetText())
							end)
						end
					},
					{ type = "button",
						text = "Connect",
						contextinfo = "Connect to server",
						size = {90,20},
						dock = DOCK_RIGHT,
						OnClick = function (s)
							self:Connect(self.server_ip:GetText())
						end
					},
					{ type = "input_text",
						name = "server_ip",
						size = {200,20},
						dock = DOCK_RIGHT,
						text = settings.GetString("network.lastip","")
					}
				}
			}, 
			{
				size = {25,25},
				dock = DOCK_BOTTOM,
				gradient = {{0,0,0},{0.1,0.1,0.1},90},
				subs = { 
					{ type = "button", 
						size = {200,30},
						dock = DOCK_LEFT,
						text = "Refresh servers",
						OnClick = function (s)
							self:LoadServers()
						end, 
					},
					{ type = "button", 
						size = {100,30},
						dock = DOCK_RIGHT,
						text = "Back",
						OnClick = function (s) 
							hook.Call("menu","main")
						end, 
					},
				}
			},
			{type = "tabmenu",
				dock = DOCK_FILL,
				tabs = {
					Favorites = {
						type = "list", name = "lfavorites",
						color = {0,0,0},
						items = {}
					},
					Browser = {
						subs = {
							{ 
								type = "list", name = "lservers",
								color = {0,0,0},
								dock = DOCK_FILL,
								items = {}
							},
							{ name = "slrefresher",
								size = {60,60}, 
								texture = "textures/gui/panel_icons/refresh.png",
								visible = false
							}
						}
					}
				}
			}
		}

	}, self,{},self)

	self:LoadFavorites()
	self:LoadServers()
end

function PANEL:LoadFavorites()
	local pr =  settings.GetData("network.favorites",nil)
	if pr and isuserdata(pr) then
		--MsgN("PR",pr)
		--PrintTable(pr)
		self.favlist =json.FromJson(pr)
	else
		self.favlist ={1}
	end
	

	local fdelserver = function (s)
		self:DelFavServer(s.serverid)
	end
	local fconnect = function (s)
		self:Connect(s.address)
	end

	self.lfavorites:ClearItems()
	if self.favlist and istable(self.favlist) then
		for k,v in pairs(self.favlist) do
			if istable(v) then
				self.lfavorites:AddItem(gui.FromTable(
				{   type = "button",
					size = {30,30}, 
					textcolor = {1,1,1},
					ColorAuto = Vector(0.1,0.1,0.1),
					margin = {1,1,1,1},
					text = v.name, 
					address = v.address,
					OnClick = fconnect,
					subs = {
						{type = "button",
							contextinfo = "Delete from favorites",
							texture = "textures/gui/panel_icons/delete.png",
							size = {30,30},
							dock = DOCK_RIGHT,
							serverid = k,
							OnClick = fdelserver
						},
						--{type = "button",
						--	contextinfo = "Rename",
						--	texture = "textures/gui/panel_icons/delete.png",
						--	size = {30,30},
						--	dock = DOCK_RIGHT
						--}
					}
				})) 
			end
		end
	end
	self.lfavorites:UpdateLayout()
	self.lfavorites:ScrollToTop()
end
function PANEL:LoadServers()

	local ffavserv = function (s)
		self:AddFavServer(s.servername,s.address)
	end
	local fconnect = function (s)
		self:Connect(s.address)
	end

	local r =0
	self.slrefresher:SetVisible(true)
	hook.Add(EVENT_GLOBAL_PREDRAW,"refresher",function ()
		r = r-5
		self.slrefresher:SetRotation(r)
	end)

	module.Require("masterserver")
	masterserver.GetServerlist( function (data)
		local list = json.FromJson(data)

		hook.Remove(EVENT_GLOBAL_PREDRAW,"refresher")
		self.slrefresher:SetVisible(false)

 
		if list and istable(list) then
			self.lservers:ClearItems()
			for k,v in pairs(list) do
				if istable(v) then
					self.lservers:AddItem(gui.FromTable(
					{   type = "button",
						size = {20,20}, 
						textcolor = {1,1,1},
						ColorAuto = Vector(0.1,0.1,0.1),
						margin = {1,1,1,1},
						text = v.name, 
						address = v.ip,
						OnClick = fconnect,
						subs = {
							{type = "button",
								contextinfo = "Add to favorites", 
								texture = "textures/gui/panel_icons/star.png",
								size = {20,20},
								dock = DOCK_RIGHT,
								servername = v.name, 
								address = v.ip,
								OnClick = ffavserv
							}, 
							{ 
								textonly = true,
								mouseenabled = false,  
								textcolor = {1,1,1},
								text = v.players.."/"..v.maxplayers,
								size = {60,20},
								dock = DOCK_RIGHT, 
							},   
							{ 
								textonly = true,
								mouseenabled = false,  
								textcolor = {1,1,1},
								text = v.world,
								size = {120,20},
								dock = DOCK_RIGHT, 
							}, 
						}
					})) 
				end
			end
			self.lservers:UpdateLayout()
			self.lservers:ScrollToTop()
		end
	end)
end

function PANEL:AddFavServer(name,address)
	if self.favlist and istable(self.favlist) then
		self.favlist[#self.favlist+1] = {name = name,address = address}
		settings.SetData("network.favorites",json.ToJson(self.favlist))
		settings.Save()

		self:LoadFavorites()
		MsgInfo("Server "..name.." at ".. address.." added to favorites")
	end
end
function PANEL:DelFavServer(id)
	if self.favlist and istable(self.favlist) then 
		self.favlist[id] =  nil 
		settings.SetData("network.favorites",json.ToJson(self.favlist))
		settings.Save()

		self:LoadFavorites()
	end
end
function PANEL:Connect(address)
	
	_GLT = address
	settings.SetString("network.lastip",_GLT)
	settings.Save()
	hook.Call("menu","loadscreen")
	debug.Delayed(1,function ()
		hook.AddOneshot("engine.worldstate.loaded","mp_load",function()   
			debug.Delayed(1,function()  
				engine.ResumePhysics()
				MAIN_MENU:SetWorldLoaded(true) 
				hook.Call("menu") 
				if chat then chat:Show() end
			end)
		end)
		debug.Delayed(1,function()  
			engine.PausePhysics() 
			if network.IsConnected() then
				world.UnloadWorld()
			end
			   
			if ConnectTo(_GLT) then
			else 
				debug.Delayed(1,function()  
					engine.ResumePhysics()
					hook.Call("menu","mp") 
					if chat then chat:Close() end
					MsgInfo("Can't connect to: "..address)
				end)
			end
		end)
	end)

end