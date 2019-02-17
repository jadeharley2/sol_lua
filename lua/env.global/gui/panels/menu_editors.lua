PANEL.basetype = "menu_dialog"
 

function PANEL:Init()  

	
	self.base.Init(self,"Editor",200,500)
	
	local bcol = Vector(83,164,255)/255
	 
	
	local ff_grid_floater = panel.Create()  
	ff_grid_floater:SetSize(400,1000)
	
	 
	local flist = debug.getregistry()._USERCLASS.Editor:GetTypeNameList()
	local totals = 0
	for k,v in pairs(flist) do 
		--local cname = string.lower( file.GetFileNameWE(v)) 
		 
		cname = v--string.sub( v,7)
		local sp_new = panel.Create("button")
		sp_new:SetText(cname) 
		sp_new:Dock(DOCK_TOP)
		sp_new:SetTextColorAuto(bcol) 
		sp_new:SetTextAlignment(ALIGN_CENTER)
		sp_new:SetSize(150,20)
		--sp_new.OnClick = function() LoadSingleplayer(cname) end
		ff_grid_floater:Add(sp_new)
		self:SetupStyle(sp_new)
		totals = totals + 20 
		
	end
	ff_grid_floater:SetSize(400,totals)
	ff_grid_floater:SetColor(bcol)
	
	local ff_grid = panel.Create("floatcontainer") 
	ff_grid:SetSize(400,120)  
	--if totals > 120 then
		ff_grid:SetScrollbars(1)
	--end
	ff_grid:SetFloater(ff_grid_floater) 
	ff_grid:SetColor(bcol)
	self:Add(ff_grid)
	--[[]]
	local sp_back = panel.Create("button")
	sp_back:SetText("Back") 
	sp_back:SetPos(0,-150)
	sp_back:SetSize(100,20)
	sp_back.OnClick = function() hook.Call("menu","main") end
	self:SetupStyle(sp_back)
	 
	
	for k,v in pairs({sp_back}) do  --sp_new,sp_new2,sp_new3,sp_new4,
		v:SetTextColorAuto(bcol)
		--v:SetTextOnly(true)
		v:SetTextAlignment(ALIGN_CENTER) 
		self:Add(v) 
	end  
	
end