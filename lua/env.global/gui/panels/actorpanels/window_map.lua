PANEL.basetype = "window"
 


function PANEL:Init()
	--PrintTable(self)
--	self.fixedsize = true
	self.base.Init(self)
	self.mv:SetTextColor(Vector(3,3,3))
	self:SetSize(1000,520)
	self.pointer = gui.FromTable({
		size = {4,4},
		color = {1,0,0},
		anchors = 5,
		mouseenabled = false,
	})
	self.cpointer = gui.FromTable({
		size = {20,20},
		color = {1,0,0},
		anchors = 5,
		texture = 'textures/gui/pointer.png',
		mouseenabled = false,
	})
	self.inner:Add(self.cpointer)
	self.inner:Add(self.pointer)
	hook.Add(EVENT_GLOBAL_UPDATE,'aamaptest',function()
		self:Update()
	end)
end 
function PANEL:Open() 
	self:UpdateLayout() 
	self:Show()
end 
function PANEL:Update()
	local c = GetCamera()
	local cp = c:GetParent()
	local planet = c:GetParentWithFlag(TAG_PLANET_SURFACE)
	if planet then
		self:SetMode('planet',planet,planet)
		self:UpdatePointerPos()
	else
		local ssystem = c:GetParentWithFlag(TAG_STARSYSTEM) 
		if ssystem then
		self:SetMode('starsystem',ssystem,cp) 
		else
			local sgal = c:GetParentWithFlag(TAG_GALAXY) 
			if sgal then
				self:SetMode('galaxy',sgal,sgal)
				self:UpdateGalPointerPos()
			else 
				self:SetMode('unknown')
			end
		end
	end
end
function PANEL:UpdateGalPointerPos ()
	local c = GetCamera()
	local sgal = c:GetParentWithFlag(TAG_GALAXY) 
	if sgal then
		local lop  =  sgal:GetLocalCoordinates(c)
		local sz = self.inner:GetSize() 
	
		self.pointer:SetPos((lop.x/2+0.5)*sz.x,(lop.z/2+0.5)*sz.y)
	end
end
function PANEL:UpdatePointerPos()
	local c = GetCamera()
	local planet = c:GetParentWithFlag(TAG_PLANET_SURFACE)
	if planet and planet.surface then
		local lon, lat  = planet.surface:GetLonLat(planet:GetLocalCoordinates(c))
		local sz = self.inner:GetSize()
		local x = -(-lon/180)*sz.x--1000  
		local y = lat/90*sz.y--500
		if x<-sz.x then x = x + sz.x*2 end
		self.pointer:SetPos(x,y)
	end 
end
function PANEL:SetMode(mode,node,cnode)
	if self.mode ~= mode or self.node ~= node or self.cnode ~= cnode then 
		MsgN("mapmode",mode,node)
		self.mode = mode
		self.node = node
		self.cnode = cnode
		if mode == 'starsystem'then self:InitSystemMap(node) 
		elseif mode == 'planet' then self:InitPlanetMap(node)
		elseif mode == 'galaxy' then self:InitGalaxyMap(node)
		else --unknown
			local u = self.inner
			u:Clear()
			u:SetColor(Vector(0,0,0))
			self:SetTitle("unknown location")
		end
	end
end
function PANEL:InitGalaxyMap(node)
	if not node then return end
	local u = self.inner
	u:Clear()
	u:SetColor(Vector(1,1,1))
	u:SetTexture("textures/space/galaxies/01.png") 
	self.skipcount = cstring.len(node:GetName())+1
	self:RSystemMap(node,1,Point(-800,0),400,GetCamera():GetParent())
	u:Remove(self.pointer)
	u:Add(self.pointer)
	self:SetTitle(node:GetName() or "unknown galaxy")

	local sz = self.inner:GetSize()
	for k,v in pairs(node:GetChildren()) do
		if not v:HasTag(21) then -- is generated
			local np = v:GetPos()
			
			self.inner:Add(gui.FromTable({
					size = {4,4}, 
					pos={(np.x/2+0.5)*sz.x-2,(np.z/2+0.5)*sz.y-2},
					--color = col, 
					--text = tostring(plnnum),
					texture = "textures/gui/circle.png",
					--anchors = 5,
					enode = v,
					contextinfo =v:GetName(), 
				}) )
		end
	end
end
function PANEL:InitSystemMap(node)
	local u = self.inner
	u:Clear()
	u:SetColor(Vector(0,0,0))
	u:SetTexture(nil)
	MsgN("map",node)
	local ss = u:GetSize()
	self:RSystemMap(node,1,Point(0,0),220,GetCamera():GetParent())
	self:SetTitle(node:GetName() or "unknown star system")
end
local continfo = function(ci,n)
	
	ci:Clear()
	ci:SetSize(200,100)
	ci:SetAutoSize(false,true)

	local cc = panel.Create('iteminfo')
	cc:SetForm("planet.default")
	cc:Dock(DOCK_TOP)
	ci:Add(cc)
	ci:UpdateLayout() 
	
end
function PANEL:RSystemMap(node,level,pos,Y,cparent)
	local ncl = node:GetClass()  
	local plnnum = 0
	for k,v in ipairs(self:GetChildrenByParentDistance(node)) do 
		local vcl = v:GetClass() 
		local nnode = false
		if vcl == 'star' or vcl == 'mass_center' then
			if k~=1 then
				Y = Y - 100 
			end
			
			local np = Point(pos.x+40,Y)
			Y = self:RSystemMap(v,level+1,np, Y,cparent)
			if v:HasTag(TAG_STAR) then 
				local ccc = v:GetParameter(VARTYPE_COLOR)*2
				local c = {ccc.x,ccc.y,ccc.z}
				nnode = gui.FromTable({
					size = {40,40}, 
					pos={np.x,np.y},
					color = c, 
					text = tostring(k),
					texture = "textures/space/star.jpg",
					contextinfo = v:GetName(),
					anchors = 5,
				}) 
			else
				nnode =gui.FromTable({
					size = {40,40}, 
					pos={np.x,np.y} , 
					anchors = 5,
					texture = "textures/gui/bar_right.png"
				}) 
			end  

		elseif vcl == 'planet' then
			plnnum = plnnum + 1 
			local np = Point(pos.x+20+plnnum*40,Y)
			local gen = v[VARTYPE_ARCHETYPE]
			local col = {0,1,0}
			if gen == 'gen_barren' then col = {1,1,0}
			elseif gen == 'earth' then col = {0,1,0.5}
			elseif gen == 'sd_hellworld' then col = {1,0.5,0}
			end
			nnode = gui.FromTable({
				size = {20,20}, 
				pos={np.x,np.y},
				color = col, 
				text = tostring(plnnum),
				texture = "textures/gui/circle.png",
				anchors = 5,
				enode = v,
				contextinfo =continfo-- v:GetName(), 
			}) 
		end
		if nnode then
			self.inner:Add(nnode) 
			if v == cparent then 
				self.pointer:SetPos(nnode:GetPos()+Point(0,nnode:GetSize().y)) 
				self.cpointer:SetPos(nnode:GetPos()) 
				self.cpointer:SetSize(nnode:GetSize()*1.5)
				self.inner:Remove(self.pointer)
				self.inner:Add(self.pointer)
				self.inner:Remove(self.cpointer)
				self.inner:Add(self.cpointer)
			end
		end
	end
	return Y
end
function PANEL:GetChildrenByParentDistance(node) 
	local orch = {}
	for k,v in pairs(node:GetChildren()) do
		orch[k] = {v:GetPos():LengthSquared(),v}
	end
	--MsgN("a")
	--PrintTable(orch)
	table.sort(orch,function(a,b) return a[1]<b[1] end)
	--MsgN("b")
	--PrintTable(orch)
	local r = {}
	for k,v in ipairs(orch) do
		r[#r+1] = v[2]
	end 
	return r
end
function PANEL:InitPlanetMap(node)
	local u = self.inner
	u:Clear()
	u:SetColor(Vector(1,1,1))
--	u:SetTexture(node.mappath or "textures/gui/map/none.png")
	u:Add(gui.FromTable({type ="tilemap",size = {200,200}, dock = DOCK_FILL}))
	u:Remove(self.pointer)
	u:Add(self.pointer)
	 

	self:SetTitle(node:GetParent():GetName() or "unknown planet")
end
function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end

local map = false
function ToggleMap()
	if not map then
		map = panel.Create('window_map')
		map:Show()
	else
		map:Close()
		map = nil
	end
end