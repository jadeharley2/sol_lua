

local layout = { --rightpanel
    size = {300,300},
    dock = DOCK_RIGHT,
    subs = {
        { 
            size = {40,40},
            dock = DOCK_TOP,
            color = {0,0,0},
            subs = { 
                { class = "bmenu", name = "bnew", texture = "textures/gui/panel_icons/new.png", 
                    contextinfo='Clear nodes'
                },
                { class = "bmenu",  name = "bsave", texture = "textures/gui/panel_icons/save.png",  
                    contextinfo = 'Save'
                },
                { class = "bmenu", name = "bsaveas", texture = "textures/gui/panel_icons/save.png",  
                    contextinfo = 'Save as'
                }, 
                { class = "bmenu",  name = "bload", texture = "textures/gui/panel_icons/load.png",   
                    contextinfo = 'Load'
                },  
                { class = "bmenu",  name = "bloadtarget", texture = "textures/gui/panel_icons/possnap.png",   
                    contextinfo = 'Load from target'
                }, 
            }
        },
        { 
            size = {40,40},
            dock = DOCK_TOP,
            color = {0,0,0},
            subs = {  
                { class = "bmenu",  name = "brun", texture = "textures/gui/panel_icons/play.png",   
                    contextinfo = 'Run'
                }, 
                { class = "bmenu",  name = "brun_cam", texture = "textures/gui/panel_icons/play.png",   
                    contextinfo = 'Run on local camera'
                }, 
                { class = "bmenu",  name = "brun_ply", texture = "textures/gui/panel_icons/play.png",   
                    contextinfo = 'Run on local player'
                }, 
                { class = "bmenu",  name = "brun_selected", texture = "textures/gui/panel_icons/play.png",   
                    contextinfo = 'Run on editor selection'
                },
                { class = "bmenu",  name = "bcom_selected", texture = "textures/gui/panel_icons/refresh.png",   
                    contextinfo = 'Recompile selected'
                },
            }
        },
        { 
            type = "tree", 
            name = "trpanel",
            size = {300,300},
            dock = DOCK_FILL 
        }
    }
}



function PANEL:Init()   
		
	self.cnodec = 0
	self.named = {}  
	self:Dock(DOCK_FILL)
	
	gui.FromTable(layout,self,global_editor_style,self)

 
	
	local ED = self 
	 
	   
	  
	local lastpath = "forms/flow"
	local curfilepath = false
	self.bnew.OnClick = function(s) 
		GLOBAL_FLOW_EDITOR:ClearNodes()
		curfilepath= ""
		GLOBAL_FLOW_EDITOR.curfile:SetText("untitled")
	end
	 
	self.bload.OnClick = function(s)  
		OpenFileDialog(lastpath,".json",function(path)
			lastpath = file.GetDirectory(path)
			GLOBAL_FLOW_EDITOR:Open(path)
			curfilepath= path
			GLOBAL_FLOW_EDITOR.curfile:SetText(path)
		end) 
	end
	self.bloadtarget.OnClick = function(s)   
		local c = E_FS:GetComponent(CTYPE_FLOW)
		if c then
			local path = c:GetScripts()[1]
			if path then
				lastpath = file.GetDirectory(path)
				GLOBAL_FLOW_EDITOR:Open(path)
				curfilepath= path
				GLOBAL_FLOW_EDITOR.curfile:SetText(path)
			end
		end
	end
	 
	 
	self.bsave.OnClick = function(s)  
		if curfilepath then
			json.Write(curfilepath,GLOBAL_FLOW_EDITOR:ToData())
			MsgInfo("Saved! "..curfilepath)
		else
			self.bsaveas.OnClick()
		end
	end
	  
	self.bsaveas.OnClick = function(s)  
		SaveFileDialog(lastpath,".json",function(path)
			json.Write(path,GLOBAL_FLOW_EDITOR:ToData())
			MsgInfo("Saved! "..path)
			curfilepath = path
			GLOBAL_FLOW_EDITOR.curfile:SetText(path)
		end)
	end
	 
	self.brun.OnClick = function(s) 
		GLOBAL_FLOW_EDITOR:Compile()
	end
	self.brun_cam.OnClick = function(s) 
		GLOBAL_FLOW_EDITOR:Compile(GetCamera())
	end
	self.brun_ply.OnClick = function(s) 
		GLOBAL_FLOW_EDITOR:Compile(LocalPlayer())
	end
	self.brun_selected.OnClick = function(s) 
		GLOBAL_FLOW_EDITOR:Compile(E_SELECTION)
	end
	self.bcom_selected.OnClick = function(s) 
		local c = E_FS:GetComponent(CTYPE_FLOW)
		if c then
			c:Recompile()
		end
	end
	
	 
	local trpanel = self.trpanel  
	local functlist = {}
	local comlist = {}
	
	local flist = flowbase.GetMethodList()
	
	for k,v in pairs(flist) do
		local type,name = unpack(v:split('.'))
		local tl = functlist[type] or {} 
		tl[#tl+1] = name
		table.sort(tl)
		functlist[type] = tl
	end
	
	for k,v in pairs(file.GetFiles("forms/flow/functions",".json",false)) do
		comlist[#comlist+1] = string.lower(file.GetFileNameWE(v))   
	end
	

	local eventlist = {"startup","invoke","interact","input.keydown"}
	for k,v in pairs(debug.GetAPIInfo('EVENT_')) do
		if string.starts(k,'EVENT_') then
			local subname =string.sub(string.lower(k),7)
			eventlist[#eventlist+1] = subname
		end
	end
	table.sort(eventlist)
	
	local tab = {
		event = eventlist, 
		flow = {"branch","assign","sequence","join","while","for"},
		constants = {"string","boolean","int","float","vector2","vector3","vector4","quaternion","Tex2DArray"},
		variables = {"string","boolean","int","float","vector2","vector3","vector4","quaternion","scriptednode"},
		input = {"string","boolean","int","float","vector2","vector3","vector4","quaternion","scriptednode"},
		output = {"string","boolean","int","float","vector2","vector3","vector4","quaternion","scriptednode"},
		functions = functlist,
		compounds = comlist,
		"group",
		map = {"point","line","polygon","group"},
	} 
	trpanel:SetTableType(3) 
	trpanel:FromTable(tab) 
	trpanel.root:SetSize(280,trpanel.root:GetSize().x)
	trpanel.grid:SetColor(Vector(0.1,0.1,0.1)) 
	
	trpanel.OnItemClick = function(tree,element)
		GLOBAL_FLOW_EDITOR:CreateNewNode(element)
	end 
	 
	
	self:UpdateLayout()

	trpanel:ScrollToTop()
	
end