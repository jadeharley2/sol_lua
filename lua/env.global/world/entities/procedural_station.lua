
local sz = (1/750)*0.75
--local corrmodels = {"corridors/v2/Corridortubes.json","corridors/v2/Corridornotubes.json"}
--local corrmodels2 = {"corridors/v2/CorridornotubesX.json","corridors/v2/CorridorpanelX.json"}
local basedir = "corridors/beta/"
local basedir2 = "corridors/gamma/"
local sections = {
	{
		tonnel_sub = true,
		type = "tonnel_sub",
		{ 
			models = {basedir.."section_straight.json",basedir.."section_window.json",basedir.."section_window_b.json"}, 
			points = { 
				{p=Vector(-2.5,0,0), a = Vector(0,180,0), t = "tonnel_sub"},{p=Vector(2.5,0,0), a = Vector(0,0,0), t = "tonnel_sub"} 
			},
			bounds = {min = Vector(-2.5,0,-3),max = Vector(2.5,6,3)}
		}
	},
	{
		tonnel_sub = true,
		type = "tonnel_sub",
		{
			models = {basedir.."section_ttype.json"}, 
			points = { 
				{p=Vector(-5,0,0), a = Vector(0,180,0), t = "tonnel_sub"},{p=Vector(5,0,0), a = Vector(0,0,0), t = "tonnel_sub"},
				{p=Vector(0,0,3), a = Vector(0,-90,0), t = "tonnel_sub"} 
			},
			bounds = {min = Vector(-5,0,-3),max = Vector(5,6,3)}
		}
	},
	--{
	--	tonnel_sub = true,
	--	type = "end",
	--	{
	--		models = {basedir.."section_end.json"}, 
	--		points = { 
	--			{p=Vector(0,0,0), a = Vector(0,180,0)}
	--		},
	--		bounds = {min = Vector(0,0,-3),max = Vector(2,6,3)}
	--	}
	--},
	{
		tonnel_sub = true,
		type = "tonnel_sub",
		{
			models = {basedir.."section_xtype.json"}, 
			points = { 
				{p=Vector(-5,0,0), a = Vector(0,180,0), t = "tonnel_sub"},{p=Vector(5,0,0), a = Vector(0,0,0), t = "tonnel_sub"},
				{p=Vector(0,0,3), a = Vector(0,-90,0), t = "tonnel_sub"} ,{p=Vector(0,0,-3), a = Vector(0,90,0), t = "tonnel_sub"} 
			},
			bounds = {min = Vector(-5,0,-3),max = Vector(5,6,3)}
		}
	},
	{
		tonnel_sub = true,
		tonnel_main = true,
		type = "tonnel_sub", 
		{
			models = {basedir2.."MainToSecondCorridorAdapter.json"}, 
			points = { 
				{p=Vector(0.592,0,0), a = Vector(0,0,0), t = "tonnel_sub"},{p=Vector(-0.408,0,0), a = Vector(0,180,0), t = "tonnel_main"}, 
			},
			bounds = {min = Vector(-0.408,0,-3.5),max = Vector(0.592,6,3.5)}
		}
	},
	{
		tonnel_main = true,
		type = "tonnel_main",
		{
			models = {basedir2.."MainCorridor.json"}, 
			points = { 
				{p=Vector(-4,0,0), a = Vector(0,180,0), t = "tonnel_main"},{p=Vector(4,0,0), a = Vector(0,0,0), t = "tonnel_main"}, 
			},
			bounds = {min = Vector(-4,0,-3.5),max = Vector(4,6,3.5)}
		}
	},
	{
		tonnel_main = true,
		type = "tonnel_main",
		{
			models = {basedir2.."MainCorridorCurve.json"}, 
			points = { 
				{p=Vector(4,0,0), a = Vector(0,0,0), t = "tonnel_main"},{p=Vector(0,0,-4), a = Vector(0,90,0), t = "tonnel_main"}, 
			},
			bounds = {min = Vector(-3.5,0,-4),max = Vector(4,6,3.5)}
		}
	},
	{
		tonnel_main = true,
		type = "tonnel_main",
		{
			models = {basedir2.."MainCorridorX.json"}, 
			points = { 
				{p=Vector(-4,0,0), a = Vector(0,180,0), t = "tonnel_main"},{p=Vector(4,0,0), a = Vector(0,0,0), t = "tonnel_main"}, 
				{p=Vector(0,0,-4), a = Vector(0,90,0), t = "tonnel_main"},{p=Vector(0,0,4), a = Vector(0,-90,0), t = "tonnel_main"}, 
			},
			bounds = {min = Vector(-4,0,-4),max = Vector(4,6,4)}
		}
	}
	
} 
CPD_allbounds = {}
function CPD_CanPlaceSection(bbox)
	for k,v in pairs(CPD_allbounds) do
		if(v:Contains(bbox)~=CT_DISJOINT)then
			return false
		end
	end
	return true
end
function CPD_AddBbox(bbox)
	CPD_allbounds[#CPD_allbounds+1] = bbox
end
function CPD_ClearBoxes()
	CPD_allbounds = {}
end
function ESpawnCorrv2(self,seed,position,angles,len,section_type)
	len = len or 10
	if(len<0) then return nil end
	local rnd = Random(seed)
	local filtered = table.Select(sections,function(k,v,a) return v[a]   end,section_type)
	MsgN("filtered: ",#sections," -> ",#filtered)
	local ctype = table.Random(filtered,rnd) 
	if ctype then
		local csection = table.Random(ctype,rnd)
		local cmodel =  table.Random(csection.models,rnd)
		local filteredatt = table.Select(csection.points,function(k,v,a) return v.t==a end,section_type)
		MsgN("filteredattachments: ",#csection.points," -> ",#filteredatt)
		local cattachpointa =  table.Random(filteredatt,rnd)-- csection.points[1]
		if cattachpointa then
			
			MsgN("new section ", cmodel)
			debug.ShapeBoxCreate(200+#CURRENT_CNODES+1 ,self,matrix.Scaling(sz*0.1) * matrix.Translation((position )*sz))
			
			angles = angles - cattachpointa.a + Vector(0,180,0)
			position = position - cattachpointa.p:Rotate(angles)
			
			local col_scale = 0.98
			local bbox = BoundingBox(csection.bounds.min*col_scale,csection.bounds.max*col_scale,matrix.Rotation(angles)*matrix.Translation(position))
			
			local boxsize = ((csection.bounds.max)-(csection.bounds.min)) 
			debug.ShapeBoxCreate(100+#CURRENT_CNODES+1 ,self, 
				matrix.Scaling(boxsize) 
				* matrix.Translation(csection.bounds.min ) 
				* matrix.Scaling(col_scale)
				* matrix.Rotation(angles) 
				* matrix.Translation(position )
				* matrix.Scaling(sz))
			
			if(CPD_CanPlaceSection(bbox)) then
				CPD_AddBbox(bbox)
				local ent = SpawnSO(cmodel,self,Vector(0,0,0),0.75)
				CURRENT_CNODES[#CURRENT_CNODES+1] = ent
				ent:SetPos(position * sz)
				ent:SetAng(angles)
				
				local otherattachpoints = table.Select(csection.points,function(k,v,a) MsgN(k," - ",v," - ", v~=a) return v~=a end,cattachpointa)
				 
				for k,AP in pairs(otherattachpoints) do 
					local position2 = position + AP.p:Rotate(angles)
					local angles2 = angles + AP.a
					ESpawnCorrv2(self,seed+4253*k,position2,angles2,len-1,AP.t)
				end
				--ent:SetWorld(world*matrix.Scaling(1/750))
				--if csection.points[2] then
				--	local AP = csection.points[2]--table.Random(csection.points,rnd)
				--	local position2 = position + AP.p:Rotate(angles)
				--	local angles2 = angles + AP.a
				--	ESpawnCorrv2(self,seed+4253,position2,angles2,len-1,AP.t)
				--end
				--if(csection.points[3]) then
				--	local AP = csection.points[3]
				--	local position3 = position + AP.p :Rotate(angles)
				--	local angles3 = angles + AP.a
				--	ESpawnCorrv2(self,seed+9999,position3,angles3,len-1,AP.t)
				--end
				--if(csection.points[4]) then
				--	local AP = csection.points[4]
				--	local position3 = position + AP.p :Rotate(angles)
				--	local angles3 = angles + AP.a
				--	ESpawnCorrv2(self,seed+3200,position3,angles3,len-1,AP.t)
				--end
			else
				MsgN("cant place section")
			end
		else
			MsgN("no attach point")
		end
	else
		MsgN("filter - no ctype")
	end
end
local rndcc = Random()
CURENT_CORNODE =0
CURRENT_CNODES = {}
function E_REGENERATE(seed)
	if not seed then
		seed = rndcc:NextInt()
	end
	for k=1,1000 do
		debug.ShapeDestroy(100+k)
	end
	for k,v in pairs(CURRENT_CNODES) do 
		v:Despawn()
	end
	CURRENT_CNODES ={}
	CPD_ClearBoxes()
	 
	ESpawnCorrv2(CURENT_CORNODE,seed or 2325, Vector(0,-80,0),Vector(0,0,0),100,"tonnel_sub")
	
end


function ESpawnCorr(self,seed,pos,dir,len)
	len = len or 10
	local rnd = Random(seed)
	
	local cpos = pos
	local cdir = dir 
	local cang = Vector(1,0,0)
	if cdir==1 then cang = Vector(0,0,1) end
	if cdir==2 then cang = Vector(-1,0,0) end
	if cdir==3 then cang = Vector(0,0,-1) end
	
	for k=1,len do 
		local ctype = rnd:NextInt(1,10)
		local cmodel = ""
		if ctype==1 then
			cmodel = corrmodels2[rnd:NextInt(1,3)]
			cpos = cpos + cang*8
			ESpawnCorr(self,seed+230*k,cpos+Vector(0,0,1)*8,2,len-k)
			ESpawnCorr(self,seed-230*k,cpos+Vector(0,0,-1)*8,3,len-k)
		else -- then
			cmodel = corrmodels[rnd:NextInt(1,3)]
			cpos = cpos + cang*8
		end
		local so = SpawnSO(cmodel,self,cpos*sz,0.75)
		--so.model:SetMaterial("textures/debug/red.json") 
		if cdir==1 then so:SetAng(Vector(0,90,0)) end
		if cdir==2 then so:SetAng(Vector(0,180,0)) end
		if cdir==3 then so:SetAng(Vector(0,270,0)) end 
	end
end

