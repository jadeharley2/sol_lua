PANEL.basetype = "window"

function PANEL:Init()
	--PrintTable(self)
	self.fixedsize = true
	self.base.Init(self)
	self:SetSize(500,500)
	self:SetColor(Vector(0.6,0.6,0.6))
	  
	self:UpdateData()
	--tabs:ShowTab(2)
	--tabs:ShowTab(1)
end 
function PANEL:Open() 
	self:UpdateLayout() 
	self:Show()
end
function PANEL:Set(actor) 
	self.stats:Set(actor) 
end
local au = 149597870700 --m
local earth_m = 5.97237*10e24
function PANEL:UpdateData()

	self.inner:Clear()
	local tabs = panel.Create("tabmenu")
	
	self.tabs = tabs
	tabs:Dock(DOCK_FILL)
	self.inner:Add(tabs)  
	
	local cam = GetCamera()
	 
	local system = cam:GetParentWith(NTYPE_STARSYSTEM)
	if system then
		local p_system = panel.Create() p_system:SetColor(Vector(0,0,0))
		self.p_system = p_system  
		
		self:AddGroup(p_system,"General")
		self:AddRecord(p_system,"Name:", system:GetName() or "unknown") 
		self:AddRecord(p_system,"Class:", system:GetParameter(VARTYPE_ARCHETYPE) or "unknown") 
		
		if system.stars then
			for k,star in pairs(system.stars) do 
				self:AddGroup(p_system,"Star")
				self:AddRecord(p_system,"Name:", star:GetName() or "unknown") 
				local r = star:GetParameter(VARTYPE_RADIUS)
				self:AddRecord(p_system,"Radius:", r/1000 .. "km" ) 
				local d = star:GetDistance(cam)
				self:AddRecord(p_system,"D to center:", d/1000 .. "km" ) 
				self:AddRecord(p_system,"D to surface:", (d-r)/1000 .. "km" ) 
				
				self:AddGroup(p_system,"Planets")
				for k,planet in pairs(star.planets) do 
					self:AddRecord(p_system,"Name:", planet:GetName() or "unknown", function()
						SetController("freecamera")
						cam:SetParent( planet)
						planet:Enter()
						debug.Delayed(1000,function()
							SetController("planetview")
						end)
					end) 
					
				end 
			end
		end
		p_system:UpdateLayout()
		tabs:AddTab("CurSystem",p_system)
		
		local planet = cam:GetParentWithFlag(FLAG_PLANET)
		if planet then 
			local p_planet = panel.Create() p_planet:SetColor(Vector(0,0,0))
			self.p_planet = p_planet
			self:AddGroup(p_planet,"General")
			self:AddRecord(p_planet,"Name:", planet:GetName() or "unknown") 
			self:AddRecord(p_planet,"Radius:", planet:GetParameter(VARTYPE_RADIUS)/1000 .. "km" ) 
			self:AddRecord(p_planet,"Mass:", (planet:GetParameter(VARTYPE_MASS) or 0)/earth_m  .. " e.m." ) 
			local dptp = planet:GetAbsPos():Length()
			local dd,dp = DistanceNormalize(dptp,true,false)
			self:AddRecord(p_planet,"Dist to parent:",tostring(dd)..dp )  
			self:AddRecord(p_planet,"Dist to parent2:",tostring(dptp/au).."au" ) 
			tabs:AddTab("CurPlanet",p_planet)
		end

		self:AddGroup(p_system,"Other stars")
		local galaxy = system:GetParent()
		if galaxy then
			local spccount=0
			for k,v in pairs(galaxy:GetChildren()) do
				if v~=system then
					local dist = v:GetDistance(system)
					if spccount<10 and dist<9.4e15*20 then
						self:AddRecord(p_system,"Name:","["..v:GetParameter(VARTYPE_ARCHETYPE).."]"..(v:GetName() or "unknown"), function()
							SetController("freecamera")
							cam:SetParent( v)
							system:Leave()
							v:Enter()
							debug.Delayed(1000,function()
								--SetController("planetview")
								self:UpdateData()
								self.tabs:ShowTab(1)
							end)
						end) 
						self:AddRecord(p_system,"Distance:", " ly: "..(dist/9.4e15))
						spccount = spccount + 1
					end	
				end
			end
		end
	end
	
	self:UpdateLayout() 
end
function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end


function PANEL:AddGroup(p,text)
	local r = panel.Create()
	r:SetSize(10,20)
	r:Dock(DOCK_TOP)
	r:SetColor(Vector(20,50,20)/100)
	r:SetText(text)
	r:SetTextAlignment(ALIGN_CENTER)
	p:Add(r)
end

function PANEL:AddRecord(p,text,value,onclick)
	if not isstring(value) then
		value = tostring(value)
	end
	
	local r = panel.Create()
	r:SetSize(10,20)
	r:Dock(DOCK_TOP)
	r:SetColor(Vector(20,20,20)/100)
	p:Add(r)
	
	local rt = panel.Create()
	rt:SetSize(150,20)
	rt:Dock(DOCK_LEFT)
	rt:SetText(text)
	rt:SetColor(Vector(20,20,50)/100)
	r:Add(rt)
	
	local rv = false
	if onclick then
		rv = panel.Create("button")
		rv.OnClick = onclick
	else
		rv = panel.Create()
	end
	rv:SetSize(150,20)
	rv:Dock(DOCK_FILL)
	rv:SetText(value)
	rv:SetColor(Vector(20,20,20)/100)
	r:Add(rv)
	
	local rd = panel.Create()
	rd:SetSize(10,1)
	rd:Dock(DOCK_TOP)
	rd:SetColor(Vector(0,0,1))
	p:Add(rd) 
end

local PPL = {}
function PANEL.ToggleInstance()
	local vsize = GetViewportSize()
	if PPL.instance then
		PPL.instance:Close()
		PPL.instance = nil
	else
		local instance = panel.Create("window_space_info") 
		instance:SetTitle("SpaceInfo")
		PPL.instance = instance
		instance:Show()
	end
	if instance then
		instance:SetPos(-vsize.x+180+150,0)  
	end
end
hook.Add("spaceinfo_toggle","si",PANEL.ToggleInstance)
