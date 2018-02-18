
gizmometa = gizmometa or {}

local function CreatePart(parent,model,color,rotation,type) 
	local R = ents.Create("gizmo_part")
	R:SetParent(parent)
	R:SetParameter(VARTYPE_MODEL, model)
	R:SetParameter(VARTYPE_COLOR, color)
	R.gtype = type
	R:Spawn()
	R.defang = rotation
	R:SetAng(rotation) 
	return R
end

function gizmometa:StartDrag(part)
	if not self.GIZMO_DRAG then 

		if input.KeyPressed(KEYS_SHIFTKEY) and self.mnode then
			editor.Copy(self.mnode)
			--part = editor.Copy(part)
			--editor.Select(part)
		end 
		
		editor.mode = "drag"
		self.lastmp = nil
		self.GIZMO_DRAG = part
		self.GIZMO_DRAG_POS = part:GetPos()
		self.GIZMO_DRAG_POINTPOS = input.getMousePosition() 
		self.startnodepos = editor.curtrace.Position
		
		
		if self.mnode and self.mnode.GetScale then
			self.startscale = self.mnode:GetScale()
		else
			self.startscale = Vector(1,1,1)
		end
		
		
		hook.Add("main.predraw","GIZMO_DRAG",function() self:DragUpdate() end)
	end
end
function gizmometa:DragUpdate()
	local G = self.GIZMO_DRAG
	if G then  
		local mousePos = input.getMousePosition() 
		local mouseDiff2 = mousePos - (self.lastmp or mousePos)
		self.lastmp = mousePos
		local mouseDiff = mousePos - self.GIZMO_DRAG_POINTPOS   
		local mouseDiffF = Point(mouseDiff.x*2,mouseDiff.y*-2)
		--local newPos = self.GIZMO_DRAG_POS + G.constraint * mouseDiff.x/10000--Vector( mouseDiff.x,mouseDiff.y)
		
		local startnodepos = self.GIZMO_DRAG_POS
		local startpos = self.startnodepos --
		local startscale = self.startscale
		local camera = GetCamera()
		local constr = G.constraint
		local constr2 = G.constraint2
		local sconstraint = G.sconstraint
		local axis = G.axis
		local forward = camera:Forward()
		local up = camera:Up()
		local right = camera:Right()
		local campos = camera:GetPos() 
		
		local snap = input.KeyPressed(KEYS_MENU)
		
		local mpos = input.getInterfaceMousePos()+Vector(0,0,0.1)
		local dir = camera:Unproject(mpos):Normalized()
		--local dir = (editor.curtrace.Position - campos):Normalized()
		local lsn = self.mnode
		if constr then
		
			local W =lsn:GetParent():GetLocalSpace(lsn)
			constr = constr:TransformN(W)
			if(constr2) then
				constr2 = constr2:TransformN(W)
				--editor.curtrace
				local pp = Plane(startpos, startpos + constr, startpos + constr2);
				
				local hit, pos = pp:Intersect(campos, dir)
				if hit then  
					local newPos = startnodepos - startpos + pos
					if snap then
						newPos = Vector(math.round(newPos.x,3),math.round(newPos.y,3),math.round(newPos.z,3))
					end
					for k,v in pairs(self.parts) do
						v:SetPos(newPos)
					end
					if lsn then lsn:SetPos(newPos) end
				end
			else  
				--local pp = Plane(startpos, startpos + constr, startpos + up*100)
				--local pp2 = Plane(startpos, startpos + constr, startpos + forward*100)
				--local pp3 = Plane(startpos, startpos + constr, startpos + right*100)
				--local hit, pos = pp:Intersect(campos, dir)
				--if hit then
				--	local rps = pp2:Project(pos)
				--	rps = pp3:Project(rps)
				--	--local newPos =   rps---campos 
				--	local newPos = startnodepos -startpos + rps 
				--	if snap then
				--		newPos = Vector(math.round(newPos.x,3),math.round(newPos.y,3),math.round(newPos.z,3))
				--	end
				--	for k,v in pairs(self.parts) do
				--		v:SetPos(newPos)
				--	end
				--	if lsn then lsn:SetPos(newPos) end
				--end
				
				
				
				local pp = Plane(startpos, startpos + constr, startpos + up*100) 
				local pp2 = Plane(startpos, constr)
				local hit, pos = pp:Intersect(campos, dir)
				if hit then
					local rps = pp2:DotCoordinate(pos) 
					--local newPos =   rps---campos
			--MsgN(pos)
					local newPos = startnodepos + constr * rps *1000000 / (startscale*startscale)
					if snap then
						newPos = Vector(math.round(newPos.x,3),math.round(newPos.y,3),math.round(newPos.z,3))
					end
					for k,v in pairs(self.parts) do
						v:SetPos(newPos)
					end
					if lsn then lsn:SetPos(newPos) end
				end
			end
		elseif axis then 
			if lsn then
				
				local W = lsn:GetLocalSpace(lsn:GetParent())
				local Waxis = axis:TransformN(W)
				
				if G.ax ==0 then
					Waxis = lsn:Right()
				elseif G.ax==1 then
					Waxis = lsn:Up()
				else 
					Waxis = lsn:Forward()
				end
				
				for k,v in pairs(self.parts) do
					v:TRotateAroundAxis(Waxis,mouseDiff2.x/100)
				end
				lsn:TRotateAroundAxis(Waxis,mouseDiff2.x/100) 
				MsgN(mouseDiff2.x)
			end
		else
			local pp = Plane(startpos, startpos + right*100, startpos + up*100)
			local hit, pos = pp:Intersect(campos, dir)
			if hit then
				local dist = (pos-startpos)*100
				local ddist = dist.x+dist.y+dist.z
				MsgN("sada",ddist)
				local newScale = startscale
				if sconstraint then 
					newScale = startscale * (sconstraint*ddist+Vector(1,1,1))
				else
					newScale = startscale * (ddist+1)
				end
				if lsn then lsn:SetScale(newScale) end 
			end
			
		end
		--[[
		Vector3 constr = startnode.GetValue<Vector3>("constraint");
		Vector3 forward = Vector3.Normalize(camera.mRotation.Forward);
		Vector3 up = Vector3.Normalize(Vector3.Cross(constr, forward));
		Ray r = new Ray(camera.position, dir);

		if (g.rAXIS.Contains(startnode))
		{
			Plane pp = new Plane(startpos, startpos + constr, startpos + up);
			Plane pp2 = new Plane(startpos, startpos + constr, startpos + forward);
			Vector3 pop;
			if (pp.Intersects(ref r, out pop))
			{
				var rps = pp2.Project(pop);

				Vector3 cp = startnodepos - startpos + rps;
				root.runtime.NodeHierachyPanel.self.MoveGizmo(cp);
			}
		}
		else if (g.rPLANE.Contains(startnode))
		{
			Vector3 constr2 = startnode.GetValue<Vector3>("constraint2");
			Plane pp = new Plane(startpos, startpos + constr, startpos + constr2);
			Vector3 pop;
			if (pp.Intersects(ref r, out pop))
			{
				root.runtime.NodeHierachyPanel.self.MoveGizmo(pop);
			}
		}
		]]
		
		
		 
		if not input.leftMouseButton() then
			self.GIZMO_DRAG = false
			UnlockMouse()
			editor.mode = false
			hook.Remove("main.predraw", "GIZMO_DRAG")
		end
	end
end

function gizmometa:Highlight(n)
	local ch = self.lasthovered
	if n~=ch then 
		for k,v in pairs(self.parts) do 
			v:Highlight(v==n)
		end
		self.lasthovered = n
	end
end
function gizmometa:Rescale(n) 
	local scale = self.scale
	if scale~=n then 
		for k,v in pairs(self.parts) do 
			v:Rescale(n)
		end
		self.scale = n
	end
end
function gizmometa:ChangeMode(newmode)
	if not newmode then 
		local mode = self.mode
		if mode == "move" then
			newmode = "rotate"
		elseif mode == "rotate" then
			newmode = "scale"
		else--if mode == "scale" then
			newmode = "move"
		end
	end
	
	if newmode == "rotate" then 
		for k,v in pairs(self.parts) do 
			v:Enable( v.type == "rotate")
		end
	elseif newmode == "scale" then 
		for k,v in pairs(self.parts) do 
			v:Enable( v.type == "scale")
		end 
	else--if newmode == "move" then 
		for k,v in pairs(self.parts) do 
			v:Enable( v.type == "move")
		end 
	end
	self.mode = newmode
end

function gizmometa:SetParent(n)
	if n then
		for k,v in pairs(self.parts) do
			if not v.disabled then
				v:SetParent(n)
			end
		end
	end
end
function gizmometa:SetPos(n)
	if n then
		for k,v in pairs(self.parts) do
			if not v.disabled then
				v:SetPos(n)
			end
		end
	end
end
function gizmometa:SetAng(n)
	if n then
		for k,v in pairs(self.parts) do
			if not v.disabled then
				v:SetAng(v.defang*n)
			end
		end
	end
end
function gizmometa:Despawn()
	if self.parts then
		for k,v in pairs(self.parts) do
			v:Despawn() 
		end
		self.parts = nil
	end
end
gizmometa.__index = gizmometa

function CreateGizmo(parent)
	local gizmo = {}
	
	local Vx = Vector(1,0,0)
	local Vy = Vector(0,1,0)
	local Vz = Vector(0,0,1)
	
	local mX = CreatePart(parent, "engine/gizmo/arrow.smd",  Vx, matrix.AxisRotation(Vz, 90))
	local mY = CreatePart(parent, "engine/gizmo/arrow.smd",  Vy, matrix.Identity())
	local mZ = CreatePart(parent, "engine/gizmo/arrow.smd",  Vz, matrix.AxisRotation(Vx, 90))

	local mXY = CreatePart(parent, "engine/gizmo/square.smd",  Vector(1, 1, 0), matrix.AxisRotation(Vy, 90))
	local mYZ = CreatePart(parent, "engine/gizmo/square.smd",  Vector(0, 1, 1), matrix.AxisRotation(Vy, 180))
	local mZX = CreatePart(parent, "engine/gizmo/square.smd",  Vector(1, 0, 1), matrix.AxisRotation(Vz, 90)* matrix.AxisRotation(Vy, 90) )

	mX.constraint = Vx
	mY.constraint = Vy
	mZ.constraint = Vz

	mXY.constraint = Vx 
	mYZ.constraint = Vy 
	mZX.constraint = Vz 
	mXY.constraint2 = Vy 
	mYZ.constraint2 = Vz 
	mZX.constraint2 = Vx 
	
	----[[
	local rP = CreatePart(parent, "engine/gizmo/circle.smd",  Vx, matrix.AxisRotation(Vz, 90),"rotation")
	local rY = CreatePart(parent, "engine/gizmo/circle.smd",  Vy, matrix.Identity(),"rotation")
	local rR = CreatePart(parent, "engine/gizmo/circle.smd",  Vz, matrix.AxisRotation(Vx, 90),"rotation")
	 
	rP.axis = Vx 
	rY.axis = Vy  
	rR.axis = Vz 
	
	rP.ax = 0
	rY.ax = 1
	rR.ax = 2
	--]]
	 
	 
	gizmo.mX = mX
	gizmo.mY = mY
	gizmo.mZ = mZ 
	
	gizmo.mXY = mXY
	gizmo.mYZ = mYZ
	gizmo.mZX = mZX
	
	gizmo.rP = rP
	gizmo.rY = rY
	gizmo.rR = rR
	
	
	
	local sX = CreatePart(parent, "engine/gizmo/arrow.smd",  Vx, matrix.AxisRotation(Vz, 90)) 
	local sY = CreatePart(parent, "engine/gizmo/arrow.smd",  Vy, matrix.Identity())
	local sZ = CreatePart(parent, "engine/gizmo/arrow.smd",  Vz, matrix.AxisRotation(Vx, 90))
	
	local sXY = CreatePart(parent, "engine/gizmo/corner.smd", Vector(1, 1, 0), matrix.AxisRotation(Vy, 90))
	local sYZ = CreatePart(parent, "engine/gizmo/corner.smd", Vector(0, 1, 1), matrix.AxisRotation(Vy, 180))
	local sZX = CreatePart(parent, "engine/gizmo/corner.smd", Vector(1, 0, 1), matrix.AxisRotation(Vz, 90)* matrix.AxisRotation(Vy, 90) )

	local sXYZ = CreatePart(parent, "engine/gizmo/scalesphere.smd",   Vector(1, 1, 1), matrix.Identity())
	 
	sX.sconstraint = Vx
	sY.sconstraint = Vy
	sZ.sconstraint = Vz

	sXY.sconstraint = Vx 
	sYZ.sconstraint = Vy 
	sZX.sconstraint = Vz 
	sXY.sconstraint2 = Vy 
	sYZ.sconstraint2 = Vz 
	sZX.sconstraint2 = Vx  
	
	gizmo.sX = sX
	gizmo.sY = sY
	gizmo.sZ = sZ 
	
	gizmo.sXY = sXY
	gizmo.sYZ = sYZ
	gizmo.sZX = sZX
	
	gizmo.sXYZ = sXYZ
	
	gizmo.mode = "move"
	gizmo.parts = {mX,mY,mZ,mXY,mYZ,mZX,  rP,rY,rR,  sX,sY,sZ,sXY,sYZ,sZX,sXYZ}
	for k,v in pairs(gizmo.parts) do
		v.root = gizmo
	end
	for k,v in pairs({mX,mY,mZ,mXY,mYZ,mZX})do
		v.type = "move"
	end
	for k,v in pairs({rP,rY,rR})do
		v.type = "rotate"
	end
	for k,v in pairs({sX,sY,sZ,sXY,sYZ,sZX,sXYZ})do
		v.type = "scale"
	end
	
	--rP.disabled = true
	--rY.disabled = true 
	--rR.disabled = true
	
	setmetatable(gizmo,gizmometa)
	
	gizmo:ChangeMode("move")
	
	return gizmo
end



