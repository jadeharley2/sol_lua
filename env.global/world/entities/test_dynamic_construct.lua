 
function SpawnDC(parent,pos)
	local e = ents.Create("test_dynamic_construct")   
	e:SetSizepower(1)
	e:SetParent(parent)
	e:SetPos(pos)    
	e:Spawn()
	return e
end

function ENT:Init()
	self:SetSpaceEnabled(false)  
  
	local phys = self:AddComponent(CTYPE_PHYSOBJ)  
	local model = self:AddComponent(CTYPE_MODEL)   
	self.model = model 
	self.phys = phys

	self:AddFlag(FLAG_PHYSSIMULATED)
end
function ENT:Spawn()
	local mdl = "@testdynconstruct"
	
	local mb = MeshBuilder()
	local dt1 = Point(0,0)
	local dt2 = Point(1,1)
	
	local AddCube = function(pos,size)
		local ppp = pos+Vector(1,1,1)*size
		local ppm = pos+Vector(1,1,-1)*size
		local mpp = pos+Vector(-1,1,1)*size
		local mpm = pos+Vector(-1,1,-1)*size
		local pmp = pos+Vector(1,-1,1)*size
		local pmm = pos+Vector(1,-1,-1)*size
		local mmp = pos+Vector(-1,-1,1)*size
		local mmm = pos+Vector(-1,-1,-1)*size
		mb:AddQuad(mpm,mpp,ppp,ppm,dt1,dt2)--top
		mb:AddQuad(mmm,pmm,pmp,mmp,dt1,dt2)--bottom
		
		mb:AddQuad(mpm,ppm,pmm,mmm,dt1,dt2)--
		mb:AddQuad(ppm,ppp,pmp,pmm,dt1,dt2)--
		
		mb:AddQuad(mpp,mmp,pmp,ppp,dt1,dt2)--
		mb:AddQuad(mpm,mmm,mmp,mpp,dt1,dt2)--
	end
	--local AddNode = function(pos,size)
	
	local AddPipe = function(pos1,pos2,size)
		local center = (pos2+pos1)/2
		local dir = (pos2-pos1)/2
		--local dist = dir:Length() 
		--local rezs = dir / dist
		rezs = Vector(math.max(dir.x,size),math.max(dir.y,size),math.max(dir.z,size))
		
		AddCube(center,rezs)
	end
	
	local AddFloor = function(pos,w,h) 
		for x=1,w+1 do
			for y=1,h+1 do  
				local p = pos+Vector((x-1)*2,0,(y-1)*2)
				AddCube(p,0.1)
				
				if x<=w then
					AddPipe(p,p+Vector(2,0,0),0.03)
				end
				if y<=h then
					AddPipe(p,p+Vector(0,0,2),0.03)
				end
				if x<=w and y<=h then 
					AddCube(p+Vector(1,0,1),Vector(0.95,0.04,0.95))
				end 
			end
		end
	end
	local AddWall = function(pos,pos2,segments) 
		local ldir = (pos2-pos1)/segments
		
		for x=1,segments+1 do
			AddPipe(p,p+Vector(0,2,0),0.03)
			if x<=segments then 
				AddCube(p+ldir/2+Vector(0,1,0),Vector(0.95,0.04,0.95))
			end
		end
		
	end
	local AddRoom = function(pos,w,h) 
		AddFloor(pos,w,h)
		AddFloor(pos+Vector(0,2,0),w,h)
	end
	AddCube(Vector(0,0,0),0.1)
	----AddCube(Vector(0,2,0),0.1)
	----AddCube(Vector(2,0,0),0.1)
	----AddCube(Vector(2,2,0),0.1)
	----
	----AddCube(Vector(0,0,2),0.1)
	----AddCube(Vector(0,2,2),0.1)
	----AddCube(Vector(2,0,2),0.1)
	----AddCube(Vector(2,2,2),0.1) 
	----
	----AddPipe(Vector(0,0,0),Vector(0,2,0),0.03)
	----AddPipe(Vector(0,2,0),Vector(2,0,0),0.04)
	----AddPipe(Vector(2,0,0),Vector(2,2,0),0.05)
	----AddPipe(Vector(2,2,0),Vector(0,0,0),0.06)
	----
	----AddPipe(Vector(0,0,2),Vector(0,2,2),0.05)
	----AddPipe(Vector(0,2,2),Vector(2,0,2),0.05)
	----AddPipe(Vector(2,0,2),Vector(2,2,2),0.05)
	----AddPipe(Vector(2,2,2),Vector(0,0,2),0.05)
	--AddCube(Vector(0,1,0),Vector(0.05,0.9,0.05))
	--AddCube(Vector(2,1,0),Vector(0.05,0.9,0.05)) 
	--AddCube(Vector(1,0,0),Vector(0.9,0.05,0.05))
	--AddCube(Vector(1,2,0),Vector(0.9,0.05,0.05))
	--
	--AddCube(Vector(1,1,0),Vector(0.95,0.95,0.04))
 
	--for k=1,3 do 
	--	AddCube(Vector(0,2+k*2,0),0.1)
	--	AddCube(Vector(2,2+k*2,0),0.1)
	--	AddCube(Vector(0,1+k*2,0),Vector(0.05,0.9,0.05))
	--	AddCube(Vector(2,1+k*2,0),Vector(0.05,0.9,0.05))  
	--	AddCube(Vector(1,2+k*2,0),Vector(0.9,0.05,0.05))
	--	AddCube(Vector(1,1+k*2,0),Vector(0.95,0.95,0.04))
	--end
	
	
	--AddCube(Vector(0,0,2),0.1)
	--AddCube(Vector(0,2,2),0.1)
	--AddCube(Vector(2,0,2),0.1)
	--AddCube(Vector(2,2,2),0.1) 
	
	AddRoom(Vector(0,0,0),3,4)
	
	mb:ToModel(mdl)
	
	scale = scale or 1
	local model = self.model
	local phys =  self.phys
	local world = matrix.Scaling(scale) 
	
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(mdl)   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world)
	 
	model:SetMaterial("textures/debug/white.json")
	--self.coll:SetShapeFromModel(matrix.Scaling(scale/0.75 ) ) 
	
	local amul = 0.8
	phys:SetShapeFromModel(world)-- * matrix.Scaling(1/amul) ) 
	phys:SetMass(10) 
	
	--model:SetMatrix( world* matrix.Translation(-phys:GetMassCenter() ))
	
	self.modelcom = true
end
 