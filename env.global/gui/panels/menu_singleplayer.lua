PANEL.basetype = "menu_dialog"
 

function PANEL:Init()  

	
	self.base.Init(self,"Singleplayer",200,500)
	
	 
	local bcol = Vector(83,164,255)/255
	
	local ff_grid_floater = panel.Create()  
	ff_grid_floater:SetSize(400,1000)
	
	 
	local flist = file.GetFiles("lua/env.global/world/entities/","lua") 
	local totals = 0
	for k,v in pairs(flist) do 
		local cname = string.lower( file.GetFileNameWE(v)) 
		if string.starts(cname,"world_") then 
			local meta = ents.GetType(cname)
			if meta and not meta.hidden then
				cname = string.sub( cname,7)
				local sp_new = panel.Create("button")
				sp_new:SetText(meta.name or cname) 
				sp_new:Dock(DOCK_TOP)
				sp_new:SetTextColorAuto(bcol) 
				sp_new:SetTextAlignment(ALIGN_CENTER)
				sp_new:SetSize(150,20)
				sp_new.OnClick = function() LoadSingleplayer(cname) end
				ff_grid_floater:Add(sp_new)
				self:SetupStyle(sp_new)
				totals = totals + 20
			end
		end 
	end
	ff_grid_floater:SetSize(400,totals)
	ff_grid_floater:SetColor(bcol)
	
	
	
	
	
	local ff_grid = panel.Create("floatcontainer") 
	ff_grid:SetSize(400,120)  
	if totals > 120 then
		ff_grid:SetScrollbars(1)
	end
	ff_grid:SetFloater(ff_grid_floater) 
	ff_grid:SetColor(bcol)
	
	--MsgN("asdflistlen" ,#flist)
	
	
	
	local sp_load = panel.Create("button")
	sp_load:SetText("Load") 
	sp_load:SetPos(-300,-150) 
	sp_load:SetSize(100,20)
	sp_load.OnClick = function() hook.Call("menu","load") end
	self:SetupStyle(sp_load)
	
	local sp_back = panel.Create("button")
	sp_back:SetText("Back") 
	sp_back:SetPos(0,-150)
	sp_back:SetSize(100,20)
	sp_back.OnClick = function() hook.Call("menu","main") end
	self:SetupStyle(sp_back)
	 
	local sp_editor = panel.Create("button")
	sp_editor:SetText("Editor") 
	sp_editor:SetPos(300,-150)
	sp_editor:SetSize(100,20)
	sp_editor.OnClick = function()  
		LoadSingleplayer("editor_template") 
	end
	self:SetupStyle(sp_editor)
	
	self:Add(ff_grid)
	for k,v in pairs({sp_load,sp_back,sp_editor}) do  --sp_new,sp_new2,sp_new3,sp_new4,
		v:SetTextColorAuto(bcol)
		--v:SetTextOnly(true)
		v:SetTextAlignment(ALIGN_CENTER) 
		self:Add(v) 
	end
	
end