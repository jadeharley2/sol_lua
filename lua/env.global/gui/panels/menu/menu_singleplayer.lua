PANEL.basetype = "menu_dialog"
 
local style = {

}
local layout = {  
	subs = {  
		{type = "xsplit",
			margin = {10,10,10,10},
			dock = DOCK_BOTTOM,
			size = {40,40},
			alpha = 0,
			subs = {
				{name = "bload",type="button", class = "btn",
					text = "Load",  
					size = {100,20},
					pos = {-300,-150}, 
					OnClick = function() hook.Call("menu","load") end,
				}, 
				{name = "bback",type="button", class = "btn",
					text = "Back", 
					size = {100,20}, 
					pos = {0,-150}, 
					OnClick = function() hook.Call("menu","main") end,
				}, 
				{name = "bedt",type="button", class = "btn",
					text = "Void", 
					size = {100,20}, 
					pos = {300,-150}, 
					OnClick = function() LoadSingleplayer("editor_template","editor") end,
				}, 
			}
		},
		{type="list",name = "items",  -- class = "submenu",
			visible = true, 
			size = {400,120},
			dock = DOCK_FILL,
			margin = {10,10,10,10},
			color = {0,0,0},   
		}, 
		--[[
		{type="floatcontainer",name = "items",  -- class = "submenu",
			visible = true, 
			size = {400,120},
			dock = DOCK_FILL,
			margin = {10,10,10,10},
			color = {0,0,0},  
			textonly=true, 
			Floater = {type="panel",
				scrollbars = 1,
				color = {0,0,0}, 
				size = {400,120},
				textonly=true, 
				autosize={false,true}
			},
		}, ]]

	}
}
function PANEL:Init()  

	
	self.base.Init(self,"Singleplayer",500,500)
	gui.FromTable(layout,self.sub,{},self)
	self.list = self.items --.floater
	self:SetupStyle(self.bload)
	self:SetupStyle(self.bback)
	self:SetupStyle(self.bedt)
	self:OLDPopulateWorldList() 
	self:UpdateLayout()
end
function PANEL:OnShow() 
	--self:OLDPopulateWorldList() 
	--self:UpdateLayout()
	
end

function PANEL:PopulateWorldList() 
	local scenarios = forms.GetList('scenario')
	
	local lst = self.list
	lst:ClearItems()
	
	for k,v in pairs(scenarios) do 
		local data = forms.GetData('scenario',k)
		if data and data.name then
			local name = data.name 
			
			local sp_new = gui.FromTable({ type = "button",
				dock = DOCK_TOP,
				text = name, 
				textalignment = ALIGN_CENTER,
				size = {150,20},
				OnClick = function() 
					--self:SelectWorld(name)  
				end
			}) 
			lst:AddItem(sp_new)
			self:SetupStyle(sp_new)  
		end
	end
	--self:UpdateLayout()
	--self.items:Scroll(-99999)
end

function PANEL:OLDPopulateWorldList() 
	local flist = file.GetFiles("lua/env.global/world/entities/","lua")  

	local lst = self.list
	lst:ClearItems()

	for k,v in pairs(flist) do 
		local cname = string.lower( file.GetFileNameWE(v)) 
		if string.starts(cname,"world_") then 
			local meta = ents.GetType(cname)
			if meta and not meta.hidden then
				cname = string.sub( cname,7)
				local sp_new = gui.FromTable({ type = "button",
					dock = DOCK_TOP,
					text = meta.name or cname, 
					textalignment = ALIGN_CENTER,
					size = {150,20},
					OnClick = function() self:SelectWorld(cname) end
				}) 
				lst:AddItem(sp_new)
				self:SetupStyle(sp_new) 
			end
		end 
	end
	self:UpdateLayout()
	self.items:Scroll(-99999)
end
function PANEL:SelectWorld(world)
	--MsgInfo("s"..world)
	local class = ents.GetType("world_"..world)
	if class and (class.options or class.GetOptions) then
		local lst = self.list
		lst:ClearItems()

		local sp_new = gui.FromTable({ type = "button",
			dock = DOCK_TOP,
			text = "<< back", 
			textalignment = ALIGN_CENTER,
			size = {150,20},
			OnClick = function() self:OLDPopulateWorldList()   end
		}) 
		lst:AddItem(sp_new)
		self:SetupStyle(sp_new) 

		if class.GetOptions then
			rawset(class,'options', class.GetOptions()) 
		end

		for k,v in SortedPairs(class.options) do
			local sp_new = gui.FromTable({ type = "button",
				dock = DOCK_TOP,
				text = v.text or k, 
				textalignment = ALIGN_CENTER,
				size = {150,20},
				OnClick = function() LoadSingleplayer(world, k) end
			}) 
			if sp_new then
				lst:AddItem(sp_new)
				self:SetupStyle(sp_new) 
			end
		end
		self:UpdateLayout()
		self.items:Scroll(-99999)
	else
		LoadSingleplayer(world) 
	end 
	--	LoadSingleplayer(cname)  
				
end