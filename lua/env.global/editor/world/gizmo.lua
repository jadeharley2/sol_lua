
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
		 
		if input.KeyPressed(KEYS_SHIFTKEY) then
			for k,v in pairs(worldeditor.selected) do
				worldeditor:Copy(k)
			end
			--part = worldeditor.Copy(part)
			--worldeditor.Select(part)
		end 
		
		worldeditor.mode = "drag"
		self.first = true
		self.lastmp = nil
		self.GIZMO_DRAG = part
		self.GIZMO_DRAG_POS = part:GetPos()
		self.GIZMO_DRAG_POINTPOS = input.getMousePosition() 
		--self.startnodepos =-- worldeditor.curtrace.Position
		
		
		if self.mnode and self.mnode.GetScale then
			self.startscale = self.mnode:GetScale()
		else
			self.startscale = Vector(1,1,1)
		end
		
		
		hook.Add(EVENT_GLOBAL_PREDRAW,"GIZMO_DRAG",function() self:DragUpdate() end)
	end
end

function gizmometa:Shift(oldpos,newpos)
	local shift = newpos - oldpos
	--MsgN(shift)
	for k,v in pairs(worldeditor.selected) do
		k:SetPos(k:GetPos()+shift)
		hook.Call("EditorNodeMove",k,oldpos,newpos)
	end
	--if lsn then lsn:SetPos(newPos) end
end
function gizmometa:Rotate(axis,shift) 
	for k,v in pairs(worldeditor.selected) do
		k:TRotateAroundAxis(axis,shift)  
		hook.Call("EditorNodeRotate",k,axis,shift)
	end
	--if lsn then lsn:SetPos(newPos) end
end
function gizmometa:Scale(anewscale) 
	for k,v in pairs(worldeditor.selected) do
		k:SetScale(anewscale)  
		hook.Call("EditorNodeScale",k,anewscale)
	end 
end

function gizmometa:DragUpdate()
	local G = self.GIZMO_DRAG
	if G and self.parts then  
		local mousePos = input.getMousePosition() 
		local mouseDiff2 = mousePos - (self.lastmp or mousePos)
		self.lastmp = mousePos
		local mouseDiff = mousePos - self.GIZMO_DRAG_POINTPOS   
		local mouseDiffF = Point(mouseDiff.x*2,mouseDiff.y*-2)
		--local newPos = self.GIZMO_DRAG_POS + G.constraint * mouseDiff.x/10000--Vector( mouseDiff.x,mouseDiff.y)
		
		local startnodepos = self.GIZMO_DRAG_POS
		local startpos = startnodepos--self.startnodepos --
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
		  
		local snap = false-- input.KeyPressed(KEYS_MENU)
		
		local mpos = input.getInterfaceMousePos()+Vector(0,0,0.1)
		local dir = camera:Unproject(mpos):Normalized()
		--local dir = (worldeditor.curtrace.Position - campos):Normalized()
		if not  worldeditor.selected:First() then return nil end
		local lsn =self.parts[1]-- worldeditor.selected:Last() 
		local lsp = worldeditor.selected:First():GetParent()
		local first = self.first or false
		local spos = self._startpos or Vector(0,0,0)
		local dpos = self._startlen or 0
		if constr then
		
			local W =lsp:GetLocalSpace(lsn) 
			constr = constr:TransformN(W)
			if(constr2) then
				constr2 = constr2:TransformN(W)
				--worldeditor.curtrace
				local pp = Plane(startpos, startpos + constr, startpos + constr2);
				
				local hit, pos = pp:Intersect(campos, dir)
				if hit then  
					if first then
						self._startpos = pos
						spos =  pos
					end
					
					local newPos = startnodepos+ pos - spos
					if snap then
						newPos = Vector(math.round(newPos.x,3),math.round(newPos.y,3),math.round(newPos.z,3))
					end
					
					local oldPos = self.parts[1]:GetPos()
					for k,v in pairs(self.parts) do
						v:SetPos(newPos)
					end 
				
					self:Shift(oldPos, newPos) 
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
					if first then
						self._startlen = rps
						dpos = rps 
					end
					--local newPos =   rps---campos
			--MsgN(pos)
					local newPos = startnodepos + constr * (rps - dpos)-- *1000000 / (startscale*startscale)
					if snap then
						newPos = Vector(math.round(newPos.x,3),math.round(newPos.y,3),math.round(newPos.z,3))
					end

					local oldPos = self.parts[1]:GetPos()
					for k,v in pairs(self.parts) do
						v:SetPos(newPos)
					end 
					self:Shift(oldPos, newPos)
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
				self:Rotate(Waxis,mouseDiff2.x/100) 
			end
		else
			local pp = Plane(startpos, startpos + right*100, startpos + up*100)
			local hit, pos = pp:Intersect(campos, dir)
			if hit then
				local dist = (pos-startpos)*100
				local ddist = dist.x+dist.y+dist.z
				--MsgN("sada",ddist)
				local newScale = startscale
				if sconstraint then 
					newScale = startscale * (sconstraint*ddist+Vector(1,1,1))
				else
					newScale = startscale * (ddist+1)
				end
				self:Scale(newScale)
				--if lsn then lsn:SetScale(newScale) end 
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
		
		
		if first then
			self.first = false
		end
		 
		if not input.leftMouseButton() then
			self.GIZMO_DRAG = false
			UnlockMouse()
			worldeditor.mode = false
			self.first = true
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
			if IsValidEnt(v) then
				v:Rescale(n) 
			end
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
	--
	--if newmode == "rotate" then 
	--	for k,v in pairs(self.parts) do 
	--		v:Enable( v.type == "rotate")
	--	end
	--elseif newmode == "scale" then 
	--	for k,v in pairs(self.parts) do 
	--		v:Enable( v.type == "scale")
	--	end 
	--else--if newmode == "move" then 
	--	for k,v in pairs(self.parts) do 
	--		v:Enable( v.type == "move")
	--	end 
	--end
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
			if v and IsValidEnt(v) then
				v:Despawn() 
			end
		end
		self.parts = nil
	end
end
gizmometa.__index = gizmometa

function CreateGizmo(parent)
	local gizmo = {}
	local Vzero = Vector(0,0,0)
	local Vx = Vector(1,0,0)
	local Vy = Vector(0,1,0)
	local Vz = Vector(0,0,1)
	
	local mX = CreatePart(parent, "models/editor/handle/move_arrow.stmd",  Vx, matrix.Identity())
	local mY = CreatePart(parent, "models/editor/handle/move_arrow.stmd",  Vy, matrix.AxisRotation(Vz, 90))
	local mZ = CreatePart(parent, "models/editor/handle/move_arrow.stmd",  Vz, matrix.AxisRotation(Vy, 90))

	local mXY = CreatePart(parent, "models/editor/handle/dmove_prism.stmd",  Vx+Vy, matrix.Identity())
	local mYZ = CreatePart(parent, "models/editor/handle/dmove_prism.stmd",  Vy+Vz, matrix.AxisRotation(Vy, 90))
	local mZX = CreatePart(parent, "models/editor/handle/dmove_prism.stmd",  Vz+Vx, matrix.AxisRotation(Vx, 90)* matrix.AxisRotation(Vy, 90) )

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
	local rP = CreatePart(parent, "models/editor/handle/rotate_circle.stmd",  Vx, matrix.AxisRotation(Vy, 90),"rotation")
	local rY = CreatePart(parent, "models/editor/handle/rotate_circle.stmd",  Vy, matrix.AxisRotation(Vx, 90) ,"rotation")
	local rR = CreatePart(parent, "models/editor/handle/rotate_circle.stmd",  Vz, matrix.Identity() ,"rotation")
	 
	rP.axis = Vx 
	rY.axis = Vy  
	rR.axis = Vz 
	
	rP.ax = 0
	rY.ax = 1
	rR.ax = 2
	--]]
	 
	----[[
	gizmo.mX = mX
	gizmo.mY = mY
	gizmo.mZ = mZ 
	
	gizmo.mXY = mXY
	gizmo.mYZ = mYZ
	gizmo.mZX = mZX
	
	gizmo.rP = rP
	gizmo.rY = rY
	gizmo.rR = rR
	
	
	 
	local sX = CreatePart(parent, "models/editor/handle/scale_cube.stmd",  Vx, matrix.Identity())
	local sY = CreatePart(parent, "models/editor/handle/scale_cube.stmd",  Vy, matrix.AxisRotation(Vz, 90))
	local sZ = CreatePart(parent, "models/editor/handle/scale_cube.stmd",  Vz, matrix.AxisRotation(Vy, 90))
	
	--local sXY = CreatePart(parent, "engine/gizmo/corner.smd", Vector(1, 1, 0), matrix.AxisRotation(Vy, 90))
	--local sYZ = CreatePart(parent, "engine/gizmo/corner.smd", Vector(0, 1, 1), matrix.AxisRotation(Vy, 180))
	--local sZX = CreatePart(parent, "engine/gizmo/corner.smd", Vector(1, 0, 1), matrix.AxisRotation(Vz, 90)* matrix.AxisRotation(Vy, 90) )
    --
	--local sXYZ = CreatePart(parent, "engine/gizmo/scalesphere.smd",   Vector(1, 1, 1), matrix.Identity())
	 
	sX.sconstraint = Vx
	sY.sconstraint = Vy
	sZ.sconstraint = Vz

	--sXY.sconstraint = Vx 
	--sYZ.sconstraint = Vy 
	--sZX.sconstraint = Vz 
	--sXY.sconstraint2 = Vy 
	--sYZ.sconstraint2 = Vz 
	--sZX.sconstraint2 = Vx  
	
	gizmo.sX = sX
	gizmo.sY = sY
	gizmo.sZ = sZ 
	
	--gizmo.sXY = sXY
	--gizmo.sYZ = sYZ
	--gizmo.sZX = sZX
	--
	--gizmo.sXYZ = sXYZ
	
	--]]
	gizmo.mode = "move"
	local parts = {}--mX,mY,mZ,mXY,mYZ,mZX,  rP,rY,rR,  sX,sY,sZ,sXY,sYZ,sZX,sXYZ}
	 
	for k,v in pairs({mX,mY,mZ,mXY,mYZ,mZX})do
		if v then
			v.type = "move"
			v.root = gizmo
			parts[#parts+1] = v
		end
	end
	for k,v in pairs({rP,rY,rR})do
		if v then
			v.type = "rotate"
			v.root = gizmo
			parts[#parts+1] = v
		end 
	end
	for k,v in pairs({sX,sY,sZ,sXY,sYZ,sZX,sXYZ})do
		if v then
			v.type = "scale"
			v.root = gizmo
			parts[#parts+1] = v
		end   
	end
	gizmo.parts = parts 
	
	--rP.disabled = true
	--rY.disabled = true 
	--rR.disabled = true
	
	setmetatable(gizmo,gizmometa)
	
	gizmo:ChangeMode("move")
	
	return gizmo
end



