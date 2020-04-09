
hook.Add("source.ent_create","basic_ents",function(class, data, parent)
	local enttools = parent
	local e = nil
	local v = data 
	if class == "info_player_start" then
		local pos = enttools:GetEntOrigin(v.origin)
		e = ents.Create("spawnpoint")
		e:SetPos(pos)-- SpawnSO("primitives/sphere.stmd",self,pos,0.75) 
		e:SetParent(parent)
		e:Spawn()
		e:SetPlayerSpawn()
		return e
	elseif class == "light" then
		local pos = enttools:GetEntOrigin(v.origin)
		local clrb = enttools:GetNumberTable(v._light)
		e = parent:CreateStaticLight(pos,Vector(clrb[1]/255,clrb[2]/255,clrb[3]/255), clrb[4]/100) 
		--SpawnSO("primitives/sphere.stmd",self,pos,0.75)
		return e
	elseif class == "light_spot" then
		local pos = enttools:GetEntOrigin(v.origin)
		local clrb = enttools:GetNumberTable(v._light)
		e = parent:CreateStaticLight(pos,Vector(clrb[1]/255,clrb[2]/255,clrb[3]/255), clrb[4]/100) 
		--SpawnSO("primitives/sphere.stmd",self,pos,0.75)
		return e
	elseif class == "info_node" and false then 
		local pos = enttools:GetEntOrigin(v.origin)
		local e = ents.Create()
		e:SetPos(pos)-- SpawnSO("primitives/sphere.stmd",self,pos,0.75)
		e:SetSizepower(2)
		e:SetParent(parent)
		e:SetSpaceEnabled(false)
		e:Spawn()
		--debug.ShapeBoxCreate(30300+tonumber(v.nodeid),self,
		--	matrix.Translation(Vector(-0.5,-0.5,-0.5)) 
		--	*matrix.Scaling(0.2/self:GetSizepower())
		--	*matrix.Translation(pos))
		return e
	elseif class == "ambient_generic" then
		
		--PrintTable(v) 
		local pos = enttools:GetEntOrigin(v.origin)
		e = ents.Create("ambient_sound")
		e:SetPos(pos)-- SpawnSO("primitives/sphere.stmd",self,pos,0.75) 
		e:SetParent(parent)
		if band(v.spawnflags,16)==0 then -- starts enabled
			e.list = {'gmod/sound/'..v.message}
			MsgN("PLAY",v.message)
		else
			e.list = {}
		end 
		e:Spawn() 
		return e
	elseif class == "worldspawn" then
		if v.skyname then
			LoadSkybox(v.skyname)
		end
	elseif class == "prop_dynamic" or class == "prop_physics" then
		local pos = enttools:GetEntOrigin(v.origin)
		local angles = enttools:FromSourceAngle(enttools:GetNumberTable(v.angles))
		e = SpawnSO("gmod/"..v.model,parent,pos,1/5)  
		if false and class == "prop_dynamic" then
		--	e:SetAng(Vector(angles[3],angles[2]+0,-angles[1]))
			e:SetAng(angles*matrix.AxisRotation(Vector(0,1,0),90))
		else
		--	e:SetAng(Vector(angles[3],angles[2],-angles[1]))
			e:SetAng(angles)
		end
		return e
	elseif class == "func_brush" then
		local pos = enttools:GetEntOrigin(v.origin) 
		e = SpawnSO("bspmodel_"..string.sub(v.model,2)..'.stmd',parent,pos,0.01905)  
		return e
	elseif class == "func_illusionary" then
		local pos = enttools:GetEntOrigin(v.origin) 
		e = SpawnSO("bspmodel_"..string.sub(v.model,2)..'.stmd',parent,pos,0.01905,2)  
		return e
	elseif class == "func_door" then
		local pos = enttools:GetEntOrigin(v.origin) 
        e = Spawn_FUNC_DOOR("bspmodel_"..string.sub(v.model,2)..'.stmd',parent,pos,0.01905)  
        e:SetData(v)
		return e
	elseif class == "func_button" then
		local pos = enttools:GetEntOrigin(v.origin) 
		e = SpawnSO("bspmodel_"..string.sub(v.model,2)..'.stmd',parent,pos,0.01905,NO_COLLISION)  
		e = SpawnButton(parent,"bspmodel_"..string.sub(v.model,2)..'.stmd',pos,nil,function () 
			parent:EntFire(v.OnPressed)
		end,20202,0.01905) 
		return e 
	elseif class == "light_environment" then --"env_sun"
		local color = enttools:GetNumberTable(v._light)
		--local angles = enttools:GetNumberTable(v.angles)
		local angles = enttools:GetNumberTable(v.angles)
		--local pos = angles:Position() --
		local pos = Vector(1,0,0):TransformN(
                matrix.AxisRotation(Vector(0,0,1),-v.pitch)
                *matrix.AxisRotation(Vector(0,1,0),angles[2]+90)
            )--Vector(angles[1],angles[2],angles[3]))
		local sun = ents.GetByName("source.sun")--self:CreateStaticLight(pos*100,Vector(color[1],color[2],color[3])/255,190000000 * 100)  
		--sun.light:SetShadow(true)
		if sun then	
			MsgN("sun found")
			sun:SetPos(pos*10)
			PrintTable(color)
			sun:SetColor(Vector(color[1],color[2],color[3])/255*color[4]/1000) --
		end
		--sun:SetName("sun")
		--self.sun = sun
		--e = sun
		
		--if CLIENT then
		--	local eshadow = ents.Create("test_shadowmap2")  
		--	eshadow.light = sun
		--	eshadow:AddTag(77723)
		--	eshadow:SetParent(space) 
		--	eshadow:Spawn() 
		--	self.shadow = eshadow
		--end 
	end
end)