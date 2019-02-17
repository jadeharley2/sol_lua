
local tBorder = LoadTexture("gui/menu/edge.png")
local tBorder2 = LoadTexture("gui/menu/edge2.png")
local tCorner = LoadTexture("gui/menu/corner.png")
local tButton32 = LoadTexture("gui/button32.png")
local button_color = Vector(38,12,8)/255
local panel_color = button_color*1.2

function NewDialogPanel(name,height,width) 
 --[[
	height = height or 200
	
	local pn = panel.Create()
	pn:SetSize(500,height) 
	pn:SetVisible(false)
	pn:SetColor(panel_color/2)
	
	local sub = panel.Create()
	sub:SetSize(500-50,height-50)  
	sub:SetColor(Vector(50,150,50)/256/3)
	
	local label = panel.Create()
	label:SetText(name)
	label:SetTextAlignment(ALIGN_CENTER)
	label:SetSize(280,20)
	label:SetPos(0,height-25) 
	label:SetTextColor( Vector(1,1,1))
	label:SetColor(panel_color/2)
	
	pn:Add(sub)
	pn:Add(label)
	
	pn.sub = sub
	
	return pn
	]]
	-- --[[
	height = height or 200
	width = width or 500
	local self = panel.Create()
	
	self:SetSize(width,height) 
	--self:SetVisible(false)
	self:SetColor(panel_color/2)
	
	local bcol = Vector(83,164,255)/255
	local pcol = Vector(0,0,0)
	
	local sub = panel.Create()
	sub:SetSize(width-20,height-20)  
	sub:SetColor(pcol)
	sub:SetAlpha(0.7)
	
	local border_t = panel.Create() border_t:Dock(DOCK_TOP)    self:Add(border_t) border_t:SetTextOnly(true)
	local border_d = panel.Create() border_d:Dock(DOCK_BOTTOM) self:Add(border_d) border_d:SetTextOnly(true)
	local border_l = panel.Create() border_l:Dock(DOCK_LEFT)   self:Add(border_l)
	local border_r = panel.Create() border_r:Dock(DOCK_RIGHT)  self:Add(border_r)
	
	local border_dl = panel.Create() border_dl:Dock(DOCK_LEFT)   border_d:Add(border_dl) border_dl:SetRotation(90)
	local border_dr = panel.Create() border_dr:Dock(DOCK_RIGHT)  border_d:Add(border_dr) border_dr:SetRotation(180)
	local border_dd = panel.Create() border_dd:Dock(DOCK_FILL)   border_d:Add(border_dd)
	
	local border_tl = panel.Create() border_tl:Dock(DOCK_LEFT)   border_t:Add(border_tl)
	local border_tr = panel.Create() border_tr:Dock(DOCK_RIGHT)  border_t:Add(border_tr) border_tr:SetRotation(-90)
	local border_tt = panel.Create() border_tt:Dock(DOCK_FILL)   border_t:Add(border_tt) 
	
	border_l:SetTexture(tBorder)
	border_r:SetTexture(tBorder)
	border_dl:SetTexture(tCorner)
	border_dr:SetTexture(tCorner)
	border_dd:SetTexture(tBorder2)
	border_tl:SetTexture(tCorner)
	border_tr:SetTexture(tCorner)
	border_tt:SetTexture(tBorder2)
	
	self:SetTextOnly(true)
	local borders = {border_t,border_d,border_l,border_r,border_dl,border_dr,border_tl,border_tr,border_dd,border_tt}
	for k,v in pairs(borders) do
		v:SetSize(16,16)
		v:SetColor(bcol)
		v:SetCanRaiseMouseEvents(false)
	end
	
	
	local label = panel.Create()
	label:SetText(name)
	label:SetTextAlignment(ALIGN_CENTER)
	label:SetSize(280,20)
	label:SetPos(0,height+15) 
	label:SetTextColor(bcol)
	label:SetColor(pcol)
	--label:SetAlpha(0.7)
	label:SetTextOnly(true)
	
	self:Add(sub)
	self:Add(label)
	
	self.sub = sub
	
	
	local bcol = Vector(83,164,255)/255
	function self:SetupStyle(p)
		p:SetTextColor(Vector(1,1,1)/2)
		p:SetColors(Vector(1,1,1),button_color,button_color*2)
		
		p:SetTextColorAuto(bcol)
		--v:SetTextOnly(true)
		p:SetTextAlignment(ALIGN_CENTER) 
	end
	return self
	--]]
end


EVENT_LIFT_CALL = 11010

function SpawnLift(ent,seed,network,model)
	model = model or "lift/lift.stmd"
	local e = ents.Create("dyn_lift")
	e:SetSeed(seed)
	e:SetParameter(VARTYPE_MODEL,model)
	e:SetParent(ent) 
	
	
	e:SetModel(e:GetParameter(VARTYPE_MODEL),e.scale or 0.75)
	
	e:SetPos(network[network.currentid].p) 
	e:SetPathNetwork(network)
	
	e:Spawn() 
	local sz = ent:GetSizepower()
	for k,v in pairs(network) do
		if isnumber(k) and v.s then
			if v.d then
				local dl = {}
				if v.d.a then 
					local door1 =SpawnDoor("lift/liftdoors.stmd",ent,v.p+Vector(-0.4,0,0)/sz,Vector(0,0,0),0.75,33232+seed+k)
					door1:RemoveFlag(FLAG_USEABLE)
					dl[1] = door1
				end
				if v.d.b then 
					local door2 =SpawnDoor("lift/liftdoors.stmd",ent,v.p+Vector(0.4,0,0)/sz,Vector(0,180,0),0.75,36232+seed+k)
					door2:RemoveFlag(FLAG_USEABLE)
					dl[2] = door2
				end
				 
				v.d = dl
			else
				local door1 =SpawnDoor("lift/liftdoors.stmd",ent,v.p+Vector(-0.4,0,0)/sz,Vector(0,0,0),0.75,33232+seed+k)
				local door2 =SpawnDoor("lift/liftdoors.stmd",ent,v.p+Vector(0.4,0,0)/sz,Vector(0,180,0),0.75,36232+seed+k)
				door1:RemoveFlag(FLAG_USEABLE)
				door2:RemoveFlag(FLAG_USEABLE)
				v.d = {door1,door2}
			end
		end
	end
	return e
end

ENT.usetype = "select destination"

function ENT:Init()  
	self:SetSizepower(1)
	
	local space = self:AddComponent(CTYPE_PHYSSPACE)  
	space:SetGravity(Vector(0,-9.5,0))
	--local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.space = space
	self.model = model
	--self.coll = coll 
	self:SetSpaceEnabled(false)
	self.speed = 30
	self.movetime = 0
	--phys:SetMass(10)  
	
	local coll = self:AddComponent(CTYPE_STATICCOLLISION) 
	self.coll = coll
	
	
	self:SetUpdating(true)
	
	self:AddEventListener(EVENT_LIFT_CALL,"event",function(self,id,user) 
		self:MoveTo(id,user)
	end)
	self:SetNetworkedEvent(EVENT_LIFT_CALL)
	
	self:AddEventListener(EVENT_USE,"use_event",function(self,user) 
		if self.graph:CurrentState()=="idle" then
			self:OpenMenu(user)
		end
	end)
	self:AddFlag(FLAG_USEABLE)  
end
function ENT:Spawn()
	local mdl = self:GetParameter(VARTYPE_MODEL) or "lift/lift.stmd"
	local door1 =SpawnDoor("lift/liftdoors.stmd",self,Vector(0,0,0),Vector(0,0,0),0.75,3190813)
	local door2 =SpawnDoor("lift/liftdoors.stmd",self,Vector(0,0,0),Vector(0,180,0),0.75,3190814)
	door1:RemoveFlag(FLAG_USEABLE)
	door2:RemoveFlag(FLAG_USEABLE)
	self.door1 = door1
	self.door2 = door2
	
	local graph = BehaviorGraph(self) 
	
	graph:NewState("idle",function(s,e)   end)
	graph:NewState("start",function(s,e) Multicall(self:GetDoors(),"Close") return 2 end)
	graph:NewState("moving",function(s,e)  
		local st = CurTime()
		e.starttime = st
		e.endtime = st + e.movetime
	end)
	graph:NewState("stop",function(s,e) Multicall(self:GetDoors(),"Open") return 2 end)
	graph:NewState("spawn",function(s,e) Multicall(self:GetDoors(),"Open") return 2 end)
	
	graph:NewTransition("start","moving",BEH_CND_ONEND)
	graph:NewTransition("stop","idle",BEH_CND_ONEND)
	
	graph:NewTransition("idle","start",BEH_CND_ONCALL,"start")
	graph:NewTransition("moving","stop",BEH_CND_ONCALL,"stop")
	
	graph:NewTransition("spawn","stop",BEH_CND_ONEND)
	graph.debug = true
	graph:SetState("spawn")
	
	self.graph = graph
	
	local light = ents.Create("omnilight")    
	light:SetParent(self)
	light:SetSizepower(0.1)
	light.color = color or Vector(1,1,1)
	light:SetSpaceEnabled(false)
	light:SetPos(Vector(0,3,0)) 
	light:Spawn() 
	self.light = light
	
	--SpawnSO("lift/lift_ref.smd",self,Vector(0,0,0),0.75,true) 
	local scale = scale or 0.75
	SpawnSO(mdl,self,Vector(0,0,0),scale) 
	 
	local coll = self.coll
	
	



	local model = self.model
	local world = matrix.Scaling(scale)
	if not norotation then
		world = world * matrix.Rotation(-90,0,0)
	end
	
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	--model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(mdl)   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world) 
 
	--if(model:HasCollision()) then
	--	coll:SetShapeFromModel(matrix.Scaling(scale/0.75 )  ) 
	--else
	--	coll:SetShape(mdl,matrix.Scaling(scale/0.75 ) ) 
	--end
	--coll:SetShape(collsmd, matrix.Scaling(1)  * matrix.Rotation(-90,0,0) ) 
	coll--:SetShape(collsmd,matrix.Rotation(-90,0,0)) --matrix.Scaling(1 )  * 
	:SetShapeFromModel(matrix.Scaling(scale)*matrix.Rotation(-90,0,0))
	--if TSHIP==self:GetParent() then
		--SpawnMirror(self,Vector(0,2.543,-4.174)*0.75)
	--end
	door2:Open()
end
function ENT:SetModel(mdl,scale) 
	--local model = self.model
	--local world =   matrix.Rotation(-90,0,0)*matrix.Scaling(scale)
	-- 
	--model:SetRenderGroup(RENDERGROUP_LOCAL)
	--model:SetModel(mdl)  
	--model:SetBlendMode(BLEND_OPAQUE) 
	--model:SetRasterizerMode(RASTER_DETPHSOLID) 
	--model:SetDepthStencillMode(DEPTH_ENABLED)  
	--model:SetBrightness(1)
	--model:SetFadeBounds(0,99999,0)  
	--model:SetMatrix( world) 
	--  
    --
	--local coll =  self.coll 
	--if(model:HasCollision()) then
	--	coll:SetShapeFromModel(matrix.Scaling(scale/0.75 ) * matrix.Rotation(-90,0,0) ) 
	--else
	--	coll:SetShape(mdl,matrix.Scaling(scale/0.75 )* matrix.Rotation(-90,0,0)  ) 
	--end
	-- 
end 
function ENT:Load()
	self.graph:LoadState()
end

function ENT:GetDoors()
	local net = self.network
	local node =net[net.currentid]
	local doorsa = {self.door1,self.door2}
	local doorsb = node.d or {}
	local doors = {}
	for k,v in pairs(doorsa) do
		local v2 = doorsb[k]
		if v2 then
			doors[#doors+1] = v
			doors[#doors+1] = v2
		end
	end
	return doors
end

function ENT:Think()
	local g = self.graph
	if g then 
		g:Run()  
		
		local state = g:CurrentState()
		if state == "moving" then
			local t = self.targetpos
			local net = self.network
			if t then
				local s = self.startpos
				local st = self.starttime
				local et = self.endtime
				local ct = CurTime()
				local d = math.Clamp((ct-st)/(et-st),0,1)
				self:SetPos(LerpVector(s,t,d))
				if(d>=1)then
					self.targetpos = nil
					net.currentid = self.endid
					MsgN("REACHED: ",self.endid)
					local node = net[net.currentid]
					if node and node.a then
						node.a(self,node)
					end
					local path = self.path 
					if path then
						local pd = self.pathid + 1
						self.pathid = pd
						local next = path[pd]
						if next then
							MsgN("NEXT NODE: ",next)
							self:PathMoveTo(next)
							local st = CurTime()
							self.starttime = st
							self.endtime = st + self.movetime
						else
							MsgN("PATH TRACK FINISHED") 
							self.path = nil
							self.pathid = nil
							if(g:Call("stop")) then
								local u = self.user
								if u then
									if CLIENT then
										u:Eject()
									end
									self.user = nil
								end
							end
						end
					end
				end
			end
		end
	end
end

function ENT:OpenMenu(user)
	if not self.menuUser then
		self.menuUser = user
		local net = self.network 
		
		local wn = self.wn
		wn = nil
		if not wn then
			local totalh = 0
			local prev = false
			local prevc =0
			local btns = {}
			for k,v in pairs(net) do
				if isnumber(k) and v.s and k ~= net.currentid then
					if v.c then
						if v.c ~= prevc then
							prevc = v.c
							prev = nil
						end
					end
					local btn = panel.Create("button") 
					btn:SetText(v.n)
					btn:SetSize(70,20)
					if prev then
						btn:AlignTo(prev,ALIGN_BOTTOM,ALIGN_TOP)  
					else
						btn:SetPos(prevc*140-300,25) 
					end
					btn.OnClick = function()
						self:SendEvent(EVENT_LIFT_CALL,v.id,user) 
						local w = self.wn
						if w then
							w:SetVisible(false) 
							w:Close() 
							BLOCK_MOUSE = false
							self.menuUser = nil
						end
					end
					prev = btn
					totalh = totalh + 25
					btns[#btns+1] = btn
				end
			end
			wn = NewDialogPanel("Select destination",totalh+20)
			BLOCK_MOUSE = true
			for k,v in pairs(btns) do
				wn:Add(v)
				wn:SetupStyle(v)
			end
			local ebtn = panel.Create("button") 
			ebtn:SetText("X")
			ebtn:SetSize(25,25) 
			ebtn:SetTextAlignment(ALIGN_CENTER)
			ebtn:AlignTo(wn,6,6)   
					wn:SetupStyle(ebtn)
					ebtn:SetTexture(tButton32)
			ebtn.OnClick = function() 
				local w = self.wn
				if w then
					w:SetVisible(false) 
					w:Close()
					BLOCK_MOUSE = false
					self.menuUser = nil
				end
			end
			wn:Add(ebtn)
			self.wn = wn
		end
		wn:SetPos(0,0) 
		wn:SetVisible(true) 
		wn:Show() 
		MsgN("NW: ",wn)
	end
	
end

function ENT:SetPathNetwork(pn) 
	local links = pn.links
	local splinks = {}
	for k,v in pairs(pn) do
		if isnumber(k) then
			v.id = k
		end
	end
	for k,v in pairs(links) do
		local vn = #v
		--if vn == 2 then
		--	splinks[#splinks+1] = v
		--else
		if vn > 1 then
			for c=1,vn-1 do
				splinks[#splinks+1] = {pn[v[c]],pn[v[c+1]]}
			end
		end
	end
	pn.links = splinks
	
	self.network = pn
end
function ENT:MoveTo(nodeid,user)
	
	MsgN("MOVE REQUEST TO: ",nodeid)
	local nid = self.network.currentid
	
	local path = self:GetPathTo(nodeid)
	if path then
		self.path = path
		self.pathid = 1
		--if nid == 1 then 
		--	self:PathMoveTo(2)
		--else
		--	self:PathMoveTo(1)
		--end
		self:PathMoveTo(path[1])
		if self.graph:Call("start") then
			self.user = user
			local ltf = self:GetLocalCoordinates(user)
			user:SetParent(self)
			user:SetPos(ltf)
		end
	end
end
---returns path id list {2,3,4,5} etc 
function ENT:GetPathTo(nodeid)
	local net = self.network
	local sid = net.currentid
	local start = net[sid]
	local target = net[nodeid]
	local open = List()
	local closed = List()
	open:Add(start)
	closed:Add(start)
	
	local iterleft = 50
	while(true) do
		for k,v in pairs(net.links) do
			if v[1]==start then
				if not open:Contains(v[2]) then
					open:Add(v[2])
					v[2].pt_from = start
					--MsgN("open add ",v[2].id," from ",start)
				else
					--spec
				end
			elseif v[2]==start then
				if not open:Contains(v[1]) then
					open:Add(v[1])
					v[1].pt_from = start
					--MsgN("open add ",v[1].id," from ",start)
				else
					--spec
				end
			end
		end
		--MsgN("cc ",closed:Count(),"oc ",open:Count()) 
		if closed:Count() < open:Count() then
			local minf = 9e10
			local minnode = false 
			for k,v in list(open) do
				if not closed:Contains(v) then
					local g = 0--v.p:DistanceSquared(start.p)
					local h = v.p:DistanceSquared(target.p)
					local f = g+h
					if minf>f then
						minf = f
						minnode = v
					end
					--MsgN("f of ",v.id," = ", f)
					v.pt_f = f 
				end
			end
			--MsgN("mnn ",minnode.id)
			if minnode then
				closed:Add(minnode)
				minnode.pt_p = minnode.pt_from 
				--MsgN("set node prev to ",minnode.pt_p)
				start = minnode
				if start == target then 
					MsgN("path found")
					local path = List()
					while start do
						--MsgN(start.id)
						if start.id == sid then
							break
						end
						path:Add(start.id)
						start = start.pt_p 
					end
					local rp = path:ToReversedTable() 
					return rp 
				end
			end
		else
			MsgN("no path found")
			return nil 
		end
		iterleft = iterleft - 1
		if iterleft<=0 then 
			MsgN("LOOP ERROR no path found")
			return nil 
		end
	end
end
 
function ENT:PathMoveTo(nodeid) 
	local net = self.network
	if nodeid == net.currentid then return nil end
	MsgN("MOVE TARGET NODE SET: ",nodeid)
	local tn = net[nodeid]
	
	local cp = self:GetPos()
	local tp = tn.p
	local sz = self:GetParent():GetSizepower()
	local spd = self.speed
	
	local st = CurTime()
	local mt = cp:Distance(tp) * sz / spd
	
	self.startpos = cp

	self.targetpos = tp
	self.movetime = mt
	self.endid = nodeid
end
 
function ENT:Call(stopid) 
end

function ENT:Lock() 
end
function ENT:Unlock() 
end

ENT._typeevents = {
	[EVENT_LIFT_CALL] = {networked = true, f = ENT.MoveTo},
	[EVENT_USE] = {networked = true, f = function(self,user)  
		if self.graph:CurrentState()=="idle" then
			self:OpenMenu(user)
		end
	end},
}  